const TryOn = require('../models/TryOn');
const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');
const asyncHandler = require('../middleware/errorMiddleware');

// @desc    Log a try-on event
// @route   POST /api/analytics/try-on
// @access  Public (or Private if user is logged in)
const logTryOn = asyncHandler(async (req, res) => {
    const { productId } = req.body;

    const product = await Product.findById(productId);
    if (!product) {
        return res.status(404).json({ message: 'Product not found' });
    }

    const tryOn = new TryOn({
        user: req.user ? req.user._id : null,
        product: productId,
        admin: product.user, // The owner of the product
    });

    await tryOn.save();
    res.status(201).json({ message: 'Try-on logged' });
});

// @desc    Get analytics for logged in brand
// @route   GET /api/analytics
// @access  Private/Admin
const getAnalytics = asyncHandler(async (req, res) => {
    const adminId = req.user._id;

    // 1. Get total try-ons for this admin's products
    const totalTryOns = await TryOn.countDocuments({ admin: adminId });

    // 2. Get all products owned by this admin
    const myProducts = await Product.find({ user: adminId }).select('_id');
    const myProductIds = myProducts.map(p => p._id);

    // 3. Get all orders containing this admin's products
    const orders = await Order.find({
        'orderItems.product': { $in: myProductIds }
    });

    const totalOrders = orders.length;

    // 4. Calculate New Customers (Unique users who bought from this admin)
    const uniqueUsers = await Order.distinct('user', {
        'orderItems.product': { $in: myProductIds }
    });
    const newCustomers = uniqueUsers.length;

    // 5. Calculate Conversion Rate
    // Percentage of try-ons that lead to orders (simplified as total orders / total try-ons)
    const conversionRate = totalTryOns > 0
        ? ((totalOrders / totalTryOns) * 100).toFixed(1)
        : 0;

    res.json({
        totalTryOns,
        totalOrders,
        newCustomers,
        conversionRate,
    });
});

module.exports = {
    logTryOn,
    getAnalytics,
};
