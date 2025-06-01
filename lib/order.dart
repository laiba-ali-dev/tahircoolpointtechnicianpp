import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OrderPage extends StatefulWidget {
  @override
  _OrderListScreenState createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderPage> {
  String? technicianId;

  @override
  void initState() {
    super.initState();
    fetchTechnicianId();
  }

  Future<void> fetchTechnicianId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
 final technicianSnapshot = await FirebaseFirestore.instance
    .collection('technicians')
    .doc(user.uid)
    .get();

      setState(() 
      {
        technicianId = technicianSnapshot.id;
      });
    }
  }

  List<DataRow> _buildOrderRows(List<DocumentSnapshot> orders) {
    return orders.map((order) {
      final data = order.data() as Map<String, dynamic>;
      return DataRow(cells: [
        DataCell(Text(data['serviceName'] ?? '')),
        DataCell(Text(data['customerName'] ?? '')),
        DataCell(Text(data['status'] ?? '')),
        DataCell(Text(data['date'] ?? '')),
      ]);
    }).toList();
  }

  Widget _buildOrderSection(String title, List<DocumentSnapshot> orders) {
    return orders.isEmpty
        ? SizedBox()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('address')),
                    DataColumn(label: Text('productPrice')),
                    DataColumn(label: Text('productTitle')),
                    DataColumn(label: Text('timestamp')),
                  ],
                  rows: _buildOrderRows(orders),
                ),
              ),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    if (technicianId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Orders')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Orders')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('technicianId', isEqualTo: technicianId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

          final allOrders = snapshot.data!.docs;

          final assignedOrders = allOrders.where((order) => order['status'] == 'Assigned').toList();
          final inProgressOrders = allOrders.where((order) => order['status'] == 'In-Progress').toList();
          final completedOrders = allOrders.where((order) => order['status'] == 'Completed').toList();
          final requestedOrders = allOrders.where((order) => order['status'] == 'requested').toList();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOrderSection('Assigned Orders', assignedOrders),
                _buildOrderSection('In Progress Orders', inProgressOrders),
                _buildOrderSection('Completed Orders', completedOrders),
                _buildOrderSection('Requested Orders', requestedOrders),
              ],
            ),
          );
        },
      ),
    );
  }
}
