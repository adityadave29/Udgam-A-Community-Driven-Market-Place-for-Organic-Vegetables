import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(25), // Rounded edges
          border: Border.all(
            color: Colors.green[700]!, // Green border for organic theme
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(
                Icons.search,
                color: Colors.green, // Matching icon color
              ),
            ),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search organic products...',
                  hintStyle: TextStyle(color: Colors.white),
                  border: InputBorder.none, // No extra border inside
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
