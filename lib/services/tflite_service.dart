import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteService {
  static Interpreter? _interpreter;

  static List<String> labels = [];

  static const int inputSize = 224;

  static const double confidenceThreshold = 0.50;

  // ================= LOAD MODEL =================

  static Future<void> loadModel() async {
    try {
      print("LOADING MODEL...");

      _interpreter?.close();

      _interpreter = await Interpreter.fromAsset(
        "assets/model/model_float32.tflite",
      );

      print("MODEL LOADED");

      final labelData = await rootBundle.loadString(
        "assets/model/labels.txt",
      );

      labels = labelData
          .split("\n")
          .where((e) => e.trim().isNotEmpty)
          .toList();

      print("LABEL COUNT: ${labels.length}");

      print(
        "INPUT SHAPE: ${_interpreter!.getInputTensor(0).shape}",
      );

      print(
        "OUTPUT SHAPE: ${_interpreter!.getOutputTensor(0).shape}",
      );

      print(
        "INPUT TYPE: ${_interpreter!.getInputTensor(0).type}",
      );

      print(
        "OUTPUT TYPE: ${_interpreter!.getOutputTensor(0).type}",
      );
    } catch (e) {
      print("LOAD MODEL ERROR");
      print(e);
      rethrow;
    }
  }

  // ================= PREDICT =================

  static Future<Map<String, dynamic>> predict(
      File imageFile,
      ) async {
    if (_interpreter == null) {
      throw Exception("Model belum dimuat");
    }

    final bytes = await imageFile.readAsBytes();

    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      throw Exception("Gagal membaca gambar");
    }

    // ================= FIX ORIENTATION =================

    image = img.bakeOrientation(image);

    // ================= CENTER CROP =================

    final cropSize =
    image.width < image.height
        ? image.width
        : image.height;

    image = img.copyCrop(
      image,
      x: (image.width - cropSize) ~/ 2,
      y: (image.height - cropSize) ~/ 2,
      width: cropSize,
      height: cropSize,
    );

    // ================= RESIZE =================

    image = img.copyResize(
      image,
      width: inputSize,
      height: inputSize,
      interpolation: img.Interpolation.linear,
    );

    final input = Float32List(
      1 * inputSize * inputSize * 3,
    );

    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);

        // Normalisasi MobileNet

        input[index++] =
            (pixel.r / 127.5) - 1.0;

        input[index++] =
            (pixel.g / 127.5) - 1.0;

        input[index++] =
            (pixel.b / 127.5) - 1.0;
      }
    }

    final inputTensor = input.reshape([
      1,
      inputSize,
      inputSize,
      3,
    ]);

    final outputShape =
        _interpreter!
            .getOutputTensor(0)
            .shape;

    final numClasses =
    outputShape[1];

    final rawOutput =
    Float32List(numClasses);

    final output =
    rawOutput.reshape([
      1,
      numClasses,
    ]);

    _interpreter!.run(
      inputTensor,
      output,
    );
    print("RAW OUTPUT:");
    print(rawOutput);

    final probabilities =
    _softmax(rawOutput);

    // ================= DEBUG =================

    print("========== TOP PREDICTION ==========");

    for (int i = 0; i < labels.length; i++) {
      print(
        "${labels[i]} : ${(probabilities[i] * 100).toStringAsFixed(2)}%",
      );
    }

    // ================= FIND BEST =================

    int maxIndex = 0;

    double maxConfidence =
    probabilities[0];

    for (int i = 1;
    i < probabilities.length;
    i++) {
      if (probabilities[i] >
          maxConfidence) {
        maxConfidence =
        probabilities[i];

        maxIndex = i;
      }
    }

    final prediction =
    labels[maxIndex];

    final reliable =
        maxConfidence >=
            confidenceThreshold;

    print(
      "FINAL: $prediction (${(maxConfidence * 100).toStringAsFixed(2)}%)",
    );

    return {
      "prediction":
      reliable
          ? prediction
          : "Tidak dikenali",

      "confidence":
      maxConfidence,

      "reliable":
      reliable,

      "top3":
      _getTopK(
        probabilities,
        3,
      ),
    };
  }

  // ================= SOFTMAX =================

  static List<double> _softmax(
      List<double> logits,
      ) {
    final maxValue =
    logits.reduce(max);

    final exps =
    logits
        .map(
          (e) =>
          exp(e - maxValue),
    )
        .toList();

    final sum =
    exps.reduce(
          (a, b) => a + b,
    );

    return exps
        .map(
          (e) => e / sum,
    )
        .toList();
  }

  // ================= TOP K =================

  static List<Map<String, dynamic>>
  _getTopK(
      List<double> scores,
      int k,
      ) {
    final indexed =
    List.generate(
      scores.length,
          (i) =>
          MapEntry(
            i,
            scores[i],
          ),
    );

    indexed.sort(
          (a, b) =>
          b.value.compareTo(
            a.value,
          ),
    );

    return indexed
        .take(k)
        .map(
          (e) => {
        "label":
        labels[e.key],
        "confidence":
        e.value,
      },
    )
        .toList();
  }

  // ================= DISPOSE =================

  static void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}