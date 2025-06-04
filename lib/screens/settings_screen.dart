import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _soundEnabled = true;
  bool _hapticFeedback = true;
  String _selectedTheme = 'Cosmic Purple';
  String _selectedLanguage = 'English';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 15,
              color: Colors.deepPurple,
            ),
          ),
          
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Account'),
                  _buildAccountSection(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Notifications'),
                  _buildNotificationsSection(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Appearance'),
                  _buildAppearanceSection(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('Privacy & Security'),
                  _buildPrivacySection(),
                  
                  const SizedBox(height: 24),
                  
                  _buildSectionHeader('About'),
                  _buildAboutSection(),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: GoogleFonts.cinzel(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAccountSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.indigo.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildAccountTile(
            icon: Icons.person,
            title: 'Profile',
            subtitle: 'Edit your spiritual profile',
            onTap: () => _showComingSoon(),
          ),
          const Divider(color: Colors.white24),
          _buildAccountTile(
            icon: Icons.star,
            title: 'Subscription',
            subtitle: 'Manage your premium features',
            onTap: () => _showSubscriptionDialog(),
          ),
          const Divider(color: Colors.white24),
          _buildAccountTile(
            icon: Icons.backup,
            title: 'Sync & Backup',
            subtitle: 'Keep your data safe',
            onTap: () => _showComingSoon(),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.blue.withOpacity(0.3),
            Colors.purple.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildSwitchTile(
            icon: Icons.notifications,
            title: 'Daily Reminders',
            subtitle: 'Get gentle reminders for your spiritual practice',
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
            },
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.schedule,
            title: 'Reminder Times',
            subtitle: '9:00 AM, 6:00 PM',
            onTap: () => _showComingSoon(),
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.auto_awesome,
            title: 'Moon Phase Alerts',
            subtitle: 'Notifications for new moon phases',
            onTap: () => _showComingSoon(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.3),
            Colors.teal.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildDropdownTile(
            icon: Icons.palette,
            title: 'Theme',
            subtitle: _selectedTheme,
            items: ['Cosmic Purple', 'Mystic Blue', 'Forest Green', 'Ruby Red'],
            onChanged: (value) {
              setState(() {
                _selectedTheme = value!;
              });
            },
          ),
          const Divider(color: Colors.white24),
          _buildSwitchTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Easy on the eyes for nighttime meditation',
            value: _darkModeEnabled,
            onChanged: (value) {
              setState(() {
                _darkModeEnabled = value;
              });
            },
          ),
          const Divider(color: Colors.white24),
          _buildSwitchTile(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            subtitle: 'Mystical sounds and chimes',
            value: _soundEnabled,
            onChanged: (value) {
              setState(() {
                _soundEnabled = value;
              });
            },
          ),
          const Divider(color: Colors.white24),
          _buildSwitchTile(
            icon: Icons.vibration,
            title: 'Haptic Feedback',
            subtitle: 'Gentle vibrations for interactions',
            value: _hapticFeedback,
            onChanged: (value) {
              setState(() {
                _hapticFeedback = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.3),
            Colors.red.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildTile(
            icon: Icons.security,
            title: 'Privacy Policy',
            subtitle: 'How we protect your spiritual data',
            onTap: () => _showComingSoon(),
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.lock,
            title: 'Data Encryption',
            subtitle: 'Your birth chart and personal info are secure',
            onTap: () => _showComingSoon(),
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.delete_forever,
            title: 'Delete Account',
            subtitle: 'Permanently remove all your data',
            onTap: () => _showDeleteAccountDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.pink.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          _buildTile(
            icon: Icons.info,
            title: 'App Version',
            subtitle: 'Crystal Grimoire Beta 0.2',
            onTap: () {},
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.help,
            title: 'Help & Support',
            subtitle: 'Get help with your spiritual journey',
            onTap: () => _showComingSoon(),
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.rate_review,
            title: 'Rate the App',
            subtitle: 'Share your experience with others',
            onTap: () => _showComingSoon(),
          ),
          const Divider(color: Colors.white24),
          _buildTile(
            icon: Icons.group,
            title: 'Community',
            subtitle: 'Connect with fellow crystal enthusiasts',
            onTap: () => _showComingSoon(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.crimsonText(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.crimsonText(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.crimsonText(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.purple,
        activeTrackColor: Colors.purple.withOpacity(0.3),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(
        title,
        style: GoogleFonts.cinzel(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.crimsonText(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      trailing: DropdownButton<String>(
        value: subtitle,
        dropdownColor: const Color(0xFF1A1A3A),
        style: GoogleFonts.cinzel(color: Colors.white),
        underline: Container(),
        icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: onChanged,
      ),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showComingSoon() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.purple),
        ),
        title: Text(
          'Coming Soon',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This feature is coming in a future update. Stay tuned!',
          style: GoogleFonts.crimsonText(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.cinzel(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.purple),
        ),
        title: Text(
          'Subscription Status',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Plan: Free',
              style: GoogleFonts.crimsonText(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Usage this month:\n• Crystal IDs: 3/5\n• Collection: 2/5 crystals',
              style: GoogleFonts.crimsonText(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Premium for:\n• 30 IDs per day\n• Unlimited crystal collection\n• Marketplace selling\n• Priority support',
              style: GoogleFonts.crimsonText(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Maybe Later',
              style: GoogleFonts.cinzel(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Upgrade',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.red),
        ),
        title: Text(
          'Delete Account',
          style: GoogleFonts.cinzel(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and will permanently remove all your data including your crystal collection, journal entries, and spiritual profile.',
          style: GoogleFonts.crimsonText(
            color: Colors.white70,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.cinzel(
                color: Colors.white54,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}