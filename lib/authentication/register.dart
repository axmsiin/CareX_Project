import 'package:carex/User/Profile/userStore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carex/role/selectRole.dart';
import 'package:carex/authentication/login.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/services/app_session.dart';

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

  String? nameError;
  String? phoneError;

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

  Future<void> register() async {
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();

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

    setState(() {});

    if (!isValid) return;

    _hasNavigatedToRole = false;
    _isVerifyingOtp = false;

    setState(() {
      isLoading = true;
    });

    try {
      final auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: "+66${phone.substring(1)}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            final userCredential = await auth.signInWithCredential(credential);
            final firebaseUid = userCredential.user?.uid ?? '';

            if (!mounted) return;
            setState(() {
              isLoading = false;
            });

            await _goToSelectRole(
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

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFDF0E8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "กรอกรหัส OTP",
            style: TextStyle(
              color: Color(0xFF564444),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: "OTP 6 หลัก",
              counterText: "",
              filled: true,
              fillColor: const Color(0xFFFCFAFF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
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
                style: TextStyle(color: Color(0xFF564444)),
              ),
            ),
            ElevatedButton(
              onPressed: verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE711E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                "ยืนยัน",
                style: TextStyle(color: Color(0xFF564444)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> verifyOtp() async {
    if (_isVerifyingOtp || _hasNavigatedToRole) return;

    final String otp = otpController.text.trim();
    final String name = nameController.text.trim();
    final String phone = phoneController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอก OTP")),
      );
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

      await _goToSelectRole(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP ไม่ถูกต้อง")),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF0E8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCFAFF),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "LOGO",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF564444),
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
                      color: Color(0xFF564444),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  onChanged: (value) {
                    if (nameError != null) {
                      setState(() {
                        nameError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "ชื่อ - นามสกุล",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF564444),
                    ),
                    errorText: nameError,
                    filled: true,
                    fillColor: const Color(0xFFFCFAFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF04444)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFF04444),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "เบอร์โทรศัพท์",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF564444),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    if (phoneError != null) {
                      setState(() {
                        phoneError = null;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "เบอร์โทรศัพท์",
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF564444),
                    ),
                    errorText: phoneError,
                    filled: true,
                    fillColor: const Color(0xFFFCFAFF),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Color(0xFFF04444)),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: Color(0xFFF04444),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEE711E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      isLoading ? "กำลังส่ง..." : "ลงทะเบียน",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: const [
                    Expanded(child: Divider(color: Color(0xFF564444))),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "หรือ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF564444),
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Color(0xFF564444))),
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
                    backgroundColor: const Color(0xFFEE711E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "เข้าสู่ระบบ",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
