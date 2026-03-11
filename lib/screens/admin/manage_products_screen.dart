import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/product_service.dart';
import '../../services/category_service.dart';

class ManageProductsScreen extends StatefulWidget {
  const ManageProductsScreen({super.key});

  @override
  State<ManageProductsScreen> createState() => _ManageProductsScreenState();
}

class _ManageProductsScreenState extends State<ManageProductsScreen> {
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final products = await _productService.getAllProducts();
      final categories = await _categoryService.getAllCategories();
      setState(() {
        _products = products;
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching data: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Manage Products',
          style: TextStyle(
            color: Color(0xFF0D0F14),
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D0F14)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
            onPressed: () => _showAddProductDialog(),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _products.isEmpty
          ? const Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Color(0xFF8A8F9E)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return _ProductCard(
                    product: product,
                    onEdit: () => _showEditProductDialog(product),
                    onDelete: () => _deleteProduct(product['id']),
                    onView: () => _showViewProductDialog(product),
                  );
                },
              ),
            ),
    );
  }

  void _showAddProductDialog() {
    showDialog(
      context: context,
      builder: (context) => ProductDialog(
        categories: _categories,
        onSave: (productData, imageFiles) async {
          try {
            await _productService.addProduct(productData, imageFiles);
            _fetchData();
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Error adding product: $e')));
          }
        },
      ),
    );
  }

  void _showEditProductDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => ProductDialog(
        isEdit: true,
        categories: _categories,
        initialProduct: product,
        onSave: (productData, imageFiles) async {
          try {
            await _productService.updateProduct(
              product['id'],
              productData,
              imageFiles,
              product['images']?.cast<String>(),
            );
            _fetchData();
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error updating product: $e')),
            );
          }
        },
      ),
    );
  }

  void _showViewProductDialog(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => ViewProductDialog(product: product),
    );
  }

  Future<void> _deleteProduct(String productId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _productService.deleteProduct(productId);
        _fetchData();
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting product: $e')));
      }
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    required this.onView,
  });

  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    final String title = product['title'] ?? 'No title';
    final String description = product['description'] ?? 'No description';
    final double originalPrice = (product['originalPrice'] ?? 0).toDouble();
    final double discountedPrice = (product['discountedPrice'] ?? 0).toDouble();
    final List<dynamic> images = product['images'] ?? [];
    final String faceImage = product['faceImage'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: faceImage.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            faceImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                color: Color(0xFF9CA3AF),
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.image, color: Color(0xFF9CA3AF)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF0D0F14),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8A8F9E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (originalPrice > 0) ...[
                            Text(
                              '₹${originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF9CA3AF),
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            '₹${discountedPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (images.isNotEmpty) ...[
              Text(
                '${images.length} images',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onView,
                  icon: const Icon(
                    Icons.visibility,
                    color: Color(0xFF7C3AED),
                    size: 16,
                  ),
                  label: const Text(
                    'View',
                    style: TextStyle(color: Color(0xFF7C3AED), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(
                    Icons.edit,
                    color: Color(0xFF059669),
                    size: 16,
                  ),
                  label: const Text(
                    'Edit',
                    style: TextStyle(color: Color(0xFF059669), fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDialog extends StatefulWidget {
  const ProductDialog({
    super.key,
    this.isEdit = false,
    this.initialProduct,
    required this.categories,
    required this.onSave,
  });

  final bool isEdit;
  final Map<String, dynamic>? initialProduct;
  final List<Map<String, dynamic>> categories;
  final Function(Map<String, dynamic> productData, List<File> imageFiles)
  onSave;

  @override
  State<ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<ProductDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  List<File> _selectedImages = [];
  List<String> _existingImages = [];

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  List<Map<String, dynamic>> _subcategories = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialProduct != null) {
      _titleController.text = widget.initialProduct!['title'] ?? '';
      _descriptionController.text = widget.initialProduct!['description'] ?? '';
      _originalPriceController.text =
          widget.initialProduct!['originalPrice']?.toString() ?? '';
      _discountedPriceController.text =
          widget.initialProduct!['discountedPrice']?.toString() ?? '';
      _selectedCategoryId = widget.initialProduct!['categoryId'];
      _selectedSubcategoryId = widget.initialProduct!['subcategoryId'];
      _existingImages = List<String>.from(
        widget.initialProduct!['images'] ?? [],
      );

      if (_selectedCategoryId != null) {
        _loadSubcategories(_selectedCategoryId!);
      }
    }
  }

  Future<void> _loadSubcategories(String categoryId) async {
    final category = widget.categories.firstWhere(
      (cat) => cat['id'] == categoryId,
      orElse: () => {},
    );

    if (category.isNotEmpty) {
      setState(() {
        _subcategories = List<Map<String, dynamic>>.from(
          category['subcategories'] ?? [],
        );
      });
    }
  }

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images.map((image) => File(image.path)));
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index < _selectedImages.length) {
        _selectedImages.removeAt(index);
      } else {
        final existingIndex = index - _selectedImages.length;
        if (existingIndex < _existingImages.length) {
          _existingImages.removeAt(existingIndex);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isEdit ? 'Edit Product' : 'Add Product',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D0F14),
                ),
              ),
              const SizedBox(height: 20),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Product Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _originalPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Original Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _discountedPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Discounted Price',
                        border: OutlineInputBorder(),
                        prefixText: '₹',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCategoryId,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: widget.categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category['id']?.toString(),
                    child: Text(category['name'] ?? 'No name'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategoryId = value;
                    _selectedSubcategoryId = null;
                    _subcategories = [];
                  });
                  if (value != null) {
                    _loadSubcategories(value);
                  }
                },
              ),
              const SizedBox(height: 16),

              if (_subcategories.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedSubcategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Subcategory',
                    border: OutlineInputBorder(),
                  ),
                  items: _subcategories.map((subcategory) {
                    return DropdownMenuItem<String>(
                      value: subcategory['id']?.toString(),
                      child: Text(subcategory['name'] ?? 'No name'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubcategoryId = value;
                    });
                  },
                ),
              const SizedBox(height: 16),

              const Text(
                'Product Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0D0F14),
                ),
              ),
              const SizedBox(height: 8),

              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 40,
                          color: Color(0xFF9CA3AF),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap to select images',
                          style: TextStyle(color: Color(0xFF9CA3AF)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_selectedImages.isNotEmpty || _existingImages.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(
                    _selectedImages.length + _existingImages.length,
                    (index) {
                      final bool isNew = index < _selectedImages.length;
                      return Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: isNew
                                  ? Image.file(
                                      _selectedImages[index],
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      _existingImages[index -
                                          _selectedImages.length],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          Positioned(
                            top: -8,
                            right: -8,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          if (index == 0)
                            Positioned(
                              bottom: 2,
                              left: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Face',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (_titleController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please enter a product title'),
                                ),
                              );
                              return;
                            }

                            if (_selectedCategoryId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a category'),
                                ),
                              );
                              return;
                            }

                            final originalPrice =
                                double.tryParse(
                                  _originalPriceController.text,
                                ) ??
                                0;
                            final discountedPrice =
                                double.tryParse(
                                  _discountedPriceController.text,
                                ) ??
                                0;

                            if (discountedPrice <= 0) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter a valid discounted price',
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => _isLoading = true);
                            try {
                              final productData = {
                                'title': _titleController.text.trim(),
                                'description': _descriptionController.text
                                    .trim(),
                                'originalPrice': originalPrice,
                                'discountedPrice': discountedPrice,
                                'categoryId': _selectedCategoryId,
                                'subcategoryId': _selectedSubcategoryId,
                              };

                              await widget.onSave(productData, _selectedImages);
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                    child: _isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewProductDialog extends StatelessWidget {
  const ViewProductDialog({super.key, required this.product});

  final Map<String, dynamic> product;

  @override
  Widget build(BuildContext context) {
    final String title = product['title'] ?? 'No title';
    final String description = product['description'] ?? 'No description';
    final double originalPrice = (product['originalPrice'] ?? 0).toDouble();
    final double discountedPrice = (product['discountedPrice'] ?? 0).toDouble();
    final List<dynamic> images = product['images'] ?? [];
    final String faceImage = product['faceImage'] ?? '';

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D0F14),
                ),
              ),
              const SizedBox(height: 16),

              if (faceImage.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      faceImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image,
                          color: Color(0xFF9CA3AF),
                          size: 50,
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 16),

              Text(
                description,
                style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  if (originalPrice > 0) ...[
                    Text(
                      '₹${originalPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Color(0xFF9CA3AF),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    '₹${discountedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF059669),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              if (images.length > 1) ...[
                const Text(
                  'All Images',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF0D0F14),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.image,
                                color: Color(0xFF9CA3AF),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
