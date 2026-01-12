const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../src/app');
const User = require('../src/models/User');
const Activity = require('../src/models/Activity');
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

    user = await User.create({
        name: 'Brand Admin',
        email: 'admin@example.com',
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
    await Activity.deleteMany({});
});

describe('Activity Endpoints', () => {
    it('should create a new activity', async () => {
        const res = await request(app)
            .post('/api/activities')
            .set('Authorization', `Bearer ${token}`)
            .send({
                label: 'New Product Added',
                icon: 'add',
                color: 'blue'
            });

        expect(res.statusCode).toEqual(201);
        expect(res.body.label).toEqual('New Product Added');
    });

    it('should fetch brand activities', async () => {
        await Activity.create({
            user: user._id,
            label: 'Test Activity',
            icon: 'test',
            color: 'green'
        });

        const res = await request(app)
            .get('/api/activities')
            .set('Authorization', `Bearer ${token}`);

        expect(res.statusCode).toEqual(200);
        expect(res.body.length).toEqual(1);
    });
});
