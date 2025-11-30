import 'package:flutter/material.dart';
import '../services/controlling_service.dart';

class ControllingPage extends StatefulWidget {
  const ControllingPage({super.key});

  @override
  State<ControllingPage> createState() => _ControllingPageState();
}

class _ControllingPageState extends State<ControllingPage> {
  final ControllingService _service = ControllingService();
  final TextEditingController _feedController = TextEditingController();
  final TextEditingController _uvController = TextEditingController();
  bool _isLoading = false;
  String _statusFeeder = '';
  String _statusUV = '';
  int _stock = 0;
  String _lastFeed = '';
  bool _uvManualActive = false;

  @override
  void initState() {
    super.initState();
    _fetchDashboard();
  }

  @override
  void dispose() {
    _feedController.dispose();
    _uvController.dispose();
    super.dispose();
  }

  Future<void> _fetchDashboard() async {
    setState(() => _isLoading = true);
    final dashboard = await _service.getDashboard();
    setState(() {
      _statusFeeder = dashboard['feeder']['status'];
      _statusUV = dashboard['uv']['state'];
      _stock = dashboard['stock']['amount_gram'];
      _uvManualActive = dashboard['uv']['manual_active'];
      _isLoading = false;
    });
    final lastFeed = await _service.getLastFeed();
    setState(() {
      _lastFeed = lastFeed;
    });
  }

  Future<void> _manualFeed(int amount) async {
    setState(() => _isLoading = true);
    final result = await _service.manualFeed(amount);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
    _fetchDashboard();
  }

  Future<void> _manualUV(int durationSeconds) async {
    setState(() => _isLoading = true);
    final result = await _service.manualUV(durationSeconds);
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
    _fetchDashboard();
  }

  Future<void> _stopManualUV() async {
    setState(() => _isLoading = true);
    final result = await _service.stopManualUV();
    setState(() => _isLoading = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result)),
      );
    }
    _fetchDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: Colors.transparent,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 50),
                  Card(
                    color: Colors.cyan,
                    child: ListTile(
                      title: const Text('Stock Pakan'),
                      subtitle: Text('$_stock gram'),
                      leading: const Icon(Icons.food_bank, color: Colors.black),
                    ),
                  ),
                  Card(
                    color: Colors.cyan,
                    child: ListTile(
                      title: const Text('Status Feeder'),
                      subtitle: Text(_statusFeeder),
                      leading: const Icon(Icons.feed, color: Colors.black),
                    ),
                  ),
                  Card(
                    color: Colors.cyan,
                    child: ListTile(
                      title: const Text('Status UV'),
                      subtitle: Text(_statusUV),
                      leading: const Icon(Icons.wb_sunny, color: Colors.black),
                      trailing: _uvManualActive
                          ? ElevatedButton(
                              onPressed: _stopManualUV,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Stop Manual UV',
                                  style: TextStyle(color: Colors.black)),
                            )
                          : null,
                    ),
                  ),
                  Card(
                    color: Colors.cyan,
                    child: ListTile(
                      title: const Text('Last Feed'),
                      subtitle: Text(_lastFeed),
                      leading: const Icon(Icons.history, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Manual Feeding',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _feedController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Jumlah pakan (gram)',
                            border: OutlineInputBorder(),
                            labelStyle:
                                TextStyle(fontSize: 20, color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.redAccent, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final amount = int.tryParse(_feedController.text);
                          if (amount != null && amount > 0) {
                            _manualFeed(amount);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Masukkan jumlah pakan yang valid')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                        ),
                        child: const Text(
                          'Feed',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('Manual UV Control',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _uvController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Durasi UV (menit)',
                            border: OutlineInputBorder(),
                            labelStyle:
                                TextStyle(fontSize: 20, color: Colors.black),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.cyan, width: 2),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.redAccent, width: 2),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          final duration = int.tryParse(_uvController.text);
                          if (duration != null && duration > 0) {
                            _manualUV(duration * 60);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Masukkan durasi UV yang valid')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _uvManualActive ? Colors.grey : Colors.cyan,
                        ),
                        child: const Text('Start UV',
                            style: TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
