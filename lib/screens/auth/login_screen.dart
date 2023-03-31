import 'package:firesos/dialogs/error_dialog.dart';
import 'package:firesos/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../utils/validator.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
                    Center(
                      child: SizedBox(
                        width: 200,
                        height: 200,
                        child: Image.asset('assets/images/fire-station.png'),
                      ),
                    ),
                    SizedBox(height: size.height / 30),
                    Center(
                      child: Text(
                        'Fire SOS',
                        style: GoogleFonts.poppins(
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 40,
                        ),
                      ),
                    ),
                    InputField(
                        size: size,
                        controller: _emailController,
                        hint: 'email'.tr),
                    InputField(
                      size: size,
                      controller: _passwordController,
                      hint: 'password'.tr,
                      obscureText: true,
                    ),
                    SizedBox(height: size.height / 15),
                    CustomButton(
                      size: size,
                      text: 'login'.tr,
                      onTap: _handleLogin,
                    ),
                    SizedBox(height: size.height / 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${'not_have_account'.tr} ',
                          style: GoogleFonts.poppins(color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.toNamed(Routes.signup);
                          },
                          child: Text(
                            'sign_up'.tr,
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

  void _handleLogin() async {
    if (_emailController.text.isEmpty) {
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
    } else {
      try {
        setState(() {
          isLoading = true;
        });
        await _authController.signIn(
          _emailController.text,
          _passwordController.text,
        );
        Get.offAndToNamed(Routes.home, parameters: {'page': '1'});
      } catch (e) {
        Get.dialog(ErrorDialog(
          content: Text('invalid_credential'.tr),
        ));
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
