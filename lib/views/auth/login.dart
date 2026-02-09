import 'package:Eksys/controllers/auth_controller.dart';
import 'package:Eksys/controllers/user_controller.dart';
import 'package:Eksys/services/api_service.dart';
import 'package:Eksys/services/localstorage_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final apiService = ApiServive();
  final storageService = StorageService();
  final userController = UserController(StorageService());

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final authController = AuthController(ApiServive(), StorageService());

  bool _obscureText = true;

  void _togglePasswordView() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
    );
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 48, 47),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Container(
                  // Set height and width as needed
                  height: 150,
                  width: 200,
                  // Decoration for the container
                  decoration: const BoxDecoration(
                    // borderRadius: BorderRadius.circular(100.0),
                    // color: Colors.amberAccent,
                    // Set background image
                    image: DecorationImage(
                        // Use AssetImage for assets
                        image: AssetImage("assets/images/logo-mob-apps.png"),
                        // Adjust how the image fits the container
                        fit: BoxFit.fitWidth),
                  ),
                ),
                Text('Login to your account',
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16)),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: TextField(
                    controller: emailController,
                    style: TextStyle(color: Colors.grey[800]),
                    cursorColor: const Color.fromARGB(255, 254, 185, 3),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
                      // labelText: "Email",
                      // labelStyle: const TextStyle(color: Colors.white),
                      hintText: "Email",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusColor: Colors.red,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.email,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: TextField(
                    controller: passwordController,
                    obscureText: _obscureText,
                    style: TextStyle(color: Colors.grey[800]),
                    cursorColor: const Color.fromARGB(255, 254, 185, 3),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.fromLTRB(15, 15, 10, 10),
                      // labelText: "Password",
                      // labelStyle: TextStyle(color: Colors.grey[800]),
                      hintText: "Password",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      filled: true,
                      fillColor: Colors.white,
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Colors.white),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusColor: Colors.red,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      prefixIcon: const Icon(
                        Icons.lock,
                        color: Colors.grey,
                      ),
                      suffixIcon: IconButton(
                        color: Colors.grey,
                        icon: Icon(
                          _obscureText ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: _togglePasswordView,
                      ),
                    ),
                    
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: const Color.fromARGB(255, 254, 185, 3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () async {
                        String email = emailController.text;
                        String password = passwordController.text;
                        if (email == "") {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  backgroundColor: Colors.red,
                                  content: Text('Email masih kosong!')));
                        } else if (password == "") {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('Password masih kosong!'),
                          ));
                        } else {
                          bool success = await authController.login(
                              email: email, password: password);
                          if (success) {
                            final user =
                                await userController.getUserFromStorage();
                            // if (user!.user_group == 'User') {
                            //   GoRouter.of(context).go('/logincabang');
                            // } else if (user!.user_group == 'Administrator') {
                            //   GoRouter.of(context).go('/main_pusat');
                            // } else {
                            //   GoRouter.of(context).go('/main');
                            // }
                            GoRouter.of(context).go('/main_pusat');
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text('Login failed')));
                          }
                        }
                      },
                      child: Text(
                        'Login',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.grey[800]),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        foregroundColor:
                            const Color.fromARGB(255, 254, 185, 3),
                        backgroundColor:
                            const Color.fromARGB(255, 254, 185, 3)
                                .withOpacity(0.08),
                        side: const BorderSide(
                          color: Color.fromARGB(255, 254, 185, 3),
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        GoRouter.of(context).push('/register');
                      },
                      child: const Text(
                        'Register',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
