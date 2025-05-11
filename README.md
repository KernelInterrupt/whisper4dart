# whisper4dart

whisper4dart is a dart wrapper for [whisper.cpp](https://github.com/ggerganov/whisper.cpp), designed to offer an all-in-one speech recognition experience. With the built-in decoder/demuxer from ffmpeg, it can handle **most audio/video file** inputs, not just wav.

| Platform | Status |
| :------: | :----: |
| Windows |   ✅   |
|  Linux  |   ✅   |
| Android |   ✅   |
|   iOS   |   ❌   |
|  MacOS  |   ❌   |

iOS and MacOS version of whisper4dart will be available in the near future. However, we have no intention to support web platform, at least now.

## Getting Started

```
flutter pub add whisper4dart
```

or add following line to your `pubspec.yaml`:

```
    whisper4dart:^0.1.4
```

After that,run following command in your terminal:

```
dart rum libmpv_dart:setup --platform <your-platform>
```

(For example,you need to run:`dart run libmpv_dart:setup --platform windows` if you want to setup for windows.)

And then,run:

```
dart run whisper4dart:setup  --prebuilt
```

Attention:If you want to build whisper.cpp by yourself instead of using prebuilt libs,run following command:

```
dart run whisper4dart:setup --source
```

OK,now you are ready to use the package,enjoy it!

## How to use

```dart

import 'package:whisper4dart/whisper4dart.dart' as whisper;

final Directory tempDirectory = await getTemporaryDirectory();
final ByteData documentBytes = await rootBundle.load(inputPath);
await File(inputPath).writeAsBytes(
    documentBytes.buffer.asUint8List(),
);
//preprocess the file,if the file is not in assets/ ,you don't need to use the code above.

final String logPath = '${tempDirectory.path}/log.txt';


var cparams=whisper4dart.createContextDefaultParams();
//create default parameters,you can modify it on your demand.

var buffer=await rootBundle.load("assets/ggml-base.en.bin");
Uint8List model=buffer.buffer.asUint8List();
//if your model file is not in assets/ ,you dont need to do so,
//and you just need to pass the file path of model to initialize whisper.
//Like this: var model="path/to/your/model";

var whisperModel=whisper.Whisper(model,cparams,outputMode:"plaintext");
//initialize whisper model
//The "outputMode" variable determines the output format. There are four options:
//"plaintext": Outputs plain text
//"txt": Outputs text-formatted strings
//"json": Outputs JSON-formatted strings
//"srt": Outputs SRT-subtitle-formatted strings
String output=await whisperModel.infer(inputPath,
logPath: logPath,
numProcessors: 1,
translate:False,
initialPrompt:"",
startTime:0,
endTime:-1,
useOriginalTime:true);
//The core function whisper.infer takes "inputPath" as the audio file path (e.g., /tmp/jfk.mp3).
//Specifying "logPath" directs whisper4dart to save encoder/demuxer logs in that directory.
//"translate" determines if the output should be translated into English.
//Use "initialPrompt" to set the model's initial prompt.
//"startTime" and "endTime" define the segment of the audio to process (unit: milliseconds).
//Setting "endTime" to -1 means no end cropping is needed.
//When "useOriginalTime" is set to true, the timestamps are based on the start of the original audio, 
//not the start of the cropped audio. This means that regardless of whether the audio has 
//been cropped, the timestamps always reference the timeline of the original audio.
```

Sample output strings of the four output modes:(input file:jfk.wav)

`plaintext`:

```
 And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.
```

`txt`:

```
 And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.
```

`json`:

```json
[{"multilingual":"false"},{"language":"en"},{"from":"00:00:00.000","to":"00:00:11.000","text":" And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country."}]
```

`srt`:

```
1
00:00:00,000 --> 00:00:11,000
 And so my fellow Americans, ask not what your country can do for you, ask what you can do for your country.
```

## Run in isolate

Just use `.inferIsolate()` to replace `.infer()` .

## Output the transcription result in real time

Just use `.inferStream()` to replace `.infer()` .

This method returns a tuple `(ValueNotifier<String>, ValueNotifier<int>)`.(known as a **record** in Dart) You can use these returned notifiers to build your widgets.

The first notifier `(ValueNotifier<String>)` provides the output strings, while the second `(ValueNotifier<int>)` tracks the progress.

(e.g., if the transcription is 50% complete, the value of the progress notifier will be 50.)

> [!CAUTION]
> In this mode,json output is not supported and you have to set numProcessors to 1.

## Acknowledgement

This project leverages contributions from[ libmpv_dart ](https://github.com/Playboy-Player/libmpv_dart)and [whisper.cpp](https://github.com/ggerganov/whisper.cpp)
