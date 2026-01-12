const express = require('express');
const router = express.Router();
const { getProducts, createProduct, getMyProducts, deleteProduct, updateProduct } = require('../controllers/productController');
const { protect, admin } = require('../middleware/auth');

const upload = require('../middleware/productUploadMiddleware');

router.get('/myproducts', protect, admin, getMyProducts);

router.route('/')
    .get(getProducts)
    .post(protect, admin, upload.single('image'), createProduct);

router.route('/:id')
    .put(protect, admin, upload.single('image'), updateProduct)
    .delete(protect, admin, deleteProduct);

module.exports = router;
