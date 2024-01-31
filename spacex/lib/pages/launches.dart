import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Engines {
  final num number;
  final String type;
  Engines({required this.number, required this.type});
}

class Stage {
  final Engines engines;
  final num burntimesec;
  final num fuelamounttons;
  Stage(
      {required this.engines,
      required this.burntimesec,
      required this.fuelamounttons});
}

class Rocket {
  final String id;
  final String name;
  final Stage? firststage;
  final Stage? secondstage;
  Rocket(
      {required this.id,
      required this.name,
      required this.firststage,
      required this.secondstage});

  factory Rocket.fromJson(Map<String, dynamic> json) {
    return Rocket(
        id: json["id"] ?? "",
        name: json.containsKey('name') ? json['name'] : "",
        firststage: json.containsKey('first_stage')
            ? Stage(
                engines: Engines(
                    number: json['first_stage']['engines'] ?? 0,
                    type: json['engines']['type'] ?? ""),
                burntimesec: json['first_stage']['burn_time_sec'] ?? 0,
                fuelamounttons: json['first_stage']['fuel_amount_tons'] ?? 0.0)
            : null,
        secondstage: json.containsKey('second_stage')
            ? Stage(
                engines: Engines(
                    number: json['second_stage']['engines'] ?? 0,
                    type: json['engines']['type'] ?? ""),
                burntimesec: json['second_stage']['burn_time_sec'] ?? 0,
                fuelamounttons: json['second_stage']['fuel_amount_tons'] ?? 0.0)
            : null);
  }
}

class LaunchPad {
  final String last_update;
  final String status;
  final String type;

  LaunchPad(
      {required this.last_update, required this.status, required this.type});

  factory LaunchPad.fromJson(Map<String, dynamic> json) {
    return LaunchPad(
        last_update: json['last_update'] ?? "",
        status: json['status'] ?? "",
        type: json['type'] ?? "");
  }
}

class Capsule {
  final String id;
  final String lastupdate;
  final String status;
  final String type;

  Capsule(
      {required this.id,
      required this.lastupdate,
      required this.status,
      required this.type});

  factory Capsule.fromJson(Map<String, dynamic> json) {
    return Capsule(
        id: json["id"] ?? "",
        lastupdate: json['last_update'] ?? "",
        status: json['status'] ?? "",
        type: json['type'] ?? "");
  }
}

class Launch {
  final String name;
  final int flightNumber;
  final String launchYear;
  final List<dynamic> capsules;
  final String launchPad;
  final String? patchSmall;
  final String dateUtc;
  final Rocket? rocket;
  final Capsule? capsule;

  Launch(
      {required this.name,
      required this.flightNumber,
      required this.launchYear,
      required this.capsules,
      required this.launchPad,
      required this.patchSmall,
      required this.dateUtc,
      this.rocket,
      this.capsule});

  factory Launch.fromJsonR(Map<String, dynamic> json, Rocket rocket) {
    return Launch(
      name: json['name'] ?? "",
      flightNumber: json['flight_number'] ?? 0,
      launchYear: json.containsKey('date_utc')
          ? json['date_utc'].toString().substring(0, 4)
          : "",
      capsules: (json.containsKey('capsules') && json['capsules'] is List)
          ? json['capsules']
          : [],
      launchPad: json['launchpad'] ?? "",
      patchSmall: json['links']['patch']['small'] ?? "",
      dateUtc: json.containsKey('date_utc') ? json['date_utc'] : "",
      rocket: rocket,
    );
  }
  factory Launch.fromJsonRC(
      Map<String, dynamic> json, Rocket rocket, Capsule capsule) {
    return Launch(
        name: json['name'] ?? "",
        flightNumber: json['flight_number'] ?? 0,
        launchYear: json.containsKey('date_utc')
            ? json['date_utc'].toString().substring(0, 4)
            : "",
        capsules: (json.containsKey('capsules') && json['capsules'] is List)
            ? json['capsules']
            : [],
        launchPad: json['launchpad'] ?? "",
        patchSmall: json['links']['patch']['small'] ?? "",
        dateUtc: json.containsKey('date_utc') ? json['date_utc'] : "",
        rocket: rocket,
        capsule: capsule);
  }
}

class LaunchesPage extends StatefulWidget {
  const LaunchesPage({super.key});

  @override
  _LaunchesPageState createState() => _LaunchesPageState();
}

class _LaunchesPageState extends State<LaunchesPage> {
  List<Launch> Launches = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLaunches();
  }

  Future<void> getLaunches() async {
    setState(() {
      isLoading = true;
    });

    final responseLaunches =
        await http.get(Uri.parse('https://api.spacexdata.com/v4/launches'));
    final responseRockets =
        await http.get(Uri.parse('https://api.spacexdata.com/v4/rockets'));
    final responseCapsules =
        await http.get(Uri.parse('https://api.spacexdata.com/v4/capsules'));
    if (responseLaunches.statusCode == 200 &&
        responseRockets.statusCode == 200 &&
        responseCapsules.statusCode == 200) {
      List<dynamic> data = jsonDecode(responseLaunches.body);
      List<dynamic> rocketsData = jsonDecode(responseRockets.body);
      List<dynamic> capsulesData = jsonDecode(responseCapsules.body);
      // Créer une liste de Rocket à partir des données des fusées
      List<Rocket> rockets =
          rocketsData.map((rocketData) => Rocket.fromJson(rocketData)).toList();
      List<Capsule> capsules = capsulesData
          .map((capsuleData) => Capsule.fromJson(capsuleData))
          .toList();
      // Créer une liste de Launch à partir des données des lancements en associant chaque lancement à sa fusée correspondante
      List<Launch> launches = [];
      for (dynamic launchData in data) {
        // Trouver la Rocket correspondante dans la liste des fusées en utilisant l'ID du rocket du lancement
        String rocketId = launchData["rocket"];
        Rocket? rocket = rockets.firstWhere((rocket) => rocket.id == rocketId);
        if (launchData["capsules"] != null &&
            launchData["capsules"].isNotEmpty) {
          String capsuleId = launchData["capsules"][0];
          Capsule? capsule =
              capsules.firstWhere((capsule) => capsule.id == capsuleId);

          // Si une Rocket correspondante est trouvée, créer un objet Launch et l'ajouter à la liste des lancements
          launches.add(Launch.fromJsonRC(launchData, rocket, capsule));
        } else {
          launches.add(Launch.fromJsonR(launchData, rocket));
        }
      }
      // Mettre à jour l'état avec la liste des lancements associée aux fusées correspondantes
      setState(() {
        Launches = launches;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load launches');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Launches'),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Expanded(
                    child: ListView.builder(
                      itemCount: Launches.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Card(
                          child: ListTile(
                            title: Text(
                                'Nom de la mission : ${Launches[index].name}'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    'Flight number : ${Launches[index].flightNumber} - Launch year : ${Launches[index].launchYear}'),
                                Text(
                                    'Rocket name : ${Launches[index].rocket?.name}'),
                                const SizedBox(height: 10),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(" "),
                                        Text("1 étage"),
                                        Text("2 étage"),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("Type et nb moteur"),
                                        Text(
                                            '${Launches.first.rocket?.firststage?.engines.type ?? ""} ${Launches.first.rocket?.firststage?.engines.number ?? ""}'),
                                        Text(
                                            '${Launches.first.rocket?.secondstage?.engines.type ?? ""} ${Launches.first.rocket?.secondstage?.engines.number ?? ""}'),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("isp"),
                                        Text(
                                            '${Launches.first.rocket?.firststage?.burntimesec ?? ""}'),
                                        Text(
                                            '${Launches.first.rocket?.secondstage?.burntimesec ?? ""}'),
                                      ],
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text("T fuel"),
                                        Text(
                                            '${Launches.first.rocket?.firststage?.fuelamounttons ?? ""}'),
                                        Text(
                                            '${Launches.first.rocket?.secondstage?.fuelamounttons ?? ""}'),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Launches[index].capsule?.lastupdate != null
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                            Container(
                                                width: 300,
                                                child: Text(
                                                    'Capsule : ${Launches[index].capsule?.lastupdate}')),
                                            Container(
                                                width: 300,
                                                child: Text(
                                                    'status : ${Launches[index].capsule?.status} | type : ${Launches[index].capsule?.type} '))
                                          ])
                                    : Container()
                              ],
                            ),
                            leading: (Launches[index].patchSmall != null &&
                                    Launches[index].patchSmall != "")
                                ? Image.network(Launches[index].patchSmall!)
                                : SizedBox(),
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
