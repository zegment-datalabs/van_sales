import 'package:flutter/material.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onLogout;

  const CommonAppBar({
    super.key,
    required this.title,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.teal,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      actions: [
        if (onLogout != null)
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: onLogout,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
class CommonButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(label, style: const TextStyle(fontSize: 18, color: Colors.white)),
    );
  }
}