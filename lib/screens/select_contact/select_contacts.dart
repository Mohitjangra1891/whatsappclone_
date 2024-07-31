import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/providers/contact_provider.dart';
import 'package:whatsappclone/utils/CGImages.dart';
import 'package:flutter/services.dart';
import '../../model/CGUserModel.dart';
import '../../utils/CGConstant.dart';
import '../chat/message_screen.dart';

void selectContact(Contact selectedContact, BuildContext context) async {
  try {
    var userCollection = await firestore.collection('users').get();
    bool isFound = false;

    // Function to extract the last 10 digits of a phone number
    String extractLast10Digits(String phoneNumber) {
      phoneNumber = phoneNumber.replaceAll(RegExp(r'\s+|-'), '');
      if (phoneNumber.length > 10) {
        return phoneNumber.substring(phoneNumber.length - 10);
      }
      return phoneNumber;
    }

    String selectedPhoneNum = extractLast10Digits(selectedContact.phones[0].number);
    print('conatct number$selectedPhoneNum  --');

    for (var document in userCollection.docs) {
      var userData = UserModel.fromMap(document.data());
      // String selectedPhoneNum = selectedContact.phones[0].number.replaceAll(
      //   ' ',
      //   '',
      // );

      String storedPhoneNum = extractLast10Digits(userData.phoneNumber);
      print("stpred numbers$storedPhoneNum");

      if (selectedPhoneNum == storedPhoneNum) {
        isFound = true;

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return message_screen(
            name: userData.name,
            uid: userData.uid,
            isGroupChat: false,
            profilePic: userData.profilePic,
          );
        }));
        break;
      }
    }

    if (!isFound) {
      snackBar(
        context,
        title: 'This number does not exist on this app.',
      );
    }
  } catch (e) {
    snackBar(context, title: e.toString());
  }
}

class selectContactsScreen extends StatefulWidget {
  static const String routeName = '/select-contact';

  const selectContactsScreen({Key? key}) : super(key: key);

  @override
  State<selectContactsScreen> createState() => _SelectContactsScreenState();
}

class _SelectContactsScreenState extends State<selectContactsScreen> {
  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if (context.read<contact_provider>().contacts.isEmpty) {
      context.read<contact_provider>().getContacts();
      // }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final contactProvider = Provider.of<contact_provider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select contact',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${contactProvider.contacts.length} contacts',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: SearchContact(contactProvider.contacts),
              );
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
            ),
          ),
        ],
      ),
      body: contactProvider.contacts.isEmpty
          ? const Center(
              child: Text(
                "",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: contactProvider.contacts.length,
              itemBuilder: (context, index) {
                final contact = contactProvider.contacts[index];
                return InkWell(
                  onTap: () => selectContact(contact, context),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ListTile(
                      title: Text(
                        contact.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      leading: contact.photo == null
                          ? CircleAvatar(
                              backgroundImage: AssetImage(
                                placeholder_profile,
                              ),
                              radius: 23,
                            )
                          : CircleAvatar(
                              backgroundImage: MemoryImage(contact.photo!),
                              radius: 23,
                            ),
                    ),
                  ),
                );
              }),
    );
  }
}

class SearchContact extends SearchDelegate<Contact?> {
  final List<Contact> contacts;

  SearchContact(this.contacts);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final contact = results[index];
        return InkWell(
          onTap: () => selectContact(contact, context),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(
                contact.displayName,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              leading: contact.photo == null
                  ? CircleAvatar(
                      backgroundImage: AssetImage(
                        placeholder_profile,
                      ),
                      radius: 23,
                    )
                  : CircleAvatar(
                      backgroundImage: MemoryImage(contact.photo!),
                      radius: 23,
                    ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = contacts.where((contact) {
      return contact.displayName.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final contact = suggestions[index];
        return InkWell(
          onTap: () => selectContact(contact, context),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(
                contact.displayName,
                style: const TextStyle(
                  fontSize: 18,
                ),
              ),
              leading: contact.photo == null
                  ? CircleAvatar(
                      backgroundImage: AssetImage(
                        placeholder_profile,
                      ),
                      radius: 23,
                    )
                  : CircleAvatar(
                      backgroundImage: MemoryImage(contact.photo!),
                      radius: 23,
                    ),
            ),
          ),
        );
      },
    );
  }
}
