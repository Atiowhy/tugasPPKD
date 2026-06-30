import 'dart:convert';
import 'dart:io';

void printRequestDetails(Map<String, dynamic> item, [String prefix = '']) {
  final name = item['name'] ?? 'Unnamed';
  if (item.containsKey('item')) {
    // It's a folder
    for (var child in item['item']) {
      printRequestDetails(child, '$prefix$name / ');
    }
    return;
  }
  if (!item.containsKey('request')) return;
  
  final req = item['request'] as Map<String, dynamic>;
  final method = req['method'] ?? 'UNKNOWN';
  var url = '';
  if (req['url'] is Map) {
    url = req['url']['raw'] ?? '';
  } else if (req['url'] is String) {
    url = req['url'];
  }
  
  // Filter only the endpoints we care about
  final targetNames = ['GET - List Trainings (Public)', 'GET - List All Batches'];
  if (!targetNames.contains(name)) return;
  
  print('=== $prefix$name [$method] $url ===');
  
  // Headers
  if (req.containsKey('header') && req['header'] is List) {
    print('Headers:');
    for (var h in req['header']) {
      print('  ${h['key']}: ${h['value']}');
    }
  }
  
  // Auth
  if (req.containsKey('auth')) {
    final auth = req['auth'];
    print('Auth: ${auth['type']}');
    if (auth['type'] == 'bearer' && auth.containsKey('bearer')) {
      for (var b in auth['bearer']) {
        if (b['key'] == 'token') {
          final tokenVal = b['value']?.toString() ?? '';
          print('  Token: ${tokenVal.length > 50 ? tokenVal.substring(0, 50) + "..." : tokenVal}');
        }
      }
    }
  }
  
  // Body
  if (req.containsKey('body')) {
    final body = req['body'] as Map<String, dynamic>;
    final mode = body['mode'];
    print('Body mode: $mode');
    if (mode == 'raw') {
      var raw = body['raw']?.toString() ?? '';
      // Truncate base64 data
      if (raw.length > 500) {
        raw = raw.substring(0, 500) + '... [TRUNCATED]';
      }
      print('Body raw: $raw');
    } else if (mode == 'formdata') {
      print('Formdata fields:');
      for (var fd in body['formdata'] ?? []) {
        final type = fd['type'] ?? 'text';
        final key = fd['key'] ?? '';
        final value = fd['value']?.toString() ?? fd['src']?.toString() ?? '';
        print('  $key ($type): ${value.length > 100 ? value.substring(0, 100) + "..." : value}');
      }
    }
  }
  
  // Response examples
  if (item.containsKey('response') && item['response'] is List) {
    final responses = item['response'] as List;
    print('Response examples: ${responses.length}');
    for (var resp in responses) {
      final respName = resp['name'] ?? '';
      final status = resp['status'] ?? '';
      final code = resp['code'] ?? '';
      var respBody = resp['body']?.toString() ?? '';
      if (respBody.length > 500) {
        respBody = respBody.substring(0, 500) + '... [TRUNCATED]';
      }
      print('  [$code $status] $respName');
      print('  Body: $respBody');
    }
  }
  
  print('');
}

void main() async {
  final filePath = 'D:/AppPro/tugas15flutter/ABSENSI PPKD B6 Latihan.postman_collection.json';
  final file = File(filePath);
  final content = await file.readAsString();
  final data = jsonDecode(content) as Map<String, dynamic>;
  
  // Base URL variable
  if (data.containsKey('variable')) {
    print('Variables:');
    for (var v in data['variable']) {
      print('  ${v['key']}: ${v['value']}');
    }
    print('');
  }
  
  final items = data['item'] as List;
  for (var item in items) {
    printRequestDetails(item);
  }
}
