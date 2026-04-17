import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final Map<String, bool> _dancePrefs = {
    'Salsa': true,
    'Bachata': true,
    'Zouk': true,
    'Kizomba': false,
    'Tango': false,
    'Swing': false,
  };

  String _level = 'Mírně pokročilý';

  final Map<String, bool> _notifications = {
    'Nové akce': true,
    'Připomínky akcí': true,
    'Marketingové zprávy': false,
  };

  final Map<String, String> _notificationSubtitles = {
    'Nové akce': 'Upozornění na nové taneční akce',
    'Připomínky akcí': 'Připomenout uložené akce',
    'Marketingové zprávy': 'Tipy a novinky o tancování',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 140,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfilePhoto(),
                  _buildSectionLabel('Osobní údaje'),
                  _buildPersonalInfo(),
                  _buildSectionLabel('O mně'),
                  _buildBio(),
                  _buildSectionLabel('Oblíbené tance'),
                  _buildDancePreferences(),
                  _buildSectionLabel('Úroveň'),
                  _buildExperienceLevel(),
                  _buildSectionLabel('Sociální sítě'),
                  _buildSocialLinks(),
                  _buildSectionLabel('Oznámení'),
                  _buildNotifications(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: _buildSaveButton(context),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: appBg.withValues(alpha: 0.9),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: appBorder)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appSurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.arrowLeft, size: 16, color: appText),
              ),
            ),
          ),
          const Text(
            'Upravit profil',
            style: TextStyle(
              color: appText,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: FaIcon(FontAwesomeIcons.check, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhoto() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(48),
                    border: Border.all(color: appPrimary, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(48),
                    child: Image.network(
                      'https://storage.googleapis.com/uxpilot-auth.appspot.com/avatars/avatar-5.jpg',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: appPrimary,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: appBg, width: 2),
                    ),
                    child: const Center(
                      child: FaIcon(FontAwesomeIcons.camera, size: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Změnit fotku',
            style: TextStyle(
              color: appPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: appMuted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Column(
        children: [
          _buildInputField('Jméno a příjmení', 'Tereza Nováková', TextInputType.name),
          const SizedBox(height: 16),
          _buildInputField('E-mail', 'tereza.novakova@email.cz', TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildInputField('Telefon', '+420 123 456 789', TextInputType.phone),
          const SizedBox(height: 16),
          _buildInputField('Město', 'Praha', TextInputType.text),
        ],
      ),
    );
  }

  Widget _buildInputField(String label, String value, TextInputType keyboardType) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: appMuted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: value,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: appText,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBio() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Popis',
              style: TextStyle(
                color: appMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: 'Miluji tanec a poznávání nových lidí. Tancuji už 5 let a stále se učím nové styly.',
              maxLines: 3,
              style: const TextStyle(color: appText),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
                hintText: 'Napište něco o sobě...',
                hintStyle: TextStyle(color: appMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDancePreferences() {
    final dances = _dancePrefs.keys.toList();
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vyberte své oblíbené tanční styly',
              style: TextStyle(
                color: appMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: dances.map((dance) {
                return GestureDetector(
                  onTap: () => setState(() => _dancePrefs[dance] = !_dancePrefs[dance]!),
                  child: Row(
                    children: [
                      _buildCheckbox(_dancePrefs[dance]!),
                      const SizedBox(width: 12),
                      Text(
                        dance,
                        style: const TextStyle(color: appText, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(bool checked) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? appPrimary : Colors.transparent,
        border: Border.all(
          color: checked ? appPrimary : appBorder,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: checked
          ? const Center(
              child: FaIcon(FontAwesomeIcons.check, size: 10, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildExperienceLevel() {
    final levels = ['Začátečník', 'Mírně pokročilý', 'Pokročilý', 'Expert'];
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vaše taneční úroveň',
              style: TextStyle(
                color: appMuted,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ...levels.map((level) {
              final selected = _level == level;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () => setState(() => _level = level),
                  child: Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected ? appPrimary : appBorder,
                            width: 2,
                          ),
                        ),
                        child: selected
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: appPrimary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        level,
                        style: const TextStyle(color: appText, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instagram',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.instagram, size: 16, color: appMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: appText),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: '@vase_uzivatelske_jmeno',
                          hintStyle: TextStyle(color: appMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: appSurface,
              border: Border.all(color: appBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Facebook',
                  style: TextStyle(
                    color: appMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const FaIcon(FontAwesomeIcons.facebook, size: 16, color: appMuted),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        style: const TextStyle(color: appText),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'facebook.com/vase.jmeno',
                          hintStyle: TextStyle(color: appMuted),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotifications() {
    final keys = _notifications.keys.toList();
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: Container(
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(color: appBorder),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: keys.asMap().entries.map((entry) {
            final i = entry.key;
            final key = entry.value;
            return Column(
              children: [
                if (i > 0)
                  const Divider(height: 1, color: appBorder),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              key,
                              style: const TextStyle(
                                color: appText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _notificationSubtitles[key]!,
                              style: const TextStyle(
                                color: appMuted,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _notifications[key]!,
                        onChanged: (val) => setState(() => _notifications[key] = val),
                        activeColor: appPrimary,
                        inactiveTrackColor: appBorder,
                        inactiveThumbColor: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
      color: appBg,
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 80,
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => context.pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: appPrimary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: const Text(
            'Uložit změny',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: appCard,
        border: Border(top: BorderSide(color: appBorder)),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navItem(context, FontAwesomeIcons.house, 'Domů', false, '/events'),
          _navItem(context, FontAwesomeIcons.magnifyingGlass, 'Hledat', false, '/events'),
          _navFab(context),
          _navItem(context, FontAwesomeIcons.heart, 'Uložené', false, '/events'),
          _navItem(context, FontAwesomeIcons.user, 'Profil', true, '/profile'),
        ],
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FaIcon(icon, size: 20, color: active ? appPrimary : appMuted),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: active ? appPrimary : appMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navFab(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: appPrimary,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: appBg, width: 4),
          boxShadow: [
            BoxShadow(
              color: appPrimary.withValues(alpha: 0.5),
              blurRadius: 20,
              spreadRadius: -5,
            ),
          ],
        ),
        child: const Center(
          child: FaIcon(FontAwesomeIcons.plus, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}
