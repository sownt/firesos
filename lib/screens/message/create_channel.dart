import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firesos/screens/home/pages/message.dart';
import 'package:firesos/screens/message/channel_naming.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/routes.dart';
import '../../utils/validator.dart';

class CreateChannel extends StatefulWidget {
  const CreateChannel({super.key});

  @override
  State<StatefulWidget> createState() => _CreateChannelState();
}

class _CreateChannelState extends State<CreateChannel> {
  final TextEditingController _search = TextEditingController();
  final TextEditingController _groupName = TextEditingController();

  List<Map<String, dynamic>> membersList = [];
  bool isLoading = false;
  Map<String, dynamic>? userMap;

  @override
  void initState() {
    super.initState();
    getCurrentUserDetails();
  }

  void getCurrentUserDetails() async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((userMap) {
      setState(() {
        membersList.add({
          "name": userMap['name'],
          "phoneNum": userMap['phoneNum'],
          "email": userMap['email'],
          "uid": userMap['uid'],
          "isAdmin": true,
        });
      });
    });
  }

  void onSearch() async {
    setState(() {
      isLoading = true;
    });

    await FirebaseFirestore.instance
        .collection('users')
        .where("phoneNum", isEqualTo: _search.text) //email
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

        userMap = null;
      });
    }
  }

  void onRemoveMembers(int index) {
    if (membersList[index]['uid'] != FirebaseAuth.instance.currentUser!.uid) {
      setState(() {
        membersList.removeAt(index);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            Get.back();
          },
          child: const Icon(Icons.arrow_back),
        ),
        title: Text('add_members'.tr),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: SingleChildScrollView(
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
                        offset: Offset(0, 10),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ListView.builder(
                    itemCount: membersList.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
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
              ),
              Container(
                height: size.height / 16,
                width: size.width / 1.2,
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
                child: SizedBox(
                  width: size.width / 1.2,
                  child: TextField(
                    controller: _search,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      prefixIconColor: Colors.grey.shade500,
                      hintText: 'phone_search'.tr
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  if (_search.text.isEmpty) {
                    Utils.snackBar('warning.phone_empty'.tr, context);
                  } else {
                    onSearch();
                  }
                },
                child: Container(
                  height: size.height / 18,
                  width: size.width / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.red,
                  ),
                  child: Center(
                    child: Text(
                      'search'.tr,
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 30,
              ),
              userMap != null
                  ? GestureDetector(
                      onTap: () {
                        onResultTap();
                      },
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
                        child: ListTile(
                          leading: Icon(
                            Icons.account_circle_rounded,
                            color: Colors.red[900],
                            size: 40,
                          ),
                          title: Text(userMap!['name']),
                          subtitle: Text(userMap!['email']),
                          trailing: Text(
                            'add'.tr,
                            style: GoogleFonts.poppins(
                              color: Colors.red[900],
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
      floatingActionButton: membersList.length >= 2
          ? FloatingActionButton.extended(
              label: Text('submit'.tr),
              icon: const Icon(Icons.check),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChannelNaming(
                    membersList: membersList,
                  ),
                ),
              ),
            )
          : const SizedBox(),
    );
  }
}
