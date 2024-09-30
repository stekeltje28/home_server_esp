import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:youtube_chat_app/widgets/container.dart';
import 'package:http/http.dart' as http;

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  List<FlSpot> spots = [];
  int _totaal_aantal = 0; // Initialize as double
  Color _status_color = Colors.red;
  IconData _status_icon = Icons.error_outline_sharp;

  @override
  void initState() {
    super.initState();
    _fetchVisitorData();
    _fetchVisitorDataForChar();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _siteonline(),
          const SizedBox(height: 20),
          aantal_bezoekers(_totaal_aantal.toString()),
          const SizedBox(height: 20),
          _container(),
          const SizedBox(height: 120),
          _bottomtext(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _bottomtext() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'Hulp nodig? Bel! |',
              style: TextStyle(color: Color(0x2F000000)),
            ),
            GestureDetector(
              child: const Text(
                ' 0616565253',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'of klik hier om te chatten',
              style: TextStyle(color: Color(0x2F000000)),
            ),
          ],
        )
      ],
    );
  }

  Widget _siteonline() {
    return CustomContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Site Status:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              const Text(
                'Active',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 12,
                backgroundColor: _status_color,
                child: Icon(
                  _status_icon as IconData?,
                  size: 16,
                  color: Color(0x2F000000),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget aantal_bezoekers(String totaal_aantal) {
    return CustomContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Totaal aantal bezoekers:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Row(
            children: [
              Text(
                totaal_aantal, // This is now a string
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _container() {
    return CustomContainer(
      child: _lineChart(),
    );
  }

  Future<void> _fetchVisitorData() async {
    final url = Uri.parse('http://localhost:8000/api/count-visitors/'); // Make sure this URL is correct
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {

        final data = json.decode(response.body)['unique_visitors'];
        setState(() {
          _status_color = Colors.green;
          _status_icon = Icons.check;
          _totaal_aantal = data.toInt(); // Set the total number of visitors
        });
      } else {
        print('Failed to fetch visitors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchVisitorDataForChar() async {
    final url = Uri.parse('http://localhost:8000/api/count-visitors/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body)['weekly_visitors'];

        setState(() {
          // Zet de ontvangen data om in FlSpot voor de grafiek
          spots = [];
          data.forEach((week, aantal) {
            spots.add(FlSpot(double.parse(week), aantal.toDouble()));
          });
        });
      } else {
        print('Failed to fetch visitors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _lineChart() {
    return Column(
      children: [
        const Text(
          'Aantal websitegebruikers',
          style: TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: LineChart(
            LineChartData(
              lineBarsData: [
                LineChartBarData(
                  spots: spots.isNotEmpty ? spots : [const FlSpot(0, 0)],
                  isCurved: true,
                  color: Colors.blueAccent,
                  barWidth: 3,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blueAccent.withOpacity(0.2),
                        Colors.blueAccent.withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: const FlDotData(show: true),
                ),
              ],
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        'Week ${value.toInt()}', // Gebruik weeknummer in plaats van dagen
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 1.0,
                verticalInterval: 1.0,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: Colors.grey.withOpacity(0.1),
                    strokeWidth: 1,
                  );
                },
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((touchedSpot) {
                      return LineTooltipItem(
                        'gebruikers: ${touchedSpot.y}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
            ),
          ),
        ),
      ],
    );
  }


}
