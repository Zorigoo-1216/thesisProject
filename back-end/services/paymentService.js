
// services/paymentService.js

const paymentDB = require('../dataAccess/paymentDB');
const jobDB = require('../dataAccess/jobDB');
const jobProgressService = require('../services/jobProgressService')
const jobProgressDB = require('../dataAccess/jobProgressDB');
const Payment = require('../models/Payment');
const { calculateSalary } = require('../utils/salaryCalculator');

const getPaymentsByJob = async (jobId, employerId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };
    if (job.employerId.toString() !== employerId.toString()) return { success: false, message: "Not authorized" };

    const payments = await Payment.find({ jobId }).populate('workerId');
    return { success: true, data: payments };
  } catch (error) {
    console.error("Error getting payments by job:", error.message);
    return { success: false, message: error.message };
  }
};

// 2. Хэрэглэгчийн бүх цалингийн мэдээлэл (ажилтан эсвэл ажил олгогч)
const getPaymentsByUser = async (userId, requesterId) => {
  try {
    if (userId !== requesterId) return { success: false, message: "Not authorized" };

    const payments = await Payment.find({ workerId: userId });
    return { success: true, data: payments };
  } catch (error) {
    console.error("Error getting payments by user:", error.message);
    return { success: false, message: error.message };
  }
};

// 3. Нэг төлбөрийн дэлгэрэнгүй мэдээлэл
const getPaymentDetail = async (paymentId, requesterId) => {
  try {
    const payment = await Payment.findById(paymentId);
    if (!payment) return { success: false, message: "Payment not found" };

    if (payment.workerId.toString() !== requesterId && payment.employeeId.toString() !== requesterId) {
      return { success: false, message: "Not authorized" };
    }

    return { success: true, data: payment };
  } catch (error) {
    console.error("Error getting payment detail:", error.message);
    return { success: false, message: error.message };
  }
};
// 4. Нэг ажилтны цалинг "paid" болгоно
const transferOneSalary = async (paymentId, employerId) => {
  try {
    const payment = await Payment.findById(paymentId);
    if (!payment) return { success: false, message: "Payment not found" };

    if (payment.employeeId.toString() !== employerId) return { success: false, message: "Not authorized" };

    payment.status = 'paid';
    payment.paidAt = new Date();
    await payment.save();

    return { success: true, data: payment };
  } catch (error) {
    console.error("Error transferring one salary:", error.message);
    return { success: false, message: error.message };
  }
};

// 5. Олон ажилтанд нэг дор цалин шилжүүлнэ
const transferMultipleSalaries = async (paymentIds, employerId) => {
  try {
    const updatedPayments = [];

    for (const id of paymentIds) {
      const payment = await Payment.findById(id);
      if (!payment) {
        console.warn(`⚠️ Payment not found: ${id}`);
        continue;
      }

      if (payment.employerId.toString() !== employerId.toString()) {
        console.warn(`⚠️ Unauthorized attempt for payment ${id}`);
        continue;
      }

      payment.status = 'paiding'; // ✅ Make sure this is in the enum
      payment.paidAt = new Date();
      await payment.save();
      updatedPayments.push(payment);
    }

    return { success: true, data: updatedPayments };
  } catch (error) {
    console.error("❌ Error transferring salaries:", error.message);
    return { success: false, message: error.message };
  }
};

const getPaymentsByJobAndUser = async (jobId, userId) => {
  try {
    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };
    if (job.employees.indexOf(userId) === -1) return { success: false, message: "Not authorized" };
    const payments = await paymentDB.getByJobAndUser(jobId, userId);
    return { success: true, data: payments };
}
  catch (error) {
    console.error("Error getting payments by job and user:", error.message);
    return { success: false, message: error.message };
  }
}

// 6. Статусыг гараар paid болгох (optional admin/testing)
const markPaymentAsPaid = async (paymentId, userId) => {
  try {
    
    const payment = await Payment.findById(paymentId);
    if (!payment) return { success: false, message: "Payment not found" };
    if (payment.workerId.toString() !== userId.toString()) return { success: false, message: "Not authorized" };
    const updated = await Payment.updateOne({ _id: paymentId }, { status: 'paid'});
    if (!updated) return { success: false, message: "Payment not found" };
    return { success: true, data: updated };
  } catch (error) {
    console.error("Error marking payment as paid:", error.message);
    return { success: false, message: error.message };
  }
};

// 7. Ажил бүрэн дууссан үед олон ажилтанд төлбөр үүсгэх

const createPayments = async (jobprogressIds, jobId) => {
  try {
    console.log("🟢 Creating payments for jobProgressIds:", jobprogressIds);
    
    const job = await jobDB.getJobById(jobId);
    if (!job) return { success: false, message: "Job not found" };

    const payments = [];

    for (const id of jobprogressIds) {
      try {
        const existing = await paymentDB.getByJobProgressId(id);
        if (existing) {
          console.log(`ℹ️ Payment already exists for jobProgressId: ${id}`);
          payments.push(existing);
          continue;
        }

        const progress = await jobProgressDB.getJobProgressById(id);
        if (!progress) {
          console.warn(`⚠️ JobProgress not found: ${id}`);
          continue;
        }

        const salary = await calculateSalary(job, progress);
        if (!salary || typeof salary.total !== 'number') {
          console.warn(`⚠️ Invalid salary for jobProgressId ${id}`);
          continue;
        }

        const data = {
          contractId: progress.contractId,
          jobId,
          jobProgressId: id,
          workerId: progress.workerId,
          employerId: progress.employerId,
          status: 'unpaid',
          totalAmount: salary.total,
          breakdown: {
            baseSalary: salary.breakdown.baseSalary,
            transportAllowance: salary.breakdown.transportAllowance,
            mealAllowance: salary.breakdown.mealAllowance,
            socialInsurance: salary.breakdown.socialInsurance,
            taxDeduction: salary.breakdown.taxDeduction,
          },
          paidAt: null,
          jobstartedAt: progress.startedAt,
          jobendedAt: progress.endedAt,
        };

        const created = await paymentDB.createPayment(data);
        payments.push(created);
      } catch (err) {
        console.error(`❌ Error processing jobProgressId ${id}:`, err.message);
      }
    }

    return { success: true, data: payments };
  } catch (error) {
    console.error("❌ Fatal error in createPayments:", error.message);
    return { success: false, message: error.message };
  }
};


const markAsPaid = async (jobId, employerId) => {
  try {
    const payment = await paymentDB.getPaymentByJobId(jobId);
    if (!payment) {
      const details = await calculateFinalPayment(jobId);
      const newPayment = await paymentDB.createPayment({
        jobId,
        employerId,
        status: 'paid',
        amount: details.total,
        paidAt: new Date(),
      });

      return { success: true, data: newPayment };
    }

    const updatedPayment = await paymentDB.updatePaymentStatus(jobId, 'paid');
    return { success: true, data: updatedPayment };
  } catch (error) {
    console.error("Error marking payment as paid:", error.message);
    return { success: false, message: error.message };
  }
};


module.exports =  {
  createPayments,
  markAsPaid,
 getPaymentsByJob,
 getPaymentsByUser,
 getPaymentDetail, 
 transferOneSalary, 
 transferMultipleSalaries, 
 markPaymentAsPaid, 
 getPaymentsByJobAndUser
}