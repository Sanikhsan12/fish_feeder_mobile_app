import 'package:flutter/material.dart';
import '../services/schedule_service.dart';
import '../models/schedule_model.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  final ScheduleService _service = ScheduleService();
  bool _isLoading = false;
  List<FeederScheduleModel> _feederSchedules = [];
  List<UVScheduleModel> _uvSchedules = [];

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _fetchSchedules();
  }

  Future<void> _fetchSchedules() async {
    setState(() => _isLoading = true);
    try {
      // Fetch both efficiently
      final results = await Future.wait([
        _service.getFeederSchedules(),
        _service.getUVSchedules(),
      ]);
      setState(() {
        _feederSchedules = results[0] as List<FeederScheduleModel>;
        _uvSchedules = results[1] as List<UVScheduleModel>;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ! Helpers for Time Picker
  Future<String?> _pickTime(BuildContext context, {String? initial}) async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (initial != null) {
      final parts = initial.split(':');
      initialTime =
          TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    final picked =
        await showTimePicker(context: context, initialTime: initialTime);
    if (picked != null) {
      return '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
    return null;
  }

  // ! Dialogs
  void _showFeederDialog({FeederScheduleModel? item}) {
    final isEdit = item != null;
    String day = item?.dayName ?? 'Mon';
    String time = item?.time ?? '08:00';
    int amount = item?.amountGram ?? 10;
    bool isActive = item?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.cyan,
          title: Text(isEdit ? 'Edit Jadwal Pakan' : 'Jadwal Pakan Baru',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: day,
                dropdownColor: Colors.cyanAccent,
                isExpanded: true,
                items: _days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => day = v!),
              ),
              ListTile(
                title:
                    const Text('Waktu', style: TextStyle(color: Colors.white)),
                trailing: Text(time,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () async {
                  final t = await _pickTime(context, initial: time);
                  if (t != null) setState(() => time = t);
                },
              ),
              TextFormField(
                initialValue: amount.toString(),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Jumlah (gram)',
                    labelStyle: TextStyle(color: Colors.white)),
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => amount = int.tryParse(v) ?? 10,
              ),
              SwitchListTile(
                title:
                    const Text('Aktif', style: TextStyle(color: Colors.white)),
                value: isActive,
                activeColor: Colors.yellow,
                onChanged: (v) => setState(() => isActive = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Simpan', style: TextStyle(color: Colors.cyan)),
              onPressed: () async {
                Navigator.pop(context);
                final data = {
                  'day_name': day,
                  'time': time,
                  'amount_gram': amount,
                  'is_active': isActive
                };
                try {
                  if (isEdit) {
                    await _service.updateFeederSchedule(item.id, data);
                  } else {
                    await _service.createFeederSchedule(data);
                  }
                  _fetchSchedules();
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showUVDialog({UVScheduleModel? item}) {
    final isEdit = item != null;
    String day = item?.dayName ?? 'Mon';
    String startTime = item?.startTime ?? '20:00';
    String endTime = item?.endTime ?? '04:00';
    bool isActive = item?.isActive ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: Colors.cyan,
          title: Text(isEdit ? 'Edit Jadwal UV' : 'Jadwal UV Baru',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: day,
                dropdownColor: Colors.cyanAccent,
                isExpanded: true,
                items: _days
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (v) => setState(() => day = v!),
              ),
              ListTile(
                title:
                    const Text('Mulai', style: TextStyle(color: Colors.white)),
                trailing: Text(startTime,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () async {
                  final t = await _pickTime(context, initial: startTime);
                  if (t != null) setState(() => startTime = t);
                },
              ),
              ListTile(
                title: const Text('Selesai',
                    style: TextStyle(color: Colors.white)),
                trailing: Text(endTime,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                onTap: () async {
                  final t = await _pickTime(context, initial: endTime);
                  if (t != null) setState(() => endTime = t);
                },
              ),
              SwitchListTile(
                title:
                    const Text('Aktif', style: TextStyle(color: Colors.white)),
                value: isActive,
                activeColor: Colors.yellow,
                onChanged: (v) => setState(() => isActive = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
              child: const Text('Simpan', style: TextStyle(color: Colors.cyan)),
              onPressed: () async {
                Navigator.pop(context);
                final data = {
                  'day_name': day,
                  'start_time': startTime,
                  'end_time': endTime,
                  'is_active': isActive
                };
                try {
                  if (isEdit) {
                    await _service.updateUVSchedule(item.id, data);
                  } else {
                    await _service.createUVSchedule(data);
                  }
                  _fetchSchedules();
                } catch (e) {
                  if (mounted)
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text('$e')));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _deleteSchedule(int id, bool isFeeder) async {
    try {
      if (isFeeder) {
        await _service.deleteFeederSchedule(id);
      } else {
        await _service.deleteUVSchedule(id);
      }
      _fetchSchedules();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: const Text('Scheduling',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 24)),
            centerTitle: true,
            bottom: const TabBar(
              indicatorColor: Colors.cyan,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.black54,
              tabs: [
                Tab(icon: Icon(Icons.set_meal), text: 'Feeder'),
                Tab(icon: Icon(Icons.wb_sunny), text: 'UV Sterilizer'),
              ],
            ),
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : TabBarView(
                  children: [
                    // ! Feeder List
                    RefreshIndicator(
                      onRefresh: _fetchSchedules,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _feederSchedules.length,
                        itemBuilder: (context, index) {
                          final item = _feederSchedules[index];
                          return Card(
                            color: Colors.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.set_meal,
                                    color: item.isActive
                                        ? Colors.white
                                        : Colors.grey),
                              ),
                              title: Text('${item.dayName} - ${item.time}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 18)),
                              subtitle: Text('${item.amountGram} gram',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () =>
                                        _showFeederDialog(item: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        _deleteSchedule(item.id, true),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ! UV List
                    RefreshIndicator(
                      onRefresh: _fetchSchedules,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _uvSchedules.length,
                        itemBuilder: (context, index) {
                          final item = _uvSchedules[index];
                          return Card(
                            color: Colors.cyan,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white24,
                                child: Icon(Icons.wb_sunny,
                                    color: item.isActive
                                        ? Colors.yellow
                                        : Colors.grey),
                              ),
                              title: Text(item.dayName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 18)),
                              subtitle: Text(
                                  '${item.startTime} - ${item.endTime}',
                                  style:
                                      const TextStyle(color: Colors.white70)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () => _showUVDialog(item: item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.redAccent),
                                    onPressed: () =>
                                        _deleteSchedule(item.id, false),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
          floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 70.0),
            child: FloatingActionButton(
              backgroundColor: Colors.cyan,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Wrap(
                      children: [
                        ListTile(
                          leading:
                              const Icon(Icons.set_meal, color: Colors.cyan),
                          title: const Text('Jadwal Pakan Baru'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showFeederDialog();
                          },
                        ),
                        ListTile(
                          leading:
                              const Icon(Icons.wb_sunny, color: Colors.orange),
                          title: const Text('Jadwal UV Baru'),
                          onTap: () {
                            Navigator.pop(ctx);
                            _showUVDialog();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )),
    );
  }
}
