import 'dart:io';

import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/auth_Provider.dart';
import 'package:whatsappclone/controller/services/chat_service.dart';
import 'package:whatsappclone/main.dart';
import 'package:whatsappclone/utils/CGConstant.dart';
import 'package:whatsappclone/utils/data_provider.dart';

import '../../../model/message_reply.dart';
import '../../../utils/AppColors.dart';
import '../../../utils/CGColors.dart';
import '../../../utils/common_Widgets.dart';
import 'message_reply_preview.dart';

class BottomChatField extends StatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;

  const BottomChatField({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  State<BottomChatField> createState() => _BottomChatFieldState();
}

class _BottomChatFieldState extends State<BottomChatField> {
  bool isShowSendButton = false;
  final TextEditingController _messageController = TextEditingController();
  FlutterSoundRecorder? _soundRecorder;
  bool isRecorderInit = false;
  bool isShowEmojiContainer = false;
  bool isRecording = false;
  FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          isShowEmojiContainer = false;
        });
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<MessageReplyNotifier>(context, listen: false)
      //     .updateMessageReply("message", true, MessageEnum.text);
    });

    _soundRecorder = FlutterSoundRecorder();
    openAudio();
  }

  void openAudio() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw RecordingPermissionException('Mic permission not allowed!');
    }
    await _soundRecorder!.openRecorder();
    isRecorderInit = true;
  }

  void sendTextMessage() async {
    if (isShowSendButton) {
      if (_messageController.text.trim().isNotEmpty) {
        chat_service.sendTextMessage(
            text: _messageController.text.trim(),
            recieverUserId: widget.recieverUserId,
            isGroupChat: widget.isGroupChat,
            context: context,
            senderUser: context.read<auth_Provider>().user!,
            messageReply: context.read<MessageReplyNotifier>().messageReply);
      }

      setState(() {
        _messageController.text = '';
      });
    } else {
      var tempDir = await getTemporaryDirectory();
      var path = '${tempDir.path}/flutter_sound.aac';
      if (!isRecorderInit) {
        return;
      }
      if (isRecording) {
        await _soundRecorder!.stopRecorder();
        sendFileMessage(File(path), MessageEnum.audio);
      } else {
        await _soundRecorder!.startRecorder(
          toFile: path,
        );
      }

      setState(() {
        isRecording = !isRecording;
      });
    }
    Provider.of<MessageReplyNotifier>(context, listen: false)
        .clearMessageReply();
  }

  void sendFileMessage(
    File file,
    MessageEnum messageEnum,
  ) {
    chat_service.sendFileMessage(
      context: context,
      file: file,
      recieverUserId: widget.recieverUserId,
      isGroupChat: widget.isGroupChat,
      senderUserData: context.read<auth_Provider>().user!,
      messageEnum: messageEnum,
      messageReply: context.read<MessageReplyNotifier>().messageReply,
    );
  }

  void selectImage() async {
    File? image = await pickImageFromGallery(context);
    if (image != null) {
      sendFileMessage(image, MessageEnum.image);
    }
  }

  void selectVideo() async {
    File? video = await pickVideoFromGallery(context);
    if (video != null) {
      sendFileMessage(video, MessageEnum.video);
    }
  }

  // void selectGIF() async {
  //   final gif = await pickGIF(context);
  //   if (gif != null) {
  //     chat_service.sendGIFMessage(
  //       context: context,
  //       gifUrl: gif.url,
  //       recieverUserId: widget.recieverUserId,
  //       isGroupChat: widget.isGroupChat,
  //       senderUser: context.read<auth_Provider>().user!,
  //     );
  //   }
  // }

  void hideEmojiContainer() {
    setState(() {
      isShowEmojiContainer = false;
    });
  }

  void showEmojiContainer() {
    setState(() {
      isShowEmojiContainer = true;
    });
  }

  void showKeyboard() => focusNode.requestFocus();

  void hideKeyboard() => focusNode.unfocus();

  void toggleEmojiKeyboardContainer() {
    if (isShowEmojiContainer) {
      showKeyboard();
      hideEmojiContainer();
    } else {
      hideKeyboard();
      showEmojiContainer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _messageController.dispose();
    _soundRecorder!.closeRecorder();
    isRecorderInit = false;
  }

  Future<bool> _onWillPop() async {
    if (isShowEmojiContainer) {
      setState(() {
        isShowEmojiContainer = false;
      });
      return false; // Prevent the default back button behavior
    }
    return true; // Allow the default back button behavior
  }

  @override
  Widget build(BuildContext context) {
    // final messageReply =
    //     Provider.of<MessageReplyNotifier>(context).messageReply;
    // final isShowMessageReply = messageReply != null;
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      child: Column(
        children: [
          Consumer<MessageReplyNotifier>(
              builder: (context, MessageReplyNotifier, _) {
            if (MessageReplyNotifier.messageReply == null) {
              print("MessageReplyNotifier.messageReply is null");
              return const SizedBox();
            } else {
              return const MessageReplyPreview();
            }
          }),
          // isShowMessageReply ? const MessageReplyPreview() : const SizedBox(),
          Row(
            // crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 1,
                child: WillPopScope(
                  onWillPop: _onWillPop,
                  child: Container(
                    // width: 44,
                    // height: 48,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                        color: mobileChatBoxColor,
                        borderRadius: BorderRadius.all(Radius.circular(24.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            onPressed: toggleEmojiKeyboardContainer,
                            icon: Icon(
                              isShowEmojiContainer
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                              // Icons.emoji_emotions,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: TextFormField(
                            maxLines: 6,
                            minLines: 1,
                            focusNode: focusNode,
                            controller: _messageController,
                            onChanged: (val) {
                              if (val.isNotEmpty) {
                                setState(() {
                                  isShowSendButton = true;
                                });
                              } else {
                                setState(() {
                                  isShowSendButton = false;
                                });
                              }
                            },
                            decoration: const InputDecoration(
                              isDense: true,
                              filled: true,
                              fillColor: mobileChatBoxColor,
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              // prefixIcon: Padding(
                              //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              //   child: SizedBox(
                              //     width: 100,
                              //     child: Row(
                              //       children: [
                              //         IconButton(
                              //           onPressed: toggleEmojiKeyboardContainer,
                              //           icon: const Icon(
                              //             Icons.emoji_emotions,
                              //             color: Colors.grey,
                              //           ),
                              //         ),
                              //         // IconButton(
                              //         //   onPressed: selectGIF,
                              //         //   icon: const Icon(
                              //         //     Icons.gif,
                              //         //     color: Colors.grey,
                              //         //   ),
                              //         // ),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                              // suffixIcon: SizedBox(
                              //   width: 100,
                              //   child: Row(
                              //     mainAxisAlignment: MainAxisAlignment.end,
                              //     children: [
                              //       IconButton(
                              //         onPressed: selectImage,
                              //         icon: const Icon(
                              //           Icons.camera_alt,
                              //           color: Colors.grey,
                              //         ),
                              //       ),
                              //       IconButton(
                              //         onPressed: selectVideo,
                              //         icon: const Icon(
                              //           Icons.attach_file,
                              //           color: Colors.grey,
                              //         ),
                              //       ),
                              //     ],
                              //   ),
                              // ),
                              hintText: 'Type a message!',
                              // border: OutlineInputBorder(
                              //   borderRadius: BorderRadius.circular(20.0),
                              //   borderSide: const BorderSide(
                              //     width: 0,
                              //     style: BorderStyle.none,
                              //   ),
                              // ),

                              contentPadding: EdgeInsets.all(10),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                          ),
                        ),
                        SizedBox(
                          width: 44,
                          height: 44,
                          child: IconButton(
                            onPressed: () {
                              addBottomSheet(context);
                            },
                            icon: const Icon(
                              Icons.attach_file,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 8,
                  right: 2,
                  left: 2,
                ),
                child: CircleAvatar(
                  backgroundColor: const Color(0xFF128C7E),
                  radius: 22,
                  child: GestureDetector(
                    onTap: sendTextMessage,
                    child: Icon(
                      isShowSendButton
                          ? Icons.send
                          : isRecording
                              ? Icons.close
                              : Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Offstage(
            offstage: !isShowEmojiContainer,
            child: Container(
              margin: EdgeInsets.only(top: 4),
              child: EmojiPicker(
                onBackspacePressed: () {
                  if (isShowEmojiContainer) {
                    setState(() {
                      isShowEmojiContainer = false;
                    });
                    // return false; // Prevent the default back button behavior
                  }
                  // return true; //
                },
                onEmojiSelected: ((category, emoji) {
                  // setState(() {
                  //   _messageController.text =
                  //       _messageController.text + emoji.emoji;
                  // });

                  if (!isShowSendButton) {
                    setState(() {
                      isShowSendButton = true;
                    });
                  }
                }),
                textEditingController: _messageController,
                // scrollController: _scrollController,
                config: Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  // emojiTextStyle: _textStyle,
                  emojiViewConfig: EmojiViewConfig(
                    backgroundColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                  ),
                  swapCategoryAndBottomBar: true,
                  skinToneConfig: SkinToneConfig(),
                  categoryViewConfig: CategoryViewConfig(
                    backgroundColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                    dividerColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                    indicatorColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                    iconColorSelected: appStore.isDarkModeOn
                        ? Colors.white
                        : appBackgroundColorDark,
                    iconColor: secondaryColor,
                    // customCategoryView: (
                    //   config,
                    //   state,
                    //   tabController,
                    //   pageController,
                    // ) {
                    //   return WhatsAppCategoryView(
                    //     config,
                    //     state,
                    //     tabController,
                    //     pageController,
                    //   );
                    // },
                    // categoryIcons: const CategoryIcons(
                    //   recentIcon: Icons.access_time_outlined,
                    //   smileyIcon: Icons.emoji_emotions_outlined,
                    //   animalIcon: Icons.cruelty_free_outlined,
                    //   foodIcon: Icons.coffee_outlined,
                    //   activityIcon: Icons.sports_soccer_outlined,
                    //   travelIcon: Icons.directions_car_filled_outlined,
                    //   objectIcon: Icons.lightbulb_outline,
                    //   symbolIcon: Icons.emoji_symbols_outlined,
                    //   flagIcon: Icons.flag_outlined,
                    // ),
                  ),
                  bottomActionBarConfig: BottomActionBarConfig(
                    backgroundColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                    buttonColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                    buttonIconColor: secondaryColor,
                  ),
                  searchViewConfig: SearchViewConfig(
                    backgroundColor: appStore.isDarkModeOn
                        ? appBackgroundColorDark
                        : Colors.white70,
                    // customSearchView: (
                    //   config,
                    //   state,
                    //   showEmojiView,
                    // ) {
                    //   return WhatsAppSearchView(
                    //     config,
                    //     state,
                    //     showEmojiView,
                    //   );
                    // },
                  ),
                ),
              ),
            ),
          ),
          // isShowEmojiContainer
          //     ? SizedBox(
          //         height: 310,
          //         child: EmojiPicker(
          //           onEmojiSelected: ((category, emoji) {
          //             setState(() {
          //               _messageController.text =
          //                   _messageController.text + emoji.emoji;
          //             });
          //
          //             if (!isShowSendButton) {
          //               setState(() {
          //                 isShowSendButton = true;
          //               });
          //             }
          //           }),
          //         ),
          //       )
          //     : const SizedBox(),
        ],
      ),
    );
  }

  void addBottomSheet(context) {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        context: context,
        builder: (BuildContext buildContext) {
          return Container(
            margin: const EdgeInsets.only(bottom: 64, left: 16, right: 16),
            color: Colors.transparent,
            child: Container(
              decoration: const BoxDecoration(
                  color: mobileChatBoxColor,
                  borderRadius: BorderRadius.all(Radius.circular(16.0))),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  quickActionWidget(
                                    Icons.dashboard,
                                    'Document',
                                    onpressed: () {},
                                  ),
                                  quickActionWidget(
                                    Icons.music_note,
                                    'Audio',
                                    onpressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  quickActionWidget(Icons.camera_alt, 'Camera',
                                      onpressed: () => selectVideo()),
                                  quickActionWidget(
                                    Icons.location_on,
                                    'Location',
                                    onpressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  quickActionWidget(
                                    Icons.image,
                                    'Gallery',
                                    onpressed: selectImage,
                                  ),
                                  quickActionWidget(
                                    Icons.person,
                                    'Contact',
                                    onpressed: () {},
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget quickActionWidget(IconData iconData, String actionText,
      {required VoidCallback onpressed}) {
    return Container(
      margin: const EdgeInsets.only(top: 8, bottom: 8),
      child: Column(
        children: <Widget>[
          ClipOval(
            child: Material(
              color: btnColor, // button color
              child: InkWell(
                splashColor: Colors.white,
                // inkwell color
                child: SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(
                      iconData,
                      color: iconOnBtn,
                      size: 25,
                    )),
                onTap: () {
                  onpressed();
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(actionText),
          )
        ],
      ),
    );
  }
}
