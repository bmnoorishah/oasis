import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/report/report.dart';
import '../../common/app_config.dart';

class ReportService {
  final String baseUrl;

  ReportService({this.baseUrl = AppConfig.reportServiceUrl});

  Future<List<Report>> fetchReports() async {
    final response = await http.get(Uri.parse('$baseUrl/reports'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => Report.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load reports');
    }
  }
}
