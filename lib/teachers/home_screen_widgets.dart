import 'package:flutter/material.dart';
import 'package:students_connect/widgets/chat_message.dart';
import 'package:students_connect/widgets/new_message.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:aws_s3_upload/aws_s3_upload.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Widget ChatScreen() {
  return Container(
    margin: EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: ChatMessage(),
        ),
        NewMessage(),
      ],
    ),
  );
}

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  File? _image;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void uploadToS3() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    try {
      print('image selected: $_image');
      // Replace with your actual AWS S3 upload logic
      var response = await AwsS3.uploadFile(
        accessKey: "AKIASB57EHHLEMXSA4GD",
        secretKey: "DP1FJdKaErdQRlxlWwAFlDmq/AQgyekYMi3AD9HO",
        file: _image!,
        bucket: "students-connect",
        region: "us-east-1", // optional
      );
      print('Upload successful: ${response.toString()}');
      var url = response.toString();
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'profileImageUrl': url,
      });

      // Awss3Response awsResponse = Awss3Response.fromJson(response);
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image != null
              ? Image.file(
                  _image!,
                  width: 300,
                  height: 300,
                  fit: BoxFit.cover,
                )
              : Text('No image selected.'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: Text('Pick Image from Gallery'),
          ),
          ElevatedButton(
            onPressed: uploadToS3,
            child: Text('Upload Image'),
          ),
        ],
      ),
    );
  }
}

class UserProfileWidget extends StatelessWidget {
  const UserProfileWidget({super.key});
  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('User data not found'));
        }

        var userData = snapshot.data!.data() as Map<String, dynamic>;
        var userName = userData['name'];
        var profileImageUrl = userData['profileImageUrl'];
        print(profileImageUrl);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              profileImageUrl != null
                  ? Image.network(
                      profileImageUrl,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.account_circle, size: 100),
              SizedBox(height: 20),
              Text(userName ?? 'No name available'),
            ],
          ),
        );
      },
    );
  }
}

class PermitOD extends StatelessWidget {
  const PermitOD({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('colleges')
          .doc('Chennai Institute of Technology')
          .collection('departments')
          .doc('CSBS')
          .collection('od_requests')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No OD requests found'));
        }

        final odRequests = snapshot.data!.docs;

        return ListView.builder(
          itemCount: odRequests.length,
          itemBuilder: (context, index) {
            var odRequest = odRequests[index].data() as Map<String, dynamic>;
            var dateTime = odRequest['data'].toDate();
            return Card(
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Student Name: ${odRequest['from']}'),
                    const SizedBox(height: 10),
                    Text('Reason: ${odRequest['purpose']}'),
                    const SizedBox(height: 10),
                    Text('Status: ${odRequest['status']}'),
                    const SizedBox(height: 10),
                    Text(
                        'Date: ${dateTime.day}-${dateTime.month}-${dateTime.year} ${dateTime.hour}:${dateTime.minute}'),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!odRequest['review'])
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('colleges')
                                  .doc('Chennai Institute of Technology')
                                  .collection('departments')
                                  .doc('CSBS')
                                  .collection('od_requests')
                                  .doc(odRequests[index].id)
                                  .update({
                                'review': true,
                                'status': 'Accepted',
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Accept',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () async {
                              await FirebaseFirestore.instance
                                  .collection('colleges')
                                  .doc('Chennai Institute of Technology')
                                  .collection('departments')
                                  .doc('CSBS')
                                  .collection('od_requests')
                                  .doc(odRequests[index].id)
                                  .update({
                                'review': true,
                                'status': 'Rejected',
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              'Reject',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class PersonalInfoWidget extends StatefulWidget {
  @override
  _PersonalInfoWidgetState createState() => _PersonalInfoWidgetState();
}

class _PersonalInfoWidgetState extends State<PersonalInfoWidget> {
  File? _image;
  String? _name;
  String? _department;
  String? _profileImageUrl;
  final _nameController = TextEditingController();
  final _departmentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        if (mounted) {
          setState(() {
            _name = userDoc['name'];
            _department = userDoc['department'];
            _profileImageUrl = userDoc['profileImageUrl'];
            _nameController.text = _name!;
            _departmentController.text = _department!;
          });
        }
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      if (mounted) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_image == null) {
      print('No image selected.');
      return;
    }

    try {
      // Replace with your actual AWS S3 upload logic
      var response = await AwsS3.uploadFile(
        accessKey: "AKIASB57EHHLEMXSA4GD",
        secretKey: "DP1FJdKaErdQRlxlWwAFlDmq/AQgyekYMi3AD9HO",
        file: _image!,
        bucket: "students-connect",
        region: "us-east-1", // optional
      );
      if (response != null) {
        if (mounted) {
          setState(() {
            _profileImageUrl = response.toString();
          });
        }
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'profileImageUrl': _profileImageUrl});
        }
        print('Upload successful: $response');
      } else {
        print('Upload failed: Response is null');
      }
    } catch (e) {
      print('Upload failed: $e');
    }
  }

  Future<void> _updateUserInfo() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'department': _departmentController.text,
      });
      if (mounted) {
        setState(() {
          _name = _nameController.text;
          _department = _departmentController.text;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _image != null
                ? FileImage(_image!)
                : _profileImageUrl != null
                    ? NetworkImage(_profileImageUrl!)
                    : AssetImage('assets/default_profile.png') as ImageProvider,
            child: _profileImageUrl == null && _image == null
                ? Icon(Icons.account_circle, size: 100)
                : null,
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            child: Text('Change Profile Photo'),
          ),
          ElevatedButton(
            onPressed: _uploadProfileImage,
            child: Text('Upload Profile Photo'),
          ),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: _departmentController,
            decoration: InputDecoration(labelText: 'Department'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _updateUserInfo,
            child: Text('Update Info'),
          ),
        ],
      ),
    );
  }
}
