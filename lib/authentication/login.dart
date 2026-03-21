import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/authentication/register.dart';
import 'package:carex/controllers/auth_controller.dart';
import 'package:carex/services/app_session.dart';
import 'package:carex/User/HomePages/home.dart' as user_home;

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController otpController = TextEditingController();

  String verificationId = "";
  bool isLoading = false;
  bool _isVerifyingOtp = false;
  bool _hasCompletedLogin = false;

  String? phoneError;

  Future<void> _goToHomeByRole(
    String role,
    String phone, {
    String? userName,
  }) async {
    if (!mounted) return;

    if (role == 'client') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => const user_home.home(),
        ),
        (route) => false,
      );
    } else if (role == 'caregiver') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            profile: caregiverData(
              fullName: userName ?? '',
              phone: phone,
            ),
          ),
        ),
        (route) => false,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบบทบาทผู้ใช้ในระบบ')),
      );
    }
  }

  Future<void> _completeLogin() async {
    if (_hasCompletedLogin) return;
    _hasCompletedLogin = true;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    debugPrint('Login: _completeLogin() started, firebaseUser=${firebaseUser?.uid}');
    if (firebaseUser == null) {
      _hasCompletedLogin = false;
      setState(() {
        isLoading = false;
        phoneError = 'ไม่พบข้อมูลผู้ใช้ Firebase';
      });
      return;
    }

    try {
      debugPrint('Login: calling AuthController.loginUser(firebaseUid=${firebaseUser.uid})');
      final result = await AuthController.loginUser(
        firebaseUid: firebaseUser.uid,
        phone: AuthController.normalizePhone(phoneController.text.trim()),
      );

      debugPrint('Login: AuthController.loginUser returned success=${result.success} role=${result.role} userId=${result.userId} token=${result.token}');

      if (!result.success) {
        _hasCompletedLogin = false;
        setState(() {
          isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message)),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Register()),
        );
        return;
      }

      final role = result.role;
      final userName = result.userName;

      if (role == null || role.isEmpty) {
        _hasCompletedLogin = false;
        setState(() {
          isLoading = false;
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่พบ role ของผู้ใช้')),
        );
        return;
      }

      await AppSession.saveUserSession(
        userId: result.userId,
        role: role,
        phone: AuthController.normalizePhone(phoneController.text.trim()),
        userName: userName ?? '',
        firebaseUid: firebaseUser.uid,
        token: result.token,
      );

      setState(() {
        isLoading = false;
      });

      await _goToHomeByRole(
        role,
        AuthController.normalizePhone(phoneController.text.trim()),
        userName: userName,
      );
    } catch (e) {
      _hasCompletedLogin = false;
      setState(() {
        isLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เข้าสู่ระบบไม่สำเร็จ: $e')),
      );
    }
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();

    debugPrint('Login: login() called for phone=$phone');

    setState(() {
      phoneError = null;
    });

    if (phone.isEmpty) {
      setState(() {
        phoneError = "กรุณากรอกเบอร์โทรศัพท์";
      });
      return;
    }

    if (!RegExp(r'^0\d{9}$').hasMatch(phone)) {
      setState(() {
        phoneError = "กรุณากรอกเบอร์โทรศัพท์ให้ถูกต้อง";
      });
      return;
    }

    _hasCompletedLogin = false;
    _isVerifyingOtp = false;

    setState(() {
      isLoading = true;
    });

    try {
      final auth = FirebaseAuth.instance;

      debugPrint('Login: calling FirebaseAuth.verifyPhoneNumber for +66${phone.substring(1)}');

      await auth.verifyPhoneNumber(
        phoneNumber: "+66${phone.substring(1)}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('Login: verificationCompleted callback fired');
          try {
            await auth.signInWithCredential(credential);
            debugPrint('Login: signInWithCredential (auto) successful');

            if (!mounted) return;

            setState(() {
              isLoading = false;
            });

            await _completeLogin();
          } catch (e) {
            debugPrint('Login: verificationCompleted error: $e');
            if (!mounted) return;
            setState(() {
              isLoading = false;
            });
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Login: verificationFailed code=${e.code} message=${e.message}');
          if (!mounted) return;

          setState(() {
            isLoading = false;
            phoneError = e.message ?? "เกิดข้อผิดพลาดในการส่ง OTP";
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Login: codeSent, verificationId=$verificationId resendToken=$resendToken');
          this.verificationId = verificationId;

          if (!mounted) return;
          setState(() {
            isLoading = false;
          });

          showOtpDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Login: codeAutoRetrievalTimeout, verificationId=$verificationId');
          this.verificationId = verificationId;

          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e) {
      debugPrint('Login: verifyPhoneNumber threw: $e');
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
          backgroundColor: const Color(0xFFFFFCE3),
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
              fillColor: const Color(0xFFD5E7FF),
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
                backgroundColor: const Color(0xFF8FBFFF),
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
    if (_isVerifyingOtp || _hasCompletedLogin) return;

    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอก OTP")),
      );
      return;
    }

    _isVerifyingOtp = true;

    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      debugPrint('Login: verifyOtp() signing in with credential (manual)');
      setState(() {
        isLoading = true;
      });

      await FirebaseAuth.instance.signInWithCredential(credential);
      debugPrint('Login: verifyOtp signInWithCredential successful');

      if (!mounted) return;
      Navigator.pop(context);

      await _completeLogin();
    } catch (_) {
      setState(() {
        isLoading = false;
      });

      if (!_hasCompletedLogin) {
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
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFCE3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35),
          child: Column(
            children: [
              const SizedBox(height: 80),
              Center(
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD5E7FF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "LOGO",
                      style: TextStyle(
                        fontSize: 18,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 70),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "เบอร์โทรศัพท์",
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF564444),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                onChanged: (_) {
                  if (phoneError != null) {
                    setState(() {
                      phoneError = null;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: "เบอร์โทรศัพท์",
                  hintStyle: const TextStyle(
                    color: Color(0xFF564444),
                    fontSize: 14,
                  ),
                  errorText: phoneError,
                  filled: true,
                  fillColor: const Color(0xFFD5E7FF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFF04444),
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFFF04444),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8FBFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    child: Text(
                      isLoading ? "กำลังส่ง..." : "เข้าสู่ระบบ",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF564444),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: const [
                  Expanded(child: Divider(color: Color(0xFF564444))),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
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
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8FBFFF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text(
                    "ลงทะเบียน",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF564444),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
