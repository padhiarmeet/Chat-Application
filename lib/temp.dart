import 'dart:ui';
import 'package:flutter/material.dart';

class SimpleChatAppBar extends StatelessWidget {
  // Constructor with optional parameters
  const SimpleChatAppBar({
    Key? key,
    this.onSearchPressed,
    this.onLogoutPressed,
  }) : super(key: key);

  // Callback functions
  final VoidCallback? onSearchPressed;
  final VoidCallback? onLogoutPressed;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent.withOpacity(0.5),
      elevation: 0,
      titleSpacing: 0,
      flexibleSpace: Stack(
        children: [
          // First layer: Colored background that will be blurred
          Container(
            color: Colors.transparent.withOpacity(0.6),
          ),

          // Second layer: Blur effect on the background
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 30),
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
        ],
      ),
      title: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: Row(
          children: [
            // Avatar with gradient background
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withBlue(
                        (Theme.of(context).primaryColor.blue + 40)
                            .clamp(0, 255)),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(23),
              ),
              child: Center(
                child: Text(
                  "G",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12),

            // Contact name and status
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 155,
                  child: Text(
                    "Gokul Chat",
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: Colors.white
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        // Search button
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: onSearchPressed,
        ),

        // Logout button
        Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: onLogoutPressed,
            splashRadius: 24,
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(10),
        child: Container(),
      ),
    );
  }
}

// Example of how to use this simple AppBar in a Scaffold
/*
Scaffold(
  appBar: SimpleChatAppBar(
    onSearchPressed: () {
      // Handle search
    },
    onLogoutPressed: () {
      // Handle logout
    },
  ),
  body: YourChatBodyWidget(),
)
*/