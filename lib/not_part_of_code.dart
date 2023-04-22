/*so in the example below we have 2 collections; the user collection and the
tweet collection and we are trying to create a function to post tweet
 */
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
/*we are making the assumption that a textformfield that takes in the tweetcontroller
has already been created below
 */
final TextEditingController tweetController = TextEditingController();
 Uint8List? imagePath;

postTweet()async{
  CollectionReference userCollection = FirebaseFirestore.instance.collection('user');
  CollectionReference tweetCollection = FirebaseFirestore.instance.collection('tweet');
  //below is the procedure to get the current users document from the user collection
  DocumentSnapshot userDoc = await userCollection.doc(FirebaseAuth.instance.currentUser!.uid).get();

  //so below we have three conditions.
  // if the user only tweets
  if(tweetController.text.isNotEmpty && imagePath == null){
    tweetCollection.doc(FirebaseAuth.instance.currentUser!.uid).set({
      'username':userDoc['userName'],
      /*what happened above was us taking the username already created in the userCollection
      and putting it in the tweet collection
       */
      'uid': FirebaseAuth.instance.currentUser!.uid,
      'likes': []
    });
  }
}
/*if we want to make a function for liking stuff this is how we do it.
above, we know that like contains an array. so in the wdget tree, if we want to
display like we go.
remember we created a streambuilder so we are taking data feom it. that is what
data in the text means
Row
GestureDetector(
onTap:(){
likePost(data[uid]);
},
child:Icon(Icons.favourite)
)
Text(data['likes'].length.toString())
 */


