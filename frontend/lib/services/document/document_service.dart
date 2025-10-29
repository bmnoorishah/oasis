import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/document/document.dart';
import '../../common/app_config.dart';

class DocumentService {
  final String baseUrl;

  DocumentService({this.baseUrl = AppConfig.documentServiceUrl});

  Future<List<Document>> fetchDocuments() async {
    final response = await http.get(Uri.parse('$baseUrl/documents'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Document.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load documents');
    }
  }

  Future<Document> fetchDocumentById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/documents/$id'));
    if (response.statusCode == 200) {
      return Document.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load document');
    }
  }
}
