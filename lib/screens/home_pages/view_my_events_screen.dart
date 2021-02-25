import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:frc_challenge_app/components/bottomNavBar.dart';
import 'package:frc_challenge_app/components/common_app_bar.dart';
import 'package:frc_challenge_app/components/common_drawers.dart';
import 'package:frc_challenge_app/db_services/email_db.dart';
import 'package:frc_challenge_app/db_services/post_db.dart';
import 'package:frc_challenge_app/db_services/user_db.dart';
import 'package:frc_challenge_app/models/post.dart';
import 'package:frc_challenge_app/models/user.dart';
import 'package:frc_challenge_app/screens/post_pages/display_post_screen.dart';

class ViewMyEventsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _ViewMyEventsScreen();
  }
}

class _ViewMyEventsScreen extends State<ViewMyEventsScreen> {
  List<Post> myPostsList = new List<Post>();

  @override
  void initState() {
    super.initState();
    User thisUser = UserDb.userMap[UserDb.emailMap[EmailDb.thisEmail]];
    DateTime now = DateTime.now();
    for (int i = 0; i < thisUser.postIdList.length; i++) {
      Post p = PostDb.localMap[thisUser.postIdList.elementAt(i)];
      if (p.active && p.eventDateTime.isAfter(now)) {
        myPostsList.add(p);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar.appBar("My Events", context),
      drawer: CommonDrawers.profileDrawer(context),
      body: Container(
        child: SingleChildScrollView(
            child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.7,
                child: ListView.builder(
                    itemCount: myPostsList.length,
                    itemBuilder: (context, index) {
                      return Dismissible(
                        key: Key("$index"),
                        onDismissed: (direction) {
                          User thisUser = UserDb
                              .userMap[UserDb.emailMap[EmailDb.thisEmail]];
                          Set<int> myPosts = thisUser.postIdList;
                          myPosts.remove(myPostsList[index].id);
                          UserDb.updateData(thisUser.id,
                              postsSignedUpFor: myPosts);

                          PostDb.deletePostFromDb(myPostsList[index].id);
                          setState(() {
                            List<Post> newPostList = new List<Post>();
                            for (int i = 0;
                                i < thisUser.postIdList.length;
                                i++) {
                              Post p = PostDb
                                  .localMap[thisUser.postIdList.elementAt(i)];
                              if (p.active) {
                                newPostList.add(p);
                              }
                            }
                            myPostsList = newPostList;
                          });
                        },
                        child: Card(
                          child: ListTile(
                            title: Text("${myPostsList[index].address}"),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => DisplayPostScreen(
                                          myPostsList[index])));
                            },
                          ),
                        ),
                        background: Container(
                          color: Colors.red,
                          child: Icon(Icons.delete)
                        ),
                      );
                    }))),
      ),
      bottomNavigationBar: bottomNavBar(),
    );
  }
}
