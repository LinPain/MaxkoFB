import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/app_colors.dart';
import '../providers/app_provider.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _register = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _busy = true; _error = null; });
    try {
      final provider = context.read<AppProvider>();
      if (_register) {
        await provider.register(name: _name.text, phone: _phone.text, email: _email.text, password: _password.text);
      } else {
        await provider.login(_phone.text, _password.text);
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(_register ? 'Tạo tài khoản MAXKO' : 'Đăng nhập MAXKO'),
        content: SizedBox(
          width: 360,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                if (_register) ...[
                  TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Họ và tên'), validator: (v) => (v ?? '').trim().isEmpty ? 'Nhập họ tên' : null),
                  TextFormField(controller: _email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v ?? '').contains('@') ? null : 'Nhập email hợp lệ'),
                ],
                TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Số điện thoại'), validator: (v) => (v ?? '').trim().length < 9 ? 'Nhập số điện thoại hợp lệ' : null),
                TextFormField(controller: _password, obscureText: true, decoration: const InputDecoration(labelText: 'Mật khẩu'), validator: (v) => (v ?? '').length < 6 ? 'Mật khẩu cần ít nhất 6 ký tự' : null),
                if (_error != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12))),
                TextButton(onPressed: _busy ? null : () => setState(() { _register = !_register; _error = null; }), child: Text(_register ? 'Đã có tài khoản? Đăng nhập' : 'Chưa có tài khoản? Đăng ký')),
              ]),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Đóng')),
          FilledButton(onPressed: _busy ? null : _submit, style: FilledButton.styleFrom(backgroundColor: AppColors.primary), child: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(_register ? 'Đăng ký' : 'Đăng nhập')),
        ],
      );
}
