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
  final int _pageSize = 10;
  int get _totalPages => (_filteredHistories.length / _pageSize).ceil();

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

  void _resetFilter() {
    setState(() {
      _selectedMonth = null;
      _selectedYear = null;
      _page = 1;
      _filteredHistories = List.from(_allHistories);
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

  List<HistoryModel> get _pagedHistories {
    final start = (_page - 1) * _pageSize;
    final end = (_page * _pageSize).clamp(0, _filteredHistories.length);
    return _filteredHistories.sublist(start, end);
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
        child: RefreshIndicator(
          onRefresh: _fetchHistories,
          child: Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedMonth,
                        hint: const Text('Pilih Bulan'),
                        items: _months
                            .map((m) =>
                                DropdownMenuItem(value: m, child: Text(m)))
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
                            .map((y) =>
                                DropdownMenuItem(value: y, child: Text(y)))
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
                        _resetFilter();
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
                    : _pagedHistories.isEmpty
                        ? const Center(
                            child: Text('Belum ada data',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.black54)))
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _pagedHistories.length,
                            itemBuilder: (context, index) {
                              final h = _pagedHistories[index];
                              IconData icon;
                              Color iconColor;
                              String title;
                              if (h.deviceType.toLowerCase().contains('uv')) {
                                icon = Icons.wb_sunny;
                                iconColor = Colors.orange;
                                title = 'UV';
                              } else {
                                icon = Icons.set_meal;
                                iconColor = Colors.blue;
                                title = 'Feeder';
                              }

                              // ! Format waktu hanya jam:menit
                              String formatTime(DateTime? dt) => dt != null
                                  ? "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}"
                                  : "-";
                              final start = formatTime(h.startTime);
                              final end = formatTime(h.endTime);

                              // ! Value formatting
                              String valueText;
                              if (title == 'UV') {
                                // * Hitung durasi dalam menit
                                int duration = 0;
                                if (h.endTime != null) {
                                  duration = h.endTime!
                                      .difference(h.startTime)
                                      .inMinutes;
                                  if (duration == 0) {
                                    duration = h.endTime!
                                        .difference(h.startTime)
                                        .inSeconds;
                                    valueText = "$duration detik";
                                  } else {
                                    valueText = "$duration menit";
                                  }
                                } else {
                                  valueText = "-";
                                }
                              } else {
                                valueText = "${h.value} gram";
                              }

                              return Card(
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                color: Colors.cyan,
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 10),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    child:
                                        Icon(icon, color: iconColor, size: 32),
                                  ),
                                  title: Text(
                                    '$title - ${h.triggerSource}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.calendar_today,
                                                size: 16, color: Colors.yellow),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${h.startTime.day.toString().padLeft(2, '0')}-"
                                              "${h.startTime.month.toString().padLeft(2, '0')}-"
                                              "${h.startTime.year}",
                                              style: const TextStyle(
                                                  color: Colors.black),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time,
                                                size: 16, color: Colors.white),
                                            const SizedBox(width: 4),
                                            Text('$start - $end',
                                                style: const TextStyle(
                                                    color: Colors.black)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Icon(
                                              title == 'UV'
                                                  ? Icons.wb_sunny
                                                  : Icons.set_meal,
                                              size: 16,
                                              color: iconColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(valueText,
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle,
                                                size: 16, color: Colors.green),
                                            const SizedBox(width: 4),
                                            Text('Status: ${h.status}',
                                                style: const TextStyle(
                                                    color: Colors.black87)),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.person,
                                                size: 16, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text('Trigger: ${h.triggerSource}',
                                                style: const TextStyle(
                                                    color: Colors.black54)),
                                          ],
                                        ),
                                      ],
                                    ),
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
      ),
    );
  }
}
