import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tahircoolpointtechnician/order.dart';
import 'package:tahircoolpointtechnician/profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
        ),
        cardTheme: CardTheme(
          color: Colors.grey[900],
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _technicianName = 'Loading...';
  bool _isLoading = true;
  int _totalOrders = 0;
  double _totalRevenue = 0;
  List<SalesData> _completedOrdersData = [];
  List<SalesData> _revenueData = [];

  @override
  void initState() {
    super.initState();
    _fetchTechnicianName();
    _fetchAnalyticsData();
  }

  Future<void> _fetchTechnicianName() async {
    try {
      final user = FirebaseAuth.instance.currentUser ;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('technicians')
            .where('email', isEqualTo: user.email)
            .get();

        if (snapshot.docs.isNotEmpty) {
          setState(() {
            _technicianName = snapshot.docs.first['full_name'] ?? 'Technician';
          });
        } else {
          setState(() {
            _technicianName = 'Technician';
          });
        }
      }
    } catch (e) {
      setState(() {
        _technicianName = 'Technician';
      });
    }
  }

  Future<void> _fetchAnalyticsData() async {
    try {
      final user = FirebaseAuth.instance.currentUser ;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return; // Exit if no user is logged in
      }

      // Get current year
      final currentYear = DateTime.now().year;

      // Fetch all completed orders for the logged-in technician
      final ordersSnapshot = await FirebaseFirestore.instance
          .collection('orders')
          .where('status', isEqualTo: 'Completed')
          .where('technicianId', isEqualTo: user.uid) // Filter by technicianId
          .get();

      // Calculate total orders and revenue
      int totalOrders = ordersSnapshot.docs.length;
      double totalRevenue = 0;

      // Initialize monthly data
      Map<String, int> monthlyOrders = {};
      Map<String, double> monthlyRevenue = {};

      // Initialize all months with 0 values
      for (int i = 1; i <= 12; i++) {
        final monthName = DateFormat('MMM').format(DateTime(currentYear, i, 1));
        monthlyOrders[monthName] = 0;
        monthlyRevenue[monthName] = 0;
      }

      // Process each order
      for (var doc in ordersSnapshot.docs) {
        final order = doc.data();
        final price = double.tryParse(order['price']?.toString() ?? '0') ?? 0;
        totalRevenue += price;

        // Get month from timestamp
        if (order['timestamp'] != null) {
          final timestamp = order['timestamp'] as Timestamp;
          final date = timestamp.toDate();
          final monthName = DateFormat('MMM').format(date);

          // Update monthly counts
          monthlyOrders[monthName] = (monthlyOrders[monthName] ?? 0) + 1;
          monthlyRevenue[monthName] = (monthlyRevenue[monthName] ?? 0) + price;
        }
      }

      // Convert to SalesData lists
      List<SalesData> completedOrdersData = [];
      List<SalesData> revenueData = [];

      monthlyOrders.forEach((month, count) {
        completedOrdersData.add(SalesData(month, count.toDouble()));
      });

      monthlyRevenue.forEach((month, amount) {
        revenueData.add(SalesData(month, amount));
      });

      // Sort by month
      completedOrdersData.sort((a, b) => _getMonthNumber(a.month).compareTo(_getMonthNumber(b.month)));
      revenueData.sort((a, b) => _getMonthNumber(a.month).compareTo(_getMonthNumber(b.month)));

      setState(() {
        _totalOrders = totalOrders;
        _totalRevenue = totalRevenue;
        _completedOrdersData = completedOrdersData;
        _revenueData = revenueData;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Handle error
      print('Error fetching analytics data: $e');
    }
  }

  // Helper function to get month number from abbreviation
  int _getMonthNumber(String monthAbbr) {
    final date = DateFormat('MMM').parse(monthAbbr);
    return date.month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _technicianName,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
            ),
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Orders',
                            '$_totalOrders',
                            Icons.shopping_cart,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildSummaryCard(
                            'Total Revenue',
                            '\$${_totalRevenue.toStringAsFixed(2)}',
                            Icons.attach_money,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    _buildChartCard(
                      'Completed Orders by Month',
                      SfCartesianChart(
                        backgroundColor: Colors.black,
                        primaryXAxis: CategoryAxis(
                          axisLine: const AxisLine(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          majorGridLines: const MajorGridLines(color: Colors.grey),
                        ),
                        primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          majorGridLines: const MajorGridLines(color: Colors.grey),
                        ),
                        series: <LineSeries<SalesData, String>>[
                          LineSeries<SalesData, String>(
                            dataSource: _completedOrdersData,
                            xValueMapper: (SalesData sales, _) => sales.month,
                            yValueMapper: (SalesData sales, _) => sales.sales,
                            color: Colors.red,
                            width: 3,
                            markerSettings: const MarkerSettings(
                              isVisible: true,
                              borderColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildChartCard(
                      'Revenue by Month',
                      SfCartesianChart(
                        backgroundColor: Colors.black,
                        primaryXAxis: CategoryAxis(
                          axisLine: const AxisLine(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          majorGridLines: const MajorGridLines(color: Colors.grey),
                        ),
                        primaryYAxis: NumericAxis(
                          axisLine: const AxisLine(color: Colors.white),
                          labelStyle: const TextStyle(color: Colors.white),
                          majorGridLines: const MajorGridLines(color: Colors.grey),
                        ),
                        series: <ColumnSeries<SalesData, String>>[
                          ColumnSeries<SalesData, String>(
                            dataSource: _revenueData,
                            xValueMapper: (SalesData sales, _) => sales.month,
                            yValueMapper: (SalesData sales, _) => sales.sales,
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.home, color: Colors.red),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.list_alt, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => OrderPage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                Icon(icon, color: Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(height: 300, child: chart),
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.month, this.sales);
  final String month;
  final double sales;
}