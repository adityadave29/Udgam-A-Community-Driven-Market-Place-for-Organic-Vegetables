import 'package:flutter/material.dart';
import 'package:form_validator/form_validator.dart';
import 'package:get/get.dart';
import 'package:udgaam/controllers/farmer_registration.dart';
import 'package:udgaam/routes/route_names.dart';
import 'package:udgaam/widgets/auth_input.dart';

class FarmerSignUp extends StatefulWidget {
  const FarmerSignUp({super.key});

  @override
  State<FarmerSignUp> createState() => _FarmerSignUpState();
}

class _FarmerSignUpState extends State<FarmerSignUp> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController(text: "");
  final TextEditingController passwordController =
      TextEditingController(text: "");
  final TextEditingController nameController = TextEditingController(text: "");
  final TextEditingController confirmController =
      TextEditingController(text: "");
  final FarmerRegiatrationController controller =
      Get.put(FarmerRegiatrationController());

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void submit() {
    if (_form.currentState!.validate()) {
      controller.register(
          nameController.text, emailController.text, passwordController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(Routenames.login),
            child: Text("Back"),
          ),
        ],
      ),
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
                      "Register",
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 20),
                    AuthInput(
                      label: "Name",
                      hintText: "Enter your name",
                      controller: nameController,
                      Validatorcallback: ValidationBuilder()
                          .minLength(3)
                          .maxLength(50)
                          .required()
                          .build(),
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
                    AuthInput(
                      label: "Confirm Password",
                      isPassword: true,
                      hintText: "Enter you password again",
                      controller: confirmController,
                      Validatorcallback: (arg) {
                        if (passwordController.text != arg) {
                          return "Confirm Password not matched";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Obx(() => ElevatedButton(
                          onPressed: submit,
                          style: ButtonStyle(
                            minimumSize: WidgetStateProperty.all(
                                const Size.fromHeight(40)),
                          ),
                          child: Text(controller.registerLoading.value
                              ? "Processing...."
                              : "Next"),
                        )),
                    SizedBox(height: 20),
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
