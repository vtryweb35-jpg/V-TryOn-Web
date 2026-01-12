const Order = require('../models/Order');
const Product = require('../models/Product');
const asyncHandler = require('../middleware/errorMiddleware');

// @desc    Create new order
// @route   POST /api/orders
// @access  Private
const addOrderItems = asyncHandler(async (req, res) => {
    const {
        orderItems,
        shippingAddress,
        paymentMethod,
        itemsPrice,
        taxPrice,
        shippingPrice,
        totalPrice,
    } = req.body;

    if (orderItems && orderItems.length === 0) {
        res.status(400).json({ message: 'No order items' });
        return;
    } else {
        const order = new Order({
            orderItems,
            user: req.user._id,
            shippingAddress,
            paymentMethod,
            itemsPrice,
            taxPrice,
            shippingPrice,
            totalPrice,
        });

        const createdOrder = await order.save();

        res.status(201).json(createdOrder);
    }
});

// @desc    Get order by ID
// @route   GET /api/orders/:id
// @access  Private
const getOrderById = asyncHandler(async (req, res) => {
    const order = await Order.findById(req.params.id).populate(
        'user',
        'name email'
    );

    if (order) {
        res.json(order);
    } else {
        res.status(404).json({ message: 'Order not found' });
    }
});

// @desc    Get logged in user orders
// @route   GET /api/orders/myorders
// @access  Private
const getMyOrders = asyncHandler(async (req, res) => {
    const orders = await Order.find({
        user: req.user._id,
        isClearedByUser: false
    });
    res.json(orders);
});

// @desc    Get all orders (Filtered by Admin's products)
// @route   GET /api/orders
// @access  Private/Admin
const getOrders = asyncHandler(async (req, res) => {
    // 1. Get all products owned by this admin
    const myProducts = await Product.find({ user: req.user._id }).select('_id');
    const myProductIds = myProducts.map(p => p._id.toString());

    // 2. Find orders that contain at least one of these products
    const orders = await Order.find({
        'orderItems.product': { $in: myProductIds }
    }).populate('user', 'id name');

    // 3. Filter each order's items to only include this admin's products
    // and recalculate the totalPrice for this admin's view
    const filteredOrders = orders.map(order => {
        const orderObj = order.toObject();

        // Keep only my items
        const myItems = orderObj.orderItems.filter(item =>
            myProductIds.includes(item.product.toString())
        );

        // Recalculate total for just my items
        const myTotal = myItems.reduce((acc, item) => acc + (item.price * item.qty), 0);

        return {
            ...orderObj,
            orderItems: myItems,
            totalPrice: myTotal // Override with admin-specific total
        };
    });

    res.json(filteredOrders);
});

// @desc    Update order status
// @route   PUT /api/orders/:id/status
// @access  Private/Admin
const updateOrderStatus = asyncHandler(async (req, res) => {
    const order = await Order.findById(req.params.id);

    if (order) {
        order.status = req.body.status || order.status;
        if (req.body.status === 'Delivered') {
            order.isDelivered = true;
            order.deliveredAt = Date.now();
            order.isPaid = true;
            order.paidAt = Date.now();
        }

        const updatedOrder = await order.save();
        const populatedOrder = await Order.findById(updatedOrder._id).populate('user', 'name email');
        res.json(populatedOrder);
    } else {
        res.status(404).json({ message: 'Order not found' });
    }
});

// @desc    Clear logged in user order history (Delivered/Cancelled only)
// @route   DELETE /api/orders/myorders
// @access  Private
const clearMyOrders = asyncHandler(async (req, res) => {
    await Order.updateMany(
        {
            user: req.user._id,
            status: { $in: ['Delivered', 'Cancelled'] }
        },
        { isClearedByUser: true }
    );
    res.json({ message: 'Order history hidden from view' });
});

// @desc    Delete order
// @route   DELETE /api/orders/:id
// @access  Private/Admin
const deleteOrder = asyncHandler(async (req, res) => {
    const order = await Order.findById(req.params.id);

    if (order) {
        // Optional: verify if this admin owns items in this order
        // (Strictly speaking, our UI only shows orders they have items in)
        await order.deleteOne();
        res.json({ message: 'Order removed' });
    } else {
        res.status(404).json({ message: 'Order not found' });
    }
});

module.exports = {
    addOrderItems,
    getOrderById,
    getMyOrders,
    getOrders,
    updateOrderStatus,
    clearMyOrders,
    deleteOrder,
};
