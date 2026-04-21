import 'package:carex/User/Profile/userStore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carex/role/selectRole.dart';
import 'package:carex/authentication/login.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/services/app_session.dart';
import 'package:carex/controllers/auth_controller.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool isLoading = false;
  bool _hasNavigatedToRole = false;
  bool _isVerifyingOtp = false;
  bool _isCheckingRegistered = false;

  String? nameError;
  String? phoneError;
  String? otpError;

  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kPrimaryTextOnButton = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const String kFont = 'Sarabun';

  String _toE164TH(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+66')) return cleaned;
    if (cleaned.startsWith('0') && cleaned.length == 10) {
      return '+66${cleaned.substring(1)}';
    }
    return cleaned;
  }

  String _toLocalTH(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleaned.startsWith('+66')) {
      return '0${cleaned.substring(3)}';
    }
    return cleaned;
  }

  Future<bool> _isAlreadyRegistered(String firebaseUid, String phone) async {
    try {
      final result = await AuthController.loginUser(
        firebaseUid: firebaseUid,
        phone: phone,
      );
      return result.success;
    } catch (_) {
      return false;
    }
  }

  Future<void> _handleAlreadyRegistered() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      isLoading = false;
      phoneError = 'เบอร์โทรศัพท์นี้ได้ทำการลงทะเบียนแล้ว';
    });
  }

  Future<void> _goToSelectRole({
    required String name,
    required String phone,
    required String firebaseUid,
  }) async {
    if (_hasNavigatedToRole || !mounted) return;
    _hasNavigatedToRole = true;
    await AppSession.savePendingRegistration(
      name: name,
      phone: phone,
      firebaseUid: firebaseUid,
    );
    await UserStore.save(UserData(fullName: name, phone: phone));
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => selectRole(
          fullName: name,
          phone: phone,
          firebaseUid: firebaseUid,
        ),
      ),
    );
  }

  Future<void> _afterOtpVerified({
    required String name,
    required String phone,
    required String firebaseUid,
  }) async {
    if (_isCheckingRegistered) return;
    _isCheckingRegistered = true;
    try {
      final alreadyRegistered = await _isAlreadyRegistered(firebaseUid, phone);
      if (alreadyRegistered) {
        await _handleAlreadyRegistered();
        return;
      }
      if (!mounted) return;
      await _goToSelectRole(
        name: name,
        phone: phone,
        firebaseUid: firebaseUid,
      );
    } finally {
      _isCheckingRegistered = false;
    }
  }

  Future<void> register() async {
    final String name = nameController.text.trim();
    final String phone = _toLocalTH(phoneController.text.trim());
    setState(() {
      nameError = null;
      phoneError = null;
    });
    bool isValid = true;
    if (name.isEmpty) {
      nameError = "กรุณากรอกชื่อ - นามสกุล";
      isValid = false;
    }
    if (phone.isEmpty) {
      phoneError = "กรุณากรอกเบอร์โทรศัพท์";
      isValid = false;
    } else if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      phoneError = "กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง";
      isValid = false;
    }
    if (!isValid) return;
    _hasNavigatedToRole = false;
    _isVerifyingOtp = false;
    _isCheckingRegistered = false;
    setState(() {
      isLoading = true;
    });
    try {
      final auth = FirebaseAuth.instance;
      await auth.verifyPhoneNumber(
        phoneNumber: _toE164TH(phone),
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await auth.signInWithCredential(credential);
            final firebaseUid = userCredential.user?.uid ?? '';
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
            await _afterOtpVerified(
              name: name,
              phone: phone,
              firebaseUid: firebaseUid,
            );
          } catch (_) {
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          setState(() {
            isLoading = false;
            phoneError = e.message ?? "เกิดข้อผิดพลาดในการส่ง OTP";
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId = verificationId;
          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
          showOtpDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId = verificationId;
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        phoneError = "เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง";
      });
    }
  }

  void showOtpDialog() {
    otpController.clear();
    setState(() {
      otpError = null;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: kBackground,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "กรอกรหัส OTP",
                style: TextStyle(
                  color: kText,
                  fontWeight: FontWeight.w600,
                  fontFamily: kFont,
                ),
              ),
              content: TextField(
                controller: otpController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(
                  color: kText,
                  fontFamily: kFont,
                ),
                onChanged: (_) {
                  if (otpError != null) {
                    setDialogState(() {
                      otpError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "OTP 6 หลัก",
                  hintStyle: const TextStyle(
                    color: kText,
                    fontFamily: kFont,
                  ),
                  errorText: otpError,
                  errorStyle: const TextStyle(fontFamily: kFont),
                  counterText: "",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kPrimary),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: kPrimary, width: 1.4),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFF04444)),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFF04444), width: 1.4),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "ยกเลิก",
                    style: TextStyle(
                      color: kText,
                      fontFamily: kFont,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => verifyOtp(setDialogState),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontFamily: kFont,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> verifyOtp(StateSetter setDialogState) async {
    if (_isVerifyingOtp || _hasNavigatedToRole) return;
    final String otp = otpController.text.trim();
    final String name = nameController.text.trim();
    final String phone = _toLocalTH(phoneController.text.trim());
    if (otp.isEmpty) {
      setDialogState(() {
        otpError = "กรุณากรอก OTP";
      });
      return;
    }
    _isVerifyingOtp = true;
    setState(() {
      isLoading = true;
    });
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );
    try {
      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUid = userCredential.user?.uid ?? '';
      if (!mounted) return;
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
      await _afterOtpVerified(
        name: name,
        phone: phone,
        firebaseUid: firebaseUid,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      if (!_hasNavigatedToRole) {
        setDialogState(() {
          otpError = "OTP ไม่ถูกต้อง";
        });
      }
    } finally {
      _isVerifyingOtp = false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hintText,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontSize: 14,
        color: kText,
        fontFamily: kFont,
      ),
      errorText: errorText,
      errorStyle: const TextStyle(
        fontFamily: kFont,
      ),
      filled: true,
      fillColor: kFieldFill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimary),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: kPrimary),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: kPrimary,
          width: 1.4,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFF04444)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(
          color: Color(0xFFF04444),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: kTopBar,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: kBackground,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          "KareX",
                          style: TextStyle(
                            fontSize: 16,
                            color: kPrimaryTextOnButton,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "ชื่อ - นามสกุล",
                      style: TextStyle(
                        fontSize: 16,
                        color: kText,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kText,
                      fontFamily: kFont,
                    ),
                    onChanged: (value) {
                      if (nameError != null) {
                        setState(() {
                          nameError = null;
                        });
                      }
                    },
                    decoration: _inputDecoration(
                      hintText: "ชื่อ - นามสกุล",
                      errorText: nameError,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "เบอร์โทรศัพท์",
                      style: TextStyle(
                        fontSize: 16,
                        color: kText,
                        fontFamily: kFont,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: kText,
                      fontFamily: kFont,
                    ),
                    onChanged: (value) {
                      if (phoneError != null) {
                        setState(() {
                          phoneError = null;
                        });
                      }
                    },
                    decoration: _inputDecoration(
                      hintText: "เบอร์โทรศัพท์",
                      errorText: phoneError,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        isLoading ? "กำลังส่ง..." : "ลงทะเบียน",
                        style: const TextStyle(
                          fontSize: 14,
                          color: kPrimaryTextOnButton,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Row(
                    children: [
                      Expanded(child: Divider(color: kText, thickness: 1)),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          "หรือ",
                          style: TextStyle(
                            fontSize: 14,
                            color: kText,
                            fontFamily: kFont,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: kText, thickness: 1)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Login()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 0,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "เข้าสู่ระบบ",
                        style: TextStyle(
                          fontSize: 14,
                          color: kPrimaryTextOnButton,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
