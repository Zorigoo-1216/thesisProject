const Payment = require('../models/Payment');

const createPayment = async (data) => {
  return await Payment.create(data);
};

const getPaymentByJobId = async (jobId) => {
  return await Payment.findOne({ jobId });
};

const markPaymentTransferred = async (jobId) => {
  return await Payment.findOneAndUpdate(
    { jobId },
    { transferred: true, transferredAt: new Date() },
    { new: true }
  );
};

module.exports = {
  createPayment,
  getPaymentByJobId,
  markPaymentTransferred,
};
