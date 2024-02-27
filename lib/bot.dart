import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemini_bot/model/Message.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:vertex_ai/vertex_ai.dart';

class ChatBot extends StatefulWidget {
  VertexAIGenAIClient vertexAi;

  ChatBot(this.vertexAi);

  @override
  _ChatBotState createState() => _ChatBotState();
}

class _ChatBotState extends State<ChatBot> {
  List<Message> messages = [];
  bool isLoading = false; // Biến cờ kiểm soát trạng thái loading
  ScrollController _scrollController = ScrollController(); // Add this line

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Flutter Chat App'),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: messages.length,
                controller: _scrollController,
                itemBuilder: (context, index) {
                  Message message = messages[index];
                  return ChatMessageWidget(message: message);
                },
              ),
            ),
            isLoading ? const CircularProgressIndicator() : const SizedBox(),
            _buildInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField() {
    TextEditingController textController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'Type your message...',
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () async {
              String content = textController.text;
              if (content.isNotEmpty) {
                // Hiển thị tin nhắn trước khi gọi API

                setState(() {
                  messages.add(Message(
                    DateTime.now().microsecondsSinceEpoch.toString(),
                    content,
                    true,
                  ));
                });

                // Hiển thị loading
                setState(() {
                  isLoading = true;
                });
                // Gọi API
                final res = await widget.vertexAi.text.predict(prompt: content);
                print(res);
                VertexAITextModelPrediction reply = res.predictions[0];

                // Tắt loading và hiển thị tin nhắn của AI
                setState(() {
                  isLoading = false;
                  messages.add(Message(
                    DateTime.now().microsecondsSinceEpoch.toString(),
                    reply.content ?? "Đang xảy ra lỗi với AI",
                    false,
                  ));
                });
                _scrollController.animateTo(
                  _scrollController.position.maxScrollExtent,
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

class ChatMessageWidget extends StatelessWidget {
  final Message message;

  const ChatMessageWidget({Key? key, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:
          message.isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isMyMessage ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
