import 'package:flutter/material.dart';
import 'package:placeholder/widgets/appbar.dart';

class GeneralAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title;
  final List<Widget> actions;

  const GeneralAppBar({required this.title, required this.actions});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title is String
          ? Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : title,
      actions: actions,
      leading: IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          color: Colors.white,
        ),
        onPressed: () {},
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}
