import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {

  static late Interpreter interpreter;

  static List<String> labels = [];

  // ================= LOAD MODEL =================

  static Future<void> loadModel() async {

    print("INSIDE LOAD MODEL");

    interpreter = await Interpreter.fromAsset(
      'assets/model/model_float32.tflite',
    );

    print("INTERPRETER CREATED");

    final labelData =
    await rootBundle.loadString(
      'assets/model/labels.txt',
    );

    labels = labelData
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    print("LABELS LOADED: ${labels.length}");
  }

  // ================= PREDICT =================

  // ================= PREDICT =================

  static Future<Map<String, dynamic>> predict(
      File imageFile
      ) async {

    final bytes =
    await imageFile.readAsBytes();

    img.Image? image =
    img.decodeImage(bytes);

    image = img.copyResize(
      image!,
      width: 224,
      height: 224,
    );

    var input = List.generate(
      1,
          (_) => List.generate(
        224,
            (_) => List.generate(
          224,
              (_) => List.filled(3, 0.0),
        ),
      ),
    );

    for (int y = 0; y < 224; y++) {

      for (int x = 0; x < 224; x++) {

        final pixel = image.getPixel(x, y);

        input[0][y][x][0] =
            pixel.r / 255.0;

        input[0][y][x][1] =
            pixel.g / 255.0;

        input[0][y][x][2] =
            pixel.b / 255.0;
      }
    }

    print("LABEL COUNT: ${labels.length}");

    var output = [
      List.filled(labels.length, 0.0)
    ];
    print("INPUT SHAPE: ${interpreter.getInputTensor(0).shape}");
    print("OUTPUT SHAPE: ${interpreter.getOutputTensor(0).shape}");
    print("LABEL COUNT: ${labels.length}");

    print("BEFORE RUN");

    interpreter.run(input, output);

    print("AFTER RUN");
    print(output);

    int maxIndex = 0;
    double maxConfidence = 0;

    for (int i = 0; i < labels.length; i++) {

      if (output[0][i] > maxConfidence) {

        maxConfidence = output[0][i];
        maxIndex = i;
      }
    }

    print("MAX INDEX: $maxIndex");
    print("MAX CONFIDENCE: $maxConfidence");

    if (labels.isEmpty) {

      throw Exception(
          "labels.txt kosong atau gagal dibaca"
      );
    }

    return {
      "prediction": labels[maxIndex],
      "confidence": maxConfidence,
    };
  }
}