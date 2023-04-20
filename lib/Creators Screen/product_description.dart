import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:walletapp/Creators%20Screen/creators_home.dart';

class ProductDescription extends StatefulWidget {
  final dynamic products;
   const ProductDescription({Key? key, required this.products}) : super(key: key);

  @override
  State<ProductDescription> createState() => _ProductDescriptionState();
}

class _ProductDescriptionState extends State<ProductDescription> {
  @override
  String _uid = '';

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
              child: Column(
                children: [
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 25, 12, 12),
                        child: widget.products['itemImage'] != null ?Container(
                          height: 450,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            image: DecorationImage(image: NetworkImage(widget.products['itemImage']),fit: BoxFit.fill)
                          ),
                        ):SizedBox(
                          height: 450,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.products['itemImageList'].length,
                              itemBuilder: (context, index){
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  height: 450,
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(18),
                                      image: DecorationImage(image: NetworkImage(widget.products['itemImageList'][index]),fit: BoxFit.fill)
                                  ),
                                ),
                              );
                              }
                          ),
                        )
                      ),
                     widget.products['discount'] <= 1?
                     Container():Positioned(
                         top: 4,
                         left: 5,
                         child: Image.asset('assets/images/discount.png', height: 60,)
                     )
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Container(
                      height: 300,
                      width: double.infinity,
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
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(widget.products['itemName'],
                                  style: GoogleFonts.epilogue(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 24
                                  )
                                ),

                                    CircleAvatar(
                                      radius: 25,
                                      backgroundColor: Colors.white,

                                      child: IconButton(
                                          onPressed: (){
                                            likePosts(widget.products['itemId']);
                                            setState(() {
                                              _uid = FirebaseAuth.instance.currentUser!.uid;
                                            });
                                          },
                                          icon: widget.products['like'].contains(_uid)?
                                          Icon(Icons.favorite, color: Colors.grey.shade500, size: 30,):
                                          Icon(Icons.favorite_border, color: Colors.grey.shade500, size: 30,)
                                      ),
                                    ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 55,
                                  width: 130,
                                  child: Card(
                                    shadowColor: Colors.grey.shade100,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(35)
                                    ),
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(6.0),
                                          child: GestureDetector(
                                            onTap: (){
                                              Navigator.push(context, MaterialPageRoute(builder: (context){
                                                return CreatorHomeScreen();
                                              }));
                                            },
                                            child: CircleAvatar(
                                              radius: 20,
                                              backgroundImage: widget.products['ProfilePic'] == null ?const NetworkImage(
                                                  'https://t4.ftcdn.net/jpg/00/64/67/63/360_F_64676383_LdbmhiNM6Ypzb3FM4PPuFP9rHe7ri8Ju.jpg'
                                              ):NetworkImage(widget.products['ProfilePic'],),
                                            ),
                                          ),
                                        ),
                                        Text('@${widget.products['FullName']}',
                                          style: GoogleFonts.epilogue(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 17
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('N${widget.products['itemPrice']}',
                                      style: GoogleFonts.epilogue(
                                        fontSize:25,
                                        fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    widget.products['discount'] > 1 ?
                                        Text('discount by ${widget.products['discount']}%',
                                          style: GoogleFonts.epilogue(
                                            fontSize: 12,
                                            color: Colors.grey.shade500,
                                            fontWeight: FontWeight.w700
                                          ),
                                        ):Container()
                                  ],
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text(widget.products['itemDescription'],
                              style: GoogleFonts.epilogue(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        elevation: 6,
                        shadowColor: Colors.grey.shade100,
                        child: ExpansionTile(
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          shape: Border.all(color: Colors.transparent),
                            title: Text('View discount detail',
                              style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w700,
                                fontSize: 15
                              ),
                            ),
                          children: [
                            widget.products['discount'] > 1 ?
                                Text('Discount by ${widget.products['discount']}% on this product.Don\'t miss out!\n\n Tap on BUY PRODUCT to view discounted price',
                                style: GoogleFonts.epilogue(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600
                                ),
                                ): Text('There are no discounts for this product',
                              style: GoogleFonts.epilogue(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        elevation: 6,
                        shadowColor: Colors.grey.shade100,
                        child: ExpansionTile(
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          shape: Border.all(color: Colors.transparent),
                          title: Text('View Instant Price',
                            style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w700,
                                fontSize: 15
                            ),
                          ),
                          children: [
                            widget.products['instantPrice'] != null ?
                            Text('You\'re lucky! For a limited time, you can buy product for ${widget.products['instantPrice']} \n\n Click on Buy Now to proceed',
                              style: GoogleFonts.epilogue(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600
                              ),
                            ): Text('No instant prices available',
                              style: GoogleFonts.epilogue(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey.shade600
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                        ),
                        elevation: 6,
                        shadowColor: Colors.grey.shade100,
                        child: ExpansionTile(
                          textColor: Colors.black,
                          iconColor: Colors.black,
                          shape: Border.all(color: Colors.transparent),
                          title: Text('Contact seller',
                            style: GoogleFonts.epilogue(
                                fontWeight: FontWeight.w700,
                                fontSize: 15
                            ),
                          ),
                          children: [
                            ListTile(
                              leading: Icon(Icons.phone),
                              title: Text(widget.products['contact'],
                                style: GoogleFonts.epilogue(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600
                                ),
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.email),
                              title: Text(widget.products['email'],
                                style: GoogleFonts.epilogue(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey.shade600
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
