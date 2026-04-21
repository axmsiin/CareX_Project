import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:carex/User/Profile/userStore.dart';
import 'package:carex/User/Profile/userData.dart';
import 'package:carex/services/backend_data_service.dart';

class editProfileUser extends StatefulWidget {
  const editProfileUser({super.key});

  @override
  State<editProfileUser> createState() => _EditProfileUserState();
}

class _EditProfileUserState extends State<editProfileUser> {
  static const Color kPrimary = Color(0xFFEE711E);
  static const Color kWhite = Color(0xFFFFFFFF);
  static const Color kText = Color(0xFF564444);
  static const Color kTopBar = Color(0xFFFFC59E);
  static const Color kBackground = Color(0xFFFDF0E8);
  static const Color kFieldFill = Color(0xFFF5F3F6);
  static const Color kBottomBar = Color(0xFFFFC59E);
  static const Color kError = Color(0xFFE95257);
  static const String kFont = 'Sarabun';

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  String? nameError;
  String? phoneError;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: UserStore.currentUser.fullName);
    phoneController = TextEditingController(text: UserStore.currentUser.phone);
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Widget buildBox({
    required Widget child,
    bool hasError = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: kFieldFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: hasError ? kError : kPrimary,
          width: 1.2,
        ),
      ),
      child: child,
    );
  }

  Widget buildError(String? error) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 4),
      child: Text(
        error,
        style: const TextStyle(
          color: kError,
          fontSize: 12,
          fontFamily: kFont,
        ),
      ),
    );
  }

  Widget buildEditableField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      cursorColor: kPrimary,
      style: const TextStyle(
        color: kText,
        fontSize: 14,
        fontFamily: kFont,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        isCollapsed: true,
        filled: false,
        fillColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        hintText: hintText,
        hintStyle: const TextStyle(
          color: kText,
          fontSize: 14,
          fontFamily: kFont,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Future<void> saveProfile() async {
    if (isSaving) return;

    setState(() {
      nameError = null;
      phoneError = null;
    });

    bool isValid = true;

    if (nameController.text.trim().isEmpty) {
      nameError = 'กรุณากรอกชื่อ-นามสกุล';
      isValid = false;
    }
    if (phoneController.text.trim().isEmpty) {
      phoneError = 'กรุณากรอกเบอร์โทรศัพท์';
      isValid = false;
    }

    setState(() {});
    if (!isValid) return;

    setState(() {
      isSaving = true;
    });

    final updated = UserData(
      fullName: nameController.text.trim(),
      phone: phoneController.text.trim(),
    );

    final ok = await BackendDataService.updateUserProfile(updated);

    if (!ok) {
      if (!mounted) return;
      setState(() {
        isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'อัปเดตข้อมูลผู้ใช้ลงฐานข้อมูลไม่สำเร็จ',
            style: TextStyle(fontFamily: kFont),
          ),
        ),
      );
      return;
    }

    await UserStore.syncFromBackend();

    if (!mounted) return;
    setState(() {
      isSaving = false;
    });
    Navigator.pop(context, true);
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 22,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'ย้อนกลับ',
            style: TextStyle(
              color: kText,
              fontSize: 16,
              fontFamily: kFont,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileIcon() {
    return const Center(
      child: Icon(
        Icons.account_circle_outlined,
        size: 122,
        color: kPrimary,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      height: 95,
      decoration: const BoxDecoration(
        color: kBottomBar,
        borderRadius: BorderRadius.vertical(top: Radius.circular(38)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          Icon(Icons.home, size: 40, color: kPrimary),
          Icon(Icons.notifications, size: 40, color: kPrimary),
          Icon(Icons.account_circle, size: 44, color: kWhite),
        ],
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
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTopBar(),
                const SizedBox(height: 28),
                _buildProfileIcon(),
                const SizedBox(height: 26),
                const Text(
                  'ข้อมูลส่วนตัว',
                  style: TextStyle(
                    fontSize: 16,
                    color: kText,
                    fontFamily: kFont,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 18),
                buildBox(
                  hasError: nameError != null,
                  child: buildEditableField(
                    controller: nameController,
                    hintText: 'ชื่อ-นามสกุล',
                  ),
                ),
                buildError(nameError),
                const SizedBox(height: 18),
                buildBox(
                  hasError: phoneError != null,
                  child: buildEditableField(
                    controller: phoneController,
                    hintText: 'เบอร์โทรศัพท์',
                    keyboardType: TextInputType.phone,
                  ),
                ),
                buildError(phoneError),
                const SizedBox(height: 28),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveProfile,
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: kPrimary,
                        disabledBackgroundColor: kPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(
                        isSaving ? '...' : 'บันทึก',
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 14,
                          fontFamily: kFont,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }
}
