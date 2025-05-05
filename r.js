const getSuitableWorkersByJob = async (jobId) => {
    try {
      const job = await jobDB.getJobById(jobId);
      if (!job) throw new Error('Job not found');
      const employees = await findEligibleUsers(job);
      console.log("✅ Eligible workers found in jobservice:", employees?.length || 0);
      const branchType = job.branch;
      const usersWithRating = [];
      for (const user of employees) {
        const viewUser = new viewUserDTO(user);
        let branchRating = 0;
        const found = Array.isArray(viewUser.averageRating?.byBranch)
          ? viewUser.averageRating.byBranch.find(
              r => r.branchType === branchType
            )
          : null;
        branchRating = found?.score || 0;
  
        usersWithRating.push({
          user: new UserDTO(user),
          rating: branchRating,
        });
      }
      usersWithRating.sort((a, b) => b.rating - a.rating);
      return usersWithRating;
    } catch (error) {
      console.error("Error in getSuitableWorkersByJob:", error);
      throw error;
    }
  };
  
  
  const findEligibleUsers = async (job) => {
    const combinedText = [job.title, ...(job.description || [])].join(" ").toLowerCase();
    const keywords = combinedText.split(/\s+/).filter(w => w.length > 2); // богино үгс хасна
    const regexes = keywords.map(word => new RegExp(word, 'i'));
    const query = {
      state: 'Active',
      isVerified: true,
      'profile.waitingSalaryPerHour': { $lte: job.salary.amount },
      ...(job.possibleForDisabled === false && { 'profile.isDisabledPerson': false }),
      ...(job.branch && { 'profile.mainBranch': job.branch }),
      $or: [
        { 'profile.skills': { $in: job.requirements || [] } },
        {
          'profile.skills': {
            $elemMatch: { $in: regexes }
          }
        }
      ]
    };
    const result = await userDB.findUsersByQuery(query);
    return Array.isArray(result) ? result : [];
  };
  
  const notifyEligibleUsers = async (job, users) => {
    await notificationService.sendBulkNotifications(users, job);
  };
  
  const createRating = async (data) => {
    const { fromUserId, toUserId, jobId, branchType, manualRating, systemRating } = data;
    const existing = await ratingDB.checkExisting(fromUserId, toUserId, jobId);
    if (existing) throw new Error('Rating already exists');
    const rating = await ratingDB.saveRating(data);
    await userDB.updateAverageRating(toUserId);
    return rating;
  };
  
  const updateAverageRating = async (userId) => {
    const ratings = await Rating.find({ toUserId: userId });
    if (ratings.length === 0) return;
    const branchScores = {};
    const branchCounts = {};
    ratings.forEach(r => {
      const score = r.manualRating.score;
      const branch = r.branchType;
      branchScores[branch] = (branchScores[branch] || 0) + score;
      branchCounts[branch] = (branchCounts[branch] || 0) + 1;
    });
    const byBranch = Object.keys(branchScores).map(branch => ({
      branchType: branch,
      score: +(branchScores[branch] / branchCounts[branch]).toFixed(1)
    }));
    const overall = ratings.reduce((sum, r) => sum + r.manualRating.score, 0) / ratings.length;
    await User.findByIdAndUpdate(userId, {
      $set: {
        averageRating: {
          overall: +overall.toFixed(1),
          byBranch
        }
      }
    });
  };
  
  
  const rateEmployee = async (userId, employeeId, ratingInput, jobId) => {
    const job = await jobDB.getJobById(jobId);
    const jobProgress = await JobProgress.findOne({ jobId, workerId: employeeId });
    let punctualityScore = 0;
    if (jobProgress?.startedAt && job.workStartTime) {
    const scheduledTime = new Date(job.startDate);
    const [hours, minutes] = job.workStartTime.split(':');
    scheduledTime.setHours(Number(hours), Number(minutes));
    const actualStart = new Date(jobProgress.startedAt);
    const diffMinutes = Math.floor((actualStart - scheduledTime) / (60 * 1000));
    if (diffMinutes <= 0) punctualityScore = 5; 
    else if (diffMinutes <= 15) punctualityScore = 4;
    else if (diffMinutes <= 30) punctualityScore = 3;
    else if (diffMinutes <= 45) punctualityScore = 2;
    else if (diffMinutes <= 60) punctualityScore = 1;
    else punctualityScore = 0;
  }
    let completionScore = jobProgress?.status === 'completed' || jobProgress?.status === 'verified' ? 5 : 0;
    const manualConverted = (ratingInput.score / 5) * 10;
    const total20 = manualConverted + punctualityScore + completionScore;
    const finalScore = +(total20 / 4).toFixed(1);    
  
    const ratingData = {
      fromUserId: userId,
      toUserId: employeeId,
      jobId,
      branchType: job.branch || '',
      manualRating: {
        score: ratingInput.score,
        comment: ratingInput.comment || ''
      },
      systemRating: [
        { metric: 'punctuality', score: punctualityScore },
        { metric: 'completion', score: completionScore }
      ],
      totalScore: finalScore
    };
    await ratingDB.createRating(ratingData);
    await userDB.updateEmployeeAverageRating(employeeId);
    const allRated = await checkIfAllEmployersRated(jobId);
    if (allRated) {
      await jobDB.updateJobStatus(jobId, 'completed');
    }
    return { success: true, message: 'Employee rated', data: ratingData };
  };
  const rateEmployer = async (userId, employerId, ratingInput, jobId) => {
    const job = await jobDB.getJobById(jobId);
    const ratingData = {
      jobId: jobId,
      fromUserId : userId,
      toUserId: employerId,
      branchType: job.branch || "",
      manualRating: {
        score: ratingInput.score,
        comment: ratingInput.comment || ''
      }
    }
    await ratingDB.createRating(ratingData);
    await userDB.updateEmployerAverageRating(employerId);
    const allRated = await checkIfAllEmployersRated(jobId);
    if (allRated) {
      await jobDB.updateJobStatus(jobId, 'completed');
      await autoRateUnratedEmployees(jobId);
    }
    return { success: true, message: 'Employer rated' };
  };
  
  const checkIfAllEmployersRated = async (jobId) => {
    const payments = await Payment.find({ jobId, status: 'paid' });
    if (!payments.length) return false;
    const employerIdRaw = payments[0]?.employerId;
    if (!employerIdRaw) {
      console.error('❌ checkIfAllEmployersRated: employerId is undefined in payments[0]');
      console.error('📦 payment object:', payments[0]);
      return false;
    }
    const employerId = employerIdRaw.toString();
    const workerIds = payments
    .map(p => p.workerId)
    .filter(Boolean)  .map(id => id.toString());
    for (const workerId of workerIds) {
      const rating = await Rating.findOne({
        fromUserId: workerId,
        toUserId: employerId,
        jobId
      });
      if (!rating) return false;
      const reverseRating = await Rating.findOne({
        fromUserId: employerId,
        toUserId: workerId,
        jobId
      });
      if (!reverseRating) return false;
    }  
    return true; 
  };
  
  const autoRateUnratedEmployees = async (jobId) => {
    const job = await jobDB.getJobById(jobId);
    const jobProgresses = await JobProgress.find({ jobId });
    const ratedUserIds = (await Rating.find({ jobId }))
      .map(r => r.toUserId.toString());
    const unratedWorkers = job.employees.filter(id => !ratedUserIds.includes(id.toString()));
    for (const workerId of unratedWorkers) {
      const jp = jobProgresses.find(jp => jp.workerId.toString() === workerId.toString());
      const punctuality = 0;
      const completion = jp?.status === 'completed' || jp?.status === 'verified' ? 5 : 0;
      const totalScore = +(completion / 4).toFixed(1); 
  
      const ratingData = {
        fromUserId: job.employerId,
        toUserId: workerId,
        jobId,
        branchType: job.branch || '',
        manualRating: { score: 0, comment: '' },
        systemRating: [
          { metric: 'punctuality', score: punctuality },
          { metric: 'completion', score: completion }
        ],
        totalScore
      };
      await ratingDB.createRating(ratingData);
      await userDB.updateEmployeeAverageRating(workerId);
    }
  };
  
  
  
  const generateAndReturnHTML = async (req, res) => {
    try {
      const employerId = req.user._id || req.user.id;
      const { jobId, templateName } = req.body;
      const result = await contractService.generateContractHTML(employerId, { jobId, templateName });
      if (result.success) {
        const { html, summary } = result.data; 
        res.status(200).json({ html, summary });
      } else {
        res.status(400).json({ message: result.message });
      }
    } catch (error) {
      console.error('❌ Error in generateAndReturnHTML:', error.message);
      res.status(500).json({ message: error.message });
    }
  };
  
  const generateContractHTML = async (employerId, { jobId, templateName }) => {
    try {
      const job = await jobDB.getJobById(jobId);
      if (!job) return { success: false, message: 'Job not found' };
  
      if (String(job.employerId) !== String(employerId)) {
        console.error('🚨 Employer mismatch:', job.employerId, employerId);
        return { success: false, message: 'Unauthorized' };
      }
  
      const employer = await userDB.getUserById(employerId);
      const templatePath = path.join(__dirname, '../templates', `${templateName}.json`);
      const templateContent = JSON.parse(fs.readFileSync(templatePath, 'utf-8'));
  
      const context = {
        today: {
          year: new Date().getFullYear(),
          month: new Date().getMonth() + 1,
          day: new Date().getDate(),
        },
        job: {
          ...job.toObject(),
          location: job.location || '',
          title: job.title || '',
          description: job.description || '',
          requirements: (job.requirements || []).map(req => req),
          startDate: {
            year: job.startDate.getFullYear(),
            month: job.startDate.getMonth() + 1,
            day: job.startDate.getDate(),
          },
          endDate: {
            year: job.endDate.getFullYear(),
            month: job.endDate.getMonth() + 1,
            day: job.endDate.getDate(),
          },
          workStartTime: job.workStartTime || '',
          workEndTime: job.workEndTime || '',
          breakStartTime: job.breakStartTime || '',
          breakEndTime: job.breakEndTime || '',
          durationDays: Math.ceil((job.endDate - job.startDate) / (1000 * 60 * 60 * 24)),
          salary: {
            amount: job.salary.amount || 0,
            type: job.salary.type || '',
          },
          benefits: {
            transportIncluded: job.benefits?.transportIncluded || false,
            mealIncluded: job.benefits?.mealIncluded || false,
            bonusIncluded: job.benefits?.bonusIncluded || false,
          }
        },
        employer: {
          firstName: employer.firstName,
          lastName: employer.lastName,
          companyName: employer.companyName || '',
          identityNumber: employer.profile?.identityNumber || ''
        },
        worker: {
          firstName: '',
          lastName: '',
          companyName: '',
          identityNumber: ''
        },
        isEmployerCompany: !!employer.companyName, 
        isWorkerCompany: false
      };
      
  
      const parsed = parser.parseTemplate(templateContent, { job, employer });
      const html = Mustache.render(parsed.contentText, context);
  
      return { success: true, data: { html, summary: parsed.summary } };
    } catch (error) {
      console.error('❌ Error generating contract HTML:', error.message);
      return { success: false, message: error.message };
    }
  };
  
  