import 'package:flutter/material.dart';
import 'SettingScreen.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBack;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      leading: showBack
          ? IconButton(
        icon: const Icon(Icons.arrow_back,size: 20,color: Colors.white, // white rakho taake purple pe clear lage
          weight: 700,     ),
        onPressed: () {
          Navigator.pop(context);
        },
      )
          : null,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white, // ✅ white title
          fontSize: 20,        // ✅ size 28
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,

      actions: [
        IconButton(
          icon: const Icon(Icons.settings,size: 20,color: Colors.white, // white rakho taake purple pe clear lage
            weight: 700,    ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  SettingScreen()),
            );
          },
        ),
      ],
      backgroundColor: Colors.purple, // default color, aap change kar sakti ho
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}