import 'package:flutter/material.dart';
import 'package:spacex/color.dart';
import './pages/capsule.dart';
import './pages/launches.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    CapsulesPage(),
    LaunchesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: AppColors.background,
          title: Center(
            child: Text(
                _selectedIndex == 0
                    ? "Liste des capsules"
                    : "Liste des launches",
                style: const TextStyle(color: AppColors.text)),
          )),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.backgroundbar,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.rocket_outlined,
                  color:
                      _selectedIndex == 1 ? AppColors.select : AppColors.text),
              label: 'Capsule',
              backgroundColor: AppColors.text),
          BottomNavigationBarItem(
            icon: Icon(Icons.rocket_launch_outlined,
                color: _selectedIndex == 0 ? AppColors.select : AppColors.text),
            label: 'Launches',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.text,
        unselectedItemColor: AppColors.select,
        selectedLabelStyle:
            const TextStyle(color: AppColors.text), // Set selected label color
        unselectedLabelStyle: const TextStyle(color: AppColors.select),
        onTap: _onItemTapped,
      ),
    );
  }
}
