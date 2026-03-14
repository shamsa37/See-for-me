import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 🔹 Import all screens
import 'package:project/SplashScreen.dart';
import 'package:project/HomeScreen.dart';
import 'package:project/LoginScreen.dart';
import 'package:project/RegistrationScreen.dart';
import 'package:project/BlindDashboardScreen.dart';
import 'package:project/sos_screen.dart';
import 'package:project/EmergencyScreen.dart';
import 'package:project/EmergencyHelp.dart';
import 'package:project/OfflineScreen.dart';
import 'package:project/ScenedescriptionScreen.dart';
import 'package:project/SettingScreen.dart';
import 'package:project/EditProfileScreen.dart';
import 'package:project/ChangePasswordScreen.dart';
import 'package:project/ForgetPasswordScreen.dart';
import 'package:project/CallScreen.dart';
import 'package:project/VolunteerHistoryScreen.dart';
import 'package:project/VolunteerDashboard.dart';
import 'package:project/VolunteerScreen.dart';
import 'package:project/BlindScreen.dart';
import 'package:project/FamilyDashboard.dart';
import 'package:project/EditProfile.dart';
import 'package:project/VolForgotPasswordScreen.dart';

// ✅ NEW IMPORT — Wrapper
import 'package:project/wrapper_screen.dart'; // make sure wrapper_screen.dart exists

// Optional / additional imports
import 'package:project/CallVolunteerScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'See For Me',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.deepPurple,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),

      // 🔹 START APP FROM WRAPPER
      home: const WrapperScreen(),

      // 🔹 Centralized routing
      onGenerateRoute: (settings) {
        WidgetBuilder builder;

        switch (settings.name) {
          case '/home':
            builder = (_) => HomeScreen();
            break;
          case '/login':
            builder = (_) => LoginScreen();
            break;
          case '/register':
            builder = (_) => RegistrationScreen();
            break;
          case '/dashboard':
            builder = (_) => BlindDashboardScreen();
            break;
          case '/sos':
            builder = (_) => const sos_screen();
            break;
          case '/callVolunteer':
            builder = (_) => const CallVolunteerScreen();
            break;
          case '/volunteerDashboard':
            builder = (_) => const VolunteerDashboard();
            break;
          case '/history':
            builder = (_) => const VolunteerHistoryScreen();
            break;
          case '/emergency':
            builder = (_) => EmergencyScreen();
            break;
          case '/emergencyhelp':
            builder = (_) => EmergencyHelp();
            break;
          case '/offline':
            builder = (_) => OfflineScreen();
            break;
          case '/scene':
            builder = (_) => ScenedescriptionScreen();
            break;
          case '/settings':
            builder = (_) => SettingScreen();
            break;
          case '/editProfile':
            builder = (_) => const EditProfileScreen();
            break;
          case '/changePassword':
            builder = (_) => const ChangePasswordScreen();
            break;
          case '/editprofile':
            builder = (_) => const EditProfile();
            break;
          case '/forgetPassword':
            builder = (_) => const ForgetPasswordScreen();
            break;
          case '/call':
            builder = (_) => const CallScreen();
            break;
          case '/family':
            builder = (_) => FamilyDashboard();
            break;

          case '/volunteer':
            builder = (_) => VolunteerScreen();
            break;
          case '/blind':
            builder = (_) => BlindScreen();
            break;
          case '/volForgotPass':
            builder = (_) => VolForgotPasswordScreen();
            break;
          default:
            builder = (_) => const SplashScreen();
        }

        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (_, animation, __, child) {
            final tween = Tween(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeInOut));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    );
  }
}