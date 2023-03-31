import 'package:firesos/screens/message/channel_screen.dart';
import 'package:firesos/screens/message/create_channel.dart';
import 'package:firesos/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<StatefulWidget> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final FirebaseFirestore store = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  bool isLoading = true;
  List groupList = [];

  @override
  void initState() {
    super.initState();
    getAvailableGroups();
  }

  void getAvailableGroups() async {
    String uid = auth.currentUser!.uid;

    await store
        .collection('users')
        .doc(uid)
        .collection('groups')
        .get()
        .then((value) {
      setState(() {
        groupList = value.docs;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Fire Notification Groups",
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAllNamed(Routes.home);
            },
            icon: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: 'logout'.tr,
          ),
        ],
      ),
      body: isLoading
          ? Container(
              height: size.height,
              width: size.width,
              alignment: Alignment.center,
              child: const CircularProgressIndicator(),
            )
          : groupList.isEmpty
              ? Center(
                  child: Text(
                    'empty_chat'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.normal,
                      color: Colors.grey,
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.separated(
                      itemCount: groupList.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          onTap: () =>
                              Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => ChannelScreen(
                              groupName: groupList[index]['name'],
                              groupChatId: groupList[index]['id'],
                            ),
                          )),
                          leading: Container(
                            height: size.height / 13,
                            width: size.height / 19,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red[900],
                            ),
                            child: Icon(
                              Icons.group,
                              color: Colors.white,
                              size: size.width / 14,
                            ),
                          ),
                          title: Text(
                            groupList[index]['name'],
                            style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                                fontSize: 18),
                          ),
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) =>
                          const SizedBox(height: 8)),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.createChannel),
        label: Text('new_conversation'.tr),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
