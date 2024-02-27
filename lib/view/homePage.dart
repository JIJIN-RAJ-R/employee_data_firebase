import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;



class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  final CollectionReference _employee =
      FirebaseFirestore.instance.collection('employee');
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  bool _isImagePickingInProgress = false;

  Future<void> _deleteEmployee(
      BuildContext context, String employeeId, String? imageUrl) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete employee'),
          content: const Text('Are you sure you want to delete this employee?'),
          actions: <Widget>[
            TextButton(
              child: const Text('No'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _employee.doc(employeeId).delete();

      // Delete employee image from Firebase Storage if imageUrl is not null
      if (imageUrl != null) {
        Reference imageRef = _storage.refFromURL(imageUrl);
        await imageRef.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted an employee'),
      ));
    }
  }

  Future<String?> _uploadImage(XFile pickedImage) async {
    final File file = File(pickedImage.path);
    final String fileName = path.basename(file.path);
    final Reference ref = _storage.ref().child('employeeImages/$fileName');

    final UploadTask uploadTask = ref.putFile(file);
    final TaskSnapshot snapshot = await uploadTask;

    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    String? imageUrl;

    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _priceController.text = documentSnapshot['price'].toString();
      _emailController.text = documentSnapshot['email'];
      _genderController.text = documentSnapshot['gender'];
      _designationController.text = documentSnapshot['designation'];
    }

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (BuildContext ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Salary'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a salary';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an email';
                    }
                    // Email format validation
                    if (!RegExp(
                            r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _genderController,
                  decoration: const InputDecoration(labelText: 'Gender'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a gender';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _designationController,
                  decoration: const InputDecoration(labelText: 'Designation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a designation';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text(action == 'create' ? 'Create' : 'Update'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final String name = _nameController.text;
                      final double? price =
                          double.tryParse(_priceController.text);
                      final email = _emailController.text;
                      final gender = _genderController.text;
                      final designation = _designationController.text;
                      if (price != null) {
                        final bool? confirmed = await showDialog<bool>(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(action == 'create'
                                  ? 'Create Employee'
                                  : 'Update Employee'),
                              content: Text(
                                  'Are you sure you want to $action this employee?'),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('No'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: const Text('Yes'),
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                ),
                              ],
                            );
                          },
                        );

                        if (confirmed == true) {
                          if (action == 'create') {
                            XFile? pickedImage = await _picker.pickImage(
                                source: ImageSource.gallery);
                            if (pickedImage != null) {
                              imageUrl = await _uploadImage(pickedImage);
                            }
                          } else {
                            imageUrl = documentSnapshot!['imageUrl'];
                          }

                          if (action == 'create' || imageUrl != null) {
                            if (action == 'create') {
                              await _employee.add({
                                'name': name,
                                'price': price,
                                'email': email,
                                'gender': gender,
                                'designation': designation,
                                'imageUrl': imageUrl,
                              });
                            } else if (action == 'update') {
                              await _employee.doc(documentSnapshot!.id).update({
                                'name': name,
                                'price': price,
                                'email': email,
                                'gender': gender,
                                'designation': designation,
                                'imageUrl': imageUrl,
                              });
                            }

                            _nameController.text = '';
                            _priceController.text = '';
                            _emailController.text = '';
                            _genderController.text = '';
                            _designationController.text = '';

                            // ignore: use_build_context_synchronously
                            Navigator.of(context).pop();
                          }
                        }
                      }
                    }
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.people)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 207, 207, 207),
        title: const Text(
          'Employee  IDCard',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.verified_user_outlined,
              size: 42,
            ),
          )
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://img.utdstc.com/screen/d46/b97/d46b9742ae4d22f1d8b9f4d646c98b68f1c5a28136c438c7452ee4294946469a:600'),
            fit: BoxFit.cover,
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: _employee.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            }
            if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
              return ListView(
                padding: const EdgeInsets.all(8.0),
                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return Card(
                    child: ListTile(
                      leading: GestureDetector(
                        onTap: () async {
                          bool? confirmUpdate = await showDialog<bool>(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Update Image'),
                                content: const Text(
                                    'Are you sure you want to update the image?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('No'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                  ),
                                  TextButton(
                                    child: const Text('Yes'),
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                  ),
                                ],
                              );
                            },
                          );
                          if (confirmUpdate == true) {
                            if (!_isImagePickingInProgress) {
                              setState(() {
                                _isImagePickingInProgress = true;
                              });
                              XFile? pickedImage = await _picker.pickImage(
                                  source: ImageSource.gallery);
                              if (pickedImage != null) {
                                // Delete the old image from Firebase Storage if it exists
                                if (data['imageUrl'] != null) {
                                  Reference oldImageRef =
                                      _storage.refFromURL(data['imageUrl']);
                                  await oldImageRef.delete();
                                }
                                // Upload the new image and update the user's profile
                                String? imageUrl =
                                    await _uploadImage(pickedImage);
                                if (imageUrl != null) {
                                  setState(() {
                                    data['imageUrl'] = imageUrl;
                                    _isImagePickingInProgress = false;
                                  });
                                  // Update the image URL in the Firestore database
                                  await _employee
                                      .doc(document.id)
                                      .update({'imageUrl': imageUrl});
                                }
                              }
                            }
                          }
                        },
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(data['imageUrl'] ?? ''),
                        ),
                      ),
                      title: Column(
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Name : ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(data['name'] ?? ''),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Email : ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(data['email'] ?? ''),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Salary :',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(data['price'].toString()),
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Gender : ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(data['gender'].toString())
                            ],
                          ),
                          Row(
                            children: [
                              const Text(
                                'Designation : ',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              Text(data['designation'].toString())
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blueGrey,
                                ),
                                onPressed: () => _createOrUpdate(document),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteEmployee(
                                    context, document.id, data['imageUrl']),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            }
            return const Center(
              child: Text('No Data Available'),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createOrUpdate,
        child: const Icon(Icons.add),
      ),
    );
  }
}
