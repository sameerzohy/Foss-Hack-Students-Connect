// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CollegeDetailsWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const CollegeDetailsWidget({super.key, required this.formKey});

  @override
  _CollegeDetailsWidgetState createState() => _CollegeDetailsWidgetState();
}

class _CollegeDetailsWidgetState extends State<CollegeDetailsWidget> {
  // final _formKey = widget.formKey;
  String selectedDepartment = 'CSBS';
  String rollNo = '';
  String collegeName = '';

  void saveDetails() async {
    if (widget.formKey.currentState!.validate()) {
      widget.formKey.currentState!.save();
      DocumentReference collegeRef =
          FirebaseFirestore.instance.collection('colleges').doc(collegeName);

      DocumentReference departmentRef =
          collegeRef.collection('departments').doc(selectedDepartment);

      await departmentRef.collection('students').doc(rollNo).set({
        'userId': FirebaseAuth.instance.currentUser!.uid,
      });
    }
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      'collegeName': collegeName,
      'department': selectedDepartment,
      'rollNo': rollNo,
    });
  }

  final List<String> departments = [
    'CSBS',
    'CZ',
    'CSE',
    'IT',
    'AIML',
    'AIDS',
    'EEE',
    'ECE',
    'ACT',
    'VLSI',
    'BME',
    'MECH',
    'CIVIL',
    'MCT',
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: widget.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'College Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                ),
                initialValue: 'Chennai Institute of Technology',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your college name';
                  }
                  return null;
                },
                onSaved: (value) => collegeName = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Department',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                ),
                value: selectedDepartment,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDepartment = newValue!;
                  });
                },
                items:
                    departments.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select your department';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Roll Number',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your roll number';
                  }
                  return null;
                },
                onSaved: (value) => rollNo = value!,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
