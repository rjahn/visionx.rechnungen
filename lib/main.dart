import 'package:rechnungen_app/custom_app_manager.dart';
import 'package:flutter_jvx/flutter_jvx.dart';

AppManager get appManager => CustomAppManager();

void main() {
  FlutterUI.start(
    FlutterUI(
      appManager: appManager,
      appConfig: AppConfig(
        autoRestartOnSessionExpired: true,
        forceSingleAppMode: true,
        customAppsAllowed: false,
        title: "Rechnungen",
        uiConfig: const UiConfig(showRememberMe: true, rememberMeChecked: true),
        serverConfigs: [
          PredefinedServerConfig(
            title: "Rechnungen",
            appName: "Rechnungen",
            baseUrl: Uri(scheme: "http", host: "10.0.0.1", port: 80, path: "/services/mobile"),
            isDefault: true,
            parametersHidden: true,
          )
        ],
      ),
    ),
  );
}
