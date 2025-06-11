import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/auth_service.dart';
import '../models/user_model.dart';
import 'owner_home.dart';
import 'foreman_home.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return StreamBuilder<User?>(
      stream: authService.user,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final user = snapshot.data;

          if (user == null) {
            return const LoginScreen();
          }

          return FutureBuilder<AppUser?>(
            future: authService._userFromFirebase(user),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (userSnapshot.hasData) {
                final appUser = userSnapshot.data;

                switch (appUser?.role) {
                  case 'owner':
                    return const OwnerHome();
                  case 'foreman':
                    return const ForemanHome();
                  default:
                    return const LoginScreen();
                }
              }

              return const LoginScreen();
            },
          );
        }

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
