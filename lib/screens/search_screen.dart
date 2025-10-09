import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _queries = [
    'Current coffee price?',
    'Weather in Kayanza?',
    'Show all alerts',
    'Price trend this week?',
  ];
  
  List<Widget> _results = [];

  void _handleQuery(String query) {
    setState(() {
      _results = [_getAnswerCard(query)];
    });
  }

  Widget _getAnswerCard(String query) {
    String answer;
    IconData icon;
    
    if (query.toLowerCase().contains('price')) {
      answer = 'Current coffee price is \$2.45/lb, down 0.03 from yesterday';
      icon = Icons.trending_down;
    } else if (query.toLowerCase().contains('weather')) {
      answer = 'Kayanza: 24°C, Partly Cloudy, 65% humidity';
      icon = Icons.wb_sunny;
    } else if (query.toLowerCase().contains('alert')) {
      answer = '3 active alerts: 1 critical, 1 warning, 1 info';
      icon = Icons.warning;
    } else {
      answer = 'Coffee prices have been declining over the past week';
      icon = Icons.show_chart;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.coffeeBrown, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    query,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(answer),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search & Chat')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask about coffee prices, weather, alerts...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      _handleQuery(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ),
              onSubmitted: _handleQuery,
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: _queries.map((query) => ActionChip(
                label: Text(query),
                onPressed: () => _handleQuery(query),
              )).toList(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: _results,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
