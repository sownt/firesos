import 'package:firebase_auth/firebase_auth.dart';
import 'package:firesos/controllers/auth_controller.dart';
import 'package:firesos/dialogs/error_dialog.dart';
import 'package:firesos/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = Get.find<AuthController>();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Colors.white,
      //   elevation: 0.0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back),
      //     color: Colors.black,
      //     onPressed: () => Navigator.pop(context),
      //   ),
      // ),
      body: SafeArea(
        child: isLoading
            ? Center(
                child: SizedBox(
                  height: size.height / 20,
                  width: size.height / 20,
                  child: const CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: size.height / 20),
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const SizedBox(height: 15),
                          Text(
                            'create_new_account'.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.red[900],
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'create_new_account_hint'.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: size.height / 30),
                    InputField(
                      size: size,
                      controller: _nameController,
                      hint: 'name'.tr,
                    ),
                    InputField(
                      size: size,
                      controller: _phoneController,
                      hint: 'phone_number'.tr,
                    ),
                    InputField(
                      size: size,
                      controller: _emailController,
                      hint: 'email'.tr,
                    ),
                    InputField(
                      size: size,
                      controller: _passwordController,
                      hint: 'password'.tr,
                      obscureText: true,
                    ),
                    SizedBox(
                      height: size.height / 20,
                    ),
                    CustomButton(
                      size: size,
                      text: 'sign_up'.tr,
                      onTap: _handleSignUp,
                    ),
                    SizedBox(height: size.height / 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'already_have_account'.tr} ',
                          style: GoogleFonts.poppins(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Text(
                            'login'.tr,
                            style: GoogleFonts.poppins(color: Colors.black),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  void _handleSignUp() async {
    if (_nameController.text.isEmpty) {
      Utils.flushBarErrorMessage(
        'warning.name_empty'.tr,
        context,
      );
    } else if (_phoneController.text.isEmpty) {
      Utils.flushBarErrorMessage(
        'warning.phone_empty'.tr,
        context,
      );
    } else if (_emailController.text.isEmpty) {
      Utils.flushBarErrorMessage(
        'warning.email_empty'.tr,
        context,
      );
    } else if (_passwordController.text.isEmpty) {
      Utils.flushBarErrorMessage(
        'warning.password_empty'.tr,
        context,
      );
    } else if (_passwordController.text.length < 6) {
      Utils.flushBarErrorMessage(
        'warning.password_length'.tr,
        context,
      );
    }
    setState(() {
      isLoading = true;
    });
    try {
      await _authController.createAccount(
        _nameController.text,
        _phoneController.text,
        _emailController.text,
        _passwordController.text,
      );
      await Get.offAndToNamed(Routes.home, parameters: {'page': '1'});
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.dialog(
          ErrorDialog(
            content: Text('error.weak_password'.tr),
          ),
        );
      } else if (e.code == 'email-already-in-use') {
        Get.dialog(
          ErrorDialog(
            content: Text('error.duplicated_account'.tr),
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
