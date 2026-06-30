import 'dart:convert';
import 'dart:io';

void extractEndpoints(List itemList, String prefix) {
  for (var item in itemList) {
    if (item.containsKey('item')) {
      var folderName = item['name'] ?? 'Unknown Folder';
      extractEndpoints(item['item'], prefix + folderName + ' / ');
    } else if (item.containsKey('request')) {
      var req = item['request'];
      var method = req['method'] ?? 'UNKNOWN';
      var url = '';
      if (req['url'] is Map) {
        url = req['url']['raw'] ?? '';
      } else if (req['url'] is String) {
        url = req['url'];
      }
      var name = item['name'] ?? 'Unnamed Request';
      print('$prefix$name [$method] $url');
    }
  }
}

void main() async {
  var filePath = 'D:/AppPro/tugas15flutter/ABSENSI PPKD B3.postman_collection.json';
  try {
    var file = File(filePath);
    var content = await file.readAsString();
    var data = jsonDecode(content);
    
    var info = data['info'] ?? {};
    print('Collection Name: ${info['name'] ?? 'Unknown'}');
    
    var items = data['item'] ?? [];
    extractEndpoints(items, '');
  } catch (e) {
    print('Error: $e');
  }
}
