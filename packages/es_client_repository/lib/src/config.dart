import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:es_client_repository/src/indices.dart';
import 'package:logger/logger.dart';

abstract class EsConfig {
  /// Creates an instance of [Dio] client that handles elasticsearch calls with custom HttpClient for ca fingerprint verification.
  /// Prepares indices on app start up if not prepared.
  static Future<Dio> setup(Map<String, String> env) async {
    final log = Logger(printer: SimplePrinter())..i("Setting up elasticsearch...");

    try {
      final dio = Dio(
        BaseOptions(
          baseUrl: env["ELASTIC_URL"]!,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            HttpHeaders.userAgentHeader: "dio",
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.authorizationHeader: "Basic ${base64.encode(utf8.encode("${env["ELASTIC_USERNAME"]!}:${env["ELASTIC_PASSWORD"]}"))}"
          }
        )
      );

      final httpClient = HttpClient();
      httpClient.badCertificateCallback = (cert, host, port) => sha256.convert(cert.der).toString() == env["ELASTIC_CA_FINGERPRINT"];


      dio.httpClientAdapter = IOHttpClientAdapter()..createHttpClient = () => httpClient;

      await _setupIndices(dio, log);

      log.i("Elasticsearch setup successful");

      return dio;
    } catch (e) {
      throw Exception(e);
    }
  }

  /// Sets up elasticsearch indices if they are not set.
  static Future<void> _setupIndices(Dio esClient, Logger log) async {
    log.i("Setting up indices if needed");

    for (var index in indices.keys) {
      try {
        await esClient.get("/$index");

        log.i("Index \"$index\" exists");
      } on DioException catch (e) {
        if (e.response?.statusCode == 404) {
          log.i("Index \"$index\" is missing, creating...");

          await esClient.put("/$index", data: indices[index]);
          
          log.i("Index \"$index\" added successfully");
        } else {
          log.e("Error checking index \"$index\": $e");
          throw Exception("Failed to check index \"$index\"");
        }
      }
    }
  }
}
