import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gemini_bot/bot.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:vertex_ai/vertex_ai.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final String serviceAccountJson =
      await rootBundle.loadString('assets/sample.json');
  final serviceAccountCredentials = ServiceAccountCredentials.fromJson(
    json.decode(serviceAccountJson),
  );
  final authClient = await clientViaServiceAccount(
    serviceAccountCredentials,
    [VertexAIGenAIClient.cloudPlatformScope],
  );
  VertexAIGenAIClient vertexAi = VertexAIGenAIClient(
    httpClient: authClient,
    project: 'igneous-study-414903',
  );
  vertexAi.text.predict(prompt: "Cho tôi lời khuyên về sức khỏe").then((res) {
    // VertexAITextModelPrediction reply = res.predictions[0];
    print(res);
  });
  runApp(MaterialApp(
    home: ChatBot(vertexAi),
  ));
}
