import 'package:flutter/material.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  void register() {
    String name = nameController.text;
    String phone = phoneController.text;

    print("Name: $name");
    print("Phone: $phone");

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("ลงทะเบียน: $name")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffE7E0C5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [

              const SizedBox(height: 40),

              ///LOGO
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: Color(0xffB9C7DF),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "LOGO",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              ///NAME LABEL
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("ชื่อ - นามสกุล"),
              ),

              const SizedBox(height: 8),

              ///กรอกชื่อ - นามสกุล
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "ชื่อ - นามสกุล",
                  filled: true,
                  fillColor: const Color(0xffB9C7DF),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              ///PHONE LABEL
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("เบอร์โทรศัพท์"),
              ),

              const SizedBox(height: 8),

              ///กรอกเบอร์โทรศัพท์
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "เบอร์โทรศัพท์",
                  filled: true,
                  fillColor: const Color(0xff89AEE8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              ///ปุ่ม Register
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff89AEE8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("ลงทะเบียน"),
                ),
              ),

              const SizedBox(height: 25),

              ///หรือ
              Row(
                children: const [
                  Expanded(child: Divider(color: Colors.black)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text("หรือ"),
                  ),
                  Expanded(child: Divider(color: Colors.black)),
                ],
              ),

              const SizedBox(height: 20),

              ///ปุ่ม Login
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff89AEE8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text("เข้าสู่ระบบ"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}