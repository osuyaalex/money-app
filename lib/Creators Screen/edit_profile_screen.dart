import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:walletapp/Creators%20Screen/creators_home.dart';


import '../controllers/auth_controller.dart';

class EditProfileScreen extends StatefulWidget {

  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthController _authController = AuthController();
  Uint8List? _image;
  Uint8List? _profilePic;
  late String _name;
   String? _location;
   String? _linked;
   int? _contact;
   int? _dob;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  uploadProfilePictureToStorage(Uint8List? image)async{
    Reference ref =  FirebaseStorage.instance.ref().child('Profile').child(FirebaseAuth.instance.currentUser!.uid);
    UploadTask uploadTask =ref.putData(image!);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  editProfile()async{
    CollectionReference creatorCollection = FirebaseFirestore.instance.collection('Creators');
    String profileImageUrl =await uploadProfilePictureToStorage(_image);
    String profilePicUrl =await uploadProfilePictureToStorage(_profilePic);
    _firestore.collection('Creators').where('uid', isEqualTo:_auth.currentUser!.uid ).
        get().
        then((QuerySnapshot snapshot){
          int length = snapshot.docs.length;
          snapshot.docs.forEach((DocumentSnapshot document) {
            final String documentId = length.toString();
            creatorCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
              'EditedFullName': _name,
              'ID':'ID $documentId',
              'location': _location,
              'links': _linked,
              'contact':_contact,
              'dob':_dob,
              'uid':FirebaseAuth.instance.currentUser!.uid,
              'likes':[],
              'Headers': profileImageUrl,
              'ProfilePic':profilePicUrl
            }).whenComplete((){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return const CreatorHomeScreen();
              }));

            });
          });
    });

  }
  pickProfileFromGallery()async{
    Uint8List im = await _authController.pickImage(ImageSource.gallery);
    setState(() {
      _profilePic = im;
    });
  }
  pickProfileFromCamera()async{
    Uint8List im = await _authController.pickImage(ImageSource.camera);
    setState(() {
      _profilePic = im;
    });
  }

  pickHeaderFromGallery()async{
    Uint8List im = await _authController.pickImage(ImageSource.gallery);
    setState(() {
      _image = im;
    });
  }
  pickHeaderFromCamera()async{
    Uint8List im = await _authController.pickImage(ImageSource.camera);
    setState(() {
      _image = im;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe5e5e5),
      appBar: AppBar(
        leading: const BackButton(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit profile',
                style: GoogleFonts.epilogue(
                  color: Colors.black,
                  fontWeight: FontWeight.w700
                ),
              ),
              TextButton(
                  onPressed: (){
                    editProfile();
                  },
                  child: Text('Save')
              )
            ],
          ),
        ),
      ),
      body:   SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                GestureDetector(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            //alignment: Alignment.center,
                            actions: [
                              TextButton(
                                  onPressed: (){
                                    pickHeaderFromCamera();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Take Picture')
                              ),
                              TextButton(
                                  onPressed: (){
                                    pickHeaderFromGallery();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Choose Existing Photo')
                              )
                            ],

                          );
                        }
                    );
                  },
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      Container(
                        height: 180,
                        width: MediaQuery.of(context).size.width,
                        decoration: _image != null ?BoxDecoration(
                            image:DecorationImage(image: MemoryImage(_image!), fit: BoxFit.fill)
                        ):const BoxDecoration(
                            color: Colors.black
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: (){
                    showDialog(
                        context: context,
                        builder: (context){
                          return AlertDialog(
                            //alignment: Alignment.center,
                            actions: [
                              TextButton(
                                  onPressed: (){
                                    pickProfileFromCamera();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Take Picture')
                              ),
                              TextButton(
                                  onPressed: (){
                                    pickProfileFromGallery();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Choose Existing Photo')
                              )
                            ],

                          );
                        }
                    );
                  },
                  child: SizedBox(
                    child: Padding(
                      padding:  const EdgeInsets.only(top: 110),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child:_profilePic == null? const CircleAvatar(
                          backgroundImage: NetworkImage(
                              'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                          ),
                          radius: 65,

                        ):CircleAvatar(
                          backgroundImage: MemoryImage(_profilePic!),
                          radius: 65,

                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                onChanged: (v){
                  _name = v;
                },
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: GoogleFonts.epilogue(
                    fontWeight: FontWeight.w500
                  )
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                onChanged: (v){
                  _location = v;
                },
                keyboardType: TextInputType.streetAddress,
                decoration: InputDecoration(
                    labelText: 'Location',
                    labelStyle: GoogleFonts.epilogue(
                        fontWeight: FontWeight.w500,
                    )

                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                onChanged: (value){
                  _linked = value;
                },
                keyboardType: TextInputType.url,
                decoration: InputDecoration(
                    labelText: 'Linked',
                    labelStyle: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w500,
                    )

                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                onChanged: (v){
                  _contact = int.parse(v);
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Contact',
                    labelStyle: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w500,
                    )

                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextFormField(
                onChanged: (v){
                  _dob = int.parse(v);
                },
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: 'Date of birth',
                    labelStyle: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w500,
                    )

                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 40,
                  width: 150,
                  decoration:  BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: const Border(
                        top: BorderSide(
                            color: Colors.black
                        ),
                        bottom: BorderSide(
                            color: Colors.black
                        ),
                        left: BorderSide(
                            color: Colors.black
                        ),
                        right: BorderSide(
                            color: Colors.black
                        ),
                      )
                  ),
                  child: Center(
                    child: Text('Go to upload',
                      style: GoogleFonts.epilogue(
                        fontWeight: FontWeight.bold,
                        fontSize: 14
                      ),
                    ),
                  )
                ),
              ],
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
      ) ,
    );
  }
}
