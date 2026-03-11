import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import 'manage_users_screen.dart';
import 'manage_categories_screen.dart';
import 'manage_products_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  final AuthService _authService = AuthService();
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final int totalUsers = 150;
  final int totalOrders = 89;
  final int totalCategories = 12;
  final int totalProducts = 256;

  // Design tokens
  static const _bg = Color(0xFFF7F8FA);
  static const _surface = Color(0xFFFFFFFF);
  static const _ink = Color(0xFF0D0F14);
  static const _muted = Color(0xFF8A8F9E);
  static const _accent = Color(0xFF2563EB);
  static const _accentLight = Color(0xFFEEF3FF);
  static const _divider = Color(0xFFECEDF1);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverHeader(context),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 24),
                    _buildSectionLabel('Overview'),
                    const SizedBox(height: 12),
                    _buildStatsGrid(),
                    const SizedBox(height: 32),
                    _buildSectionLabel('Management'),
                    const SizedBox(height: 12),
                    _buildManagementGroup([
                      _MenuItem(
                        Icons.people_outline,
                        'Users',
                        'View and manage all users',
                        const Color(0xFF2563EB),
                      ),
                      _MenuItem(
                        Icons.receipt_long_outlined,
                        'Orders',
                        'Track and manage orders',
                        const Color(0xFF0891B2),
                      ),
                      _MenuItem(
                        Icons.grid_view_outlined,
                        'Categories',
                        'Add, edit, remove categories',
                        const Color(0xFF7C3AED),
                      ),
                      _MenuItem(
                        Icons.inventory_2_outlined,
                        'Products',
                        'Add, edit, remove products',
                        const Color(0xFF059669),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildManagementGroup([
                      _MenuItem(
                        Icons.campaign_outlined,
                        'Announcements',
                        'Create and manage announcements',
                        const Color(0xFFD97706),
                      ),
                      _MenuItem(
                        Icons.notifications_outlined,
                        'Notifications',
                        'Send and manage notifications',
                        const Color(0xFFDB2777),
                      ),
                      _MenuItem(
                        Icons.view_carousel_outlined,
                        'Carousels',
                        'Manage homepage carousels',
                        const Color(0xFF0D9488),
                      ),
                      _MenuItem(
                        Icons.tune_outlined,
                        'Settings',
                        'App and admin settings',
                        const Color(0xFF6B7280),
                      ),
                    ]),
                    const SizedBox(height: 32),
                    _buildLogoutButton(),
                    const SizedBox(height: 32),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        color: _surface,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar / logo mark
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                    letterSpacing: -0.4,
                  ),
                ),
                Text(
                  'Dashboard',
                  style: TextStyle(
                    fontSize: 12,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _HeaderBadge(label: 'Live', color: const Color(0xFF22C55E)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: _muted,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      _StatData(
        'Users',
        totalUsers,
        Icons.people_outline,
        const Color(0xFF2563EB),
        const Color(0xFFEEF3FF),
      ),
      _StatData(
        'Orders',
        totalOrders,
        Icons.receipt_long_outlined,
        const Color(0xFF0891B2),
        const Color(0xFFECFEFF),
      ),
      _StatData(
        'Categories',
        totalCategories,
        Icons.grid_view_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF5F3FF),
      ),
      _StatData(
        'Products',
        totalProducts,
        Icons.inventory_2_outlined,
        const Color(0xFF059669),
        const Color(0xFFECFDF5),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.55,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => _StatCard(data: stats[i]),
    );
  }

  Widget _buildManagementGroup(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuRow(item: items[i]),
              if (!isLast)
                const Divider(height: 1, indent: 56, color: _divider),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _signOut,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFECACA), width: 1),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out',
              style: TextStyle(
                color: Color(0xFFDC2626),
                fontWeight: FontWeight.w600,
                fontSize: 15,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
      }
    }
  }
}

// ── Sub-widgets ────────────────────────────────────────────────

class _StatData {
  const _StatData(this.label, this.value, this.icon, this.color, this.bgColor);
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bgColor;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: data.bgColor,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(data.icon, color: data.color, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value.toString(),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0D0F14),
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF8A8F9E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem(this.icon, this.title, this.subtitle, this.color);
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.item});
  final _MenuItem item;

  @override
  State<_MenuRow> createState() => _MenuRowState();
}

class _MenuRowState extends State<_MenuRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: () {
        if (widget.item.title == 'Users') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
          );
        } else if (widget.item.title == 'Categories') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageCategoriesScreen(),
            ),
          );
        } else if (widget.item.title == 'Products') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ManageProductsScreen(),
            ),
          );
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        color: _pressed ? const Color(0xFFF7F8FA) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: widget.item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(widget.item.icon, color: widget.item.color, size: 17),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: Color(0xFF0D0F14),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.item.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8A8F9E),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(0xFFCBCDD6),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderBadge extends StatelessWidget {
  const _HeaderBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
