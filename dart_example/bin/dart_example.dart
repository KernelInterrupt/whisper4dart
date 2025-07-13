import 'dart:io';

import 'package:whisper4dart/other.dart' as whisper;
import 'package:whisper4dart/whisper.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.length < 2) {
    print('Usage: dart dart_example.dart <input_audio_path> <model_path>');
    exit(1);
  }
  final String inputPath = arguments[0];
  final String modelPath = arguments[1];

  final Directory tempDirectory = Directory.systemTemp;
  final String logPath = '${tempDirectory.path}/log.txt';

  var cparams = whisper.createContextDefaultParams();
  // You can modify cparams as needed.

  // For native, just pass the model file path
  var whisperModel = Whisper(modelPath, cparams, outputMode: "plaintext");
  // initialize whisper model

  String output = await whisperModel.infer(
    inputPath,
    logPath: logPath,
    numProcessors: 1,
    translate: false,
    initialPrompt: "",
    startTime: 0,
    endTime: -1,
    useOriginalTime: true,
  );

  print('Transcription result:');
  print(output);
}
