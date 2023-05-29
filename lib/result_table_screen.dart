import 'package:flutter/material.dart';

class ResultTableScreen extends StatelessWidget {
  final List<String> slNoList;
  final List<String> comList;
  final List<String> customerList;
  final List<String> deliveryNoList;
  final List<String> weightList;
  final List<String> unitList;

  ResultTableScreen(this.slNoList, this.comList, this.customerList,
      this.deliveryNoList, this.weightList, this.unitList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table View'),
      ),
      body: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(label: Text('SL No.')),
            DataColumn(label: Text('Company')),
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Delivery No.')),
            DataColumn(label: Text('Weight')),
            DataColumn(label: Text('Weight Unit')),
          ],
          rows: _buildRows(),
        ),
      ),
    );
  }

  List<DataRow> _buildRows() {
    final rowCount = (slNoList.length);
    final rows = List<DataRow>.generate(rowCount!, (index) {
      return DataRow(
        cells: [
          DataCell(Text(slNoList[index])),
          DataCell(Text(comList[index])),
          DataCell(Text(customerList[index])),
          DataCell(Text(deliveryNoList[index])),
          DataCell(Text(weightList[index])),
          DataCell(Text(unitList[index])),
        ],
      );
    });

    // Add the total row
    rows.add(DataRow(
      cells: [
        DataCell(Text('Total')),
        DataCell(Text('')),
        DataCell(Text('')),
      ],
    ));

    return rows;
  }
}
