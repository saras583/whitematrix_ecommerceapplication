import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whitematrix_app/controller/auth_controller.dart';
import 'package:whitematrix_app/controller/cart_controller.dart';
import 'package:whitematrix_app/controller/product_controller.dart';
import 'package:whitematrix_app/controller/wishlist_controller.dart';
import 'package:whitematrix_app/core/theme.dart';
import 'package:whitematrix_app/view/screen/home_screen.dart';
import 'package:whitematrix_app/view/screen/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()..init()),
        ChangeNotifierProvider(create: (_) => ProductController()..init()),
        ChangeNotifierProvider(create: (_) => WishlistController()..init()),
        ChangeNotifierProvider(create: (_) => CartController()),
      ],
      child: const ShopApp(),
    ),
  );
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morrow Shop',
      theme: AppTheme.light,
      home: Consumer<AuthController>(
        builder: (_, auth, _) {
          if (!auth.isInitialised) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            );
          }

          return auth.isLoggedIn ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
