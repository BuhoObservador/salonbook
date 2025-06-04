import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonbook/models/model.dart';
import 'package:salonbook/pages/admin/admin_dashboard.dart';
import 'package:salonbook/pages/auth_page.dart';
import 'package:salonbook/pages/salonbook.dart';

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final model = Provider.of<Model>(context);

    if (model.auth.currentUser != null) {

      return FutureBuilder<bool>(
        future: model.isUserAdmin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.data == true) {
            return const AdminDashboard();
          } else {
            return const SalonBook();
          }
        },
      );
    } else {

      return LoginRegister(savedThemeMode: AdaptiveTheme.of(context).mode);
    }
  }
}