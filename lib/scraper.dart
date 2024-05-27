import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:beautiful_soup_dart/beautiful_soup.dart';

Future<List<Map<String, String>>> scrapeData() async {
  final url =
      'https://incidentesmovilidad.cdmx.gob.mx/public/bandejaEstadoServicio.xhtml?idMedioTransporte=mb';
  final response = await http.get(Uri.parse(url));
  List<Map<String, String>> data = [];

  if (response.statusCode == 200) {
    final soup = BeautifulSoup(response.body);
    final int contentLength = response.contentLength ?? response.body.length;
    print('Content-Length: $contentLength');
    final divTableWrapper =
        soup.find('div', class_: 'ui-datatable-tablewrapper');

    if (divTableWrapper != null) {
      final table = divTableWrapper.find('table');
      if (table != null) {
        final thead = table.find('thead');
        List<String> headers = [];
        if (thead != null) {
          final headerRow = thead.find('tr');
          if (headerRow != null) {
            headers =
                headerRow.findAll('th').map((th) => th.text.trim()).toList();
            headers.insert(0, 'Linea');
          }
        }
        final tbody = table.find('tbody');
        if (tbody != null) {
          final rows = tbody.findAll('tr');
          for (final row in rows) {
            Map<String, String> rowData = {};
            final cols = row.findAll('td').map((td) => td.text.trim()).toList();
            final img = row.find('img');
            String identifier = '';
            if (img != null) {
              final src = img.attributes['src'];
              if (src != null) {
                final fileName = src.split('/').last.split('?').first;
                identifier = RegExp(r'MB\d+').stringMatch(fileName) ?? '';
              }
            }
            rowData['Linea'] = identifier;
            for (int i = 0; i < headers.length - 1 && i < cols.length; i++) {
              rowData[headers[i + 1]] = cols[i];
            }
            data.add(rowData);
          }
        } else {
          Dialog(
            child: Text('No se encontró el tbody en la tabla.'),
          );
          print('No se encontró el tbody en la tabla.');
        }
      } else {
        print('No se encontró la tabla dentro del div.');
      }
    } else {
      print('No se encontró el div con la clase "ui-datatable-tablewrapper".');
    }
  } else {
    print('Error al obtener la página web: ${response.statusCode}');
    Dialog(
      child: Text('Error al obtener la página web: ${response.statusCode}'),
    );
  }
  return data;
}
