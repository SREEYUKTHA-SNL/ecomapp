import 'package:flutter/material.dart';

class CustomMenu extends StatelessWidget {
  final List<MenuOption> menuOptions;

  const CustomMenu({Key? key, required this.menuOptions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          AppBar(
            title: const Text(
              'Menu',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.teal,
            automaticallyImplyLeading: false,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: menuOptions.map((option) {
                return Column(
                  children: [
                    ListTile(
                      leading:Icon(option.icon),
                      title: Text(
                        option.text,
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => option.page),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// Model for menu option
class MenuOption {
  final String text;
  final Widget page;
  final IconData icon;

  MenuOption( {required this.text, required this.page,required this.icon,});
}
