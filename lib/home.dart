import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tahircoolpointtechnician/order.dart';
import 'package:tahircoolpointtechnician/profile.dart';

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
  // Sample data for charts
  final List<SalesData> orderData = [
    SalesData('Jan', 35),
    SalesData('Feb', 28),
    SalesData('Mar', 42),
    SalesData('Apr', 50),
    SalesData('May', 65),
    SalesData('Jun', 58),
  ];

  final List<SalesData> revenueData = [
    SalesData('Jan', 3500),
    SalesData('Feb', 2800),
    SalesData('Mar', 4200),
    SalesData('Apr', 5000),
    SalesData('May', 6500),
    SalesData('Jun', 5800),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            // Navbar logo image - replace with your actual image asset
            Image.asset(
              'images/icon.png', // Make sure to add your image to the assets folder
              height: 30,
              width: 30,
              errorBuilder: (context, error, stackTrace) => 
                const Icon(Icons.business, color: Colors.red), // Fallback if image fails to load
            ),
            const SizedBox(width: 10),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.black,
            ),
            onPressed: () {
              // Notification action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Cards
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Orders',
                      '248',
                      Icons.shopping_cart,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      'Total Revenue',
                      '\$12,450',
                      Icons.attach_money,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Order Chart
              _buildChartCard(
                'Orders Completed by Month',
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
                      dataSource: orderData,
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

              // Revenue Chart
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
                      dataSource: revenueData,
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
                // Navigate to home screen using a widget
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomePage()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.list_alt, color: Colors.white),
              onPressed: () {
                // Navigate to home screen using a widget
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