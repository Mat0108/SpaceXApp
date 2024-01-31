import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Capsule {
  final String type;
  final String lastUpdate;
  final String status;

  Capsule({
    required this.type,
    required this.lastUpdate,
    required this.status,
  });

  factory Capsule.fromJson(Map<String, dynamic> json) {
    return Capsule(
        type: json['type'] ?? "",
        lastUpdate: json['last_update'] ?? "",
        status: json['status'] ?? "");
  }
}

class CapsulesPage extends StatefulWidget {
  const CapsulesPage({super.key});

  @override
  _CapsulesPageState createState() => _CapsulesPageState();
}

class _CapsulesPageState extends State<CapsulesPage> {
  List<Capsule> capsules = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response =
        await http.get(Uri.parse('https://api.spacexdata.com/v4/capsules'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      setState(() {
        capsules = data.map((item) => Capsule.fromJson(item)).toList();
      });
    } else {
      throw Exception('Failed to load capsules');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des capsules'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: capsules.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capsule: ${capsules[index].type}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8.0),
                          if (capsules[index].lastUpdate != "" &&
                              capsules[index].lastUpdate !=
                                  "Location and status unknown")
                            Text('Last update: ${capsules[index].lastUpdate}'),
                          if (capsules[index].status != "" &&
                              capsules[index].status != "unknown")
                            Text('Status: ${capsules[index].status}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
