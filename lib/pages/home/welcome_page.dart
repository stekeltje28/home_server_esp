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
  List<FlSpot> dailySpots = [];
  List<FlSpot> weeklySpots = [];
  List<FlSpot> monthlySpots = [];
  List<FlSpot> yearlySpots = [];
  int _totaal_aantal = 0;
  int _unieke_bezoekers = 0;
  int _gemiddeld_aantal_per_week = 0;
  Color _status_color = Colors.red;
  IconData _status_icon = Icons.error_outline_sharp;

  @override
  void initState() {
    super.initState();
    _fetchVisitorData();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _siteonline(),
          const SizedBox(height: 20),
          aantal_bezoekers(_totaal_aantal.toString(), _unieke_bezoekers.toString()),
          const SizedBox(height: 20),
          gemiddeldAantalBezoekers(_gemiddeld_aantal_per_week.toString()),
          const SizedBox(height: 20),
          _lineChart(dailySpots, 'Aantal dagelijkse gebruikers'),
          const SizedBox(height: 20),
          _lineChart(weeklySpots, 'Aantal wekelijkse gebruikers'),
          const SizedBox(height: 20),
          _lineChart(monthlySpots, 'Aantal maandelijkse gebruikers'),
          const SizedBox(height: 20),
          _lineChart(yearlySpots, 'Aantal jaarlijkse gebruikers'),
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
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
        const SizedBox(height: 8),
        const Text(
          'of klik hier om te chatten',
          style: TextStyle(color: Color(0x2F000000)),
        ),
      ],
    );
  }

  Widget _siteonline() {
    return CustomContainer(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Site Status:',
            style: TextStyle(
              fontSize: 18,
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
                  _status_icon,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget aantal_bezoekers(String totaalAantal, String uniekeBezoekers) {
    return CustomContainer(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aantal page requests:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                totaalAantal,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Unieke bezoekers:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                uniekeBezoekers,
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

  Widget gemiddeldAantalBezoekers(String gemiddeldAantal) {
    return CustomContainer(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Gemiddeld aantal bezoekers per week:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            gemiddeldAantal,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _fetchVisitorData() async {
    final url = Uri.parse('http://localhost:8000/api/count-visitors/');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('API response: $data');

        setState(() {
          _status_color = Colors.green;
          _status_icon = Icons.check;
          _totaal_aantal = data['total_visitors'] ?? 0;
          _unieke_bezoekers = data['unique_visitors'] ?? 0;
          _gemiddeld_aantal_per_week = data['weekly_visitors']['count'] ?? 0;

          // Voor dagelijkse bezoekers
          dailySpots = [];
          dailySpots.add(FlSpot(1, data['daily_visitors']['count'].toDouble())); // Dit kan je aanpassen voor meerdere dagen als nodig

          // Voor wekelijkse bezoekers
          weeklySpots = [];
          weeklySpots.add(FlSpot(data['weekly_visitors']['week_number'].toDouble(), data['weekly_visitors']['count'].toDouble()));

          // Voor maandelijkse bezoekers
          monthlySpots = [];
          monthlySpots.add(FlSpot(data['monthly_visitors']['month'].toDouble(), data['monthly_visitors']['count'].toDouble()));

          // Voor jaarlijkse bezoekers
          yearlySpots = [];
          yearlySpots.add(FlSpot(data['yearly_visitors']['year'].toDouble(), data['yearly_visitors']['count'].toDouble()));
        });
      } else {
        print('Failed to fetch visitors: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Widget _lineChart(List<FlSpot> spots, String title) {
    if (spots.isEmpty) {
      return const SizedBox(); // Geen gegevens om weer te geven
    }

    // Bereken minY en maxY op basis van de waarden in spots
    double minY = spots.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
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
                    dotData: FlDotData(show: true),
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
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
