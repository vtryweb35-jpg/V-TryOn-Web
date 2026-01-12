const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const User = require('../src/models/User');
const Order = require('../src/models/Order');
const Product = require('../src/models/Product');
const jwt = require('jsonwebtoken');

process.env.JWT_SECRET = 'testsecret';

let mongoServer;
let token;
let user;
let product;

beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const uri = mongoServer.getUri();
    if (mongoose.connection.readyState === 0) {
        await mongoose.connect(uri);
    }

    user = await User.create({
        name: 'Test Customer',
        email: 'customer@example.com',
        password: 'password123',
        role: 'user'
    });
    token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });

    product = await Product.create({
        name: 'Test Product',
        price: 100,
        user: user._id,
        image: '/img.jpg',
        brand: 'Test Brand',
        category: 'Test Cat',
        countInStock: 5,
        description: 'Desc'
    });
});

afterAll(async () => {
    await mongoose.disconnect();
    await mongoServer.stop();
});

beforeEach(async () => {
    await Order.deleteMany({});
});

describe('Order Endpoints', () => {
    const testOrder = {
        orderItems: [
            {
                name: 'Test Product',
                qty: 1,
                image: '/img.jpg',
                price: 100,
                product: null // Will be set in test
            }
        ],
        shippingAddress: {
            address: '123 Test St',
            city: 'Test City',
            postalCode: '12345',
            country: 'Test Country'
        },
        paymentMethod: 'Stripe',
        itemsPrice: 100,
        taxPrice: 0,
        shippingPrice: 0,
        totalPrice: 100
    };

    it('should create a new order', async () => {
        testOrder.orderItems[0].product = product._id;
        const res = await request(app)
            .post('/api/orders')
            .set('Authorization', `Bearer ${token}`)
            .send(testOrder);

        expect(res.statusCode).toEqual(201);
        expect(res.body.totalPrice).toEqual(100);
    });

    it('should fetch my orders', async () => {
        testOrder.orderItems[0].product = product._id;
        await Order.create({ ...testOrder, user: user._id });

        const res = await request(app)
            .get('/api/orders/myorders')
            .set('Authorization', `Bearer ${token}`);

        expect(res.statusCode).toEqual(200);
        expect(res.body.length).toEqual(1);
    });

    it('should return 400 if no order items', async () => {
        const res = await request(app)
            .post('/api/orders')
            .set('Authorization', `Bearer ${token}`)
            .send({ ...testOrder, orderItems: [] });

        expect(res.statusCode).toEqual(400);
    });
});
