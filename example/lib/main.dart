import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart' as path;
import 'package:whisper4dart/whisper4dart.dart' as whisper;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

Future<String> inference(String inputPath) async {
  final Directory tempDirectory = await getTemporaryDirectory();
// final ByteData documentBytes = await rootBundle.load(inputPath);

  final String logPath = path.join(tempDirectory.path, "log.txt");
// await File(inputPath).writeAsBytes(
//     documentBytes.buffer.asUint8List(),
// );

  var buffer = await rootBundle.load("assets/ggml-base.en.bin");
  Uint8List model = buffer.buffer.asUint8List();
  var cparams = whisper.createContextDefaultParams();
  var whisperModel = whisper.Whisper(model, cparams,
      outputMode: "plaintext", initMode: "late");
  return whisperModel.inferIsolate(inputPath,
      logPath: logPath, numProcessors: 1, startTime: 3000);
}

Future<(ValueNotifier<String>,ValueNotifier<int>)> inferenceStream(String inputPath) async {
  final Directory tempDirectory = await getTemporaryDirectory();
// final ByteData documentBytes = await rootBundle.load(inputPath);

  final String logPath = path.join(tempDirectory.path, "log.txt");
// await File(inputPath).writeAsBytes(
//     documentBytes.buffer.asUint8List(),
// );

  var buffer = await rootBundle.load("assets/ggml-base.en.bin");
  Uint8List model = buffer.buffer.asUint8List();
  var cparams = whisper.createContextDefaultParams();
  var whisperModel = whisper.Whisper(model, cparams, outputMode: "plaintext");
  return whisperModel.inferStream(inputPath,
      logPath: logPath, numProcessors: 1, startTime: 0);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ValueNotifier<String> _textNotifier = ValueNotifier<String>('');
  ValueNotifier<int> _progressNotifier = ValueNotifier<int>(0);
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 25);
    const spacerSmall = SizedBox(height: 10);
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Native Packages'),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                const Text(
                  'Here we have two buttons. '
                  'The first button processes all the audio for transcription at once and prints it to the console. The second button processes the audio in chunks and presents the results progressively in the TextField.',
                  style: textStyle,
                  textAlign: TextAlign.center,
                ),
                spacerSmall,
                ElevatedButton(
                    onPressed: () async {
                      print(await inference("assets/test.m4a"));
                    },
                    child: const Text("Do inference at once")),
                ElevatedButton(
                  onPressed: () async {
                    var (resultNotifier,progressMotifier) = await inferenceStream("assets/test.m4a");
                    setState(() {
                      _textNotifier = resultNotifier;
                      _progressNotifier = progressMotifier;
                    });

                    // print(await inference("assets/test4.mp4"));
                  },
                  child: const Text("Do inference progressively"),
                ),
                spacerSmall,
                 ValueListenableBuilder<int>(
              valueListenable: _progressNotifier,
              builder: (context, value, child) {
                return Text("progress: $value");
              },
            ),
                ValueListenableBuilder<String>(
                  valueListenable: _textNotifier,
                  builder: (context, value, child) {
                    return SingleChildScrollView(
                        child: TextField(
                      // 设置文本框为只读，不允许用户输入
                      readOnly: true,
                      maxLines: null,
                      // 设置文本框的控制器，使其显示notifier的值
                      controller: TextEditingController(text: value),
                    ));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
