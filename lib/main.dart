import 'package:flutter/cupertino.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:orbit_app/mode_screens/interviewmode.dart';
import 'package:orbit_app/mode_screens/stopmotionmode.dart';
import 'package:orbit_app/mode_screens/timelapsemode.dart';
import 'package:orbit_app/modeinformation.dart';
import 'package:orbit_app/motorinterface.dart';
import 'package:orbit_app/ui_elements/bottombar.dart';
import 'package:orbit_app/mode_screens/productmode.dart';
import 'package:orbit_app/ui_elements/connectbutton.dart';
import 'package:orbit_app/ui_elements/connectionindicator.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((value) => runApp(ChangeNotifierProvider(
            create: (context) => MotorInterface('ws://192.168.4.1/ws'),
            child: const OrbitApp(),
          )));
}

class OrbitApp extends StatelessWidget {
  const OrbitApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const title = 'Orbit App';
    return Consumer<MotorInterface>(builder: (context, value, child) {
      return CupertinoApp(
        title: title,
        home: const Remote(),
        theme: CupertinoThemeData(
            brightness: Brightness.dark,
            primaryColor: colorRGBAInfo[value.visorColor]),
      );
    });
  }
}

class Remote extends StatelessWidget {
  const Remote({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    List<TabInfo> tabInfo = [
      TabInfo('Product', CupertinoIcons.cube_box,
          modeInformation['Product']!['modeScaler']!),
      TabInfo('Interview', CupertinoIcons.person,
          modeInformation['Interview']!['modeScaler']!),
      TabInfo('Timelapse', CupertinoIcons.time,
          modeInformation['Timelapse']!['modeScaler']!),
      TabInfo('Stop-Motion', CupertinoIcons.timer,
          modeInformation['Stop-Motion']!['modeScaler']!),
    ];

    const List<StatelessWidget> modeScreens = [
      ProductMode(),
      InterviewMode(),
      TimelapseMode(),
      StopmotionMode()
    ];

    return DefaultTextStyle(
        style: CupertinoTheme.of(context).textTheme.textStyle,
        child: CupertinoTabScaffold(
          tabBar: CupertinoTabBar(
            items: [
              for (final tabInfo in tabInfo)
                BottomNavigationBarItem(
                    icon: Icon(tabInfo.icon), label: tabInfo.title)
            ],
            onTap: (value) {
              Provider.of<MotorInterface>(context, listen: false)
                  .changeMode(modes[value]);
              debugPrint(modes[value]);
              HapticFeedback.mediumImpact();
            },
          ),
          tabBuilder: ((context, index) {
            return CupertinoTabView(
              restorationScopeId: 'cupertino_tab_view_$index',
              builder: (context) => CupertinoPageScaffold(
                  navigationBar: CupertinoNavigationBar(
                    leading: Consumer<MotorInterface>(
                      builder: (context, value, child) => ConnectionIndicator(
                          connected:
                              value.connected == ConnectionStatus.connected),
                    ),
                    middle: Text('${tabInfo[index].title} Mode'),
                    trailing: Consumer<MotorInterface>(
                        builder: (context, value, child) {
                      if (value.connectionFailed) {
                        value.connectionFailed = false;
                        SchedulerBinding.instance.addPostFrameCallback(
                            (_) => _showConnectionFailure(context));
                      }
                      return ConnectButton(
                        connectToOrbit: value.connectToOrbit,
                        connectionStatus: value.connected,
                      );
                    }),
                  ),
                  child: modeScreens[index]),
            );
          }),
        ));
  }

  _showConnectionFailure(BuildContext context) {
    showCupertinoModalPopup(
        context: context,
        builder: ((context) => CupertinoAlertDialog(
              title: const Text('Connection Failed!'),
              content:
                  const Text('Could not connect to Orbit, please try again.'),
              actions: [
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('OK'),
                )
              ],
            )));
  }
}
