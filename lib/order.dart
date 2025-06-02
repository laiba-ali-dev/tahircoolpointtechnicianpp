import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tahircoolpointtechnician/home.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  Future<void> _openGoogleMaps(double latitude, double longitude) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<String?> _getTechnicianIdByEmail(String email) async {
    final technicianSnapshot = await FirebaseFirestore.instance
        .collection('technicians')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (technicianSnapshot.docs.isNotEmpty) {
      return technicianSnapshot.docs.first.id; // document ID
    }

    return null;
  }

  Future<void> _updateOrderStatus(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(docId)
          .update({'status': 'In-Progress'});
    } catch (e) {
      print('Error updating status: $e');
    }
  }


Future<void> _completeOrder(BuildContext context, String docId) async {
  final TextEditingController _priceController = TextEditingController();

  await showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Enter Price'),
        content: TextField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'Enter Price'),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Next'),
            onPressed: () async {
              final price = _priceController.text.trim();

              if (price.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a price')),
                );
                return;
              }

              try {
                await FirebaseFirestore.instance
                    .collection('orders')
                    .doc(docId)
                    .update({
                  'status': 'Completed',
                  'price': price,
                });
                Navigator.of(context).pop(); // Close the modal
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {



    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: Text(
            'Please login first',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: _getTechnicianIdByEmail(currentUser.email!),
      builder: (context, technicianSnapshot) {
        if (technicianSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(child: CircularProgressIndicator(color: Colors.red)),
          );
        }

        if (!technicianSnapshot.hasData || technicianSnapshot.data == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text('Technician not found',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          );
        }

        final technicianId = technicianSnapshot.data;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
             leading: IconButton(
    icon: const Icon(Icons.arrow_back, color: Colors.black),
    onPressed: () {
      // Agar aap peechle screen par jana chahte hain

      
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
    },
  ),
            title: Row(
              children: [
                Image.asset(
                  'images/icon.png',
                  height: 30,
                  width: 30,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.business, color: Colors.red),
                ),
                const SizedBox(width: 10),
                const Text(
                  'My Orders',
                  style: TextStyle(color: Colors.black),
                ),
              ],
            ),
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('orders')
                .where('technicianId', isEqualTo: technicianId)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Error fetching orders',
                      style: TextStyle(color: Colors.white)),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.red));
              }

              final orders = snapshot.data?.docs ?? [];

              if (orders.isEmpty) {
                return const Center(
                  child: Text('No orders found', style: TextStyle(color: Colors.white)),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Card(
                  color: Colors.grey,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Text(
                          'My Orders',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(Colors.red),
                            dataRowColor:
                                MaterialStateProperty.all(Colors.grey[800]),
                            columns: const [
                              DataColumn(
                                label: Text('Product Name',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text('Address',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text('View Map',
                                    style: TextStyle(color: Colors.white)),
                              ),
                              DataColumn(
                                label: Text('Next', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                            rows: orders.map((doc) {
                              final data = doc.data()! as Map<String, dynamic>;
                              final productName = data['productTitle'] ?? 'N/A';
                              final address = data['address'] ?? 'N/A';
                              final latitude = data['latitude'];
                              final longitude = data['longitude'];
                              final status = data['status'] ?? '';

                              return DataRow(
                                cells: [
                                  DataCell(Text(productName,
                                      style: const TextStyle(color: Colors.white))),
                                  DataCell(Text(address,
                                      style: const TextStyle(color: Colors.white))),
                                  DataCell(
                                    (latitude != null && longitude != null)
                                        ? IconButton(
                                            icon: const Icon(Icons.map, color: Colors.red),
                                            onPressed: () => _openGoogleMaps(latitude, longitude),
                                          )
                                        : const Text('N/A',
                                            style: TextStyle(color: Colors.grey)),
                                  ),
                              DataCell(
  status == 'Completed'
      ? const Text('Completed',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
      : status == 'In-Progress'
          ? ElevatedButton(
              onPressed: () => _completeOrder(context, doc.id),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text(
                'Next',
                style: TextStyle(color: Colors.white),
              ),
            )
          : TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () async {
                await _updateOrderStatus(doc.id);
              },
              child: const Text('Next'),
            ),
),


                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
