import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:profanity_filter/profanity_filter.dart';
import 'package:simplify/page/boosterCommunity/screen/home/comment/commentItem.dart';
import 'package:simplify/page/boosterCommunity/screen/home/comment/viewPostHeader.dart';
import 'package:simplify/page/boosterCommunity/service/firebaseHelper.dart';
import '../../../../../algo/globals.dart' as globals;

class CommentSection extends StatefulWidget {
  final DocumentSnapshot postInfo;
  final String postId;
  final String userId;
  final Map<String, dynamic>? myLikeList;
  const CommentSection(
      {Key? key,
      required this.postInfo,
      required this.userId,
      required this.postId,
      required this.myLikeList
      })
      : super(key: key);

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _msgTextController = new TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;

  //upload to firebase
  String _commenterSchool = '';
  String _commenterFirstName = '';
  String _commenterLastName = '';
  String _commenterIcon = '';

  @override
  void initState() {
    super.initState();
    getInfo(_auth.currentUser!.uid);
  }

  Future getInfo(String publisherUid) async {
    FirebaseFirestore.instance
        .collection('users')
        .doc(publisherUid)
        .get()
        .then((value) {
      setState(() {
        _commenterSchool = value.get('school');
        _commenterFirstName = value.get('first-name');
        _commenterLastName = value.get('last-name');
        _commenterIcon = value.get('userIcon');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text('Support Community'),
      ),
      body: Column(
        children: [
          StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('thread')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center();
                return PostHeader(postInfo: snapshot.data!, userId: widget.userId);
              }),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('thread')
                    .doc(widget.postId)
                    .collection('comment')
                    .orderBy('published-time', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return Center(child: CircularProgressIndicator());
                  return Stack(children: <Widget>[
                    ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs
                          .map((DocumentSnapshot commentInfo) {
                        return CommentItem(
                          myLikeList: widget.myLikeList,
                          postId: widget.postId,
                          commentInfo: commentInfo,
                          userId: widget.userId,
                        );
                      }).toList(),
                    )
                  ]);
                }),
          ),
          //if global is Editing is false, return create comment
          globals.isEditing == false? _buildTextComposer() 
          //if true return null widget
          :Container(child: Text('is editing is true'),)
          // StreamBuilder<DocumentSnapshot>(
          //   stream: FirebaseFirestore.instance.collection('thread').doc(widget.postId).snapshots(),
          //   builder: (context, snapshot){
          //     if(snapshot.connectionState == ConnectionState.done){
          //       return PostHeader(postInfo: snapshot.data! , userId: widget.userId);
          //     }
          //     else {
          //         return Padding(
          //           padding: const EdgeInsets.only(top: 30),
          //           child: Center(child: CircularProgressIndicator()),
          //         );
          //       }
          //   }
          //   ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: <Widget>[
            Flexible(
              child: TextField(
                focusNode: FocusNode(),
                controller: _msgTextController,
                onSubmitted: null,
                decoration:
                    InputDecoration.collapsed(hintText: "Write a comment"),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    final additionalWords = ProfanityFilter.filterAdditionally(globals.badWordsList);
                    bool hasProfanity =  additionalWords.hasProfanity(_msgTextController.text);
                    // bool hasProfanity = filter.hasProfanity(_msgTextController.text);
                    if(hasProfanity){
                        showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                            title: Text("Profanity Check"),
                            content: Text("Seems like your comment contains inapropriate or improper words, Please consider reconstructiong your comment."), 
                            actions: [
                              ElevatedButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ));
                    } else {
                        AuthService().addComment(
                        _msgTextController.text,
                        widget.postId,
                        _commenterFirstName,
                        _commenterLastName,
                        _commenterIcon,
                        _commenterSchool);
                    FocusScope.of(context).requestFocus(FocusNode());
                    _msgTextController.text = '';
                    }
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
