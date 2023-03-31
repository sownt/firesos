import 'package:firesos/controllers/auth_controller.dart';
import 'package:firesos/controllers/position_controller.dart';
import 'package:firesos/screens/auth/create_account.dart';
import 'package:firesos/screens/auth/login_screen.dart';
import 'package:firesos/screens/home/home_screen.dart';
import 'package:firesos/screens/message/create_channel.dart';
import 'package:get/get.dart';

class Routes {
  Routes._();

  static const home = '/home';
  static const login = '/login';
  static const signup = '/signup';
  static const createChannel = '/create_channel';

  static final List<GetPage> pages = [
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut(() => PositionController());
        },
      ),
    ),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      binding: BindingsBuilder(
        () {
          Get.lazyPut(() => AuthController());
        },
      ),
    ),
    GetPage(
      name: signup,
      page: () => const CreateAccount(),
      binding: BindingsBuilder(
            () {
          Get.lazyPut(() => AuthController());
        },
      ),
    ),
    GetPage(
      name: createChannel,
      page: () => const CreateChannel(),
    ),
  ];
}
