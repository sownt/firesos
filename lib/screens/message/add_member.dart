import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/validator.dart';

class AddMember extends StatefulWidget {
  final String groupChatId, name;
  final List membersList;

  const AddMember(
      {super.key,
      required this.groupChatId,
      required this.name,
      required this.membersList});

  @override
  State<AddMember> createState() => _AddMemberState();
}

class _AddMemberState extends State<AddMember> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userMap;
  List membersList = [];
  bool isLoading = false;
  final TextEditingController search = TextEditingController();
  @override
  void initState() {
    super.initState();
    membersList = widget.membersList;
  }

  void onResultTap() {
    bool isAlreadyExist = false;

    for (int i = 0; i < membersList.length; i++) {
      if (membersList[i]['uid'] == userMap!['uid']) {
        isAlreadyExist = true;
        break; //suggest break when found exist
      }
    }

    if (!isAlreadyExist) {
      setState(() {
        membersList.add({
          "name": userMap!['name'],
          "phoneNum": userMap!['phoneNum'],
          "email": userMap!['email'],
          "uid": userMap!['uid'],
          "isAdmin": false,
        });
        _firestore.collection('groups').doc(widget.groupChatId).update({
          "members": membersList,
        });

        userMap = null;
      });
    }
  }

  // void onAddMembers() async {
  //   if (userMap != null) {
  //     membersList.add(userMap);

  //     await _firestore.collection('groups').doc(widget.groupChatId).update({
  //       "members": membersList,
  //     });

  //     await _firestore
  //         .collection('users')
  //         .doc(userMap?['uid'])
  //         .collection('groups')
  //         .doc(widget.groupChatId)
  //         .set({"name": widget.name, "id": widget.groupChatId});
  //   }
  // }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != auth.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await _firestore
        .collection('users')
        .where("phoneNum", isEqualTo: search.text)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        setState(() {
          userMap = value.docs.first.data();
          userMap?.addAll({
            "uid": value.docs.first.id,
          });
          isLoading = false;
        });
      }
      print(userMap);
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red[900],
          leading: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
              )),
          title: Text('Add new Members',
              style: GoogleFonts.poppins(color: Colors.white)),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  width: size.width / 1.1,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [
                        BoxShadow(
                            color: Color.fromRGBO(200, 168, 201, 0.3),
                            blurRadius: 20,
                            offset: Offset(0, 10)),
                      ],
                      borderRadius: BorderRadius.circular(20)),
                  child: ListView.builder(
                    itemCount: membersList.length,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () => onRemoveMembers(index),
                        leading: Icon(
                          Icons.account_circle,
                          color: Colors.red[900],
                          size: 40,
                        ),
                        title: Text(membersList[index]['name']),
                        subtitle: Text(membersList[index]['email']),
                        trailing: Icon(Icons.close, color: Colors.red[900]),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 20,
                width: size.width / 1.2,
              ),
              Container(
                height: size.height / 16,
                width: size.width,
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: size.width / 13),
                margin: EdgeInsets.symmetric(
                    horizontal: size.width / 14, vertical: size.height / 35),
                decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromRGBO(200, 168, 201, 0.3),
                          blurRadius: 20,
                          offset: Offset(0, 10)),
                    ],
                    borderRadius: BorderRadius.circular(20)),
                child: Container(
                  width: size.width / 1.2,
                  child: TextField(
                    controller: search,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Colors.grey.shade500,
                      hintText: "Phone number search",
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 50,
              ),
              isLoading
                  ? Container(
                      height: size.height / 12,
                      width: size.height / 12,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        if (search.text.isEmpty) {
                          Utils.snackBar(
                              'Please enter the phonenumber', context);
                        } else {
                          onSearch();
                        }
                      },
                      child: Container(
                        height: size.height / 18,
                        width: size.width / 4,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.red[900],
                        ),
                        child: Center(
                          child: Text('Search',
                              style: GoogleFonts.poppins(color: Colors.white)),
                        ),
                      ),
                    ),
              userMap != null
                  ? GestureDetector(
                      onTap: () {
                        onResultTap();
                      },
                      child: Card(
                        child: ListTile(
                          leading: Icon(Icons.account_circle_rounded,
                              color: Colors.red[900], size: 40),
                          title: Text(userMap!['name']),
                          subtitle: Text(userMap!['email']),
                          trailing: Text('Add',
                              style: GoogleFonts.poppins(
                                  color: Colors.red[900],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16)),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
