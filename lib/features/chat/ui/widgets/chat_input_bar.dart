import 'package:flutter/material.dart';
import 'package:itc_chat/core/widgets/widgets.dart';

class ChatInputBar extends StatelessWidget {
  const ChatInputBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(inputDecorationTheme: InputDecorationTheme()),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: GlassEffect(
              borderRadius: BorderRadiusGeometry.circular(30),
              child: CircleAvatar(
                backgroundColor: Colors.transparent,
                radius: 26,
                child: Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: GlassEffect(
              borderRadius: BorderRadius.circular(20),
              child: TextField(
                style: TextStyle(color: Colors.white),
                minLines: 1,
                maxLines: 4,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Ask AI',
                  hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.only(left: 20, right: 10, top: 14, bottom: 14),
                  suffixIcon: CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.send_outlined, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
