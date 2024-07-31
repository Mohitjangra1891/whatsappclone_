import 'CGUserModel.dart';

class ChatModel {
  final User? sender;
  final String? text;
  final String? time;
  final String? avatarUrl;
  final String? date;
  final bool? video;
  final bool? call;
  final bool? callRecived;
  final bool? callConnect;
  final bool? unread;

  ChatModel(
      {this.sender,
      this.text,
      this.time,
      this.avatarUrl,
      this.date,
      this.video,
      this.call,
      this.callRecived,
      this.callConnect,
      this.unread});
}

// you - current user
final User currentUser = User(
    id: 0,
    name: 'Current User',
    avatarUrl: 'https://randomuser.me/api/portraits/men/86.jpg');

// USERS
final User greg = User(
    id: 1,
    name: 'Greg',
    avatarUrl: 'https://randomuser.me/api/portraits/men/96.jpg',
    isHide: false,
    isAddToGroup: false);
final User james = User(
    id: 2,
    name: 'James',
    avatarUrl: 'https://randomuser.me/api/portraits/men/95.jpg',
    isHide: false,
    isAddToGroup: false);
final User john = User(
    id: 3,
    name: 'John',
    avatarUrl: 'https://randomuser.me/api/portraits/women/55.jpg',
    isHide: false,
    isAddToGroup: false);
final User olivia = User(
    id: 4,
    name: 'Olivia',
    avatarUrl: 'https://randomuser.me/api/portraits/women/95.jpg',
    isHide: false,
    isAddToGroup: false);
final User sam = User(
    id: 5,
    name: 'Sam',
    avatarUrl: 'https://randomuser.me/api/portraits/women/86.jpg',
    isHide: false,
    isAddToGroup: false);
final User sophia = User(
    id: 6,
    name: 'Sophia',
    avatarUrl: 'https://randomuser.me/api/portraits/women/65.jpg',
    isHide: false,
    isAddToGroup: false);
final User steven = User(
    id: 7,
    name: 'Steven',
    avatarUrl: 'https://randomuser.me/api/portraits/men/98.jpg',
    isHide: false,
    isAddToGroup: false);

List<User> fav = [greg, james, john, olivia, sam, sophia, steven];

/* for payment method data */
class PaymentBank {
  final String? bankImage;
  final String? bankName;

  PaymentBank({this.bankImage, this.bankName});
}

class PaymentBankData {
  final PaymentBank? payBank;
  final String? nameofBank;

  PaymentBankData({this.nameofBank, this.payBank});
}
