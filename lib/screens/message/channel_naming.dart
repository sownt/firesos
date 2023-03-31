import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';

import '../../utils/routes.dart';

class ChannelNaming extends StatefulWidget {
  final List<Map<String, dynamic>> membersList;

  const ChannelNaming({required this.membersList, Key? key}) : super(key: key);

  @override
  State<ChannelNaming> createState() => _ChannelNamingState();
}

class _ChannelNamingState extends State<ChannelNaming> {
  final TextEditingController _groupName = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void createGroup() async {
    setState(() {
      isLoading = true;
    });

    String groupId = const Uuid().v1();

    await _firestore.collection('groups').doc(groupId).set({
      "members": widget.membersList,
      "id": groupId,
    });

    for (int i = 0; i < widget.membersList.length; i++) {
      String uid = widget.membersList[i]['uid'];

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('groups')
          .doc(groupId)
          .set({
        "name": _groupName.text,
        "id": groupId,
      });
    }

    await _firestore.collection('groups').doc(groupId).collection('chats').add({
      "message": "${_auth.currentUser!.displayName} Created This Group.",
      "type": "notify",
    });

    Get.toNamed(Routes.home, parameters: {'page': '1'});
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'create_new_group'.tr,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(
                color: Colors.black,
              ),
            )
          : Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: size.height / 16,
                    width: size.width / 1.2,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(horizontal: size.width / 13),
                    margin: EdgeInsets.symmetric(
                        horizontal: size.width / 14,
                        vertical: size.height / 35),
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
                    child: SizedBox(
                      width: size.width / 1.2,
                      child: TextField(
                        controller: _groupName,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: const Icon(Icons.search),
                          prefixIconColor: Colors.grey.shade500,
                          hintText: 'group_name'.tr,
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      createGroup();
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
                          'create'.tr,
                          style: GoogleFonts.poppins(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
