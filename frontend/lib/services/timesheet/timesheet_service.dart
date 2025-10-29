import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/timesheet/timesheet_entry.dart';
import '../../common/app_config.dart';

class TimesheetService {
  final String baseUrl;

  TimesheetService({this.baseUrl = AppConfig.timesheetServiceUrl});

  Future<List<TimesheetEntry>> fetchEntries() async {
    final response = await http.get(Uri.parse('$baseUrl/timesheet'));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => TimesheetEntry.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load timesheet entries');
    }
  }

  Future<void> submitEntry(TimesheetEntry entry) async {
    final response = await http.post(
      Uri.parse('$baseUrl/timesheet'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(entry.toJson()),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to submit timesheet entry');
    }
  }
}
