import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/Users%20Screen/search_screen.dart';
import 'package:walletapp/utils/snackbar.dart';

import '../product_description.dart';
import '../view_creators.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance.collection('Products').snapshots();
  likePosts(String docId)async{
    DocumentSnapshot document = await FirebaseFirestore.instance.collection('Products').doc(docId).get();
    if(document ['like'].contains(FirebaseAuth.instance.currentUser!.uid)){
      FirebaseFirestore.instance.collection('Products').doc(docId).update({
        'like':FieldValue.arrayRemove([FirebaseAuth.instance.currentUser!.uid])
      });
    }else{
      FirebaseFirestore.instance.collection('Products').doc(docId).update({
        'like':FieldValue.arrayUnion([FirebaseAuth.instance.currentUser!.uid])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
                          padding: const EdgeInsets.fromLTRB(20.0,12,12,0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SvgPicture.asset('assets/images/Logo.svg'),
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap:(){
                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                        return SearchScreen();
                                      }));
                                    },
                                      child: SvgPicture.asset('assets/icons/Search.svg')
                                  ),
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
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      Text('Discover, buy, and sell',
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.w700,
                          fontSize: 18
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text('All Types Of Products',
                        style: GoogleFonts.epilogue(
                          fontSize: 27,
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      StreamBuilder<QuerySnapshot>(
                        stream: _productStream,
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Text('Something went wrong');
                          }

                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text("Loading");
                          }

                          return SizedBox(
                            width: MediaQuery.of(context).size.width*0.95,
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index){
                                  final creatorUid = snapshot.data!.docs[index]['uid'];
                                  final products = snapshot.data!.docs[index];
                                  final documentRef = FirebaseFirestore.instance.collection('Products').doc(snapshot.data!.docs[index]['itemId']);
                                  return Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height:525,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey.shade300,
                                                    blurRadius: 7,
                                                    spreadRadius: 2,
                                                    offset: const Offset(
                                                        1.1,
                                                        5.0
                                                    )
                                                )
                                              ],
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(25)
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Column(
                                              children: [
                                                products['itemImage'] != null ?
                                                GestureDetector(
                                                  onTap:(){
                                                    documentRef.update({
                                                      'open': true
                                                    }).catchError((e){
                                                      snack(context, e.toString());
                                                    });
                                                  },
                                                  child: Container(
                                                    height: 400,
                                                    width:MediaQuery.of(context).size.width*0.8,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(25),
                                                        image: DecorationImage(image: NetworkImage(products['itemImage']),fit: BoxFit.fill)

                                                    ),
                                                  ),
                                                ):Stack(
                                                  children: [
                                                    GestureDetector(
                                                      onTap:(){
                                                      documentRef.update({
                                                        'open': true
                                                      }).catchError((e){
                                                       snack(context, e.toString());
                                                      });
                                                      },
                                                      child: Container(
                                                        height: 400,
                                                        width:MediaQuery.of(context).size.width*0.8,
                                                        decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(25),
                                                            image:DecorationImage(image: NetworkImage(products['itemImageList'][0]), fit: BoxFit.fill)
                                                        ),
                                                      ),
                                                    ),
                                                    Positioned(
                                                        right: 5,
                                                        bottom: 3,
                                                        child: TextButton(
                                                            onPressed: (){
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (context){
                                                                    return ListView.builder(
                                                                        scrollDirection: Axis.horizontal,
                                                                        itemCount: products['itemImageList'].length,
                                                                        itemBuilder: (context, index){
                                                                          return AlertDialog(
                                                                            titlePadding: const EdgeInsets.all(12),
                                                                            title: Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                Text('All Products',
                                                                                  style: GoogleFonts.epilogue(
                                                                                      fontSize: 18,
                                                                                      fontWeight: FontWeight.w700
                                                                                  ),
                                                                                ),
                                                                                IconButton(
                                                                                    onPressed: (){
                                                                                      Navigator.pop(context);
                                                                                    },
                                                                                    icon: const Icon(Icons.close)
                                                                                )
                                                                              ],
                                                                            ),
                                                                            shape: RoundedRectangleBorder(
                                                                                borderRadius: BorderRadius.circular(20)
                                                                            ),
                                                                            content: Container(
                                                                              height: 400,
                                                                              width:MediaQuery.of(context).size.width*0.8,
                                                                              decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(25),
                                                                                  image:DecorationImage(image: NetworkImage(products['itemImageList'][index]), fit: BoxFit.fill)
                                                                              ),
                                                                            ),
                                                                          );
                                                                        }
                                                                    );
                                                                  }
                                                              );
                                                            },
                                                            child: Text('view all products',
                                                              style: GoogleFonts.epilogue(
                                                                  color: Colors.yellow,
                                                                  fontWeight: FontWeight.w700,
                                                                  fontSize: 12
                                                              ),
                                                            )
                                                        )
                                                    )
                                                  ],
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 12.0),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      Text(products['itemName'],
                                                        style: GoogleFonts.epilogue(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 27
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 6,
                                                ),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      child: GestureDetector(
                                                        onTap:(){
                                                          Navigator.push(context, MaterialPageRoute(builder: (context){
                                                            return ViewCreator(creatorId: creatorUid,);
                                                          }));
                                                        },
                                                        child: Row(
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 20,
                                                              backgroundImage: products['ProfilePic'] == null ?const NetworkImage(
                                                                  'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                                              ):NetworkImage(products['ProfilePic'],),
                                                            ),
                                                            Column(
                                                              children: [
                                                                Text(products['FullName'],
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
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.only(right: 12.0),
                                                      child: IconButton(
                                                          onPressed: (){
                                                            likePosts(products['itemId']);
                                                          },
                                                          icon: products['like'].contains(FirebaseAuth.instance.currentUser!.uid)?
                                                          Icon(Icons.favorite, color: Colors.grey.shade500, size: 30,):
                                                          Icon(Icons.favorite_border, color: Colors.grey.shade500, size: 30,)
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                products['instantPrice'] != null ?Row(
                                                  mainAxisAlignment: MainAxisAlignment.end,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: ()async{
                                                        DocumentSnapshot document = await FirebaseFirestore.instance.collection('Products').doc(products['itemId']).get();
                                                        if(document ['instantPrice']== products['instantPrice']){
                                                          FirebaseFirestore.instance.collection('Products').doc(products['itemId']).update({
                                                            'instantPrice':null
                                                          });
                                                        }
                                                      },
                                                      child: Text('Remove instant Price',
                                                        style: GoogleFonts.epilogue(
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 13,
                                                            color: Colors.grey.shade600
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                                    :Container(),
                                              ],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 15,
                                        ),
                                        products['open'] == true ?
                                            SizedBox(
                                              width: MediaQuery.of(context).size.width*0.95,
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment: MainAxisAlignment.end,
                                                    children: [
                                                      IconButton(
                                                          onPressed: (){
                                                            documentRef.update({
                                                              'open': false
                                                            }).catchError((e){
                                                              snack(context, e.toString());
                                                            });
                                                          },
                                                          icon: Icon(Icons.close, color: Colors.grey.shade600,)
                                                      )
                                                    ],
                                                  ),
                                                  Container(
                                                    height: 50,
                                                      width: MediaQuery.of(context).size.width,
                                                    decoration: BoxDecoration(
                                                        gradient: const LinearGradient(
                                                            colors: [
                                                              Color(0xff0038F5),
                                                              Color(0xff9F03FF)
                                                            ]),
                                                      borderRadius: BorderRadius.circular(10)
                                                    ),
                                                    child: Center(
                                                      child: Text('Buy Now',
                                                      style: GoogleFonts.epilogue(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 16
                                                      ),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  GestureDetector(
                                                    onTap: (){
                                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                                        return ProductDescription(products: products);
                                                      }));
                                                    },
                                                    child: Container(
                                                      height: 50,
                                                      width: MediaQuery.of(context).size.width,
                                                      decoration: BoxDecoration(
                                                          border: const Border(
                                                            top: BorderSide(
                                                              color: Colors.purpleAccent
                                                            ),
                                                           left: BorderSide(
                                                                color: Colors.purpleAccent
                                                            ),
                                                            right: BorderSide(
                                                                color: Colors.purpleAccent
                                                            ),
                                                            bottom: BorderSide(
                                                                color: Colors.purpleAccent
                                                            ),
                                                          ),
                                                          borderRadius: BorderRadius.circular(10)
                                                      ),
                                                      child: Center(
                                                        child: Text('product detail',
                                                          style: GoogleFonts.epilogue(
                                                              fontWeight: FontWeight.w700,
                                                              fontSize: 16
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ):Container()
                                      ],
                                    ),
                                  );
                                }
                            ),
                          );
                        },
                      ),

                    ],
                  ),
                ),
              ),
            )
          ],
        )
    );
  }
}

