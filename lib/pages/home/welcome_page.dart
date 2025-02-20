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
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _siteonline(),
            const SizedBox(height: 20),
            aantal_bezoekers(
                _totaal_aantal.toString(), _unieke_bezoekers.toString()),
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
            Text(
              'Hulp nodig? Bel! |',
              style: TextStyle(
                color: Theme
                    .of(context)
                    .textTheme
                    .bodyLarge
                    ?.color,
              ),
            ),
            GestureDetector(
              child: Text(
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
        Text(
          'of klik hier om te chatten',
          style: TextStyle(
            color: Theme
                .of(context)
                .textTheme
                .bodyLarge
                ?.color,
          ),
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
            ),
          ),
          Row(
            children: [
              const Text(
                'Active',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                ),
              ),
              Text(
                totaalAantal,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
                ),
              ),
              Text(
                uniekeBezoekers,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
            ),
          ),
          Text(
            gemiddeldAantal,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
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
          dailySpots.add(FlSpot(1, data['daily_visitors']['count']
              .toDouble())); // Dit kan je aanpassen voor meerdere dagen als nodig

          // Voor wekelijkse bezoekers
          weeklySpots = [];
          weeklySpots.add(FlSpot(
              data['weekly_visitors']['week_number'].toDouble(),
              data['weekly_visitors']['count'].toDouble()));

          // Voor maandelijkse bezoekers
          monthlySpots = [];
          monthlySpots.add(FlSpot(data['monthly_visitors']['month'].toDouble(),
              data['monthly_visitors']['count'].toDouble()));

          // Voor jaarlijkse bezoekers
          yearlySpots = [];
          yearlySpots.add(FlSpot(data['yearly_visitors']['year'].toDouble(),
              data['yearly_visitors']['count'].toDouble()));
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
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      // Ruimte tussen grafieken
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Theme
                  .of(context)
                  .textTheme
                  .bodyLarge
                  ?.color,
              fontSize: 22,
              fontWeight: FontWeight.bold, // Meer nadruk op de titel
            ),
          ),
          const SizedBox(height: 12),
          AspectRatio(
            aspectRatio: 1.7,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, _) {
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .textTheme
                                .bodyLarge
                                ?.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) =>
                          Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Theme
                                  .of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.color,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawHorizontalLine: true,
                  horizontalInterval: (maxY - minY) / 5, // Betere gridverdeling
                  getDrawingHorizontalLine: (value) =>
                      FlLine(
                        color: Theme
                            .of(context)
                            .dividerColor,
                        strokeWidth: 1,
                      ),
                ),
                borderData: FlBorderData(
                    show: true, border: Border.all(color: Theme
                    .of(context)
                    .dividerColor, width: 1)),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.blueAccent,
                    barWidth: 5,
                    isStrokeCapRound: true,
                    // Zorgt voor een ronde lijn
                    belowBarData: BarAreaData(
                        show: true, color: Colors.blueAccent.withOpacity(0.3)),
                    dotData: FlDotData(
                        show: false), // Verberg de punten op de lijn
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                  ),
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

