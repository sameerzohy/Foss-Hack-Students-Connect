import 'package:flutter/material.dart';
import 'package:students_connect/teachers/home_screen_widgets.dart';

class TeacherHomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<TeacherHomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _selectedIndex == 0
            ? Text('Home')
            : _selectedIndex == 1
                ? Text('Classroom')
                : _selectedIndex == 2
                    ? Text('Permissions')
                    : Text('Personal Info'),
      ),
      body: _selectedIndex == 0
          ? ImagePickerWidget()
          : _selectedIndex == 1
              ? ChatScreen()
              : _selectedIndex == 2
                  ? PermitOD()
                  : PersonalInfoWidget(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color.fromARGB(255, 24, 37, 31),
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amberAccent,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: 'Classroom',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Permissions',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Personal Info',
          ),
        ],
      ),
    );
  }
}
