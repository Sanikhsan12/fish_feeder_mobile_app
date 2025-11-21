import 'package:flutter/material.dart';
import '../services/history_service.dart';
import '../models/history_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final HistoryService historyService = HistoryService();
  int _page = 1;
  bool _isLoading = false;
  List<HistoryModel> _histories = [];
  final int _limit = 5; // gunakan limit yang sama dengan service

  // ! Fetching data
  Future<void> _fetchHistories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final histories =
          await historyService.getHistoryData(limit: _limit, page: _page);
      setState(() {
        _histories = histories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHistories();
  }

  void nextPage() {
    setState(() {
      _page += 1;
    });
    _fetchHistories();
  }

  void previousPage() {
    if (_page > 1) {
      setState(() {
        _page -= 1;
        _fetchHistories();
      });
    }
  }

  void goToFirstPage() {
    if (_page != 1) {
      setState(() {
        _page = 1;
        _fetchHistories();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'History Feeding',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _histories.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada data',
                            style:
                                TextStyle(fontSize: 18, color: Colors.black54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: _histories.length,
                          itemBuilder: (context, index) {
                            final h = _histories[index];
                            return Card(
                              color: Colors.cyan,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 8),
                              child: ListTile(
                                title: Text(
                                    '${h.deviceType} - ${h.triggerSource}'),
                                subtitle: Text(
                                  'Status: ${h.status}\nWaktu: ${h.startTime} - ${h.endTime ?? "-"}\nValue: ${h.value}',
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _page > 1 ? goToFirstPage : null,
                    child: const Text('First'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _page > 1 ? previousPage : null,
                    child: const Text('Prev'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    // Tombol Next nonaktif jika data kurang dari limit (halaman terakhir)
                    onPressed: _histories.length == _limit ? nextPage : null,
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
