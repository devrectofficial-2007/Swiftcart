import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../services/auth_service.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final AuthService _authService = AuthService();
  final CartService _cartService = CartService();
  final WishlistService _wishlistService = WishlistService();
  User? _currentUser;
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  int _selectedBottomNavIndex = 0;
  int _selectedTab = 0; // 0 for Home, 1 for Category
  int _cartItemCount = 0;

  @override
  void initState() {
    super.initState();
    _currentUser = _authService.currentUser;
    _startAutoScroll();
    _loadCartItemCount();
  }

  void _loadCartItemCount() async {
    _cartService.getCartItems().listen((items) {
      if (mounted) {
        setState(() {
          _cartItemCount = items.fold(0, (sum, item) => sum + item.quantity);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < 4) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6), // #FAF9F6 background color
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: const Color(0xFFFAF9F6), // #FAF9F6 background color
        toolbarHeight: 80, // Space badhane ke liye
        automaticallyImplyLeading: false, // Default back button hatane ke liye
        titleSpacing: 20, // Left side margin
        title: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey.shade100,
              backgroundImage: _currentUser?.photoURL != null
                  ? NetworkImage(_currentUser!.photoURL!)
                  : null,
              child: _currentUser?.photoURL == null
                  ? const Icon(Icons.person, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Hi, ${_currentUser?.displayName?.split(' ')[0] ?? 'User'}', // Sirf first name
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const Text(
                  "Let's go shopping",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: _buildSearchIcon(), // Aapka custom painter
              onPressed: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                  onPressed: () {},
                ),
                // Notification Red Dot
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 8,
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedBottomNavIndex = index;
              });
            },
            children: [
              _buildHomeContent(),
              const CartScreen(),
              const WishlistScreen(),
              const AccountScreen(),
            ],
          ),
          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  // Home Content
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20), // Top space for dashboard
          // Home/Category Tab Bar
          _buildHomeCategoryTabBar(),
          const SizedBox(height: 16),
          // Carousel Section
          _buildCarousel(),
          const SizedBox(height: 10),
          _buildCarouselIndicator(),
          const SizedBox(height: 20),
          // New Arrivals Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.62, // Further reduced from 0.68
                  children: [
                    _buildProductCard(
                      name: 'Wireless Headphones',
                      price: '₹2,999',
                      originalPrice: '₹4,999',
                      rating: 4.5,
                      reviews: 234,
                      discount: '40% OFF',
                      productId: 'wh1',
                      onTap: () {},
                    ),
                    _buildProductCard(
                      name: 'Smart Watch',
                      price: '₹3,499',
                      originalPrice: '₹5,999',
                      rating: 4.3,
                      reviews: 189,
                      discount: '42% OFF',
                      productId: 'sw1',
                      onTap: () {},
                    ),
                    _buildProductCard(
                      name: 'Laptop Stand',
                      price: '₹899',
                      originalPrice: '₹1,499',
                      rating: 4.7,
                      reviews: 421,
                      discount: '40% OFF',
                      productId: 'ls1',
                      onTap: () {},
                    ),
                    _buildProductCard(
                      name: 'USB-C Hub',
                      price: '₹1,299',
                      originalPrice: '₹2,199',
                      rating: 4.4,
                      reviews: 156,
                      discount: '41% OFF',
                      productId: 'uh1',
                      onTap: () {},
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 100), // Extra padding for floating bottom nav
        ],
      ),
    );
  }

  // Home/Category Tab Bar
  Widget _buildHomeCategoryTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: Column(
                children: [
                  Text(
                    'Home',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 0
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedTab == 0)
                    Container(height: 3, width: 40, color: Colors.deepPurple),
                ],
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: Column(
                children: [
                  Text(
                    'Category',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 1
                          ? Colors.deepPurple
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_selectedTab == 1)
                    Container(height: 3, width: 40, color: Colors.deepPurple),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Auto-scrolling Carousel
  Widget _buildCarousel() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: 5,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  _getCarouselColor(index).withOpacity(0.8),
                  _getCarouselColor(index).withOpacity(0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getCarouselColor(index).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getCarouselTitle(index),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getCarouselSubtitle(index),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getCarouselButton(index),
                          style: TextStyle(
                            color: _getCarouselColor(index),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Decorative element
                Positioned(
                  right: 20,
                  top: 20,
                  child: Icon(
                    _getCarouselIcon(index),
                    size: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getCarouselColor(int index) {
    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
    ];
    return colors[index % colors.length];
  }

  String _getCarouselTitle(int index) {
    final titles = [
      'Flash Sale!',
      'New Arrivals',
      'Special Offers',
      'Trending Now',
      'Limited Edition',
    ];
    return titles[index % titles.length];
  }

  String _getCarouselSubtitle(int index) {
    final subtitles = [
      'Up to 50% off on selected items',
      'Check out the latest products',
      'Exclusive deals just for you',
      'Most popular this week',
      'While supplies last',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getCarouselButton(int index) {
    final buttons = [
      'Shop Now',
      'Explore',
      'View Deals',
      'Shop Trending',
      'Get Yours',
    ];
    return buttons[index % buttons.length];
  }

  IconData _getCarouselIcon(int index) {
    final icons = [
      Icons.flash_on,
      Icons.new_releases,
      Icons.local_offer,
      Icons.trending_up,
      Icons.star,
    ];
    return icons[index % icons.length];
  }

  // Carousel Indicator Dots
  Widget _buildCarouselIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == index ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == index
                ? const Color(0xFF6C63FF)
                : const Color(0xFFC0C0C0),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }

  Widget _buildProductCard({
    required String name,
    required String price,
    required String originalPrice,
    required double rating,
    required int reviews,
    required String discount,
    required String productId,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image Placeholder
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  gradient: LinearGradient(
                    colors: [Colors.grey.shade100, Colors.grey.shade200],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Discount Badge
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Wishlist Button
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: () => _toggleWishlist(
                          productId,
                          name,
                          price,
                          originalPrice,
                          rating,
                          reviews,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_border,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                    // Product Icon Placeholder
                    Center(
                      child: Icon(
                        Icons.shopping_bag,
                        size: 40,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Product Details
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    // Rating
                    Row(
                      children: [
                        Icon(Icons.star, size: 8, color: Colors.amber),
                        const SizedBox(width: 1),
                        Text(
                          rating.toString(),
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '($reviews)',
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Price
                    Row(
                      children: [
                        Text(
                          price,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontSize: 8,
                            color: Colors.grey.shade600,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Add to Cart Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _addToCart(
                          productId,
                          name,
                          price,
                          originalPrice,
                          rating,
                          reviews,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          minimumSize: const Size(0, 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Add to Cart',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(
    String productId,
    String name,
    String price,
    String originalPrice,
    double rating,
    int reviews,
  ) async {
    try {
      CartItem cartItem = CartItem(
        id: productId,
        name: name,
        price: price,
        originalPrice: originalPrice,
        imageUrl: '',
        quantity: 1,
        rating: rating,
        reviews: reviews,
      );

      await _cartService.addToCart(cartItem);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added to cart'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'View Cart',
              textColor: Colors.white,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartScreen()),
                );
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding to cart: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleWishlist(
    String productId,
    String name,
    String price,
    String originalPrice,
    double rating,
    int reviews,
  ) async {
    try {
      WishlistItem wishlistItem = WishlistItem(
        id: productId,
        name: name,
        price: price,
        originalPrice: originalPrice,
        imageUrl: '',
        rating: rating,
        reviews: reviews,
        addedAt: DateTime.now(),
      );

      await _wishlistService.toggleWishlist(wishlistItem);

      bool isInWishlist = await _wishlistService.isInWishlist(productId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isInWishlist
                  ? '$name added to wishlist'
                  : '$name removed from wishlist',
            ),
            backgroundColor: isInWishlist ? Colors.green : Colors.orange,
            action: isInWishlist
                ? SnackBarAction(
                    label: 'View Wishlist',
                    textColor: Colors.white,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WishlistScreen(),
                        ),
                      );
                    },
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating wishlist: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 2,
          ),
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF6C63FF).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          children: [
            // Home
            Expanded(
              child: _buildNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
            ),
            // Cart with special design
            Expanded(
              child: _buildNavItem(
                icon: Icons.shopping_cart_outlined,
                selectedIcon: Icons.shopping_cart,
                label: 'Cart',
                index: 1,
                showBadge: _cartItemCount > 0,
                badgeCount: _cartItemCount,
              ),
            ),
            // Wishlist
            Expanded(
              child: _buildNavItem(
                icon: Icons.favorite_outline,
                selectedIcon: Icons.favorite,
                label: 'Wishlist',
                index: 2,
              ),
            ),
            // Accounts
            Expanded(
              child: _buildNavItem(
                icon: Icons.account_circle_outlined,
                selectedIcon: Icons.account_circle,
                label: 'Account',
                index: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        if (index == 1) {
          // Cart tab - navigate to CartScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CartScreen()),
          );
        } else if (index == 3) {
          // Accounts tab - navigate to AccountScreen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AccountScreen()),
          );
        } else {
          // Home and Wishlist tabs - use PageView
          setState(() {
            _selectedBottomNavIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Container(
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF6C63FF).withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  Icon(
                    isSelected ? selectedIcon : icon,
                    size: 24,
                    color: isSelected
                        ? const Color(0xFF6C63FF)
                        : Colors.grey.shade600,
                  ),
                  if (showBadge && badgeCount > 0)
                    Positioned(
                      right: -4,
                      top: -4,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.red.withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF6C63FF)
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom Search Icon matching the SVG design
  Widget _buildSearchIcon() {
    return CustomPaint(size: const Size(24, 24), painter: SearchIconPainter());
  }
}

class SearchIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = 7;

    // Draw circle (magnifying glass)
    canvas.drawCircle(Offset(centerX - 3, centerY - 3), radius, paint);

    // Draw handle (magnifying glass handle)
    final Offset start = Offset(centerX + 3, centerY + 3);
    final Offset end = Offset(centerX + 9, centerY + 9);
    canvas.drawLine(start, end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
