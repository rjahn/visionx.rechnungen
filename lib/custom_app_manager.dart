import 'package:carousel_app/carousel_screen.dart';
import 'package:flutter_jvx/flutter_jvx.dart';

class CustomAppManager extends AppManager {
  /// Constructor initiating the appmanager of this app
  CustomAppManager() {
    registerScreen(
      CustomScreen.online(
        key: CarouselScreen.SCREEN_KEY,
        screenBuilder: (buildContext, originalScreen) => const CarouselScreen(),
      ),
    );
  }
}
