import 'package:flutter/material.dart';
import 'package:ocr/result_table_screen.dart';

class ResultScreen extends StatelessWidget {
  final String text;

  const ResultScreen({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(30.0),
              child: Text(text),
            ),
            ElevatedButton(
              onPressed: () => _convertToTable(context),
              child: Text('DataTable View'),
            ),
          ],
        ),
      ),
    );
  }

  void _convertToTable(BuildContext context) {
    try {
      final lines = text.split('\n');
      final slNoList = lines
          .where((line) => line.startsWith('SL No.'))
          .map((line) => line.substring(7).trim())
          .toList();
      final comList = lines
          .where((line) => line.startsWith('Company'))
          .map((line) => line.substring(8).trim())
          .toList();
      final customerList = lines
          .where((line) => line.startsWith('Customer'))
          .map((line) => line.substring(9).trim())
          .toList();
      final deliveryNoList = lines
          .where((line) => line.startsWith('Delivery No.'))
          .map((line) => line.substring(13).trim())
          .toList();
      final weightList = lines
          .where((line) => line.startsWith('Weight'))
          .map((line) => line.substring(7).trim())
          .toList();
      final unitList = lines
          .where((line) => line.startsWith('Unit'))
          .map((line) => line.substring(5).trim())
          .toList();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => ResultTableScreen(
            slNoList,
            comList,
            customerList,
            deliveryNoList,
            weightList,
            unitList,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
  }
}
