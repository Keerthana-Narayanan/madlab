import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

void main() => runApp(PlantCareApp());

class PlantCareApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plant Care Reminder',
      theme: ThemeData(primarySwatch: Colors.green),
      home: PlantListScreen(),
    );
  }
}

class Plant {
  String name;
  int wateringFrequency; // in days
  String sunlightRequirement;
  String tips;
  String imagePath;
  DateTime lastWatered;

  Plant({
    required this.name,
    required this.wateringFrequency,
    required this.sunlightRequirement,
    required this.tips,
    required this.imagePath,
    required this.lastWatered,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'wateringFrequency': wateringFrequency,
    'sunlightRequirement': sunlightRequirement,
    'tips': tips,
    'imagePath': imagePath,
    'lastWatered': lastWatered.toIso8601String(),
  };

  static Plant fromJson(Map<String, dynamic> json) => Plant(
    name: json['name'],
    wateringFrequency: json['wateringFrequency'],
    sunlightRequirement: json['sunlightRequirement'],
    tips: json['tips'],
    imagePath: json['imagePath'],
    lastWatered: DateTime.parse(json['lastWatered']),
  );
}

class PlantListScreen extends StatefulWidget {
  @override
  _PlantListScreenState createState() => _PlantListScreenState();
}

class _PlantListScreenState extends State<PlantListScreen> {
  List<Plant> plants = [];

  @override
  void initState() {
    super.initState();
    _loadPlants();
  }

  Future<void> _loadPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('plants') ?? [];
    setState(() {
      plants = data.map((e) => Plant.fromJson(json.decode(e))).toList();
    });
  }

  Future<void> _savePlants() async {
    final prefs = await SharedPreferences.getInstance();
    final data = plants.map((e) => json.encode(e.toJson())).toList();
    await prefs.setStringList('plants', data);
  }

  void _addOrEditPlant({Plant? plant, int? index}) async {
    final result = await Navigator.push<Plant>(
      context,
      MaterialPageRoute(builder: (context) => PlantFormScreen(plant: plant)),
    );

    if (result != null) {
      setState(() {
        if (index != null) {
          plants[index] = result;
        } else {
          plants.add(result);
        }
      });
      _savePlants();
    }
  }

  void _deletePlant(int index) {
    setState(() {
      plants.removeAt(index);
    });
    _savePlants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Plants')),
      body: ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          final nextWaterDate = plant.lastWatered.add(
            Duration(days: plant.wateringFrequency),
          );
          return Card(
            child: ListTile(
              leading: Image.asset(
                plant.imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(plant.name),
              subtitle: Text(
                'Next Watering: ${DateFormat.yMMMd().format(nextWaterDate)}\nSunlight: ${plant.sunlightRequirement}\nTips: ${plant.tips}',
              ),
              isThreeLine: true,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed:
                        () => _addOrEditPlant(plant: plant, index: index),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deletePlant(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _addOrEditPlant(),
      ),
    );
  }
}

class PlantFormScreen extends StatefulWidget {
  final Plant? plant;
  PlantFormScreen({this.plant});

  @override
  _PlantFormScreenState createState() => _PlantFormScreenState();
}

class _PlantFormScreenState extends State<PlantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _frequencyController;
  late TextEditingController _sunlightController;
  late TextEditingController _tipsController;
  String _imagePath = 'assets/plant_default.jpg';
  DateTime _lastWatered = DateTime.now();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.plant?.name ?? '');
    _frequencyController = TextEditingController(
      text: widget.plant?.wateringFrequency.toString() ?? '',
    );
    _sunlightController = TextEditingController(
      text: widget.plant?.sunlightRequirement ?? '',
    );
    _tipsController = TextEditingController(text: widget.plant?.tips ?? '');
    _imagePath = widget.plant?.imagePath ?? 'assets/plant_default.jpg';
    _lastWatered = widget.plant?.lastWatered ?? DateTime.now();
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastWatered,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _lastWatered = picked);
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final newPlant = Plant(
        name: _nameController.text,
        wateringFrequency: int.parse(_frequencyController.text),
        sunlightRequirement: _sunlightController.text,
        tips: _tipsController.text,
        imagePath: _imagePath,
        lastWatered: _lastWatered,
      );
      Navigator.pop(context, newPlant);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.plant == null ? 'Add Plant' : 'Edit Plant'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Plant Name'),
                validator:
                    (value) => value!.isEmpty ? 'Enter plant name' : null,
              ),
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: 'Watering Frequency (days)',
                ),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? 'Enter frequency' : null,
              ),
              TextFormField(
                controller: _sunlightController,
                decoration: InputDecoration(labelText: 'Sunlight Requirement'),
              ),
              TextFormField(
                controller: _tipsController,
                decoration: InputDecoration(labelText: 'Tips'),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Last Watered: ${DateFormat.yMMMd().format(_lastWatered)}',
                    ),
                  ),
                  TextButton(onPressed: _pickDate, child: Text('Pick Date')),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: Text('Save Plant')),
            ],
          ),
        ),
      ),
    );
  }
}
