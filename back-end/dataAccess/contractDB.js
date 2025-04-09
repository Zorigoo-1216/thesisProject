// const Contract = require('../models/Contracts');

// const createContract = async (data) => {
//   const contract = new Contract({
//     ...data,
//     status: 'pending',
//     isSignedByEmployer: false,
//     isSignedByWorker: false,
//     createdAt: new Date(),
//     updatedAt: new Date()
//   });
//   return await contract.save();
// };

// const getContractById = async (id) => {
//   return await Contract.findById(id);
// };

// const getContractDetails = async (id) => {
//   return await Contract.findById(id)
//     .populate('jobId')
//     .populate('employerId')
//     .populate('workerId');
// };

// const updateContractText = async (id, contractText, summary) => {
//   return await Contract.findByIdAndUpdate(
//     id,
//     { contractText, summary, updatedAt: new Date() },
//     { new: true }
//   );
// };

// const employerSign = async (id) => {
//   return await Contract.findByIdAndUpdate(
//     id,
//     {
//       isSignedByEmployer: true,
//       employerSignedAt: new Date(),
//       updatedAt: new Date(),
//       status: 'signed'
//     },
//     { new: true }
//   );
// };

// const workerSign = async (id) => {
//   return await Contract.findByIdAndUpdate(
//     id,
//     {
//       isSignedByWorker: true,
//       workerSignedAt: new Date(),
//       updatedAt: new Date(),
//       status: 'signed'
//     },
//     { new: true }
//   );
// };

// const rejectContract = async (id) => {
//   return await Contract.findByIdAndUpdate(
//     id,
//     { status: 'rejected', updatedAt: new Date() },
//     { new: true }
//   );
// };

// const getContractsForUser = async (userId) => {
//   return await Contract.find({
//     $or: [{ employerId: userId }, { workerId: userId }]
//   }).sort({ createdAt: -1 });
// };

// module.exports = {
//   createContract,
//   getContractById,
//   getContractDetails,
//   updateContractText,
//   employerSign,
//   workerSign,
//   rejectContract,
//   getContractsForUser
// };
