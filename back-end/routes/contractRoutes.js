// const express = require('express');
// const router = express.Router();
// const contractController = require('../controllers/contractController');
// const authMiddleware = require('../middleware/authMiddleware');

// // 1. Create contract from template
// router.post('/create', authMiddleware, contractController.createContract);

// // 2. Get contract summary Worker and employer views summary
// router.get('/:id/summary', authMiddleware, contractController.getContractSummary);

// // 3. Edit contract (employer edits)
// router.put('/:id/edit', authMiddleware, contractController.editContract);

// // 4. Employer signs contract
// router.put('/:id/employer-sign', authMiddleware, contractController.employerSignContract);

// // 5. Send contract to selected employees (accepted workers)
// router.post('/:id/send', authMiddleware, contractController.sendContractToWorkers);

// // 6. Worker and employer views contract
// router.get('/:id', authMiddleware, contractController.getContractById);

// // 7. Worker signs contract
// router.put('/:id/worker-sign', authMiddleware, contractController.workerSignContract);

// // 8. Worker rejects contract
// router.put('/:id/reject', authMiddleware, contractController.workerRejectContract);

// // worker and employer view after contract are completed
// router.get('/contracthistory', authMiddleware, contractController.getContractHistory);
// module.exports = router;
