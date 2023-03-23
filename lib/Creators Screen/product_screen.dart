import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/Creators%20Screen/product_description.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance.collection('Products').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _productStream,
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text("Loading");
        }

        if (!snapshot.hasData){
          return Container();
        }

        return SizedBox(
          width: MediaQuery.of(context).size.width*0.8,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index){
                final products = snapshot.data!.docs[index];
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context){
                      return ProductDescription(products: products);
                    }));
                  },
                  child: Container(
                    height:510,
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
                          Container(
                            height: 400,
                            width:MediaQuery.of(context).size.width*0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: snapshot.data!.docs[index]['itemImage'] != null ?
                              DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['itemImage']),fit: BoxFit.fill):
                                  DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['itemImageList'][0]), fit: BoxFit.fill)
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(snapshot.data!.docs[index]['itemName'],
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

                                child: Row(
                                  children: [
                                     CircleAvatar(
                                      radius: 20,
                                      backgroundImage: snapshot.data!.docs[index]['ProfilePic'] == null ?const NetworkImage(
                                          'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                      ):NetworkImage(snapshot.data!.docs[index]['ProfilePic'],),
                                    ),
                                    Column(
                                      children: [
                                        Text(snapshot.data!.docs[index]['FullName'],
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
                               Padding(
                                padding: const EdgeInsets.only(right: 12.0),
                                child: Icon(Icons.favorite_border, color: Colors.grey.shade500, size: 30,),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
              }
          ),
        );
      },
    );
  }
}
