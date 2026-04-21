import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carex/Caregiver/HomePages/home.dart';
import 'package:carex/Caregiver/Profile_Caregiver/caregiver_store.dart';
import 'package:carex/Caregiver/Profile_Caregiver/question.dart'
    as caregiver_question;
import 'package:carex/authentication/register.dart';
import 'package:carex/controllers/auth_controller.dart';
import 'package:carex/services/app_session.dart';
import 'package:carex/User/Profile/userStore.dart';
import 'package:carex/User/HomePages/elderlyStore.dart';
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
  String? otpError; // แจ้งเตือน OTP ผิดพลาดภายในกล่อง

  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kText = Color(0xFF564444);
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

  Future<void> _goToHomeByRole(
    String role,
    String phone, {
    String? userName,
    int? caregiverScore,
  }) async {
    if (!mounted) return;

    if (role == 'client') {
      await UserStore.syncFromBackend();
      await ElderlyStore.syncFromBackend();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const user_home.home()),
        (route) => false,
      );

      final user = UserStore.currentUser;
      if (user.fullName.trim().isEmpty) {
        _showIncompleteProfilePopup(
          'ยังไม่ได้กรอกข้อมูลในหน้า Profile กรุณากรอกข้อมูลเพื่อใช้งานระบบ',
        );
      }
    } else if (role == 'caregiver') {
      await CaregiverStore.syncFromBackend();
      final profile = CaregiverStore.currentProfile;

      final effectiveScore = profile.score ?? caregiverScore;

      if (effectiveScore == null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => caregiver_question.question(profile: profile),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => Home(profile: profile)),
          (route) => false,
        );

        if (profile.fullName.trim().isEmpty) {
          _showIncompleteProfilePopup(
            'ยังไม่ได้กรอกข้อมูลในหน้า Profile ข้อมูลของคุณจะถูกใช้ในการ Matching กรุณากรอกข้อมูลให้ครบ',
          );
        }
      }
    } else if (role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kPrimary,
          content: Text(
            'ยังไม่ได้สร้างโปรไฟล์ กรุณากรอกข้อมูลต่อ',
            style: const TextStyle(
              fontFamily: kFont,
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: kPrimary,
          content: Text(
            'ไม่พบ role ของผู้ใช้',
            style: const TextStyle(
              fontFamily: kFont,
              color: Colors.white,
            ),
          ),
        ),
      );
    }
  }

  void _showIncompleteProfilePopup(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: kBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: kPrimary),
              SizedBox(width: 8),
              Text(
                'แจ้งเตือน',
                style: TextStyle(
                  color: kText,
                  fontSize: 16,
                  fontFamily: kFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: kText,
              fontSize: 14,
              fontFamily: kFont,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'ตกลง',
                style: TextStyle(
                  color: kPrimary,
                  fontFamily: kFont,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Future<void> _completeLogin() async {
    if (_hasCompletedLogin) return;
    _hasCompletedLogin = true;

    final firebaseUser = FirebaseAuth.instance.currentUser;
    debugPrint(
      'Login: _completeLogin() started, firebaseUser=${firebaseUser?.uid}',
    );

    if (firebaseUser == null) {
      _hasCompletedLogin = false;
      setState(() {
        isLoading = false;
        phoneError = 'ไม่พบข้อมูลผู้ใช้ Firebase';
      });
      return;
    }

    try {
      debugPrint(
        'Login: calling AuthController.loginUser(firebaseUid=${firebaseUser.uid})',
      );

      final result = await AuthController.loginUser(
        firebaseUid: firebaseUser.uid,
        phone: _toLocalTH(phoneController.text.trim()),
      );

      debugPrint(
        'Login: AuthController.loginUser returned '
        'success=${result.success} role=${result.role} userId=${result.userId} token=${result.token}',
      );

      if (!result.success) {
        _hasCompletedLogin = false;

        await FirebaseAuth.instance.signOut();

        if (mounted) {
          setState(() {
            isLoading = false;
            phoneError = 'เบอร์นี้ยังไม่ได้ลงทะเบียน กรุณาลงทะเบียนก่อน';
          });
        }
        return;
      }

      final role = result.role ?? '';
      // ... (rest of field extraction)
      final userName = result.userName;
      final userId = result.userId;
      final token = result.token;
      final clientId = result.clientId;
      final caregiverId = result.caregiverId;

      if (userId == null || userId.isEmpty) {
        throw Exception('ระบบไม่ได้ส่ง user_id กลับมาหลังเข้าสู่ระบบ');
      }

      if (token == null || token.isEmpty) {
        throw Exception('ระบบไม่ได้ส่ง token กลับมาหลังเข้าสู่ระบบ');
      }

      // ห้าม .trim() หรือแก้ไข phone/id ที่นี่ เพื่อรักษาความสอดคล้องกับ backend
      final String rawPhone = phoneController.text; 

      await AppSession.saveUserSession(
        userId: userId,
        role: role,
        phone: rawPhone,
        userName: userName ?? '',
        firebaseUid: firebaseUser.uid,
        token: token,
        clientId: clientId,
        caregiverId: caregiverId,
      );

      debugPrint(
        '✅ Login success: role=$role, clientId=$clientId, caregiverId="$caregiverId"',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      await _goToHomeByRole(
        role,
        _toLocalTH(phoneController.text.trim()),
        userName: userName,
        caregiverScore: result.caregiverScore,
      );
    } catch (e) {
      _hasCompletedLogin = false;

      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}

      if (mounted) {
        setState(() {
          isLoading = false;
          phoneError = 'เข้าสู่ระบบไม่สำเร็จ: ${e.toString().replaceFirst('Exception: ', '')}';
        });
      }
    }
  }

  Future<void> login() async {
    final phone = _toLocalTH(phoneController.text.trim());

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

      debugPrint(
        'Login: calling FirebaseAuth.verifyPhoneNumber for ${_toE164TH(phone)}',
      );

      await auth.verifyPhoneNumber(
        phoneNumber: _toE164TH(phone),
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
          debugPrint(
            'CRITICAL Firebase Error: [${e.code}] ${e.message}',
          );
          if (!mounted) return;

          setState(() {
            isLoading = false;
            phoneError = "เกิดข้อผิดพลาด (${e.code}): ${e.message}";
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint(
            'Login: codeSent, verificationId=$verificationId resendToken=$resendToken',
          );
          this.verificationId = verificationId;

          if (!mounted) return;
          setState(() {
            isLoading = false;
          });

          showOtpDialog();
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint(
            'Login: codeAutoRetrievalTimeout, verificationId=$verificationId',
          );
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
                    borderSide:
                        const BorderSide(color: Color(0xFFF04444), width: 1.4),
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
                  ),
                  child: const Text(
                    "ยืนยัน",
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontFamily: kFont,
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
    if (_isVerifyingOtp || _hasCompletedLogin) return;

    final otp = otpController.text.trim();

    if (otp.isEmpty) {
      setDialogState(() {
        otpError = "กรุณากรอก OTP";
      });
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
    } catch (e) {
      debugPrint('Login: verifyOtp error: $e');

      setState(() {
        isLoading = false;
      });

      if (!_hasCompletedLogin) {
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
    phoneController.dispose();
    otpController.dispose();
    super.dispose();
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
        backgroundColor: const Color(0xFFFDF0E8),
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 35),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 50),
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEE711E),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "KareX",
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFFFFFFFF),
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
                    "เบอร์โทรศัพท์",
                    style: TextStyle(
                      fontSize: 14,
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
                    color: kText,
                    fontSize: 14,
                    fontFamily: kFont,
                  ),
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
                      color: kText,
                      fontSize: 14,
                      fontFamily: kFont,
                    ),
                    errorText: phoneError,
                    errorStyle: const TextStyle(
                      fontFamily: kFont,
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF5F3F6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kPrimary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: kPrimary),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(
                        color: kPrimary,
                        width: 1.4,
                      ),
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
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 0,
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
                          color: Color(0xFFFFFFFF),
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Row(
                  children: [
                    Expanded(child: Divider(color: kText, thickness: 1)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
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
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Register()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 0,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14),
                    child: Text(
                      "ลงทะเบียน",
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFFFFFFFF),
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
    );
  }
}
