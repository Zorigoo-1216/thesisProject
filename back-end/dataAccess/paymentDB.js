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

module.exports = {
  createPayment,
  getByJobProgressId,
  markPaymentTransferred,
};
