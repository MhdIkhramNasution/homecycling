import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {

  static late Interpreter interpreter;
  static List<String> labels = [];

  // Model input size (confirmed from model_float32.tflite)
  static const int inputSize = 224;

  // ================= LOAD MODEL =================

  static Future<void> loadModel() async {
    print("INSIDE LOAD MODEL");

    interpreter = await Interpreter.fromAsset(
      'assets/model/model_float32.tflite',
    );

    print("INTERPRETER CREATED");

    final labelData = await rootBundle.loadString(
      'assets/model/labels.txt',
    );

    labels = labelData
        .split('\n')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    print("LABELS LOADED: ${labels.length}");

    // Sanity check: model output shape is [1, 36]
    final outputShape = interpreter.getOutputTensor(0).shape;
    if (outputShape[1] != labels.length) {
      print(
        "WARNING: Model output has ${outputShape[1]} classes "
            "but labels.txt has ${labels.length} entries. "
            "Prediction results may be incorrect.",
      );
    }
  }

  // ================= PREDICT =================

  static Future<Map<String, dynamic>> predict(File imageFile) async {
    if (labels.isEmpty) {
      throw Exception("Labels belum dimuat. Panggil loadModel() terlebih dahulu.");
    }

    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception("Gagal mendekode gambar.");
    }

    image = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final inputBytes = Float32List(1 * inputSize * inputSize * 3);
    int idx = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        inputBytes[idx++] = (pixel.r / 127.5) - 1.0;
        inputBytes[idx++] = (pixel.g / 127.5) - 1.0;
        inputBytes[idx++] = (pixel.b / 127.5) - 1.0;
      }
    }

    final input = inputBytes.buffer.asFloat32List().reshape([1, inputSize, inputSize, 3]);

    final outputShape = interpreter.getOutputTensor(0).shape; // [1, 36]
    final numClasses = outputShape[1];
    final outputBuffer = [List<double>.filled(numClasses, 0.0)];

    print("INPUT SHAPE : ${interpreter.getInputTensor(0).shape}");
    print("OUTPUT SHAPE: ${interpreter.getOutputTensor(0).shape}");
    print("LABEL COUNT : ${labels.length}");
    print("BEFORE RUN");

    interpreter.run(input, outputBuffer);

    print("AFTER RUN");
    print(outputBuffer);

    int maxIndex = 0;
    double maxConfidence = outputBuffer[0][0];

    for (int i = 1; i < numClasses; i++) {
      if (outputBuffer[0][i] > maxConfidence) {
        maxConfidence = outputBuffer[0][i];
        maxIndex = i;
      }
    }

    print("MAX INDEX     : $maxIndex");
    print("MAX CONFIDENCE: $maxConfidence");

    if (maxIndex >= labels.length) {
      throw Exception(
        "Index prediksi ($maxIndex) melebihi jumlah label (${labels.length}). "
            "Pastikan labels.txt memiliki tepat $numClasses entri.",
      );
    }

    return {
      "prediction": labels[maxIndex],
      "confidence": maxConfidence,
    };
  }
}