import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplify/page/boosterCommunity/screen/home/homeTab/add_post_form.dart';
import 'package:simplify/page/boosterCommunity/screen/home/reportPost/reportPost.dart';
import 'package:simplify/page/boosterCommunity/service/convertTimeStamp.dart';
import 'package:simplify/page/boosterCommunity/service/firebaseHelper.dart';

class UserFeed extends StatefulWidget {
  const UserFeed({ Key? key }) : super(key: key);

  @override
  _UserFeedState createState() => _UserFeedState();
}

class _UserFeedState extends State<UserFeed> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String userId;

  @override
  void initState() {
    userId = _auth.currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('thread').orderBy('published-time',descending: true).snapshots(),
        builder: (context,snapshot) {
          if (!snapshot.hasData) return LinearProgressIndicator();
          return Stack(
            children:<Widget>[
              snapshot.data!.docs.length > 0 ?
              ListView(
                shrinkWrap: true,
                children: snapshot.data!.docs.map((DocumentSnapshot postInfo){
                  return ThreadItem(postInfo: postInfo);
                }).toList(),
              ) 
              : Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(Icons.error,color: Colors.grey[700],
                        size: 64,),
                        Padding(
                          padding: const EdgeInsets.all(14.0),
                          child: Text('There is no post',
                          style: TextStyle(fontSize: 16,color: Colors.grey[700]),
                          textAlign: TextAlign.center,),
                      ),
                    ],
                  )
                ),
              ),
              // Center(child: CircularProgressIndicator() ,)
            ],
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddPostForm()));
        },
        tooltip: 'Increment',
        child: Icon(Icons.create),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


//thread Item
class ThreadItem extends StatefulWidget {
  final DocumentSnapshot postInfo;
  const ThreadItem({ Key? key, required this.postInfo }) : super(key: key);

  @override
  _ThreadItemState createState() => _ThreadItemState();
}

class _ThreadItemState extends State<ThreadItem> {
  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('users');
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late String userId;

    @override
  void initState() {
    userId = _auth.currentUser!.uid;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[50],
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 4,
                                                offset: Offset(2, 2)),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 5),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      8.0, 0, 8.0, 0),
                                              child: Divider(
                                                color: Colors.grey,
                                              ),
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          12, 8, 12, 0),
                                                  child: Text(
                                                      widget.postInfo.get('title'),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w500)),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      12.0),
                                                  child: Text(widget.postInfo
                                                      .get('description')),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding: EdgeInsets.all(12),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Wrap(
                                                      children: [
                                                    //upvote
                                                    Icon(Icons.upload),
                                                    Text(' ${widget.postInfo['up-votes']}'),
                                                    SizedBox(width: 5),

                                                    //downVote
                                                    Icon(Icons.download),
                                                    Text(' ${widget.postInfo['down-votes']}'),
                                                    ],),
                        
                                                    Wrap(
                                                      children: [
                                                    Icon(Icons.comment_outlined),
                                                    SizedBox(width: 5),                                                  
                                                    Text('0'),
                                                      ],),

                                                  ],
                                                  ),
                                              )
                                          ],
                                        ),
                                      ),
                                    );
  }
}