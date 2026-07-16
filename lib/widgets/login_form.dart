// login_form.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nssapp/global/global_auth_helper.dart';
import 'package:nssapp/utils/routes.dart';
import 'package:nssapp/utils/authenticator.dart';
import 'package:nssapp/services/api_service.dart';

const Color _kBrand = Color(0xFF1A3B5A);
const Color _kInk = Color(0xFF0F172A);
const Color _kMuted = Color(0xFF6C757D);

// Roboto Flex helper — one place to tweak the family/weight.
TextStyle rf({
  double? fontSize,
  FontWeight fontWeight = FontWeight.w300,
  Color? color,
  double? letterSpacing,
  double? height,
}) =>
    GoogleFonts.robotoFlex(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
    );

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final AuthService _authService = AuthService();
  final TextEditingController rollController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _passwordFocus = FocusNode();

  bool _isAA = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    rollController.dispose();
    passwordController.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> loginUser() async {
    if (_loading) return;
    if (rollController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _snack("Please fill in all fields.");
      return;
    }

    setState(() => _loading = true);

    final reqBody = {
      "roll": rollController.text.trim(),
      "password": passwordController.text,
      "isaa": _isAA,
    };

    try {
      final response = await ApiService.login(reqBody);
      final jsonResponse = jsonDecode(response.body);
      if (jsonResponse['status'] == true) {
        await _authService.saveToken(
          jsonResponse['userData'],
          jsonResponse['token'],
        );
        await GlobalAuthHelper.fetchToken();
        rollController.clear();
        passwordController.clear();
        if (mounted) {
          Navigator.popAndPushNamed(context, Routes.homeRoute);
        }
      } else {
        _snack(jsonResponse['message'] ?? "Something went wrong.");
      }
    } catch (_) {
      _snack("Couldn't reach the server. Please try again.");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PillField(
            controller: rollController,
            hintText: 'Roll number',
            prefixIcon: Icons.person_outline,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              LengthLimitingTextInputFormatter(10),
            ],
            onSubmitted: (_) => _passwordFocus.requestFocus(),
          ),
          const SizedBox(height: 16),
          PillField(
            controller: passwordController,
            focusNode: _passwordFocus,
            hintText: 'Password',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            onSubmitted: (_) => loginUser(),
            suffix: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: _kMuted,
                size: 20,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => setState(() => _isAA = !_isAA),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _isAA,
                          onChanged: (v) => setState(() => _isAA = v ?? false),
                          activeColor: _kBrand,
                          checkColor: Colors.white,
                          side: const BorderSide(
                              color: Color(0xFFCED4DA), width: 1.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Are you an AA?',
                        style: rf(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _kInk,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () =>
                    Navigator.pushNamed(context, Routes.forgotPassword),
                child: Text(
                  'Forgot password?',
                  style: rf(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _kBrand,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          PillButton(
            label: 'Sign In',
            loading: _loading,
            onPressed: loginUser,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Segmented Sign In / Sign Up switcher used at the top of auth screens.
// ============================================================================
enum AuthTab { signIn, signUp }

class AuthTabs extends StatelessWidget {
  final AuthTab selected;
  final ValueChanged<AuthTab>? onChanged;
  const AuthTabs({super.key, required this.selected, this.onChanged});

  void _switchTo(BuildContext context, AuthTab target) {
    if (target == selected) return;
    if (onChanged != null) {
      onChanged!(target);
      return;
    }
    if (target == AuthTab.signIn) {
      Navigator.pushReplacementNamed(context, Routes.loginRoute);
    } else {
      Navigator.pushReplacementNamed(context, Routes.signUpRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF3),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Row(
        children: [
          Expanded(
            child: _tab(
              context,
              'Sign In',
              selected: selected == AuthTab.signIn,
              target: AuthTab.signIn,
            ),
          ),
          Expanded(
            child: _tab(
              context,
              'Sign Up',
              selected: selected == AuthTab.signUp,
              target: AuthTab.signUp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(
    BuildContext context,
    String label, {
    required bool selected,
    required AuthTab target,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _switchTo(context, target),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x141A3B5A),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: rf(
            fontSize: 15,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? _kInk : _kMuted,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// Shared UI primitives — pill field, pill button, brand wordmark.
// ============================================================================
class PillField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool enabled;

  const PillField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.focusNode,
    this.autofillHints,
    this.inputFormatters,
    this.onSubmitted,
    this.errorText,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: enabled ? Colors.white : const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(32),
            boxShadow: enabled
                ? const [
                    BoxShadow(
                      color: Color(0x0F1A3B5A),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: enabled,
            obscureText: obscureText,
            keyboardType: keyboardType,
            textInputAction: textInputAction,
            autofillHints: autofillHints,
            inputFormatters: inputFormatters,
            onSubmitted: onSubmitted,
            style: rf(fontSize: 15, fontWeight: FontWeight.w400, color: _kInk),
            cursorColor: _kBrand,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: rf(
                fontSize: 15,
                fontWeight: FontWeight.w300,
                color: _kMuted,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 18, right: 12),
                child: Icon(prefixIcon, size: 20, color: _kMuted),
              ),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 0, minHeight: 0),
              suffixIcon: suffix == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: suffix,
                    ),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 18),
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 6),
            child: Text(
              errorText!,
              style: rf(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFFDC2626),
              ),
            ),
          ),
      ],
    );
  }
}

class PillButton extends StatelessWidget {
  final String label;
  final bool loading;
  final VoidCallback? onPressed;
  const PillButton({
    super.key,
    required this.label,
    this.loading = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: _kBrand.withOpacity(0.28),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kBrand,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _kBrand.withOpacity(0.6),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: rf(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
        ),
      ),
    );
  }
}

// NSS logo + "NSS IIT Bombay" wordmark. All black.
class BrandWordmark extends StatelessWidget {
  final double logoSize;
  final double fontSize;
  const BrandWordmark({super.key, this.logoSize = 40, this.fontSize = 22});

  @override
  Widget build(BuildContext context) {
    return Row(
      // Shrink to content so parents can align (Column stretch centers it,
      // Column start left-aligns it).
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/nsslogo.png',
          width: logoSize,
          height: logoSize,
          errorBuilder: (_, __, ___) => Icon(
            Icons.volunteer_activism_outlined,
            size: logoSize * 0.72,
            color: _kInk,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'NSS IIT Bombay',
          style: rf(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: _kInk,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}
