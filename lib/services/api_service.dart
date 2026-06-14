// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// class ApiService {
//
//   Future<String> detectImage(File image) async {
//
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('http://127.0.0.1:8000/detect/'),
//     );
//
//     request.files.add(
//       await http.MultipartFile.fromPath('file', image.path),
//     );
//
//     var response = await request.send();
//
//     return await response.stream.bytesToString();
//   }
// }

// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// class ApiService {
//   // ⚠️ CHANGE THIS based on emulator / mobile
//   final String baseUrl = "http://192.168.x.x:8000";
//
//   Future<String> detectImage(File image) async {
//     var request = http.MultipartRequest(
//       'POST',
//       Uri.parse('$baseUrl/detect/'),
//     );
//
//     request.files.add(
//       await http.MultipartFile.fromPath('file', image.path),
//     );
//
//     var response = await request.send();
//
//     if (response.statusCode == 200) {
//       return await response.stream.bytesToString();
//     } else {
//       return '{"objects": []}';
//     }
//   }
// }


import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  final String baseUrl = "http://192.168.10.18:8000";

  Future<String> detectImage(File image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/detect'),
      );

      // ✅ Content-Type add karo
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          image.path,
          contentType: MediaType('image', 'jpeg'), // ← ADD THIS
        ),
      );

      print("🌐 Sending request to: $baseUrl/detect");
      print("📁 File: ${image.path}");

      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      var response = await http.Response.fromStream(streamedResponse);

      print("📡 Response Status: ${response.statusCode}");
      print("📦 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        return response.body;
      } else {
        print("❌ Server Error: ${response.statusCode}");
        return '{"success": false, "objects": ["Server Error"]}';
      }
    } on SocketException catch (e) {
      print("❌ Connection Error: $e");
      return '{"success": false, "objects": ["No Internet"]}';
    } catch (e) {
      print("❌ Error: $e");
      return '{"success": false, "objects": ["Error: $e"]}';
    }
  }
}