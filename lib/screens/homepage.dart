import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:van_sales/screens/login_page.dart';
import 'package:van_sales/widgets/common_widgets.dart';
import 'package:van_sales/screens/ordermanagement.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _username = "User";
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? "User";
      _profileImageUrl = prefs.getString('profilePicPath') ?? "";
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(title: 'Home', onLogout: _logout),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Section
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl.isNotEmpty
                        ? NetworkImage(_profileImageUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Welcome, $_username!",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Grid Layout for Navigation Buttons
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // Two columns
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  CommonGridButton(
                    label: 'Order Management',
                    icon: Icons.shopping_cart,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const OrderManagementPage()),
                      );
                    },
                  ),
                  CommonGridButton(
                    label: 'Substock Summary',
                    icon: Icons.inventory,
                    onPressed: () {},
                  ),
                  CommonGridButton(
                    label: 'Reconcile',
                    icon: Icons.compare_arrows,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}