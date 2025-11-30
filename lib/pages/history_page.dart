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
  bool _isLoading = false;
  List<HistoryModel> _allHistories = [];
  List<HistoryModel> _filteredHistories = [];
  int _page = 1;
  final int _totalPages = 1;

  String? _selectedMonth;
  String? _selectedYear;

  final List<String> _months = [
    '01',
    '02',
    '03',
    '04',
    '05',
    '06',
    '07',
    '08',
    '09',
    '10',
    '11',
    '12'
  ];
  final List<String> _years = [
    for (var y = 2023; y <= DateTime.now().year; y++) y.toString()
  ];

  Future<void> _fetchHistories() async {
    setState(() => _isLoading = true);
    try {
      final histories = await historyService.getAllHistoryData();
      setState(() {
        _allHistories = histories;
        _applyFilter();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilter() {
    setState(() {
      _filteredHistories = _allHistories.where((h) {
        final month = h.startTime.month.toString().padLeft(2, '0');
        final year = h.startTime.year.toString();
        final matchMonth = _selectedMonth == null || month == _selectedMonth;
        final matchYear = _selectedYear == null || year == _selectedYear;
        return matchMonth && matchYear;
      }).toList();
    });
  }

  void nextPage() {
    if (_page < _totalPages) {
      setState(() {
        _page += 1;
      });
      _fetchHistories();
    }
  }

  void previousPage() {
    if (_page > 1) {
      setState(() {
        _page -= 1;
      });
      _fetchHistories();
    }
  }

  void goToFirstPage() {
    if (_page != 1) {
      setState(() {
        _page = 1;
      });
      _fetchHistories();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHistories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History Feeding',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedMonth,
                      hint: const Text('Pilih Bulan'),
                      items: _months
                          .map(
                              (m) => DropdownMenuItem(value: m, child: Text(m)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedMonth = val;
                        });
                        _applyFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedYear,
                      hint: const Text('Pilih Tahun'),
                      items: _years
                          .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)))
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedYear = val;
                        });
                        _applyFilter();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedMonth = null;
                        _selectedYear = null;
                      });
                      _applyFilter();
                    },
                    child: const Text('Reset Filter',
                        style: TextStyle(color: Colors.black)),
                  )
                ],
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredHistories.isEmpty
                      ? const Center(
                          child: Text('Belum ada data',
                              style: TextStyle(
                                  fontSize: 18, color: Colors.black54)))
                      : ListView.builder(
                          itemCount: _filteredHistories.length,
                          itemBuilder: (context, index) {
                            final h = _filteredHistories[index];
                            return Card(
                              color: Colors.cyan,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 8),
                              child: ListTile(
                                title: Text(
                                    '${h.deviceType} - ${h.triggerSource}'),
                                subtitle: Text(
                                    'Status: ${h.status}\nWaktu: ${h.startTime} - ${h.endTime ?? "-"}\nValue: ${h.value}'),
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
                    onPressed: _page < _totalPages ? nextPage : null,
                    child: const Text('Next'),
                  ),
                  const SizedBox(width: 16),
                  Text('Page $_page / $_totalPages'),
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
