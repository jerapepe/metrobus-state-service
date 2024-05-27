import 'package:flutter/material.dart';
import 'scraper.dart';
import 'theme/theme_prov.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Web Scraping App',
      themeMode: themeProvider.themeMode,
      darkTheme: ThemeData.dark(),
      theme: ThemeData.light(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, String>> data = [];

  @override
  void initState() {
    super.initState();
    _scrapeData();
  }

  Future<void> _scrapeData() async {
    data = await scrapeData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Web Scraping App'),
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  columns: _createColumns(),
                  rows: _createRows(),
                ),
              ),
            ),
    );
  }

  List<DataColumn> _createColumns() {
    if (data.isNotEmpty) {
      return data[0]
          .keys
          .where((columnTitle) => columnTitle != 'Línea')
          .map((columnTitle) => DataColumn(label: Text(columnTitle)))
          .toList();
    }
    return [];
  }

  List<DataRow> _createRows() {
    return data.map((row) {
      return DataRow(
        cells: row.entries.where((entry) => entry.key != 'Línea').map((cell) {
          return DataCell(
            Padding(
              padding: const EdgeInsets.all(0.5),
              child: Text(cell.value),
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}
