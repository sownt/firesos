import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firesos/screens/home/pages/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/routes.dart';
import 'add_member.dart';

class ChannelDrawer extends StatefulWidget {
  final String groupId, groupName;

  const ChannelDrawer(
      {super.key, required this.groupId, required this.groupName});

  @override
  State<ChannelDrawer> createState() => _ChannelDrawerState();
}

class _ChannelDrawerState extends State<ChannelDrawer> {
  List membersList = [];
  bool isLoading = true;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  void initState() {
    super.initState();

    getGroupDetails();
  }

  Future getGroupDetails() async {
    await _firestore
        .collection('groups')
        .doc(widget.groupId)
        .get()
        .then((chatMap) {
      membersList = chatMap['members'];
      print(membersList);
      isLoading = false;
      setState(() {});
    });
  }

  bool checkAdmin() {
    bool isAdmin = false;

    for (var element in membersList) {
      if (element['uid'] == _auth.currentUser!.uid) {
        isAdmin = element['isAdmin'];
      }
    }
    return isAdmin;
  }

  Future removeMembers(int index) async {
    String uid = membersList[index]['uid'];

    setState(() {
      isLoading = true;
      membersList.removeAt(index);
    });

    await _firestore.collection('groups').doc(widget.groupId).update({
      "members": membersList,
    }).then((value) async {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      setState(() {
        isLoading = false;
      });
    });
  }

  void showDialogBox(int index) {
    if (checkAdmin()) {
      if (_auth.currentUser!.uid != membersList[index]['uid']) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content: ListTile(
                  onTap: () => removeMembers(index),
                  title: Text("Remove This Member",
                      style: GoogleFonts.poppins(
                          color: Colors.red, fontWeight: FontWeight.w500)),
                ),
              );
            });
      }
    }
  }

  Future onLeaveGroup() async {
    if (!checkAdmin()) {
      setState(() {
        isLoading = true;
      });

      for (int i = 0; i < membersList.length; i++) {
        if (membersList[i]['uid'] == _auth.currentUser!.uid) {
          membersList.removeAt(i);
        }
      }

      await _firestore.collection('groups').doc(widget.groupId).update({
        "members": membersList,
      });

      await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .collection('groups')
          .doc(widget.groupId)
          .delete();

      Get.offAndToNamed(Routes.home, parameters: {'page': '1'});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return SafeArea(
      child: Scaffold(
        body: isLoading
            ? Container(
                height: size.height,
                width: size.width,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.black,
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: BackButton(),
                    ),
                    Container(
                      height: size.height / 8,
                      width: size.width / 1.1,
                      child: Row(
                        children: [
                          Container(
                            height: size.height / 11,
                            width: size.height / 11,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[900],
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 10,
                            ),
                          ),
                          SizedBox(
                            width: size.width / 20,
                          ),
                          Expanded(
                            child: Container(
                              child: Text(
                                widget.groupName,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: size.width / 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    //

                    SizedBox(
                      height: size.height / 20,
                    ),

                    Container(
                      width: size.width / 1.1,
                      child: Text(
                        "${membersList.length} Members",
                        style: TextStyle(
                          fontSize: size.width / 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    SizedBox(
                      height: size.height / 20,
                    ),

                    // Members Name

                    checkAdmin()
                        ? ListTile(
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddMember(
                                  groupChatId: widget.groupId,
                                  name: widget.groupName,
                                  membersList: membersList,
                                ),
                              ),
                            ),
                            leading:  const Icon(
                              Icons.add,color: Colors.blueAccent,
                            ),
                            title: Text(
                              "Add Members",
                              style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,color: Colors.blueAccent
                              ),
                            ),
                          )
                        : const SizedBox(),

                    Flexible(
                      child: ListView.builder(
                        itemCount: membersList.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return ListTile(
                            onTap: () => showDialogBox(index),
                            leading: Icon(Icons.account_circle,size: 30,color: Colors.red[900],),
                            title: Text(
                              membersList[index]['name'],
                              style: TextStyle(
                                fontSize: size.width / 22,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            subtitle: Text(membersList[index]['email']),
                            trailing: Text(
                                membersList[index]['isAdmin'] ? "Admin" : ""),
                          );
                        },
                      ),
                    ),

                    ListTile(
                      onTap: onLeaveGroup,
                      leading: const Icon(
                        Icons.logout,
                        color: Colors.redAccent,
                      ),
                      title: Text(
                        "Leave Group",
                        style: TextStyle(
                          fontSize: size.width / 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
