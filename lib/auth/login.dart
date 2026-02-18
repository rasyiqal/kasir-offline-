import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'database.dart';

class LoginPopup extends StatefulWidget {
  const LoginPopup({super.key});

  @override
  State<LoginPopup> createState() => _LoginPopupState();
}

class _LoginPopupState extends State<LoginPopup> {
  final TextEditingController _pinController = TextEditingController();
  final FocusNode _pinFocusNode = FocusNode();
  String _errorMessage = "";

  @override
  void dispose() {
    _pinController.dispose();
    _pinFocusNode.dispose();
    super.dispose();
  }

  // --- UI HELPER ---
  PinTheme _getPinTheme({bool isError = false}) {
    return PinTheme(
      width: 45,
      height: 50,
      textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      decoration: BoxDecoration(
        color: isError
            ? Colors.red.shade50
            : Colors.grey.shade50, // Samakan dengan Reset PIN
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? Colors.red.withOpacity(0.5) : Colors.grey.shade300,
          width: 1.5,
        ),
      ),
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _errorMessage = "");
      }
    });
  }

  // --- LOGIC ---
  Future<void> _prosesLogin(String pin) async {
    if (pin.length < 6) {
      _showError("PIN harus 6 digit");
      return;
    }

    final isValid = await AppDatabase.validatePin(pin);
    if (isValid) {
      if (!mounted) return;
      Navigator.pop(context, true);
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/dashboard',
        (route) => false,
      );
    } else {
      _pinController.clear();
      _pinFocusNode.requestFocus();
      _showError("PIN salah, silakan coba lagi");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 360,
          ), 
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.blue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Keamanan PIN",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Masukkan 6 digit PIN pengelola",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),

              const SizedBox(height: 8),

              SizedBox(
                height: 32,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _errorMessage.isNotEmpty
                      ? Container(
                          key: ValueKey(_errorMessage),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
              ),

              const SizedBox(height: 8),

              // Pinput Field
              Pinput(
                length: 6,
                controller: _pinController,
                focusNode: _pinFocusNode,
                obscureText: true,
                autofocus: true,
                defaultPinTheme: _getPinTheme(
                  isError: _errorMessage.isNotEmpty,
                ),
                focusedPinTheme: _getPinTheme().copyWith(
                  decoration: _getPinTheme().decoration!.copyWith(
                    border: Border.all(color: Colors.blue, width: 2),
                  ),
                ),
                onCompleted: _prosesLogin,
              ),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context, "reset"),
                  child: const Text(
                    "Lupa PIN?",
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Action Buttons Samakan dengan Reset PIN
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text("Batal"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _prosesLogin(_pinController.text),
                      child: const Text(
                        "MASUK",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
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
