import 'package:flutter/material.dart';

import '../model/CGChatModel.dart';
import 'CGConstant.dart';

List<ChatModel> chats = [
  ChatModel(
    sender: greg,
    text: 'When we are having Flutter Workshop',
    time: '15:30 PM',
    date: '20 January,',
    video: false,
    call: true,
    callRecived: true,
    callConnect: true,
    unread: true,
  ),
  ChatModel(
    sender: james,
    text: 'Good question - I am still trying to figure that out!',
    time: '16:34 AM',
    date: '20 January,',
    video: true,
    call: true,
    callRecived: false,
    callConnect: false,
    unread: true,
  ),
  ChatModel(
    sender: john,
    text: 'hi bro',
    time: '10:00 PM',
    date: '20 January,',
    video: false,
    call: true,
    callRecived: true,
    callConnect: false,
    unread: true,
  ),
  ChatModel(
    sender: olivia,
    text: 'when we are meeting?',
    time: '15:30 PM',
    date: '20 January,',
    video: true,
    call: true,
    callRecived: false,
    callConnect: true,
    unread: false,
  ),
  ChatModel(
    sender: sam,
    text: 'when we are having Flutter Workshop',
    time: '15:30 PM',
    date: '20 January,',
    video: false,
    call: true,
    callRecived: true,
    callConnect: true,
    unread: false,
  ),
  ChatModel(
    sender: sophia,
    text: 'when we are having Flutter Workshop',
    time: '15:30 PM',
    date: '20 January,',
    video: false,
    call: true,
    callRecived: false,
    callConnect: false,
    unread: false,
  ),
  ChatModel(
    sender: steven,
    text: 'when we are having Flutter Workshop',
    time: '15:30 PM',
    date: '20 January,',
    video: true,
    call: true,
    callRecived: true,
    callConnect: false,
    unread: false,
  ),
];

//Example for messages conversation
List<ChatModel> message = [
  ChatModel(
    sender: james,
    text: 'I hope we will meet soon',
    time: '1:35 PM',
    date: '20 January,',
    video: true,
    callRecived: true,
    callConnect: false,
    unread: false,
  ),
  ChatModel(
    sender: currentUser,
    text: 'I will be happy to teach you',
    time: '1:30 PM',
    date: '20 January,',
    video: false,
    callRecived: false,
    callConnect: false,
    unread: false,
  ),
  ChatModel(
    sender: james,
    text: 'okay, we love to develop more apps',
    time: '1:25 PM',
    date: '20 January,',
    video: false,
    callRecived: true,
    callConnect: true,
    unread: false,
  ),
  ChatModel(
    sender: currentUser,
    text: 'That\'s nice but its completly depends on your feadback?',
    time: '1:15 PM',
    date: '20 January,',
    video: true,
    callRecived: false,
    callConnect: true,
    unread: false,
  ),
  ChatModel(
    sender: james,
    text: 'But we want more workshop',
    time: '1:10 PM',
    date: '20 January,',
    video: false,
    callRecived: true,
    callConnect: false,
    unread: true,
  ),
  ChatModel(
    sender: currentUser,
    text: 'Good question - I am still trying to figure it out!',
    time: '1:05 PM',
    date: '20 January,',
    video: true,
    callRecived: false,
    callConnect: false,
    unread: true,
  ),
  ChatModel(
    sender: james,
    text: 'when we are having next Flutter Workshop',
    time: '1:00 PM',
    date: '20 January,',
    video: false,
    callRecived: true,
    callConnect: true,
    unread: true,
  ),
];

//popup menu item list
List<PopupMenuItem> chatpopupItem = [
  PopupMenuItem(value: 1, child: Text('New group')),
  PopupMenuItem(value: 2, child: Text('New Broadcast')),
  PopupMenuItem(value: 3, child: Text('$CGAppName Web')),
  PopupMenuItem(value: 4, child: Text('Starred messages')),
  PopupMenuItem(value: 6, child: Text("Payment")),
  PopupMenuItem(value: 5, child: Text('Settings'))
];

List<PopupMenuItem> statuspopupItem = [
  PopupMenuItem(value: 1, child: Text('Status privacy')),
  PopupMenuItem(value: 5, child: Text('Settings'))
];
List<PopupMenuItem> callpopupItem = [
  PopupMenuItem(value: 1, child: Text('Clear call log')),
  PopupMenuItem(value: 5, child: Text('Settings'))
];

//popup menu for message screen
final List<PopupMenuEntry> menuEntry = [
  PopupMenuItem(value: 1, child: Text("View contact")),
  PopupMenuItem(value: 2, child: Text("Media, Link, and docs")),
  PopupMenuItem(value: 3, child: Text("Mute notification")),
  PopupMenuItem(value: 4, child: Text("Wallpaper")),
  PopupMenuItem(value: 5, child: Text("Clear chat"))
];

//wallpaper list
final List<String> wallpaperImage = [
  "images/whatsApp/chatbackground.jpg",
  "images/whatsApp/Whatsapp-Wallpaper-1.jpg",
  "images/whatsApp/Whatsapp-Wallpaper-2.jpg",
  "images/whatsApp/Whatsapp-Wallpaper-3.jpg",
  "images/whatsApp/Whatsapp-Wallpaper-4.jpg",
  "images/whatsApp/Whatsapp-Wallpaper-5.jpg",
  "images/whatsApp/Whatsapp-Wallpaper-6.jpg"
];

/* bank details model */

final PaymentBank axis = PaymentBank(
    bankImage:
        "https://www.searchpng.com/wp-content/uploads/2019/01/Axis-Bank-PNG-Logo-.png",
    bankName: "Axis Bank Ltd.");
final PaymentBank hdfc = PaymentBank(
    bankImage:
        "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQEH_yewBcePPAjqbDeHh6Xy2yfs7xNKTA26w&usqp=CAU",
    bankName: "HDFC BANK LTD");
final PaymentBank icici = PaymentBank(
    bankImage:
        "https://www.searchpng.com/wp-content/uploads/2019/01/ICICI-Bank-PNG-Icon.png",
    bankName: "ICICI Bank");
final PaymentBank sbi = PaymentBank(
    bankImage:
        "https://upload.wikimedia.org/wikipedia/commons/thumb/c/cc/SBI-logo.svg/1200px-SBI-logo.svg.png",
    bankName: "State Bank Of India");
final PaymentBank allahabad = PaymentBank(
    bankImage: "https://www.credenc.com/images/logo/bank/allahabad_bank.png",
    bankName: "Allahabad Bank");
final PaymentBank bob = PaymentBank(
    bankImage:
        "https://www.searchpng.com/wp-content/uploads/2019/01/Bank-of-baroa-PNG-Icon.png",
    bankName: "Bank of Baroda");
final PaymentBank boi = PaymentBank(
    bankImage:
        "https://www.thebusinessquiz.com/wp-content/uploads/2014/11/Bank-of-India-logo.png",
    bankName: "Bank of India");
final PaymentBank citi = PaymentBank(
    bankImage:
        "https://dwglogo.com/wp-content/uploads/2019/02/Citigroup_logo.png",
    bankName: "CITI Bank");
final PaymentBank yes = PaymentBank(
    bankImage:
        "https://mk0bfsieletsonlt96u6.kinstacdn.com/wp-content/uploads/2017/01/yes-bank-newsletter.png",
    bankName: "Yes Bank Ltd");
final PaymentBank union = PaymentBank(
    bankImage:
        "https://play-lh.googleusercontent.com/MRPhEwsB_jrIvKWI5j6wVKoVdRx20Rww-T8dC2Ws_IHZ4DA8MCYW80Z3C8idot2xug",
    bankName: "Union Bank od india");

List<PaymentBank> banklist = [
  axis,
  hdfc,
  icici,
  sbi,
  allahabad,
  bob,
  boi,
  citi,
  yes,
  union
];

/* bank data */
List<PaymentBank> payBankData = [axis];

/* profile scree horizontal image */
final List<String> docimg = [
  'https://randomuser.me/api/portraits/men/96.jpg',
  'https://randomuser.me/api/portraits/men/95.jpg',
  'https://randomuser.me/api/portraits/women/55.jpg',
  'https://randomuser.me/api/portraits/women/95.jpg',
  'https://randomuser.me/api/portraits/women/86.jpg',
  'https://randomuser.me/api/portraits/women/65.jpg',
  'https://randomuser.me/api/portraits/men/98.jpg'
];
