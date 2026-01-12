/*import 'package:flutter/material.dart';

// 🔹 Import all screens (make sure these files exist in lib/)
import 'package:project/firebase_test.dart';
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
//import 'package:project/VolunteerLoginScreen.dart';
//import 'package:project/VolunteerRegScreen.dart';
import 'package:project/VolunteerScreen.dart';
import 'package:project/BlindScreen.dart';
import 'package:project/FamilyDashboard.dart';
import 'package:project/SmsScreen.dart';
import 'package:project/EditProfile.dart';
import 'package:project/LocationShareScreen.dart';
import 'package:project/VolForgotPasswordScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const SplashScreen(),

      // 🔹 Unified routes
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
            builder = (_) => sos_screen();
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

        // 🔹 Additional Routes
          case '/family':
            builder = (_) => FamilyDashboard();
            break;
          case '/sms':
            builder = (_) => SmsScreen(
              contactName: "John Doe",
              contactNumber: "+923001234567",
            );
            break;
        /*case '/volLogin':
            builder = (_) => VolunteerLoginScreen();
            break;
          case '/volreg':
            builder = (_) => VolunteerRegScreen();
            break;*/
          case '/volunteer':
            builder = (_) => VolunteerScreen();
            break;
          case '/blind':
            builder = (_) => BlindScreen();
            break;
          case '/volForgotPass':
            builder = (_) => VolForgotPasswordScreen();
            break;
        /*case '/location':
            builder = (_) =>  LocationShareScreen();
            break;*/

          default:
            builder = (_) => const SplashScreen();
        }

        // 🔹 Custom slide animation
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOut;

            var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        );
      },
    );
  }
}*/
import 'package:flutter/material.dart';

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
import 'package:project/SmsScreen.dart';
import 'package:project/EditProfile.dart';
import 'package:project/VolForgotPasswordScreen.dart';

// ✅ NEW IMPORT
import 'package:project/CallVolunteerScreen.dart';

void main() {
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

      home: const SplashScreen(),

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

          case '/callVolunteer': // ✅ ADDED
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

          case '/sms':
            builder = (_) => SmsScreen(
              contactName: "John Doe",
              contactNumber: "+923001234567",
            );
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
