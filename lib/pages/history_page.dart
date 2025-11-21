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
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  List<HistoryModel> _histories = [];
  bool _showScrollToTop = false;

  // ! Fetch all data
  Future<void> _fetchHistories() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final histories =
          await historyService.getHistoryData(limit: 100, page: 1);
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

  void onScroll() {
    if (_scrollController.offset > 800 && !_showScrollToTop) {
      setState(() {
        _showScrollToTop = true;
      });
    } else if (_scrollController.offset <= 800 && _showScrollToTop) {
      setState(() {
        _showScrollToTop = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchHistories();
    _scrollController.addListener(onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _histories.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada data',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _histories.length,
                    itemBuilder: (context, index) {
                      final h = _histories[index];
                      return Card(
                        color: Colors.cyan,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 8),
                        child: ListTile(
                          title: Text('${h.deviceType} - ${h.triggerSource}'),
                          subtitle: Text(
                            'Status: ${h.status}\nWaktu: ${h.startTime} - ${h.endTime ?? "-"}\nValue: ${h.value}',
                          ),
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: _showScrollToTop
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 100.0),
                child: FloatingActionButton(
                  onPressed: _scrollToTop,
                  backgroundColor: Colors.cyan,
                  child: const Icon(Icons.arrow_upward, color: Colors.white),
                  tooltip: 'Kembali ke atas',
                ),
              ),
            )
          : null,
    );
  }
}
