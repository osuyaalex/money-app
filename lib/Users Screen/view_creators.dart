import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
class ViewCreator extends StatefulWidget {
final String creatorId;
  const ViewCreator({Key? key, required this.creatorId}) : super(key: key);

  @override
  State<ViewCreator> createState() => _ViewCreatorState();
}

class _ViewCreatorState extends State<ViewCreator> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? uid;
  bool _scroll = false;

  likeUser()async{
    DocumentSnapshot document = await _firestore.collection('Creators').doc(widget.creatorId).get();
    if(document ['like'].contains(_auth.currentUser!.uid)){
      _firestore.collection('Creators').doc(widget.creatorId).update({
        'like': FieldValue.arrayRemove([_auth.currentUser!.uid])//this is how to remove values to a list in firestore
      });
    }else{
      _firestore.collection('Creators').doc(widget.creatorId).update({
        'like': FieldValue.arrayUnion([_auth.currentUser!.uid])//this is how to add values to a list in firestore
      });
    }
  }
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
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  getUid(){
    String currentUid= _auth.currentUser!.uid;
    setState(() {
      uid = currentUid;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference editProfileScreen = FirebaseFirestore.instance.collection('Creators');
    final Stream<QuerySnapshot> _productStream = FirebaseFirestore.instance.collection('Products').where('uid', isEqualTo: widget.creatorId).snapshots();

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
                  child:Column(
                    children: [
                      FutureBuilder<DocumentSnapshot>(
                          future: editProfileScreen.doc(widget.creatorId).get(),
                          builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Something went wrong');
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Text("Loading");
                            }
                            if (snapshot.hasData && !snapshot.data!.exists) {
                              return const Text("Document does not exist");
                            }

                            if (snapshot.connectionState == ConnectionState.done) {
                              Map<String, dynamic> data = snapshot.data!.data() as Map<
                                  String,
                                  dynamic>;
                              return Column(
                                children: [
                                  Stack(
                                    children: [
                                      data['Headers'] == null ? Container(
                                        height: 180,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        decoration: const BoxDecoration(
                                            color: Colors.black
                                        ),
                                      ) : Container(
                                        height: 180,
                                        width: MediaQuery
                                            .of(context)
                                            .size
                                            .width,
                                        decoration: BoxDecoration(
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
                                          child: data['ProfilePic'] == null
                                              ? const CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                            ),
                                            radius: 65,
                                          )
                                              : CircleAvatar(
                                            radius: 65,
                                            backgroundImage: NetworkImage(
                                                data['ProfilePic']),
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
                                      child: data['FullName'] == null ? Text(
                                        data['fullName'],
                                        style: GoogleFonts.epilogue(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 20
                                        ),
                                      ) : Text(data['FullName'],
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
                                    height: 340,
                                    width: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.9,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20)
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 17.0, top: 17),
                                      child: Column(
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.email_outlined,
                                                color: Colors.black,),
                                          SizedBox(
                                            width: MediaQuery
                                                .of(context)
                                                .size
                                                .width * 0.03,
                                          ),
                                          Text(data['email'],
                                            style: GoogleFonts.epilogue(
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500
                                            ),
                                          ),
                                          ]),
                                          const SizedBox(
                                            height: 19,
                                          ),
                                          Row(
                                            children: [
                                              const Icon(Icons.credit_card_outlined,
                                                color: Colors.black,),
                                              SizedBox(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.03,
                                              ),
                                              data['links'] == null ? Text('Linked',
                                                style: GoogleFonts.redHatDisplay(
                                                  //decoration: TextDecoration.underline,
                                                    decorationStyle: TextDecorationStyle
                                                        .double,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ) : Text(data['links'].toString(),
                                                style: GoogleFonts.redHatDisplay(
                                                  // decoration: TextDecoration.underline,
                                                    decorationStyle: TextDecorationStyle
                                                        .double,
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
                                              SvgPicture.asset(
                                                  'assets/icons/Call.svg'),
                                              SizedBox(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.03,
                                              ),
                                              data['contact'] == null ? Text('contact',
                                                style: GoogleFonts.redHatDisplay(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w500
                                                ),
                                              ) : Text(data['contact'].toString(),
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
                                              SvgPicture.asset(
                                                  'assets/icons/Link.svg'),
                                              SizedBox(
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.03,
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
                                                width: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .width * 0.06,
                                              ),
                                              Container(
                                                height: 45,
                                                width: 160,
                                                decoration: BoxDecoration(
                                                    borderRadius: BorderRadius
                                                        .circular(10),
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
                                                  mainAxisAlignment: MainAxisAlignment
                                                      .center,
                                                  children: [
                                                    GestureDetector(
                                                        onTap: () {
                                                          likeUser();
                                                          getUid();
                                                        },
                                                        child: data['like'].contains(
                                                            uid) ? const Icon(
                                                          Icons.favorite_border,
                                                          size: 35,) :
                                                        const Icon(
                                                          Icons.favorite,
                                                          color: Colors.black,
                                                          size: 35,)
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(horizontal: 8.0),
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

                                            ],
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text('Member since ...',
                                            style: GoogleFonts.epilogue(
                                                color: Colors.grey.shade700,
                                                fontWeight: FontWeight.w700
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 30,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 50,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Text('My items',
                                          style: GoogleFonts.epilogue(
                                              fontSize: 23,
                                              fontWeight: FontWeight.w700
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ],

                              );
                            }
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }
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

                          if (!snapshot.hasData){
                            return Container();
                          }

                          return SizedBox(
                            width: MediaQuery.of(context).size.width*0.8,
                            child: ListView.builder(
                              physics: _scroll == false?NeverScrollableScrollPhysics():null,
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
                      ),
                      const SizedBox(
                        height: 93,
                      ),
                      Center(
                        child: GestureDetector(
                          onTap: (){
                            setState(() {
                              _scroll = !_scroll;
                            });
                          },
                            child: _scroll == false ?
                            SvgPicture.asset('assets/images/Button (4).svg'):
                                Container()
                        ),
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
                  )
              ),
            )
          ],
        )

    );
  }
}
