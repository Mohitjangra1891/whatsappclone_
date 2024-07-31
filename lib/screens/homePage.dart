import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:whatsappclone/controller/providers/home_page_provider.dart';
import 'package:whatsappclone/controller/services/firebase_service.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/screens/select_contact/select_contacts.dart';
import 'package:whatsappclone/screens/settings/settings_screen.dart';
import 'package:whatsappclone/screens/status/status_image_preview.dart';
import 'package:whatsappclone/screens/status/widgets/status_camera_screen.dart';
import 'package:whatsappclone/screens/tabs/Tab_Calls_Screen.dart';
import 'package:whatsappclone/screens/tabs/Tab_Chat_screen.dart';
import 'package:whatsappclone/screens/tabs/Tab_Status_screen.dart';

import '../utils/AppColors.dart';
import '../utils/CGColors.dart';
import '../utils/CGConstant.dart';
import '../utils/common_Widgets.dart';
import 'camera/camera_screen.dart';

const List<PopupMenuItem> chatpopupItem = [
  PopupMenuItem(value: 1, child: Text('New group')),
  PopupMenuItem(value: 2, child: Text('New Broadcast')),
  PopupMenuItem(value: 3, child: Text('$CGAppName Web')),
  PopupMenuItem(value: 4, child: Text('Starred messages')),
  PopupMenuItem(value: 6, child: Text("Payment")),
  PopupMenuItem(value: 5, child: Text('Settings'))
];

const List<PopupMenuItem> statuspopupItem = [
  PopupMenuItem(value: 1, child: Text('Status privacy')),
  PopupMenuItem(value: 5, child: Text('Settings'))
];
const List<PopupMenuItem> callpopupItem = [
  PopupMenuItem(value: 1, child: Text('Clear call log')),
  PopupMenuItem(value: 5, child: Text('Settings'))
];

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> with TickerProviderStateMixin, WidgetsBindingObserver {
  TabController? _tabController;
  // final PanelController panel_Controller = PanelController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   firebase_service.setUserState(true);
    // });
    // panel_Controller = new PanelController();

    init();
  }

  init() async {
    _tabController = TabController(vsync: this, initialIndex: 1, length: 4);
    _tabController!.addListener(() {
      context.read<homepage_Provider>().change_tabIndex(_tabController!.index);
    });
    // context.read<homepage_Provider>().initializeGroupsStream();
  }

  @override
  void dispose() {
    super.dispose();
    // firebase_service.setUserState(false);
    WidgetsBinding.instance.removeObserver(this);

    _tabController?.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        firebase_service.setUserState(true);
        // ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        firebase_service.setUserState(false);
        // ref.read(authControllerProvider).setUserState(false);
        break;
      case AppLifecycleState.hidden:
        firebase_service.setUserState(false);

      // TODO: Handle this case.
    }
  }

  @override
  Widget build(BuildContext context) {
    final tabIndex_provider = Provider.of<homepage_Provider>(context).tabIndex;

    return PopScope(
      canPop: false,
      onPopInvoked: (bool canPop) async {
        if (canPop) {
          return;
        }
        if (_tabController?.index == 0 && panel_Controller.isPanelOpen) {
          panel_Controller.close();
          return Future.value(false); // Do not switch tab yet
        }
        if (_tabController?.index != 1) {
          _tabController!.animateTo(1);
          return Future.value(false); // Do not switch tab yet
        } else {
          SystemNavigator.pop();
        }

        // final bool shouldPop = await _onBackPressed(context) ?? false;
        // if (context.mounted && shouldPop) {
        // Navigator.pop(context);
        // }
      },
      child: SafeArea(
        child: DefaultTabController(
          length: 4,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: appBackgroundColorDark,
              systemNavigationBarColor: appBackgroundColorDark,
            ),
            child: Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                centerTitle: false,
                // backgroundColor: secondaryColor,
                title: Text(CGAppName, style: boldTextStyle(size: 22, weight: FontWeight.w900, color: Colors.white)),
                actions: [
                  IconButton(
                    icon: Icon(Icons.search, color: iconPrimaryColor),
                    onPressed: () {
                      // showSearch(context: context, delegate: SearchContact());
                    },
                  ),
                  PopupMenuButton(
                      color: cardBackgroundBlackDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(radiusCircular(10))),
                      position: PopupMenuPosition.under,
                      onSelected: (dynamic v) {
                        if (v == 5) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                        } else if (tabIndex_provider == 2 && v == 1) {
                          // CGStatusPrivacyScreen().launch(context);
                        } else if (tabIndex_provider == 3 && v == 1) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: const Text("Do you want to clear your entire call log?"),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      finish(context);
                                    },
                                    child: Text("CANCEL", style: boldTextStyle(color: secondaryColor)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      finish(context);
                                    },
                                    child: Text("OK", style: boldTextStyle(color: secondaryColor)),
                                  ),
                                ],
                              );
                            },
                          );
                        } else if (v == 1 && tabIndex_provider == 1) {
                          // CGNewGroupAndBroadcastScreen(isNewGroup: true)
                          //     .launch(context);
                        } else if (v == 2 && tabIndex_provider == 1) {
                          // CGNewGroupAndBroadcastScreen(isNewGroup: false)
                          //     .launch(context);
                        } else if (v == 6 && tabIndex_provider == 1) {
                          // CGPaymentScreen().launch(context);
                        } else if (v == 3 && tabIndex_provider == 1) {
                          toast('Coming soon');
                        }
                      },
                      icon: Icon(Icons.more_vert, color: Colors.white),
                      itemBuilder: (context) {
                        if (tabIndex_provider == 1) {
                          return chatpopupItem;
                        } else if (tabIndex_provider == 2) {
                          return statuspopupItem;
                        } else if (tabIndex_provider == 3) {
                          return callpopupItem;
                        } else {
                          return chatpopupItem;
                        }
                      })
                ],
                bottom: TabBar(
                  dividerColor: Colors.transparent,
                  onTap: (index) {
                    context.read<homepage_Provider>().change_tabIndex(index);
                  },
                  controller: _tabController,
                  indicatorColor: kPrimaryColor,
                  labelStyle: boldTextStyle(size: 16, color: textPrimaryColors),
                  unselectedLabelColor: appStore.isDarkModeOn ? Colors.white : kPrimaryColor,
                  labelColor: !appStore.isDarkModeOn ? Colors.white : kPrimaryColor,
                  tabs: [
                    Container(
                        width: 30,
                        child: Icon(
                          Icons.camera_alt,
                          color: tabIndex_provider == 0 ? kPrimaryColor : Colors.white70,
                        )),
                    Row(
                      children: [
                        const Tab(text: 'Chats'),
                        4.width,
                        Container(
                          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(30.0)),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: const Text("2", style: TextStyle(fontSize: 12, color: Colors.black)).center(),
                        )
                      ],
                    ),
                    const Tab(text: 'Status'),
                    const Tab(text: 'Calls'),
                  ],
                ),
              ),
              body: TabBarView(
                controller: _tabController,
                children: [
                  CameraScreen(
                    panelController: panel_Controller,
                  ),
                  chat_screen(),
                  status_screen(),
                  const call_screen()
                ],
              ),
              floatingActionButton: _changeFLoatingActionButton(tabIndex_provider),
            ),
          ),
        ),
      ),
    );
  }

  _changeFLoatingActionButton(int indexAt) {
    if (indexAt == 1) {
      return FloatingActionButton(
        backgroundColor: buttonColor,
        onPressed: () {
          const selectContactsScreen().launch(context);
        },
        child: const Icon(Icons.message, color: Colors.white),
      );
    } else if (indexAt == 2) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 1,
            mini: true,
            backgroundColor: Colors.white,
            onPressed: () {
              const selectContactsScreen().launch(context);
            },
            child: const Icon(Icons.create, color: secondaryColor),
          ),
          8.height,
          FloatingActionButton(
            heroTag: 2,
            backgroundColor: buttonColor,
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => status_CameraScreen(),
                ),
              );
              // final image = await pickImageFromGallery(context);
              // if (image != null) {
              //   Navigator.push(context, MaterialPageRoute(builder: (context) => StatusImageConfirmPage(file: image)));
              // } else {}
            },
            child: const Icon(Icons.camera_alt_rounded, color: Colors.white),
          ),
        ],
      );
    } else if (indexAt == 3) {
      return FloatingActionButton(
        backgroundColor: buttonColor,
        onPressed: () {
          // CGSelectContactScreen(isCallScreen: true).launch(context);
        },
        child: const Icon(
          Icons.add_call,
          color: Colors.white,
        ),
      );
    }
  }
}

//
// class SearchContact extends SearchDelegate<ChatModel?> {
//   @override
//   List<Widget> buildActions(BuildContext context) {
//     return [
//       IconButton(
//         icon: Icon(Icons.clear),
//         onPressed: () {
//           query = '';
//         },
//       )
//     ];
//   }
//
//   @override
//   Widget buildLeading(BuildContext context) {
//     return IconButton(
//       icon: Icon(Icons.arrow_back),
//       onPressed: () {
//         close(context, null);
//       },
//     );
//   }
//
//   @override
//   Widget buildResults(BuildContext context) {
//     return CGChatScreen();
//   }
//
//   @override
//   Widget buildSuggestions(BuildContext context) {
//     return CGChatScreen();
//   }
// }
