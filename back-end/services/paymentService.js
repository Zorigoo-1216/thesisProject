
// services/paymentService.js

const paymentDB = require('../dataAccess/paymentDB');
const jobDB = require('../dataAccess/jobDB');
const jobProgressService = require('../services/jobProgressService')
const jobProgressDB = require('../dataAccess/jobProgressDB');
const Payment = require('../models/Payment');
const getPaymentsByJob = async (jobId, employerId) => {
  const job = await jobDB.getJobById(jobId);
  if (!job) throw new Error('Job not found');
  if (job.employerId.toString() !== employerId) throw new Error('Not authorized');

  return await Payment.find({ jobId });
};

// 2. Хэрэглэгчийн бүх цалингийн мэдээлэл (ажилтан эсвэл ажил олгогч)
const getPaymentsByUser = async (userId, requesterId) => {
  if (userId !== requesterId) throw new Error('Not authorized');
  return await Payment.find({ workerId: userId });
};

// 3. Нэг төлбөрийн дэлгэрэнгүй мэдээлэл
const getPaymentDetail = async (paymentId, requesterId) => {
  const payment = await Payment.findById(paymentId);
  if (!payment) throw new Error('Payment not found');
  if (payment.workerId.toString() !== requesterId && payment.employeeId.toString() !== requesterId) {
    throw new Error('Not authorized');
  }
  return payment;
};

// 4. Нэг ажилтны цалинг "paid" болгоно
const transferOneSalary = async (paymentId, employerId) => {
  const payment = await Payment.findById(paymentId);
  if (!payment) throw new Error('Payment not found');
  if (payment.employeeId.toString() !== employerId) throw new Error('Not authorized');

  payment.status = 'paid';
  payment.paidAt = new Date();
  await payment.save();
  return payment;
};

// 5. Олон ажилтанд нэг дор цалин шилжүүлнэ
const transferMultipleSalaries = async (paymentIds, employerId) => {
  const updatedPayments = [];
  for (const id of paymentIds) {
    const payment = await Payment.findById(id);
    if (!payment) continue;
    if (payment.employeeId.toString() !== employerId) continue;

    payment.status = 'paid';
    payment.paidAt = new Date();
    await payment.save();
    updatedPayments.push(payment);
  }
  return updatedPayments;
};

// 6. Статусыг гараар paid болгох (optional admin/testing)
const markPaymentAsPaid = async (paymentId, userId) => {
  const payment = await Payment.findById(paymentId);
  if (!payment) throw new Error('Payment not found');

  payment.status = 'paid';
  payment.paidAt = new Date();
  await payment.save();
  return payment;
};

// 7. Ажил бүрэн дууссан үед олон ажилтанд төлбөр үүсгэх

const createPayments = async (jobprogressIds, jobId, userId )=> {
  job = await jobDB.getJobById(jobId);
  if (!job) throw new Error("Job not found");
  const result = PromiseAll(
    jobprogressIds.map(async (id) => {
      const progress = jobProgressDB.getJobProgressById(id);
      if (!progress) throw new Error(`JobProgress not found for id: ${id}`);
      const salary = await jobProgressService.calculateSalary(job, progress);
      const data = {
        contractId: progress.contractId,
        jobId: jobId,
        jobProgressId: id,
        workerId: progress.workerId,
        employeeId: progress.employerId,
        status: 'unpaid',
        totalAmount: salary.total,
        breakdown: {
          baseSalary: salary.breakdown.baseSalary,
          transportAllowance: salary.breakdown.transportAllowance,
          mealAllowance: salary.breakdown.mealAllowance,
          socialInsurance: salary.breakdown.socialInsurance,
          taxDeduction: salary.breakdown.taxDeduction,
        },
        paidAt: null
      };
      return await paymentDB.createPayment(data);
    })
  );
  return result;
  
}


const markAsPaid = async (jobId, employerId) => {
  const payment = await paymentDB.getPaymentByJobId(jobId);
  if (!payment) {
    const details = await calculateFinalPayment(jobId);
    return await paymentDB.createPayment({
      jobId,
      employerId,
      status: 'paid',
      amount: details.total,
      paidAt: new Date()
    });
  }

  return await paymentDB.updatePaymentStatus(jobId, 'paid');
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
}