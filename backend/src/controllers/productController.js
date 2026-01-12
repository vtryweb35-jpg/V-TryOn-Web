const Product = require('../models/Product');
const asyncHandler = require('../middleware/errorMiddleware');

// @desc    Fetch all products
// @route   GET /api/products
// @access  Public
const getProducts = asyncHandler(async (req, res) => {
    const products = await Product.find({});
    res.json(products);
});

// @desc    Create a product
// @route   POST /api/products
// @access  Private/Admin
const createProduct = asyncHandler(async (req, res) => {
    const { name, price, brand, category, countInStock, description } = req.body;
    let image = req.body.image;

    if (req.file) {
        image = `http://${req.headers.host}/uploads/products/${req.file.filename}`;
    }

    const product = new Product({
        name,
        price,
        user: req.user._id,
        image,
        brand,
        category,
        countInStock,
        description,
    });

    const createdProduct = await product.save();
    res.status(201).json(createdProduct);
});

// @desc    Fetch products for logged in user
// @route   GET /api/products/myproducts
// @access  Private/Admin
const getMyProducts = asyncHandler(async (req, res) => {
    const products = await Product.find({ user: req.user._id });
    res.json(products);
});

// @desc    Delete a product
// @route   DELETE /api/products/:id
// @access  Private/Admin
const deleteProduct = asyncHandler(async (req, res) => {
    const product = await Product.findById(req.params.id);

    if (product) {
        if (product.user.toString() !== req.user._id.toString()) {
            res.status(401).json({ message: 'User not authorized' });
            return;
        }
        await product.deleteOne();
        res.json({ message: 'Product removed' });
    } else {
        res.status(404).json({ message: 'Product not found' });
    }
});

// @desc    Update a product
// @route   PUT /api/products/:id
// @access  Private/Admin
const updateProduct = asyncHandler(async (req, res) => {
    const { name, price, description, brand, category, countInStock } = req.body;

    const product = await Product.findById(req.params.id);

    if (product) {
        if (product.user.toString() !== req.user._id.toString()) {
            res.status(401).json({ message: 'User not authorized' });
            return;
        }

        product.name = name || product.name;
        product.price = price || product.price;
        product.description = description || product.description;
        product.brand = brand || product.brand;
        product.category = category || product.category;
        product.countInStock = countInStock || product.countInStock;

        if (req.file) {
            product.image = `http://${req.headers.host}/uploads/products/${req.file.filename}`;
        }

        const updatedProduct = await product.save();
        res.json(updatedProduct);
    } else {
        res.status(404).json({ message: 'Product not found' });
    }
});

module.exports = {
    getProducts,
    createProduct,
    getMyProducts,
    deleteProduct,
    updateProduct,
};
