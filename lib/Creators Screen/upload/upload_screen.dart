
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:walletapp/Creators%20Screen/creators_home.dart';
import 'package:walletapp/utils/snackbar.dart';




class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  bool _enterDiscount = false;
  bool _instantSalePrice = false;
  bool _unlockOncePurchased = false;
  dynamic _file;
  dynamic _extension;
  List<PlatformFile> _pickFileList = [];
  bool _showMultiPick = false;
 int _discount = 1;
 int? _instantPrice;
  late String _itemName;
  late int _itemPrice;
  late String _itemDescription;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  late String _itemId;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  Map<String, dynamic> _creatorDoc = {};

 


  _pickFile()async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png','gif','webp','mp4','mp3', 'jpg'],
    );
    if(result != null){
      File file = File(result.files.single.path!);
      setState(() {

        _file = file;
        _extension = result.files.single.extension!;
      });
    }
  }
  _pickMultipleFiles()async{
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: ['png','gif','webp','mp4','mp3', 'jpg'],
    );
    if(result != null){
      List<PlatformFile> _pickedFile = result.files;
      setState(() {
        _pickFileList = _pickedFile;
      });
    }
  }


  VideoPlayerController _getVideoPlayer(){
    final controller = VideoPlayerController.file(_file!);
    controller.initialize().then((_){
      setState(() {});
    });
    controller.play();
    return controller;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if(_extension == 'mp4'){
      _getVideoPlayer().dispose();
    }
    super.dispose();
  }

  _uploadItemImageToStorage(image)async{
    if(_file != null){
      try{
        final ref = FirebaseStorage.instance.ref().child('singleImages/${DateTime.now().millisecondsSinceEpoch}.jpg');
        final task = ref.putFile(File(image.path));
        final snapshot = await task.whenComplete(() => null);
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }catch(e){
        print(e.toString());
      }
    }


  }
  Future <List<String>?> _uploadMultipleItemImageToStorage()async{
    List<String> downloadUrls = [];
    if(_pickFileList.isNotEmpty){
      try{
        for(PlatformFile file in _pickFileList){
          Reference ref =  FirebaseStorage.instance.ref().child('imageMulti').child(Uuid().v4());
          await ref.putFile(File(file.path!)).whenComplete(()async{
            await ref.getDownloadURL().then((value){
              downloadUrls.add(value);
            });
          });
        }
      }catch(e){
        print(e);
      }
     return downloadUrls;
    }else{
      return null;
    }

  }

    _updateFirebaseCollection()async{
    setState(() {
      EasyLoading.show(status: 'Please wait');
    });
    if(_globalKey.currentState!.validate()){
     if(_file != null || _pickFileList.isNotEmpty){
       if(_discount <= 100){
         CollectionReference productCollection =  _firestore.collection('Products');
         DocumentSnapshot userDoc = await FirebaseFirestore.instance
             .collection('Creators')
             .doc(_auth.currentUser!.uid)
             .get();
         setState(() {
           Map<String, dynamic> creatorData = userDoc.data()!as Map<String, dynamic>;
           _creatorDoc = creatorData;
         });
         String? itemImageUrl = await _uploadItemImageToStorage(_file);
         List<String>? multiImage = await _uploadMultipleItemImageToStorage();
         _itemId =const Uuid().v4();
         await productCollection.doc(_itemId).set({
           'email': _creatorDoc['email'],
           'itemId': _itemId,
           'like': [],
           'location': _creatorDoc['location'],
           'links': _creatorDoc['links'],
           'contact':_creatorDoc['contact'],
           'Headers': _creatorDoc['Headers'],
           'ProfilePic':_creatorDoc['ProfilePic'],
           'FullName':_creatorDoc['FullName'],
           'uid': _auth.currentUser!.uid,
           'itemName': _itemName,
           'itemImage': itemImageUrl,
           'itemImageList': multiImage,
           'itemDescription': _itemDescription,
           'itemPrice':_itemPrice,
           'discount': _discount,
           'instantPrice':_instantPrice,
           'open': false
         });
         EasyLoading.dismiss();
       }else{
         EasyLoading.dismiss();
         return snack(context, 'Discounts Cannot be greater than 100%');
       }
     }else{
         EasyLoading.dismiss();
       return snack(context, 'Please Select Image');
     }
    }else{
     return EasyLoading.dismiss();
    }
    }
    _getProfilePic()async{
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('Creators')
            .doc(_auth.currentUser!.uid)
            .get();
        setState(() {
          Map<String, dynamic> creatorData = userDoc.data()!as Map<String, dynamic>;
          _creatorDoc = creatorData;
        });
    }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _globalKey,
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              toolbarHeight: MediaQuery.of(context).size.height*0.1,
              flexibleSpace: LayoutBuilder(
                  builder: (context, constraints){
                    return FlexibleSpaceBar(
                      background: Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset('assets/images/Logo.svg'),
                              Row(
                                children: [
                                  SvgPicture.asset('assets/icons/Search.svg'),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  SvgPicture.asset('assets/icons/Menu.svg'),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  }
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 30, bottom: 20),
                      child: Text('Upload Artwork',
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.w700,
                          fontSize: 23
                        ),
                      ),
                    ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: GestureDetector(
                  onTap: (){
                    setState(() {
                      _pickFileList.clear();
                    });
                    _pickFile();
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 160,
                    decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30)
                    ),
                    child: Center(
                      child: SvgPicture.asset('assets/icons/Group 26.svg'),
                    ),
                  ),
                ),
              ),
                    Row(
                      children: [
                        Checkbox(
                          value: _showMultiPick,
                          onChanged: (value) {
                            setState(() {
                              _showMultiPick = value!;
                            });
                          },
                          side: BorderSide(
                            color: Colors.grey.shade500
                          ),
                        ),
                        Text('Multi-File',
                          style: GoogleFonts.epilogue(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade500
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _showMultiPick ?GestureDetector(
                            onTap: (){
                              setState(() {
                                _file = null;
                              });
                              _pickMultipleFiles();
                            },
                            child: SvgPicture.asset('assets/images/Select.svg',)
                        ):
                        SvgPicture.asset('assets/images/Select.svg',colorFilter:ColorFilter.mode(Colors.grey, BlendMode.clear),),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 15),
                      child: Text('Information',
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.w700,
                          fontSize: 19
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: TextFormField(
                        validator: (v){
                          if(v!.isEmpty){
                            return 'Please fill in item name';
                          }
                        },
                        onChanged: (value){
                          setState(() {
                            _itemName = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Item name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          )
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: TextFormField(
                        keyboardType: TextInputType.number,
                        validator: (v){
                          if(v!.isEmpty){
                            return 'Please fill in Price';
                          }
                        },
                        onChanged: (value){
                          _itemPrice = int.parse(value);
                        },
                        decoration: InputDecoration(
                          fillColor: Colors.grey.shade300,
                            filled: true,
                            labelText: 'Price',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          enabledBorder:  OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(
                              color: Colors.transparent
                            )
                          )
                        ),

                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: TextFormField(
                        validator: (v){
                          if(v!.isEmpty || v.length < 60){
                            return 'info not enough. Put in more';
                          }
                        },
                        maxLength: 500,
                        onChanged: (value){
                          _itemDescription = value;
                        },
                        decoration: InputDecoration(
                            contentPadding: const EdgeInsets.fromLTRB(20, 25, 20, 100),
                            fillColor: Colors.grey.shade300,
                            filled: true,
                            labelText: 'Description',

                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            enabledBorder:  OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                    color: Colors.transparent
                                )
                            )
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Checkbox(
                            value: _enterDiscount,
                            onChanged: (value) {
                              setState(() {
                                _enterDiscount = value!;
                              });
                            },
                            side: BorderSide(
                                color: Colors.grey.shade400
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Enter Discount',
                              style: GoogleFonts.epilogue(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black
                              ),
                            ),
                            _enterDiscount ?Row(
                              children: [
                                Text('Enter Discount Here:',
                                  style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    height: 30,
                                    width: 25,
                                    child: TextFormField(
                                      keyboardType: TextInputType.number,
                                      onChanged: (v){
                                        _discount = int.parse(v);
                                      },
                                    ),
                                  ),
                                ),
                                 Text('%',
                                     style: GoogleFonts.epilogue(
                                         fontWeight: FontWeight.w500
                                     )
                                 )
                              ],
                            ): Container(),
                            const SizedBox(
                              height: 7,
                            ),
                            Text('Put in a discount on this item (Discounts start from 2%)',

                              style: GoogleFonts.epilogue(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 30.0),
                          child: Checkbox(
                            value: _instantSalePrice,
                            onChanged: (value) {
                              setState(() {
                                _instantSalePrice = value!;
                              });
                            },
                            side: BorderSide(
                                color: Colors.grey.shade400
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Instant sale price',
                              style: GoogleFonts.epilogue(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black
                              ),
                            ),
                            _instantSalePrice ?Row(
                              children: [
                                Text('Put in price Here:',
                                  style: GoogleFonts.epilogue(
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                SizedBox(
                                  height: 30,
                                  width: 40,
                                  child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    onChanged: (v){
                                      _instantPrice = int.parse(v);
                                    },
                                  ),
                                )
                              ],
                            ): Container(),
                            const SizedBox(
                              height: 7,
                            ),
                            SizedBox(
                              width: 300,
                              child: Text('Enter the price for which the item would be instantly sold',
                                softWrap: true,
                                maxLines: 2,
                                style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 32.0),
                          child: Checkbox(
                            value: _unlockOncePurchased,
                            onChanged: (value) {
                              setState(() {
                                _unlockOncePurchased = value!;
                              });
                            },
                            side: BorderSide(
                                color: Colors.grey.shade400
                            ),
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Unlock once purchased',
                              style: GoogleFonts.epilogue(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black
                              ),
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            SizedBox(
                              width: 300,
                              child: Text('Content will be unlocked after successful transaction',
                                softWrap: true,
                                maxLines: 2,
                                style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade500
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    
                    Center(
                      child: GestureDetector(
                          onTap: (){
                            _getProfilePic();
                           if(_globalKey.currentState!.validate()){
                             if(_pickFileList.isNotEmpty){
                               showDialog(
                                   context: context,
                                   builder: (context){
                                     return ListView.builder(
                                         scrollDirection: Axis.horizontal,
                                         itemCount: _pickFileList.length,
                                         itemBuilder: (context, index){
                                           PlatformFile file = _pickFileList[index];
                                           return AlertDialog(
                                             shape: RoundedRectangleBorder(
                                                 borderRadius: BorderRadius.circular(15)
                                             ),
                                             title:Row(
                                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                               children:  [
                                                 const Text('Preview',),
                                                 IconButton(
                                                     onPressed: (){
                                                       Navigator.pop(context);
                                                     },
                                                     icon: Icon(Icons.clear)
                                                 )
                                               ],
                                             ),
                                             titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                             titleTextStyle: GoogleFonts.epilogue(
                                               fontSize: 23,
                                               fontWeight: FontWeight.w700,
                                               color: Colors.black,
                                             ),
                                             content:
                                             Container(
                                               height: MediaQuery.of(context).size.height*0.5,
                                               width: MediaQuery.of(context).size.width*0.9,
                                               decoration: BoxDecoration(
                                                   borderRadius: BorderRadius.circular(10),
                                                   image: DecorationImage(image: FileImage(File(file.path!)), fit: BoxFit.cover)
                                               ),
                                             ),
                                             actions: [
                                               Text(_itemName,
                                                 style: GoogleFonts.epilogue(
                                                     fontWeight: FontWeight.w700,
                                                     fontSize: 23
                                                 ),
                                               ),
                                             ],
                                             actionsAlignment: MainAxisAlignment.start,
                                             actionsPadding: EdgeInsets.only(left: 30),
                                           );
                                         }
                                     );

                                   }
                               );
                             }else if(_pickFileList.isEmpty &&_file != null){
                               if(_extension == 'png'){
                                 _getProfilePic();
                                 showDialog(
                                     context: context,
                                     builder: (context){
                                       return AlertDialog(
                                         shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(15)
                                         ),
                                         title:Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children:  [
                                             const Text('Preview',),
                                             IconButton(
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 icon: Icon(Icons.clear)
                                             )
                                           ],
                                         ),
                                         titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                         titleTextStyle: GoogleFonts.epilogue(
                                           fontSize: 23,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.black,
                                         ),
                                         content:
                                         Container(
                                           height: MediaQuery.of(context).size.height*0.5,
                                           width: MediaQuery.of(context).size.width*0.9,
                                           decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(10),
                                               image: DecorationImage(image: FileImage(_file), fit: BoxFit.cover)
                                           ),
                                         ),
                                         actions: [
                                           Column(
                                             children: [
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                 children: [
                                                   Padding(
                                                     padding: const EdgeInsets.all(8.0),
                                                     child: Text(_itemName,
                                                       style: GoogleFonts.epilogue(
                                                           fontWeight: FontWeight.w700,
                                                           fontSize: 19
                                                       ),
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               const SizedBox(
                                                 height: 7,
                                               ),
                                               Row(
                                                 children: [
                                                   GestureDetector(
                                                     onTap:(){
                                                       Navigator.push(context, MaterialPageRoute(builder: (context){
                                                         return const CreatorHomeScreen();
                                                       }));
                                                     },
                                                     child: CircleAvatar(
                                                       radius: 20,
                                                       backgroundImage: _creatorDoc['ProfilePic'] == null ? const NetworkImage(
                                                           'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                                       ):NetworkImage(_creatorDoc['ProfilePic']),
                                                     ),
                                                   ),
                                                   Column(
                                                     children: [
                                                       Text(_creatorDoc['FullName'],
                                                         style: GoogleFonts.epilogue(
                                                             letterSpacing: 1,
                                                             fontWeight: FontWeight.w700,
                                                             fontSize: 17
                                                         ),
                                                       ),
                                                       Padding(
                                                         padding: const EdgeInsets.only(left: 8.0),
                                                         child: Text('creator',
                                                           style: GoogleFonts.epilogue(
                                                               fontWeight: FontWeight.w500,
                                                               color: Colors.grey.shade700
                                                           ),
                                                         ),
                                                       )
                                                     ],
                                                   )
                                                 ],
                                               ),
                                               const SizedBox(
                                                 height: 20,
                                               )
                                             ],
                                           ),

                                         ],
                                         actionsAlignment: MainAxisAlignment.start,
                                         actionsPadding: EdgeInsets.only(left: 30),
                                       );

                                     }
                                 );
                               } else if(_extension == 'jpg'){
                                 _getProfilePic();
                                 showDialog(
                                     context: context,
                                     builder: (context){
                                       return AlertDialog(
                                         shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(15)
                                         ),
                                         title:Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children:  [
                                             Text('Preview',),
                                             IconButton(
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 icon: Icon(Icons.clear)
                                             )
                                           ],
                                         ),
                                         titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                         titleTextStyle: GoogleFonts.epilogue(
                                           fontSize: 23,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.black,
                                         ),
                                         content: Container(
                                           height: MediaQuery.of(context).size.height*0.5,
                                           width: MediaQuery.of(context).size.width*0.9,
                                           decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(10),
                                               image: DecorationImage(image: FileImage(_file), fit: BoxFit.cover)
                                           ),
                                         ),
                                         actions: [
                                           Column(
                                             children: [
                                               Row(
                                                 mainAxisAlignment: MainAxisAlignment.start,
                                                 children: [
                                                   Padding(
                                                     padding: const EdgeInsets.all(8.0),
                                                     child: Text(_itemName,
                                                       style: GoogleFonts.epilogue(
                                                           fontWeight: FontWeight.w700,
                                                           fontSize: 23
                                                       ),
                                                     ),
                                                   ),
                                                 ],
                                               ),
                                               const SizedBox(
                                                 height: 7,
                                               ),
                                               Row(
                                                 children: [
                                                   GestureDetector(
                                                     onTap:(){
                                                       Navigator.push(context, MaterialPageRoute(builder: (context){
                                                         return const CreatorHomeScreen();
                                                       }));
                                                     },
                                                     child: CircleAvatar(
                                                       radius: 20,
                                                       backgroundImage: _creatorDoc['ProfilePic'] == null ? const NetworkImage(
                                                           'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                                       ):NetworkImage(_creatorDoc['ProfilePic']),
                                                     ),
                                                   ),
                                                   Column(
                                                     children: [
                                                       Text(_creatorDoc['FullName'],
                                                         style: GoogleFonts.epilogue(
                                                             letterSpacing: 1,
                                                             fontWeight: FontWeight.w700,
                                                             fontSize: 17
                                                         ),
                                                       ),
                                                       Padding(
                                                         padding: const EdgeInsets.only(left: 8.0),
                                                         child: Text('creator',
                                                           style: GoogleFonts.epilogue(
                                                               fontWeight: FontWeight.w500,
                                                               color: Colors.grey.shade700
                                                           ),
                                                         ),
                                                       )
                                                     ],
                                                   )
                                                 ],
                                               ),
                                               const SizedBox(
                                                 height: 20,
                                               ),
                                             ],
                                           ),

                                         ],
                                         actionsAlignment: MainAxisAlignment.start,
                                         actionsPadding: EdgeInsets.only(left: 30),
                                       );

                                     }
                                 );
                               }else if(_extension == 'pdf'){
                                 showDialog(
                                     context: context,
                                     builder: (context){
                                       return AlertDialog(
                                         shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(15)
                                         ),
                                         title:Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children:  [
                                             Text('Preview',),
                                             IconButton(
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 icon: Icon(Icons.clear)
                                             )
                                           ],
                                         ),
                                         titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                         titleTextStyle: GoogleFonts.epilogue(
                                           fontSize: 23,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.black,
                                         ),
                                         content:
                                         Container(
                                           height: MediaQuery.of(context).size.height*0.5,
                                           width: MediaQuery.of(context).size.width*0.9,
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(10),
                                           ),
                                           child: PDFView(
                                             filePath: _file,
                                             enableSwipe: true,
                                             swipeHorizontal: true,
                                           ),
                                         ),
                                         actions: [
                                           Text(_itemName,
                                             style: GoogleFonts.epilogue(
                                                 fontWeight: FontWeight.w700,
                                                 fontSize: 23
                                             ),
                                           ),
                                         ],
                                         actionsAlignment: MainAxisAlignment.start,
                                         actionsPadding: EdgeInsets.only(left: 30),

                                       );

                                     }
                                 );
                               }else if(_extension == 'mp4'){
                                 showDialog(
                                     context: context,
                                     builder: (context){
                                       return AlertDialog(
                                         shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(15)
                                         ),
                                         title:Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children:  [
                                             Text('Preview',),
                                             IconButton(
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 icon: Icon(Icons.clear)
                                             )
                                           ],
                                         ),
                                         titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                         titleTextStyle: GoogleFonts.epilogue(
                                           fontSize: 23,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.black,
                                         ),
                                         content:
                                         Container(
                                             height: MediaQuery.of(context).size.height*0.5,
                                             width: MediaQuery.of(context).size.width*0.9,
                                             decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(10),
                                             ),
                                             child: VideoPlayer(_getVideoPlayer())
                                         ),
                                         actions: [
                                           Text(_itemName,
                                             style: GoogleFonts.epilogue(
                                                 fontWeight: FontWeight.w700,
                                                 fontSize: 23
                                             ),
                                           ),
                                         ],
                                         actionsAlignment: MainAxisAlignment.start,
                                         actionsPadding: EdgeInsets.only(left: 30),

                                       );

                                     }
                                 );
                               }else if(_extension == 'gif'){
                                 showDialog(
                                     context: context,
                                     builder: (context){
                                       return AlertDialog(
                                         shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(15)
                                         ),
                                         title:Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children:  [
                                             Text('Preview',),
                                             IconButton(
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 icon: Icon(Icons.clear)
                                             )
                                           ],
                                         ),
                                         titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                         titleTextStyle: GoogleFonts.epilogue(
                                           fontSize: 23,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.black,
                                         ),
                                         content:
                                         Container(
                                           height: MediaQuery.of(context).size.height*0.5,
                                           width: MediaQuery.of(context).size.width*0.9,
                                           decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(10),
                                               image: DecorationImage(image: FileImage(_file), fit: BoxFit.cover)
                                           ),
                                         ),
                                         actions: [
                                           Text(_itemName,
                                             style: GoogleFonts.epilogue(
                                                 fontWeight: FontWeight.w700,
                                                 fontSize: 23
                                             ),
                                           ),
                                         ],
                                         actionsAlignment: MainAxisAlignment.start,
                                         actionsPadding: const EdgeInsets.only(left: 30),
                                       );

                                     }
                                 );
                               }else if(_extension == 'webp'){
                                 showDialog(
                                     context: context,
                                     builder: (context){
                                       return AlertDialog(
                                         shape: RoundedRectangleBorder(
                                             borderRadius: BorderRadius.circular(15)
                                         ),
                                         title:Row(
                                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                           children:  [
                                             const Text('Preview',),
                                             IconButton(
                                                 onPressed: (){
                                                   Navigator.pop(context);
                                                 },
                                                 icon: const Icon(Icons.clear)
                                             )
                                           ],
                                         ),
                                         titlePadding: const EdgeInsets.only(left: 23, top: 12, right: 19),
                                         titleTextStyle: GoogleFonts.epilogue(
                                           fontSize: 23,
                                           fontWeight: FontWeight.w700,
                                           color: Colors.black,
                                         ),
                                         content:
                                         Container(
                                           height: MediaQuery.of(context).size.height*0.5,
                                           width: MediaQuery.of(context).size.width*0.9,
                                           decoration: BoxDecoration(
                                               borderRadius: BorderRadius.circular(10),
                                               image: DecorationImage(image: FileImage(_file), fit: BoxFit.cover)
                                           ),
                                         ),
                                         actions: [
                                           Text(_itemName,
                                             style: GoogleFonts.epilogue(
                                                 fontWeight: FontWeight.w700,
                                                 fontSize: 23
                                             ),
                                           ),
                                         ],
                                         actionsAlignment: MainAxisAlignment.start,
                                         actionsPadding: const EdgeInsets.only(left: 30),

                                       );

                                     }
                                 );
                               }
                             }else{
                               return;
                             }
                           }
                          },
                          child: SvgPicture.asset('assets/images/Button.svg')
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: GestureDetector(
                          onTap: (){
                            _updateFirebaseCollection();
                          },
                            child: SvgPicture.asset('assets/images/Button (1).svg')
                        )
                    ),
                    const SizedBox(
                      height: 45,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25.0),
                      child: Divider(
                        height: 6,
                      ),
                    ),
                    const SizedBox(
                      height: 120,
                    ),
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset('assets/icons/Logo (1).svg'),
                      ),
                    ),
                    Center(child: SvgPicture.asset('assets/icons/The New Creative Economy.svg')),
                    const SizedBox(
                      height: 25,
                    ),
                   Center(
                     child: Padding(
                         padding: const EdgeInsets.all(8),
                       child:  SvgPicture.asset('assets/images/Button (2).svg'),
                     ),
                   ),
                    Center(child: SvgPicture.asset('assets/images/Button (3).svg')),
                    const SizedBox(
                      height: 90,
                    ),
                    SvgPicture.asset('assets/images/Footer.svg',width: MediaQuery.of(context).size.width,)
                  ],
                ),
              ) ,
            )
          ],
        )
      ),
    );
  }
}
