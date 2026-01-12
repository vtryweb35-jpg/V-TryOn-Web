const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const User = require('../src/models/User');
const Product = require('../src/models/Product');
const TryOn = require('../src/models/TryOn');
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
        name: 'Brand Admin',
        email: 'admin@example.com',
        password: 'password123',
        role: 'brand'
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
    await TryOn.deleteMany({});
});

describe('Analytics Endpoints', () => {
    it('should log a try-on event', async () => {
        const res = await request(app)
            .post('/api/analytics/try-on')
            .send({ productId: product._id });

        expect(res.statusCode).toEqual(201);
        expect(res.body.message).toEqual('Try-on logged');
    });

    it('should fetch analytics for brand', async () => {
        await TryOn.create({
            product: product._id,
            admin: user._id
        });

        const res = await request(app)
            .get('/api/analytics')
            .set('Authorization', `Bearer ${token}`);

        expect(res.statusCode).toEqual(200);
        expect(res.body).toHaveProperty('totalTryOns', 1);
        expect(res.body).toHaveProperty('conversionRate');
    });
});
