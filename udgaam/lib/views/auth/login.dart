import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:get/route_manager.dart';
import 'package:udgaam/controllers/auth_controller.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/widgets/auth_input.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
  final AuthController authController = Get.put(AuthController());

  final List<String> roles = ["User", "Farmer", "Admin"];
  String selectedRole = "User"; // Default role

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void submit() {
    if (_form.currentState!.validate()) {
      authController.login(
          emailController.text, passwordController.text, selectedRole);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Center(
            child: SingleChildScrollView(
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                          20), // Half of width/height to make it circular
                      child: Image.asset(
                        "assets/logo.png",
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover, // Ensures the image fits properly
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Udgam",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Login",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 20),
                    AuthInput(
                      label: "Email",
                      hintText: "Enter your email",
                      controller: emailController,
                      Validatorcallback:
                          ValidationBuilder().email().required().build(),
                    ),
                    SizedBox(height: 20),
                    AuthInput(
                      label: "Password",
                      hintText: "Enter your password",
                      controller: passwordController,
                      isPassword: true,
                      Validatorcallback: ValidationBuilder()
                          .minLength(4)
                          .maxLength(8)
                          .required()
                          .build(),
                    ),
                    SizedBox(height: 20),
                    // Dropdown for role selection
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: "Select Role",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      items: roles.map((role) {
                        return DropdownMenuItem(
                          value: role,
                          child: Text(role),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedRole = value!;
                        });
                      },
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: submit,
                      style: ButtonStyle(
                        minimumSize:
                            WidgetStateProperty.all(const Size.fromHeight(40)),
                      ),
                      child: Text("Submit"),
                    ),
                    SizedBox(height: 20),
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                          text: "Sign Up",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.toNamed("./register"),
                        )
                      ], text: "Don't have account? "),
                    ),
                    SizedBox(height: 5),
                    TextButton(
                      onPressed: () => Get.offAllNamed(Routenames.farmerSignUp),
                      child: Text(
                        "Become verified seller",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
