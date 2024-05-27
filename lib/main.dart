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
  String? hora;

  @override
  void initState() {
    super.initState();
    _scrapeData();
  }

  Future<void> _scrapeData() async {
    final result = await scrapeData();
    setState(() {
      data = result.data;
      hora = result.hora;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estado del servicio'),
      ),
      body: data.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Hora de actualización: $hora',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
                IconButton(onPressed: _scrapeData, icon: Icon(Icons.refresh)),
                Expanded(
                  child: ListView.builder(
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final row = data[index];
                      final linea = row['Linea'] ?? 'Línea desconocida';
                      final estadoServicio =
                          row['Estado'] ?? 'Estado desconocido';
                      final lineasAfectadas =
                          (row['Estaciones afectadas'] ?? '').split(',');
                      final infoAdicional = row['Información adicional'] ?? '';
                      return Card(
                        child: Column(
                          children: [
                            ListTile(
                              leading: Image.asset('images/$linea.png',
                                  width: 24, height: 24),
                              title: Text(row['Linea']!),
                              subtitle: Text(row['Estado']!),
                            ),
                            if (row['Estaciones afectadas']!.isNotEmpty)
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: row['Estaciones afectadas']!
                                    .split(',')
                                    .map((linea) => Chip(
                                          label: Text(linea.trim()),
                                        ))
                                    .toList(),
                              ),
                            if (row['Información adicional']!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(row['Información adicional']!),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
