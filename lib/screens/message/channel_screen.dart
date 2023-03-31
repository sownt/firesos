import 'dart:io';

import 'package:firesos/widgets/rounded_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'channel_drawer.dart';

class ChannelScreen extends StatefulWidget {
  const ChannelScreen({
    super.key,
    required this.groupChatId,
    required this.groupName,
  });

  final String groupChatId;
  final String groupName;

  @override
  State<StatefulWidget> createState() => _ChannelScreenState();
}

class _ChannelScreenState extends State<ChannelScreen> {
  final TextEditingController _message = TextEditingController();

  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore store = FirebaseFirestore.instance;
  File? imageFile;

  void onSendMessage() async {
    if (_message.text.isNotEmpty) {
      Map<String, dynamic> chatData = {
        "sendBy": auth.currentUser!.displayName,
        "message": _message.text,
        "type": "text",
        "time": FieldValue.serverTimestamp(),
      };

      _message.clear();

      await store
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .add(chatData);
    }
  }

  Future getImage() async {
    ImagePicker _picker = ImagePicker();

    await _picker.pickImage(source: ImageSource.gallery).then((xFile) {
      if (xFile != null) {
        imageFile = File(xFile.path);
        uploadImage();
      }
    });
  }

  Future takePicture() async {
    ImagePicker _take = ImagePicker();
    await _take.pickImage(source: ImageSource.camera).then((XFile) {
      if (XFile != null) {
        imageFile = File(XFile.path);
        uploadImage();
      }
    });
  }

  Future uploadImage() async {
    String fileName = const Uuid().v1();
    int status = 1;

    await store
        .collection('groups')
        .doc(widget.groupChatId)
        .collection('chats')
        .doc(fileName)
        .set({
      "sendby": auth.currentUser!.displayName,
      "message": "",
      "type": "img",
      "time": FieldValue.serverTimestamp(),
    });

    var ref =
        FirebaseStorage.instance.ref().child('images').child("$fileName.jpg");

    var uploadTask = await ref.putFile(imageFile!).catchError((error) async {
      await store
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .delete();

      status = 0;
    });

    if (status == 1) {
      String imageUrl = await uploadTask.ref.getDownloadURL();

      await store
          .collection('groups')
          .doc(widget.groupChatId)
          .collection('chats')
          .doc(fileName)
          .update({"message": imageUrl});

      print(imageUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        // leading: GestureDetector(
        //     onTap: () {
        //       Navigator.of(context).push(MaterialPageRoute(
        //         builder: (context) => const GroupChatScreen(),
        //       ));
        //     },
        //     child: const Icon(
        //       Icons.arrow_back_ios_new_rounded,
        //       color: Colors.white,
        //     )),
        title: Text(
          widget.groupName,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ChannelDrawer(
                  groupName: widget.groupName,
                  groupId: widget.groupChatId,
                ),
              ),
            ),
            icon: const Icon(Icons.info),
          ),
        ],
        elevation: 5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: size.height / 1.27,
              width: size.width,
              child: StreamBuilder<QuerySnapshot>(
                stream: store
                    .collection('groups')
                    .doc(widget.groupChatId)
                    .collection('chats')
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> chatMap =
                            snapshot.data!.docs[index].data()
                                as Map<String, dynamic>;

                        return messageTitle(size, chatMap, context);
                      },
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            Container(
              height: size.height / 10,
              width: size.width / 0.5,
              alignment: Alignment.center,
              child: SizedBox(
                height: size.height / 12,
                width: size.width / 1.1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: size.height / 13,
                      width: size.height / 19,
                      child: IconButton(
                        onPressed: () {
                          takePicture();
                        },
                        icon: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width / 40,
                    ),
                    Container(
                      height: size.height / 17,
                      width: size.width / 1.5,
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
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width / 20),
                        child: TextField(
                          style: GoogleFonts.poppins(color: Colors.black),
                          controller: _message,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              onPressed: () => getImage(),
                              icon: Icon(
                                Icons.crop_original_rounded,
                                color: Colors.red[900],
                                size: size.width / 15,
                              ),
                            ),
                            hintText: "Send a message",
                            hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade600),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: size.width / 25,
                    ),
                    GestureDetector(
                      onTap: () {
                        onSendMessage();
                      },
                      child: Icon(Icons.send, color: Colors.red[900]),
                    ),
                    // IconButton(
                    //     onPressed: () {
                    //       onSendMessage();
                    //     },
                    //     icon: const Icon(Icons.send, color: Colors.blue))
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget messageTitle(
      Size size, Map<String, dynamic> chatMap, BuildContext context) {
    return Builder(
      builder: (_) {
        if (chatMap['type'] == "text") {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            padding: EdgeInsets.symmetric(
                horizontal: size.width / 100, vertical: size.height / 400),
            child: Column(
              children: [
                Text(
                  chatMap['sendBy'],
                  style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.red[900]),
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height / 200,
                      ),
                      Text(
                        chatMap['message'],
                        style: GoogleFonts.poppins(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (chatMap['type'] == 'img') {
          return Container(
            width: size.width,
            alignment: chatMap['sendBy'] == auth.currentUser!.displayName
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Container(
              height: size.height / 2.5,
              width: size.width,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              // margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              alignment: chatMap['sendby'] == auth.currentUser!.displayName
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RoundedImage(
                      imageUrl: chatMap['message'],
                    ),
                  ),
                ),
                child: Container(
                  height: size.height / 2.5,
                  width: size.width / 2,
                  alignment:
                      chatMap['message'] != "" ? null : Alignment.centerRight,
                  child: chatMap['message'] != ""
                      ? Image.network(
                          chatMap['message'],
                          fit: BoxFit.cover,
                        )
                      : const CircularProgressIndicator(),
                ),
              ),
            ),
          );
        } else if (chatMap['type'] == 'notify') {
          return Container(
            width: size.width,
            alignment: Alignment.center,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15), color: Colors.white),
              child: Text(
                chatMap['message'],
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.black),
              ),
            ),
          );
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
