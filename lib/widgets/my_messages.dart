import 'package:final_project_ppb/models/chat.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class MyMessageWidget extends StatelessWidget {
  const MyMessageWidget({super.key, required this.message});

  final Chat message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        margin: const EdgeInsets.only(bottom: 8),
        child: Column(
          children: [
            MarkdownBody(selectable: true, data: message.answer.toString()),
          ],
        ),
      ),
    );
  }
}
