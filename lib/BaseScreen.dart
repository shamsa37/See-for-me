import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final String title;
  final Widget body;
  final bool showBackButton;

  const BaseScreen({
    Key? key,
    required this.title,
    required this.body,
    this.showBackButton = true, // default back button visible
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        leading: showBackButton
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        )
            : null,
      ),
      body: body,
    );
  }
}