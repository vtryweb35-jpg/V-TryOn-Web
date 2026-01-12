const express = require('express');
const router = express.Router();
const {
    addOrderItems,
    getOrderById,
    getMyOrders,
    getOrders,
    updateOrderStatus,
    clearMyOrders,
    deleteOrder,
} = require('../controllers/orderController');
const { protect, admin } = require('../middleware/auth');

router.route('/').post(protect, addOrderItems).get(protect, admin, getOrders);
router.route('/myorders').get(protect, getMyOrders).delete(protect, clearMyOrders);
router.route('/:id').get(protect, getOrderById).delete(protect, admin, deleteOrder);
router.route('/:id/status').put(protect, admin, updateOrderStatus);

module.exports = router;
