import 'package:firebase_auth/firebase_auth.dart';
import 'package:firesos/screens/home/pages/library.dart';
import 'package:firesos/screens/home/pages/map.dart';
import 'package:firesos/screens/home/pages/message.dart';
import 'package:firesos/screens/home/pages/notifications.dart';
import 'package:firesos/screens/home/pages/settings.dart';
import 'package:firesos/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int pos = 0;
  late List<Widget> widgets;

  @override
  void initState() {
    super.initState();
    widgets = [
      const MapPage(),
      const SizedBox(),
      const NotificationsPage(),
      const LibraryPage(),
      const SettingsPage()
    ];
    try {
      pos = int.parse(Get.parameters['page']!);
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
      bottomNavigationBar: _bottomNavigationBar(context),
    );
  }

  Widget _body(BuildContext context) {
    if (pos == 1) {
      return const MessagePage();
    }
    return IndexedStack(
      index: pos,
      children: widgets,
    );
  }

  Widget _bottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home_outlined),
          label: 'home'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.chat_bubble_outline_rounded),
          label: 'messages'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.notifications),
          label: 'notifications'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.sticky_note_2_rounded),
          label: 'library'.tr,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: 'settings'.tr,
        ),
      ],
      onTap: (value) async {
        if (value == 1 && FirebaseAuth.instance.currentUser == null) {
          await Get.toNamed(Routes.login);
        } else {
          setState(() {
            pos = value;
          });
        }
      },
      currentIndex: pos,
      showUnselectedLabels: false,
      selectedFontSize: 12,
      type: BottomNavigationBarType.fixed,
    );
  }
}
