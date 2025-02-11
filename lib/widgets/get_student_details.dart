import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StudentDetailsWidget extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  const StudentDetailsWidget({super.key, required this.formKey});

  @override
  State<StudentDetailsWidget> createState() => _StudentDetailsWidgetState();
}

class _StudentDetailsWidgetState extends State<StudentDetailsWidget> {
  String studentName = '';
  DateTime? dateOfBirth;

  void saveDetails() {
    if (widget.formKey.currentState!.validate()) {
      widget.formKey.currentState!.save();
      FirebaseFirestore.instance
          .collection('students')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'studentName': studentName,
        'dateOfBirth': dateOfBirth,
      });
    }
  }

  int calculateAge(DateTime birthDate) {
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: dateOfBirth ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != dateOfBirth) {
      setState(() {
        dateOfBirth = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20),
        child: Form(
          key: widget.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Enter your Details'),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Student Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                ),
                onSaved: (value) => studentName = value!,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.grey, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: dateOfBirth == null
                      ? ''
                      : '${dateOfBirth!.day}/${dateOfBirth!.month}/${dateOfBirth!.year}',
                ),
                validator: (value) {
                  if (dateOfBirth == null) {
                    return 'Please select your date of birth';
                  }
                  int age = calculateAge(dateOfBirth!);
                  if (age < 17) {
                    return 'You must be 17 years or older';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
