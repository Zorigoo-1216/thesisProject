const paymentService = require('../services/paymentService');

// 1. Ажил олгогч тухайн ажлын бүх төлбөрийн мэдээллийг харах
const viewPaymentInfoByJob = async (req, res) => {
  try {
    const { jobId } = req.params;
    const employerId = req.user.id;
    console.log('📥 /viewPaymentInfoByJob GET - jobId:', jobId);
    const result = await paymentService.getPaymentsByJob(jobId, employerId);
    if (!result.success) {
      return res.status(400).json({ success: false, message: result.message });
    }
    console.log('✅ Payment info retrieved successfully:', result.data);
    res.status(200).json({ success: true, data: result.data });
  } catch (error) {
    console.error('❌ Error in viewPaymentInfoByJob:', error.message);
    res.status(500).json({ success: false, message: 'Internal Server Error' });
  }
};

// 2. Хэрэглэгчийн бүх төлбөрийн мэдээллийг харах
const getUserPaymentInfo = async (req, res) => {
  const { userId } = req.params;
  const requesterId = req.user.id;
  const result = await paymentService.getPaymentsByUser(userId, requesterId);
  res.json(result);
};

// 3. Нэг төлбөрийн дэлгэрэнгүйг харах (ажил олгогч болон ажилтан аль аль нь ашиглаж болно)
const getPaymentDetail = async (req, res) => {
  const { paymentId } = req.params;
  const requesterId = req.user.id;
  const result = await paymentService.getPaymentDetail(paymentId, requesterId);
  res.json(result);
};

// 4. Нэг ажилтанд цалин шилжүүлэх
const transferWorkerSalary = async (req, res) => {
  const { paymentId } = req.params;
  const employerId = req.user.id;
  const result = await paymentService.transferOneSalary(paymentId, employerId);
  res.json(result);
};

// 5. Олон ажилтанд нэг дор цалин шилжүүлэх
const transferWorkersSalary = async (req, res) => {
  const { paymentIds } = req.body; // array of IDs
  const employerId = req.user.id;
  const result = await paymentService.transferMultipleSalaries(paymentIds, employerId);
  res.json(result);
};

// 6. Статусыг `paid` болгох (тест эсвэл админ нөхцөлд)
const markAsPaid = async (req, res) => {
  const { paymentId, userId } = req.params;
  const result = await paymentService.markPaymentAsPaid(paymentId, userId);
  res.json(result);
};

module.exports = {
  viewPaymentInfoByJob,
  getUserPaymentInfo,
  getPaymentDetail,
  transferWorkerSalary,
  transferWorkersSalary,
  markAsPaid
};
