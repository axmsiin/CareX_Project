import 'package:flutter/material.dart';
import 'package:carex/authentication/register.dart';

void main() {
  runApp(
    MaterialApp(
      title: "CareX",
      home: Scaffold(
        body: const Register(),
      ),
    ),
  );
}