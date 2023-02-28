import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/Creators%20Screen/edit_profile_screen.dart';
import 'package:walletapp/Creators%20Screen/upload/upload_screen.dart';

class CreatorHomeScreen extends StatefulWidget {

   const CreatorHomeScreen({Key? key}) : super(key: key);

  @override
  State<CreatorHomeScreen> createState() => _CreatorHomeScreenState();
}

class _CreatorHomeScreenState extends State<CreatorHomeScreen> {
  final Stream<QuerySnapshot> _editProfileStream = FirebaseFirestore.instance.collection('Creators').snapshots();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String uid = '';


  likePosts()async{
    DocumentSnapshot document = await _firestore.collection('Creators').doc(_auth.currentUser!.uid).get();
    if(document ['like'].contains(_auth.currentUser!.uid)){
      _firestore.collection('Creators').doc(_auth.currentUser!.uid).update({
        'like': FieldValue.arrayRemove([_auth.currentUser!.uid])//this is how to remove values to a list in firestore
      });
    }else{
      _firestore.collection('Creators').doc(_auth.currentUser!.uid).update({
        'like': FieldValue.arrayUnion([_auth.currentUser!.uid])//this is how to add values to a list in firestore
      });
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUid();
  }
  getUid(){
    String currentUid= _auth.currentUser!.uid;
    setState(() {
      uid = currentUid;
    });
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Color(0xfffafafa),
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
             child:StreamBuilder<QuerySnapshot>(
               stream: _editProfileStream,
               builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                 if (snapshot.hasError) {
                   return Text('Something went wrong');
                 }

                 if (snapshot.connectionState == ConnectionState.waiting) {
                   return Text("Loading");
                 }
                 if(!snapshot.hasData){}

                 return Column(
                   children: snapshot.data!.docs.map((DocumentSnapshot document) {
                     Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                     return Column(
                       children: [
                         Stack(
                           children: [
                             data['Headers'] == null ?Container(
                               height: 180,
                               width: MediaQuery.of(context).size.width,
                               decoration: const BoxDecoration(
                                   color: Colors.black
                               ),
                             ):Container(
                               height: 180,
                               width: MediaQuery.of(context).size.width,
                               decoration:  BoxDecoration(
                                   image: DecorationImage(
                                       image: NetworkImage(data['Headers'],),
                                     fit: BoxFit.fill
                                   )
                               ),
                             ),
                              Align(
                               alignment: Alignment.bottomCenter,
                               child: Padding(
                                 padding: const EdgeInsets.only(top: 110.0),
                                 child: data['ProfilePic'] == null?const CircleAvatar(
                                   backgroundImage: NetworkImage(
                                       'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                   ),
                                   radius: 65,
                                 ):CircleAvatar(
                                   radius: 65,
                                   backgroundImage: NetworkImage(data['ProfilePic']),
                                 ),
                               ),
                             )
                           ],
                         ),
                         const SizedBox(
                           height: 10,
                         ),
                         Padding(
                           padding: const EdgeInsets.all(8.0),
                           child: data['FullName']== null ?Text(data['fullName'],
                             style: GoogleFonts.epilogue(
                                 fontWeight: FontWeight.w700,
                                 fontSize: 20
                             ),
                           ):Text(data['FullName'],
                             style: GoogleFonts.epilogue(
                                 fontWeight: FontWeight.w700,
                                 fontSize: 20
                             ),
                           )
                         ),
                         Row(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                             Text(data['uid'].toString(),
                               style: GoogleFonts.epilogue(
                                 fontSize: 14
                               ),
                             ),
                             const Icon(Icons.copy)
                           ],
                         ),
                         const SizedBox(
                           height: 20,
                         ),
                         Container(
                           height: 320,
                           width: MediaQuery.of(context).size.width*0.9,
                           decoration: BoxDecoration(
                               color: Colors.white,
                               borderRadius: BorderRadius.circular(20)
                           ),
                           child: Padding(
                             padding: const EdgeInsets.only(left: 17.0, top: 17),
                             child: Column(
                               children: [
                                 const SizedBox(
                                   height: 10,
                                 ),
                                 Row(
                                   children: [
                                      const Icon(Icons.email_outlined, color: Colors.black,),
                                            SizedBox(
                                             width: MediaQuery.of(context).size.width*0.03,
                                           ),
                                           Text(data['email'],
                                           style: GoogleFonts.epilogue(
                                           fontSize: 17,
                                           fontWeight: FontWeight.w500
                                           ),
                                           ),
                                     SizedBox(
                                       width: MediaQuery.of(context).size.width*0.23,
                                     ),
                                     GestureDetector(
                                         onTap: (){
                                           Navigator.push(context, MaterialPageRoute(builder: (context){
                                             return  EditProfileScreen();
                                           }));
                                         },
                                         child: SvgPicture.asset('assets/icons/Edt.svg')
                                     )
                                   ],
                                 ),
                                 const SizedBox(
                                   height: 19,
                                 ),
                                 Row(
                                   children:  [
                                   const Icon(Icons.credit_card_outlined, color: Colors.black,),
                                     SizedBox(
                                       width: MediaQuery.of(context).size.width*0.03,
                                     ),
                                     data['links']== null?Text('Linked',
                                       style: GoogleFonts.redHatDisplay(
                                           //decoration: TextDecoration.underline,
                                           decorationStyle: TextDecorationStyle.double,
                                           fontSize: 17,
                                           fontWeight: FontWeight.w500
                                       ),
                                     ):Text(data['links'].toString(),
                                       style: GoogleFonts.redHatDisplay(
                                         // decoration: TextDecoration.underline,
                                           decorationStyle: TextDecorationStyle.double,
                                           fontSize: 17,
                                           fontWeight: FontWeight.w500
                                       ),
                                     ),
                                   ],
                                 ),
                                 const SizedBox(
                                   height: 19,
                                 ),
                                 Row(
                                   children: [
                                     SvgPicture.asset('assets/icons/Call.svg'),
                                     SizedBox(
                                       width: MediaQuery.of(context).size.width*0.03,
                                     ),
                                     data['contact']== null?Text('contact',
                                       style: GoogleFonts.redHatDisplay(
                                           fontSize: 16,
                                           fontWeight: FontWeight.w500
                                       ),
                                     ):Text(data['contact'].toString(),
                                       style: GoogleFonts.redHatDisplay(
                                           fontSize: 17,
                                           fontWeight: FontWeight.w500
                                       ),
                                     ),
                                   ],
                                 ),
                                 const SizedBox(
                                   height: 19,
                                 ),
                                 Row(
                                   children: [
                                      SvgPicture.asset('assets/icons/Link.svg'),
                                     SizedBox(
                                       width: MediaQuery.of(context).size.width*0.03,
                                     ),
                                     Text('OpenArtDesign',
                                       style: GoogleFonts.redHatDisplay(
                                           fontSize: 17,
                                           fontWeight: FontWeight.w500
                                       ),
                                     ),
                                   ],
                                 ),

                                 const SizedBox(
                                   height: 23,
                                 ),
                                 Row(
                                   children: [
                                     SizedBox(
                                       width: MediaQuery.of(context).size.width*0.06,
                                     ),
                                     Container(
                                       height: 45,
                                       width: 160,
                                       decoration:  BoxDecoration(
                                           borderRadius: BorderRadius.circular(10),
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
                                       child: Row(
                                         mainAxisAlignment: MainAxisAlignment.center,
                                         children: [
                                           GestureDetector(
                                             onTap:(){
                                               likePosts();
                                             },
                                               child: data['like'].contains(uid)?const Icon(Icons.favorite, color: Colors.black, size: 35,):
                                                   const Icon(Icons.favorite_border, size: 35,)
                                           ),
                                           Padding(
                                             padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                             child: Text('Follow',
                                               style: GoogleFonts.epilogue(
                                                   fontSize: 20,
                                                   fontWeight: FontWeight.w700
                                               ),
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                     Padding(
                                       padding: const EdgeInsets.all(15.0),
                                       child: GestureDetector(
                                         onTap: (){
                                           Navigator.push(context, MaterialPageRoute(builder: (context){
                                             return UploadScreen();
                                           }));
                                         },
                                         child: Container(
                                             height: 45,
                                             width: 45,
                                             decoration: BoxDecoration(
                                                 borderRadius: BorderRadius.circular(30),
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
                                             child:const Icon(Icons.upload)
                                         ),
                                       ),
                                     ),
                                     Container(
                                         height: 45,
                                         width: 45,
                                         decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(30),
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
                                         child:const Icon(Icons.more_horiz)
                                     ),
                                   ],
                                 )
                               ],
                             ),
                           ),
                         ),

                       ],

                     );
                   }).toList(),
                 );
               },
             )
           ),
          )
        ],
      )

    );
  }
}
