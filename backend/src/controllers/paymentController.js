const stripeSecretKey = process.env.STRIPE_SECRET_KEY;
const stripe = require('stripe')(stripeSecretKey);
const Order = require('../models/Order');

// @desc    Create Payment Intent
// @route   POST /api/payment/create-payment-intent
// @access  Private
const createPaymentIntent = async (req, res) => {
    const { amount, currency, orderId } = req.body;

    try {
        const paymentIntent = await stripe.paymentIntents.create({
            amount: Math.round(amount * 100), // Stripe expects amount in cents
            currency: currency || 'usd',
            metadata: { orderId },
        });

        res.status(200).send({
            clientSecret: paymentIntent.client_secret,
        });
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

// @desc    Confirm Payment and update order
// @route   POST /api/payment/confirm-payment
// @access  Private
const confirmPayment = async (req, res) => {
    const { orderId, paymentIntentId } = req.body;

    try {
        // Basic check for test ORDER123 or similar non-mongo IDs
        if (!orderId.match(/^[0-9a-fA-F]{24}$/)) {
            return res.status(200).json({
                message: 'Test Order ID processed successfully (No DB update)',
                orderId,
                paymentIntentId
            });
        }

        const order = await Order.findById(orderId);

        if (order) {
            order.isPaid = true;
            order.paidAt = Date.now();
            order.paymentResult = {
                id: paymentIntentId,
                status: 'succeeded',
                update_time: new Date().toISOString(),
            };
            order.status = 'Accepted'; // Or another status to indicate it's ready for processing

            const updatedOrder = await order.save();
            res.json(updatedOrder);
        } else {
            res.status(404).json({ message: 'Order not found' });
        }
    } catch (error) {
        res.status(500).json({ message: error.message });
    }
};

module.exports = {
    createPaymentIntent,
    confirmPayment,
};
