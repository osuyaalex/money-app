import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/Users%20Screen/product_description.dart';
import 'package:walletapp/Users%20Screen/view_creators.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance.collection('Products').snapshots();
  List<QueryDocumentSnapshot<Object?>> _snap = [];
  List <QueryDocumentSnapshot<Object?>>_findItems = [];
  @override
  void initState() {
    setState(() {
      _findItems = _snap;
    });
    super.initState();
  }
  _runFilter(String enterKeyword){
    List <QueryDocumentSnapshot<Object?>> _results = [];
    if(enterKeyword.isEmpty){
      // if the search field is empty or only contains white-space, we'll display all users
      _results = [];
    }else{
      _results = _snap.where((user) =>
          user["itemName"].toLowerCase().contains(enterKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    setState(() {
      _findItems = _results;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding:  EdgeInsets.only(top:MediaQuery.of(context).padding.top,),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                      onPressed: (){
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.arrow_back_outlined)
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.8,
                    child: TextFormField(
                      onChanged: (value)=>_runFilter(value),
                      decoration: InputDecoration(
                        fillColor: Colors.grey.shade300,
                        filled: true,
                        hintText: 'search items',
                        prefixIcon: IconButton(
                          onPressed: (){},
                          icon: Icon(Icons.search),
                        ),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Colors.transparent
                            )
                        ),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: const BorderSide(
                                color: Colors.transparent
                            )
                        ),
                      ),
                    ),
                  ),
                ],
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
                  _snap =snapshot.data!.docs;
                  return SizedBox(
                    width: MediaQuery.of(context).size.width*0.95,

                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _findItems.length,
                        itemBuilder: (context, index){
                          final creatorUid = _findItems[index]['uid'];
                          final products = _findItems[index];
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
                                            Navigator.push(context, MaterialPageRoute(builder: (context){
                                              return ProductDescription(products: products);
                                            }));
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
                                                Navigator.push(context, MaterialPageRoute(builder: (context){
                                                  return ProductDescription(products: products);
                                                }));
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
    );
  }
}
