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
  double? _temperature;
  double? _humidity;

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
    try {
      final dashboard = await _service.getDashboard();
      setState(() {
        _statusFeeder = dashboard['feeder']['status'] ?? '';
        _statusUV = dashboard['uv']['state'] ?? '';
        _stock = dashboard['stock']['amount_gram'] ?? 0;
        _uvManualActive = dashboard['uv']['manual_active'] ?? false;

        if (dashboard['environment'] != null) {
          _temperature = dashboard['environment']['temperature']?.toDouble();
          _humidity = dashboard['environment']['humidity']?.toDouble();
        } else {
          _temperature = null;
          _humidity = null;
        }

        _isLoading = false;
      });
      final lastFeed = await _service.getLastFeed();
      setState(() {
        _lastFeed = lastFeed;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat dashboard: $e')),
        );
      }
    }
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

  Future<void> _showStockDialog() async {
    final TextEditingController stockController =
        TextEditingController(text: _stock.toString());

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Stock Pakan'),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Jumlah baru (gram)',
            suffixText: 'gram',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                Navigator.pop(dialogContext);
                setState(() => _isLoading = true);
                final result = await _service.updateStock(newStock);
                setState(() => _isLoading = false);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result)),
                  );
                }
                _fetchDashboard();
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyan),
            child: const Text('Simpan', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
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
          : RefreshIndicator(
              onRefresh: () async {
                await _fetchDashboard();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 50),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final double colWidth = (constraints.maxWidth - 16) / 2;
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: colWidth,
                              child: Column(
                                children: [
                                  if (_temperature != null)
                                    Card(
                                      color: Colors.cyan,
                                      child: ListTile(
                                        title: const Text('Suhu Sekarang'),
                                        subtitle: Text(
                                            '${_temperature!.toStringAsFixed(2)} °C',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        leading: const Icon(Icons.thermostat,
                                            color: Colors.red),
                                      ),
                                    ),
                                  if (_humidity != null)
                                    Card(
                                      color: Colors.cyan,
                                      child: ListTile(
                                        title:
                                            const Text('Kelembapan Sekarang'),
                                        subtitle: Text(
                                            '${_humidity!.toStringAsFixed(2)} %',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        leading: const Icon(Icons.water_drop,
                                            color: Colors.blue),
                                      ),
                                    ),
                                  Card(
                                    color: Colors.cyan,
                                    child: InkWell(
                                      onTap: _showStockDialog,
                                      borderRadius: BorderRadius.circular(12),
                                      child: ListTile(
                                        title: const Text('Stock Pakan'),
                                        subtitle: Text('$_stock gram',
                                            style: const TextStyle(
                                                color: Colors.white)),
                                        leading: const Icon(Icons.food_bank,
                                            color: Colors.green),
                                        trailing: const Icon(Icons.edit,
                                            color: Colors.white70, size: 20),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: colWidth,
                              child: Column(
                                children: [
                                  Card(
                                    color: Colors.cyan,
                                    child: ListTile(
                                      title: const Text('Status Feeder'),
                                      subtitle: Text(_statusFeeder,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      leading: const Icon(Icons.feed,
                                          color: Colors.brown),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.cyan,
                                    child: ListTile(
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                      leading: const Icon(Icons.wb_sunny,
                                          color: Colors.yellow),
                                      title: const Text('Status UV',
                                          style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold)),
                                      subtitle: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_statusUV,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 13)),
                                          if (_uvManualActive)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8.0),
                                              child: SizedBox(
                                                height: 35,
                                                width: double.infinity,
                                                child: ElevatedButton(
                                                  onPressed: _stopManualUV,
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor: Colors.red,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  child: const Text('Stop UV',
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12)),
                                                ),
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Card(
                                    color: Colors.cyan,
                                    child: ListTile(
                                      title: const Text('Last Feed'),
                                      subtitle: Text(_lastFeed,
                                          style: const TextStyle(
                                              color: Colors.white)),
                                      leading: const Icon(Icons.history,
                                          color: Colors.orange),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text('Manual Feeding',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _feedController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Jumlah pakan (gram)',
                              prefixIcon: const Icon(Icons.food_bank,
                                  color: Colors.green),
                              filled: true,
                              fillColor: Colors.cyan,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              labelStyle: const TextStyle(
                                  fontSize: 18, color: Colors.black),
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
                                    content: Text(
                                        'Masukkan jumlah pakan yang valid')),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                          ),
                          child: const Text('Feed',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Manual UV Control',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _uvController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Durasi UV (menit)',
                              prefixIcon:
                                  const Icon(Icons.timer, color: Colors.yellow),
                              filled: true,
                              fillColor: Colors.cyan,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              labelStyle: const TextStyle(
                                  fontSize: 18, color: Colors.black),
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
            ),
    );
  }
}
