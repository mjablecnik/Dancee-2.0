import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';

class AuthorContactScreen extends StatefulWidget {
  const AuthorContactScreen({super.key});

  @override
  State<AuthorContactScreen> createState() => _AuthorContactScreenState();
}

class _AuthorContactScreenState extends State<AuthorContactScreen> {
  String _selectedSubject = '';
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _emailController =
      TextEditingController(text: 'tereza.novakova@email.cz');

  bool _isLoading = false;
  bool _isSent = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _isSent = false;
    });
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() {
      _isLoading = false;
      _isSent = true;
    });
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _isSent = false;
      });
    }
  }

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
                left: 20,
                right: 20,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAuthorInfo(),
                  const SizedBox(height: 24),
                  _buildContactForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xE60F172A),
        border: Border(bottom: BorderSide(color: appBorder)),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
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
                shape: BoxShape.circle,
              ),
              child: const Icon(FontAwesomeIcons.arrowLeft,
                  color: appText, size: 16),
            ),
          ),
          const Text(
            'Napsat autorovi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: appText,
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Container(
      decoration: BoxDecoration(
        color: appSurface,
        border: Border.all(color: appBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [appPrimary, appAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(FontAwesomeIcons.user,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tým Dancee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: appText,
                    ),
                  ),
                  Text(
                    'hello@dancee.app',
                    style: TextStyle(fontSize: 14, color: appMuted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Rádi si přečteme vaše zpětné vazby, návrhy na vylepšení nebo nahlášení problémů. Odpovíme vám co nejdříve!',
            style: TextStyle(fontSize: 14, color: appMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subject selection
        const Text(
          'Předmět zprávy',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appText,
          ),
        ),
        const SizedBox(height: 8),
        _buildSubjectOption('feedback', FontAwesomeIcons.comment,
            const Color(0xFF3B82F6), 'Zpětná vazba'),
        const SizedBox(height: 8),
        _buildSubjectOption('bug', FontAwesomeIcons.bug,
            const Color(0xFFEF4444), 'Nahlásit problém'),
        const SizedBox(height: 8),
        _buildSubjectOption('feature', FontAwesomeIcons.lightbulb,
            const Color(0xFFEAB308), 'Návrh na vylepšení'),
        const SizedBox(height: 8),
        _buildSubjectOption(
            'other', FontAwesomeIcons.question, appMuted, 'Ostatní'),
        const SizedBox(height: 16),

        // Message title
        const Text(
          'Název zprávy',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          style: const TextStyle(color: appText),
          decoration: InputDecoration(
            hintText: 'Stručně popište váš problém nebo návrh',
            hintStyle: const TextStyle(color: appMuted),
            filled: true,
            fillColor: appSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appPrimary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Message content
        const Text(
          'Zpráva',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _messageController,
          maxLines: 6,
          style: const TextStyle(color: appText),
          decoration: InputDecoration(
            hintText:
                'Podrobně popište váš problém, návrh nebo zpětnou vazbu. Pokud hlásíte problém, uveďte prosím kroky jak ho reprodukovat.',
            hintStyle: const TextStyle(color: appMuted),
            filled: true,
            fillColor: appSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appPrimary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        // Device info card
        Container(
          decoration: BoxDecoration(
            color: appSurface,
            border: Border.all(color: appBorder),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(FontAwesomeIcons.mobileScreen,
                      color: appMuted, size: 14),
                  const SizedBox(width: 8),
                  const Text(
                    'Informace o zařízení',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: appText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: appPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Automaticky přiloženo',
                      style: TextStyle(
                        fontSize: 12,
                        color: appPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildDeviceInfoRow('Aplikace:', 'Dancee v1.2.5'),
              const SizedBox(height: 8),
              _buildDeviceInfoRow('Zařízení:', 'iPhone 14 Pro'),
              const SizedBox(height: 8),
              _buildDeviceInfoRow('Systém:', 'iOS 17.2'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Email for response
        const Text(
          'Váš e-mail pro odpověď',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: appText,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: appText),
          decoration: InputDecoration(
            filled: true,
            fillColor: appSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: appPrimary, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),

        // Submit button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (_isLoading || _isSent) ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _isSent ? const Color(0xFF16A34A) : appPrimary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              disabledBackgroundColor:
                  _isSent ? const Color(0xFF16A34A) : appPrimary.withValues(alpha: 0.7),
              disabledForegroundColor: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                else if (_isSent)
                  const Icon(FontAwesomeIcons.check, size: 16)
                else
                  const Icon(FontAwesomeIcons.paperPlane, size: 16),
                const SizedBox(width: 8),
                Text(
                  _isLoading
                      ? 'Odesílání...'
                      : _isSent
                          ? 'Odesláno!'
                          : 'Odeslat zprávu',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Response time info
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
            border: Border.all(
                color: const Color(0xFF3B82F6).withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(FontAwesomeIcons.circleInfo,
                    color: Color(0xFF60A5FA), size: 14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Doba odezvy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF93C5FD),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Obvykle odpovídáme do 24 hodin v pracovní dny. Děkujeme za trpělivost!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF60A5FA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectOption(
      String value, IconData icon, Color iconColor, String label) {
    final isSelected = _selectedSubject == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedSubject = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: appSurface,
          border: Border.all(
            color: isSelected ? appPrimary : appBorder,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: Radio<String>(
                value: value,
                groupValue: _selectedSubject,
                onChanged: (v) => setState(() => _selectedSubject = v ?? ''),
                activeColor: appPrimary,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: iconColor, size: 14),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 14, color: appText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: appMuted)),
        Text(value, style: const TextStyle(fontSize: 12, color: appMuted)),
      ],
    );
  }
}
