import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';

/// Opens the full-page authentication flow and returns true after a successful sign-in.
Future<bool?> openAuthScreen(BuildContext context, {bool startWithSignUp = false}) {
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => AuthScreen(startWithSignUp: startWithSignUp),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.startWithSignUp = false});

  final bool startWithSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _register = widget.startWithSignUp;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final provider = context.read<AppProvider>();
      if (_register) {
        await provider.register(
          name: _name.text,
          phone: _phone.text,
          email: _email.text,
          password: _password.text,
        );
      } else {
        await provider.login(_phone.text, _password.text);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateIdentifier(String? value) {
    final input = (value ?? '').trim();
    if (input.isEmpty) return 'Nhập số điện thoại hoặc email';
    if (input.contains('@')) {
      return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input)
          ? null
          : 'Email chưa đúng định dạng';
    }
    return input.replaceAll(RegExp(r'\D'), '').length >= 9
        ? null
        : 'Số điện thoại chưa đúng định dạng';
  }

  void _switchMode() {
    setState(() {
      _register = !_register;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 760;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -65,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withOpacity(.55),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -70,
              child: Container(
                width: 270,
                height: 270,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9D5).withOpacity(.65),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Quay lại',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: isWide ? 900 : 460),
                        child: isWide
                            ? Row(
                                children: [
                                  Expanded(child: _buildWelcomePanel()),
                                  const SizedBox(width: 36),
                                  SizedBox(width: 420, child: _buildFormCard()),
                                ],
                              )
                            : _buildFormCard(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePanel() => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.restaurant_menu_rounded,
                  color: Colors.white, size: 31),
            ),
            const SizedBox(height: 28),
            const Text(
              'Hương vị yêu thích,\nluôn ở bên bạn.',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 36,
                height: 1.15,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Đăng nhập MAXKO để đặt món nhanh hơn, theo dõi đơn hàng và tích điểm thành viên.',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16, height: 1.55),
            ),
          ],
        ),
      );

  Widget _buildFormCard() => Container(
        padding: const EdgeInsets.all(26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1B1C1A).withOpacity(.07),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _register ? 'Tạo tài khoản' : 'Chào mừng trở lại',
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _register
                    ? 'Tham gia MAXKO Club để nhận ưu đãi thành viên.'
                    : 'Đăng nhập để tiếp tục trải nghiệm MAXKO.',
                style: const TextStyle(color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              if (_register) ...[
                _field(
                  controller: _name,
                  label: 'Họ và tên',
                  icon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) => (value ?? '').trim().length < 2
                      ? 'Vui lòng nhập họ tên'
                      : null,
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                          .hasMatch((value ?? '').trim())
                      ? null
                      : 'Nhập email hợp lệ',
                ),
                const SizedBox(height: 14),
                _field(
                  controller: _phone,
                  label: 'Số điện thoại',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) => (value ?? '').replaceAll(RegExp(r'\D'), '').length >= 9
                      ? null
                      : 'Nhập số điện thoại hợp lệ',
                ),
              ] else
                _field(
                  controller: _phone,
                  label: 'Số điện thoại hoặc email',
                  icon: Icons.person_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateIdentifier,
                  onSubmitted: (_) => _submit(),
                ),
              const SizedBox(height: 14),
              _field(
                controller: _password,
                label: 'Mật khẩu',
                icon: Icons.lock_outline_rounded,
                obscureText: _hidePassword,
                suffixIcon: IconButton(
                  tooltip: _hidePassword ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                  onPressed: () => setState(() => _hidePassword = !_hidePassword),
                  icon: Icon(_hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                ),
                validator: (value) => (value ?? '').length < 6
                    ? 'Mật khẩu cần ít nhất 6 ký tự'
                    : null,
                onSubmitted: (_) => _submit(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF1F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_error!,
                            style: const TextStyle(color: Colors.red, fontSize: 13)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 22),
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _busy ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_register ? 'Tạo tài khoản' : 'Đăng nhập',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    _register ? 'Bạn đã có tài khoản?' : 'Bạn chưa có tài khoản?',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _switchMode,
                    child: Text(_register ? 'Đăng nhập' : 'Đăng ký',
                        style: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onSubmitted,
  }) => TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        obscureText: obscureText,
        onFieldSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFFFAFAF9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppColors.borderLight),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
      );
}
