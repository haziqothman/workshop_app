import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth/auth_service.dart';
import 'services/rating_service.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/foreman_home.dart';
import 'screens/owner_home.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialization successful');
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthService()),
          Provider(create: (_) => RatingService()),
        ],
        child: const MyApp(),
      ),
    );
  } catch (e) {
    print('Firebase initialization error: $e');
    runApp(
      MaterialApp(
        home: Scaffold(body: Center(child: Text('Firebase init failed: $e'))),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: true),
      ),
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/foreman': (context) => const ForemanHome(),
        '/owner': (context) => const OwnerHome(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        print('Auth state: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final user = snapshot.data;
        print('User status: ${user != null ? "Logged in" : "Not logged in"}');

        return user == null ? const LoginScreen() : const RoleHomeScreen();
      },
    );
  }
}

class RoleHomeScreen extends StatelessWidget {
  const RoleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    if (user == null) {
      print('User unexpectedly null in RoleHomeScreen');
      return const LoginScreen();
    }

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
      builder: (context, snapshot) {
        print('Role check state: ${snapshot.connectionState}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          print('Role check error: ${snapshot.error}');
          return Scaffold(body: Center(child: Text('Error loading user data')));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          print('User document missing');
          return Scaffold(body: Center(child: Text('User data not found')));
        }

        final role = snapshot.data!.get('role') ?? 'foreman';
        print('User role determined: $role');

        return role == 'workshop_owner'
            ? const OwnerHome()
            : const ForemanHome();
      },
    );
  }
}
