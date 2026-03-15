import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiverData.dart';
import 'package:carex/authentication/register.dart';
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

  String? phoneError;

  Future<String> getUserRoleFromBackend(String phone) async {
    // TODO: รอเชื่อม backend จริง
    // backend จะคืนค่าเป็น 'caregiver' หรือ 'user'
    return 'caregiver';
  }

  Future<void> goToHomeByRole(String phone) async {
    final role = await getUserRoleFromBackend(phone);

    if (!mounted) return;

    if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const user_home.home(),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(
            profile: caregiverData(
              phone: phone,
            ),
          ),
        ),
      );
    }
  }

  Future<void> login() async {
    String phone = phoneController.text.trim();

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

    setState(() {
      isLoading = true;
    });

    try {
      final FirebaseAuth auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: "+66${phone.substring(1)}",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await auth.signInWithCredential(credential);

          if (!mounted) return;
          await goToHomeByRole(phone);
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

          if (!mounted) return;
          setState(() {
            isLoading = false;
          });
        },
      );
    } catch (e) {
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
    String otp = otpController.text.trim();

    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("กรุณากรอก OTP")),
      );
      return;
    }

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    try {
      await FirebaseAuth.instance.signInWithCredential(credential);

      if (!mounted) return;

      Navigator.pop(context);
      await goToHomeByRole(phoneController.text.trim());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("OTP ไม่ถูกต้อง")),
      );
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
