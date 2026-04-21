import 'package:flutter/material.dart';

Future<bool?> showPrivacyConsentDialog(BuildContext context) {
  bool isChecked = false;

  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            backgroundColor: const Color(0xFFFCFAFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'นโยบายความเป็นส่วนตัวและการขอความยินยอม',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF564444),
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'แอปพลิเคชัน KareX ให้ความสำคัญกับการปกป้องข้อมูลส่วนบุคคลของคุณ เพื่อให้เราสามารถให้บริการค้นหาและจับคู่ผู้ดูแลที่เหมาะสมที่สุดสำหรับคุณ ระบบมีความจำเป็นต้องเก็บรวบรวมและประมวลผลข้อมูลดังต่อไปนี้:\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const Text(
                      'ข้อมูลส่วนบุคคลทั่วไป: ชื่อ-นามสกุล, เบอร์โทรศัพท์ เพื่อใช้ในการยืนยันตัวตน (OTP) และการติดต่อสื่อสาร\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const Text(
                      'ข้อมูลสุขภาพ (สำหรับฝั่งญาติ/ผู้สูงอายุ): ข้อมูลโรคประจำตัว และผลการประเมินบุคลิกภาพ เพื่อนำไปใช้คำนวณเปอร์เซ็นต์ความเหมาะสม (Matching Percentage) กับผู้ดูแล\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const Text(
                      'ข้อมูลตำแหน่งที่ตั้ง (GPS): พิกัดที่อยู่ของคุณ เพื่อใช้ในการคำนวณระยะทางการเดินทางระหว่างผู้ดูแลและผู้สูงอายุ\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const Text(
                      'ข้อมูลวิชาชีพ (สำหรับฝั่งผู้ดูแล): ประสบการณ์การทำงาน และเอกสารใบประกาศนียบัตร เพื่อตรวจสอบและยืนยันคุณสมบัติในการรับงาน\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const Text(
                      'วัตถุประสงค์ในการใช้งาน:\nข้อมูลทั้งหมดจะถูกจัดเก็บอย่างปลอดภัยบนระบบฐานข้อมูลมาตรฐาน (Google Cloud และ Firebase) และจะถูกนำมาใช้เพื่อ "ประมวลผลการจับคู่ (Matching) และอำนวยความสะดวกในการให้บริการภายในแอปพลิเคชัน KareX เท่านั้น" เราจะไม่มีการนำข้อมูลของท่านไปจำหน่ายหรือเปิดเผยแก่บุคคลภายนอกที่ไม่เกี่ยวข้องโดยเด็ดขาด\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const Text(
                      'ท่านมีสิทธิในการเข้าถึง แก้ไข หรือขอลบข้อมูลส่วนบุคคลของท่านออกจากระบบได้ตลอดเวลาผ่านเมนูการตั้งค่าภายในแอปพลิเคชัน\n',
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Color(0xFF564444),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDF0E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: isChecked,
                            activeColor: const Color(0xFFEE711E),
                            onChanged: (value) {
                              setStateDialog(() {
                                isChecked = value ?? false;
                              });
                            },
                          ),
                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                'ข้าพเจ้าได้อ่านและทำความเข้าใจนโยบายความเป็นส่วนตัวเรียบร้อยแล้ว และ ยินยอม ให้แอปพลิเคชัน KareX เก็บรวบรวมและประมวลผลข้อมูลส่วนบุคคล ข้อมูลสุขภาพ และตำแหน่งที่ตั้งของข้าพเจ้า เพื่อใช้สำหรับการให้บริการและจับคู่ผู้ดูแลตามที่ระบุไว้ข้างต้น',
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Color(0xFF564444),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isChecked
                      ? () => Navigator.pop(dialogContext, true)
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEE711E),
                    disabledBackgroundColor: const Color(0xFFE0E0E0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('ยอมรับและดำเนินการต่อ'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF564444),
                    side: const BorderSide(color: Color(0xFFEE711E)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('ปฏิเสธ'),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}
