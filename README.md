ลง flutter
https://docs.flutter.dev
แล้วเปิด Edit the system environment variables 
แล้วกด Environment Variables แล้วเลือก Path แล้วกดเพิ่มแล้วใส่ path (ตัวอย่าง -> C:\src\flutter\bin)
แล้วหลังจากนั้นก็เช็คว่า Flutter ใช้ได้ไหม
เปิด Command Prompt 
flutter --version
แล้วติดตั้ง Android Studio ต่อ https://developer.android.com/studio?hl=th
ตอนติดตั้งเลือก
Android SDK
Android SDK Platform
Android Virtual Device
พอติดตั้งเสร็จเปิด Android Studio เพื่อจะไปติดตั้ง Android SDK
เปิดแล้วไปที่ 
More Actions
SDK Manager แล้วติดตั้ง
Android SDK Platform 33 หรือ 34
Android SDK Build Tools
Android SDK Command-line Tools
Android Emulator
แล้วหลังจากนั้นก็ไปตั้งค่า Android Emulator
เปิดแล้วไปที่ 
More Actions
SDK Manager
แล้วกด Create Device เลือก Pixel 6 แล้วเลือก Android 13 หรือ 14
หลังจากนั้นไปที่ terminal อีกรอบเพื่อไปเช็ค Flutter Environment
ใช้คำสั่ง 
flutter doctor
แล้วพอ clone มาแล้ว เปิด terminal รันคำสั่ง flutter pub get 
