// const contractService = require('../services/contractService');

// const createContract = async (req, res) => {
//   try {
//     const { jobId, templateId, contractCategory } = req.body;
//     const contract = await contractService.createContract({
//       jobId,
//       employerId: req.user.id,
//       templateId,
//       contractCategory
//     });
//     res.status(201).json({ message: 'Гэрээ амжилттай үүсгэлээ', contract });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// const getContractSummary = async (req, res) => {
//   try {
//     const summary = await contractService.getContractSummary(req.params.id);
//     res.status(200).json({ summary });
//   } catch (err) {
//     res.status(404).json({ error: err.message });
//   }
// };

// const editContract = async (req, res) => {
//   try {
//     const updated = await contractService.editContract(req.params.id, req.body.contractText);
//     res.status(200).json({ message: 'Гэрээ шинэчлэгдлээ', contract: updated });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// const employerSignContract = async (req, res) => {
//   try {
//     await contractService.employerSignContract(req.params.id);
//     res.status(200).json({ message: 'Гэрээнд ажил олгогч гарын үсэг зурлаа' });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// const sendContractToWorkers = async (req, res) => {
//   try {
//     const result = await contractService.sendContractToWorkers(req.params.id, req.body.workerIds);
//     res.status(200).json({ message: 'Гэрээ ажилчдад илгээгдлээ', result });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// const getContractById = async (req, res) => {
//   try {
//     const contract = await contractService.getContractById(req.params.id);
//     res.status(200).json({ contract });
//   } catch (err) {
//     res.status(404).json({ error: err.message });
//   }
// };

// const workerSignContract = async (req, res) => {
//   try {
//     await contractService.workerSignContract(req.params.id, req.user.id);
//     res.status(200).json({ message: 'Гэрээнд ажилтан гарын үсэг зурлаа' });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// const workerRejectContract = async (req, res) => {
//   try {
//     await contractService.workerRejectContract(req.params.id);
//     res.status(200).json({ message: 'Гэрээг ажилтан татгалзлаа' });
//   } catch (err) {
//     res.status(400).json({ error: err.message });
//   }
// };

// const getContractHistory = async (req, res) => {
//   try {
//     const history = await contractService.getContractHistory(req.user.id);
//     res.status(200).json({ contracts: history });
//   } catch (err) {
//     res.status(404).json({ error: err.message });
//   }
// };

// module.exports = {
//   createContract,
//   getContractSummary,
//   editContract,
//   employerSignContract,
//   sendContractToWorkers,
//   getContractById,
//   workerSignContract,
//   workerRejectContract,
//   getContractHistory
// };
