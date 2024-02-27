// import 'package:firebase_crud/view/homePage.dart';
// import 'package:flutter/material.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class LoginPage extends StatelessWidget {
//   const LoginPage({Key? key});

//   @override
//   Widget build(BuildContext context) {
//     final TextEditingController emailController = TextEditingController();
//     final TextEditingController passwordController = TextEditingController();

//     return Scaffold(
//       appBar: AppBar(
//         actions: const [
//           Padding(
//             padding: EdgeInsets.all(18.0),
//             child: FaIcon(FontAwesomeIcons.key),
//           )
//         ],
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             const FaIcon(
//               FontAwesomeIcons.lock,
//               size: 100,
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Private access',
//               style: TextStyle(fontSize: 20),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: const InputDecoration(
//                   hintText: 'Email',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: TextField(
//                 controller: passwordController,
//                 obscureText: true,
//                 decoration:const InputDecoration(
//                   hintText: 'Password',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(10.0),
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.black,
//                 ),
//                 onPressed: () {
//                   final String email = emailController.text.trim();
//                   final String password = passwordController.text.trim();

//                   if (email.isEmpty || password.isEmpty) {
//                     // Show error message if email or password is empty
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(
//                         content: Text('Please enter email and password'),
//                       ),
//                     );
//                   } else {
//                     // Proceed with login logic
//                     // Here, you can add your authentication logic
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (context) => const HomePage()),
//                     );
//                   }
//                 },
//                 child: Container(
//                   width: double.infinity,
//                   height: MediaQuery.of(context).size.height * 0.06,
//                   alignment: Alignment.center,
//                   decoration: const BoxDecoration(
//                     border: Border(),
//                   ),
//                   child: const Text(
//                     'Login',
//                     style: TextStyle(fontSize: 22, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
