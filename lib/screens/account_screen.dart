import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';

// ─────────────────────────────────────────────
//  Design Tokens
// ─────────────────────────────────────────────
class _T {
  static const bg = Color(0xFFF4F6FB);
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF0E1117);
  static const subtext = Color(0xFF6C7589);
  static const border = Color(0xFFE8EBF3);
  static const hero1 = Color(0xFF1A1F36);
  static const hero2 = Color(0xFF2B3780);

  static const blue = Color(0xFF4361EE);
  static const cyan = Color(0xFF06B6D4);
  static const violet = Color(0xFF8B5CF6);
  static const green = Color(0xFF10B981);
  static const amber = Color(0xFFF59E0B);
  static const rose = Color(0xFFF43F5E);
  static const teal = Color(0xFF14B8A6);
  static const slate = Color(0xFF64748B);

  static TextStyle poppins({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = ink,
    double spacing = 0,
    double? height,
  }) => GoogleFonts.poppins(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: spacing,
    height: height,
  );
}

// ─────────────────────────────────────────────
//  Screen
// ─────────────────────────────────────────────
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen>
    with TickerProviderStateMixin {
  final AuthService _authService = AuthService();

  late final AnimationController _masterCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  Animation<double> _stagger(double start, double end) => CurvedAnimation(
    parent: _masterCtrl,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  late final Animation<double> _headerAnim = _stagger(0.0, 0.45);
  late final Animation<double> _statsAnim = _stagger(0.2, 0.65);
  late final Animation<double> _menuAnim = _stagger(0.4, 0.85);
  late final Animation<double> _footerAnim = _stagger(0.6, 1.0);

  final int totalUsers = 150;
  final int totalOrders = 89;
  final int totalCategories = 12;
  final int totalProducts = 256;

  @override
  void dispose() {
    _masterCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: _T.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: _FadeSlide(animation: _headerAnim, child: _buildHeader()),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 28),

                _FadeSlide(animation: _statsAnim, child: _buildStatsGrid()),

                const SizedBox(height: 32),

                _FadeSlide(
                  animation: _menuAnim,
                  child: _buildSectionHeader('Core Management'),
                ),
                const SizedBox(height: 12),
                _FadeSlide(
                  animation: _menuAnim,
                  child: _buildGroup([
                    _MenuEntry(
                      icon: Icons.supervised_user_circle_rounded,
                      label: 'Users',
                      sub: 'Manage accounts & roles',
                      color: _T.blue,
                    ),
                    _MenuEntry(
                      icon: Icons.receipt_long_rounded,
                      label: 'Orders',
                      sub: 'Track & fulfill orders',
                      color: _T.cyan,
                    ),
                    _MenuEntry(
                      icon: Icons.category_rounded,
                      label: 'Categories',
                      sub: 'Organise product tree',
                      color: _T.violet,
                    ),
                    _MenuEntry(
                      icon: Icons.storefront_rounded,
                      label: 'Products',
                      sub: 'Inventory & listings',
                      color: _T.green,
                    ),
                  ]),
                ),

                const SizedBox(height: 20),

                _FadeSlide(
                  animation: _menuAnim,
                  child: _buildSectionHeader('Content & Settings'),
                ),
                const SizedBox(height: 12),
                _FadeSlide(
                  animation: _menuAnim,
                  child: _buildGroup([
                    _MenuEntry(
                      icon: Icons.spatial_audio_off_rounded,
                      label: 'Announcements',
                      sub: 'Publish platform-wide alerts',
                      color: _T.amber,
                    ),
                    _MenuEntry(
                      icon: Icons.notifications_active_rounded,
                      label: 'Notifications',
                      sub: 'Push & in-app messages',
                      color: _T.rose,
                    ),
                    _MenuEntry(
                      icon: Icons.burst_mode_rounded,
                      label: 'Carousels',
                      sub: 'Homepage hero banners',
                      color: _T.teal,
                    ),
                    _MenuEntry(
                      icon: Icons.tune_rounded,
                      label: 'Settings',
                      sub: 'App configuration',
                      color: _T.slate,
                    ),
                  ]),
                ),

                const SizedBox(height: 32),

                _FadeSlide(animation: _footerAnim, child: _buildLogout()),

                const SizedBox(height: 36),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ───────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_T.hero1, _T.hero2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 13),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Console',
                        style: _T.poppins(
                          size: 17,
                          weight: FontWeight.w700,
                          color: Colors.white,
                          spacing: -0.3,
                        ),
                      ),
                      Text(
                        'Full system access',
                        style: _T.poppins(
                          size: 12,
                          color: Colors.white.withOpacity(0.55),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF22C55E).withOpacity(0.35),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Live',
                          style: _T.poppins(
                            size: 11,
                            weight: FontWeight.w600,
                            color: const Color(0xFF4ADE80),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                'Good morning 👋',
                style: _T.poppins(
                  size: 13,
                  color: Colors.white.withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Dashboard Overview',
                style: _T.poppins(
                  size: 27,
                  weight: FontWeight.w700,
                  color: Colors.white,
                  spacing: -0.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats Grid ───────────────────────────────────────────────
  Widget _buildStatsGrid() {
    final stats = [
      _StatData(
        'Total Users',
        totalUsers,
        Icons.supervised_user_circle_rounded,
        _T.blue,
        const Color(0xFFEEF2FF),
      ),
      _StatData(
        'Total Orders',
        totalOrders,
        Icons.receipt_long_rounded,
        _T.cyan,
        const Color(0xFFECFEFF),
      ),
      _StatData(
        'Categories',
        totalCategories,
        Icons.category_rounded,
        _T.violet,
        const Color(0xFFF5F3FF),
      ),
      _StatData(
        'Total Products',
        totalProducts,
        Icons.storefront_rounded,
        _T.green,
        const Color(0xFFECFDF5),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => _StatCard(data: stats[i]),
    );
  }

  // ── Section header ───────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Text(
          title,
          style: _T.poppins(
            size: 12.5,
            weight: FontWeight.w600,
            color: _T.subtext,
            spacing: 0.1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Container(height: 1, color: _T.border)),
      ],
    );
  }

  // ── Menu group ───────────────────────────────────────────────
  Widget _buildGroup(List<_MenuEntry> entries) {
    return Container(
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _T.blue.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(entries.length, (i) {
          final last = i == entries.length - 1;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _MenuRow(entry: entries[i]),
              if (!last) Divider(height: 1, indent: 70, color: _T.border),
            ],
          );
        }),
      ),
    );
  }

  // ── Logout ───────────────────────────────────────────────────
  Widget _buildLogout() {
    return _Pressable(
      onTap: _signOut,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 17),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFECACA), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Color(0xFFDC2626),
                size: 17,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sign Out',
              style: _T.poppins(
                size: 14.5,
                weight: FontWeight.w600,
                color: const Color(0xFFDC2626),
                spacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _signOut() async {
    await _authService.signOut();
  }
}

// ─────────────────────────────────────────────
//  Stat Card
// ─────────────────────────────────────────────
class _StatData {
  const _StatData(this.label, this.value, this.icon, this.color, this.bg);
  final String label;
  final int value;
  final IconData icon;
  final Color color;
  final Color bg;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: data.color.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: data.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _T.ink,
                  letterSpacing: -1,
                  height: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                data.label,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: _T.subtext,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Menu Entry
// ─────────────────────────────────────────────
class _MenuEntry {
  const _MenuEntry({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
}

class _MenuRow extends StatefulWidget {
  const _MenuRow({required this.entry});
  final _MenuEntry entry;

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
        // TODO: Navigate to respective screens
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: _pressed ? const Color(0xFFF8FAFF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: widget.entry.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                widget.entry.icon,
                color: widget.entry.color,
                size: 21,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.entry.label,
                    style: _T.poppins(
                      size: 14,
                      weight: FontWeight.w600,
                      color: _T.ink,
                      spacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.entry.sub,
                    style: _T.poppins(size: 11.5, color: _T.subtext),
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4FD),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 12,
                color: Color(0xFFADB5C8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Animation Helpers
// ─────────────────────────────────────────────
class _FadeSlide extends StatelessWidget {
  const _FadeSlide({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (_, __) => Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, 22 * (1 - animation.value)),
          child: child,
        ),
      ),
    );
  }
}

class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: widget.child,
      ),
    );
  }
}
