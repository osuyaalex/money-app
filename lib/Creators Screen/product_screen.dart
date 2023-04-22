import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class ProductScreen extends StatefulWidget {
  const ProductScreen({Key? key}) : super(key: key);

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance.collection('Products').where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).snapshots();

  @override
  Widget build(BuildContext context) {
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
                child: Container(
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
                      snapshot.data!.docs[index]['itemImage'] != null ?
                      Container(
                            height: 400,
                            width:MediaQuery.of(context).size.width*0.8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              image: DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['itemImage']),fit: BoxFit.fill)

                            ),
                          ):Stack(
                            children: [
                              Container(
                                height: 400,
                                width:MediaQuery.of(context).size.width*0.8,
                                decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(25),
                                image:DecorationImage(image: NetworkImage(snapshot.data!.docs[index]['itemImageList'][0]), fit: BoxFit.fill)
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
                          :Container()
                        ],
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
