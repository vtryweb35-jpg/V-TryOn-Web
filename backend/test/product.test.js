const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const User = require('../src/models/User');
const Product = require('../src/models/Product');
const jwt = require('jsonwebtoken');

process.env.JWT_SECRET = 'testsecret';

let mongoServer;
let token;
let user;

beforeAll(async () => {
    mongoServer = await MongoMemoryServer.create();
    const uri = mongoServer.getUri();
    if (mongoose.connection.readyState === 0) {
        await mongoose.connect(uri);
    }

    // Create a test brand user and get token
    user = await User.create({
        name: 'Brand User',
        email: 'brand@example.com',
        password: 'password123',
        role: 'brand'
    });
    token = jwt.sign({ id: user._id }, process.env.JWT_SECRET, { expiresIn: '30d' });
});

afterAll(async () => {
    await mongoose.disconnect();
    await mongoServer.stop();
});

beforeEach(async () => {
    await Product.deleteMany({});
});

describe('Product Endpoints', () => {
    const testProduct = {
        name: 'Test Shirt',
        price: 29.99,
        brand: 'Test Brand',
        category: 'Shirts',
        countInStock: 10,
        description: 'A nice test shirt',
        image: '/test.jpg'
    };

    it('should fetch all products', async () => {
        await Product.create({ ...testProduct, user: user._id });
        const res = await request(app).get('/api/products');
        expect(res.statusCode).toEqual(200);
        expect(res.body.length).toEqual(1);
    });

    it('should create a new product (Brand only)', async () => {
        const res = await request(app)
            .post('/api/products')
            .set('Authorization', `Bearer ${token}`)
            .send(testProduct);

        expect(res.statusCode).toEqual(201);
        expect(res.body.name).toEqual(testProduct.name);
    });

    it('should delete a product', async () => {
        const product = await Product.create({ ...testProduct, user: user._id });
        const res = await request(app)
            .delete(`/api/products/${product._id}`)
            .set('Authorization', `Bearer ${token}`);

        expect(res.statusCode).toEqual(200);
        expect(res.body.message).toEqual('Product removed');
    });

    it('should not delete product of another user', async () => {
        const otherUser = await User.create({
            name: 'Other',
            email: 'other@example.com',
            password: 'password',
            role: 'brand'
        });
        const product = await Product.create({ ...testProduct, user: otherUser._id });

        const res = await request(app)
            .delete(`/api/products/${product._id}`)
            .set('Authorization', `Bearer ${token}`);

        expect(res.statusCode).toEqual(401);
    });
});
