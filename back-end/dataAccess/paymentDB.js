const Payment = require('../models/Payment');

const createPayment = async (data) => {
  return await Payment.create(data);
};

const getByJobProgressId = async (jobProgressId) => {
  return await Payment.findOne({ jobProgressId });
};


const markPaymentTransferred = async (jobId) => {
  return await Payment.findOneAndUpdate(
    { jobId },
    { transferred: true, transferredAt: new Date() },
    { new: true }
  );
};
const getByJobAndUser = async (jobId, userId) => {
  return await Payment.findOne({ jobId: jobId, workerId: userId })
  .populate('workerId', 'firstName lastName phone') // 👈
  .populate('employerId', 'firstName lastName');
}

const getByJobByStatus = async (jobId, status) => {
  return await Payment.find({ jobId, status });
};

module.exports = {
  createPayment,
  getByJobProgressId,
  markPaymentTransferred,
  getByJobAndUser,
  getByJobByStatus
};
