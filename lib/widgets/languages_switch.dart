import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        final locale = Get.locale?.languageCode == 'en'
            ? const Locale('vi', 'VN')
            : const Locale('en', 'US');
        GetStorage().write('locale', {
          'languageCode': locale.languageCode,
          'countryCode': locale.countryCode!,
        });
        Get.updateLocale(locale);
      },
      style: const ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory),
      child: Text(
        'lang'.tr,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}

class LanguageSwitchFlag extends StatelessWidget {
  const LanguageSwitchFlag({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: Get.locale?.languageCode == 'en' ? 'Vietnamese' : 'English',
      onPressed: () {
        final locale = Get.locale?.languageCode == 'en'
            ? const Locale('vi', 'VN')
            : const Locale('en', 'US');
        GetStorage().write('locale', {
          'languageCode': locale.languageCode,
          'countryCode': locale.countryCode!,
        });
        Get.updateLocale(locale);
      },
      style: const ButtonStyle(
          overlayColor: MaterialStatePropertyAll(Colors.transparent),
          splashFactory: NoSplash.splashFactory),
      icon: Image.asset(
        Get.locale?.languageCode == 'en'
            ? 'assets/icons/vn.png'
            : 'assets/icons/usa.png',
      ),
    );
  }
}
