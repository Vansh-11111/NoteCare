import 'package:flutter/material.dart';

// A full-width button that pushes to a given page. Extracted so the list
// of placeholder pages in HomeScreen isn't repeating the same Padding/
// SizedBox/ElevatedButton boilerplate three times.
class NavButton extends StatelessWidget {
  final String title;
  final Widget page;

  const NavButton({super.key, required this.title, required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => page));
          },
          child: Text(title),
        ),
      ),
    );
  }
}
