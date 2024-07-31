import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';
import 'package:whatsappclone/controller/services/firebase_service.dart';
import 'package:whatsappclone/utils/CGConstant.dart';

import '../../controller/providers/auth_Provider.dart';
import '../../utils/common_Widgets.dart';

class create_profile_screen extends StatefulWidget {
  const create_profile_screen({super.key});

  @override
  State<create_profile_screen> createState() => _login_screenState();
}

class _login_screenState extends State<create_profile_screen> {
  final TextEditingController nameController = TextEditingController();
  File? image;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<auth_Provider>().fetchUserData(auth.currentUser!.uid);
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    addname();

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    image = await pickImageFromGallery(context);
    setState(() {});
  }

  void addname() async {
    setState(() {
      nameController.text = context.read<auth_Provider>().user_name;
    });
  }

  void storeUserData() async {
    if (nameController.text.isEmpty) {
      snackBar(context, title: "Please enter your name");
      return;
    }
    context.read<auth_Provider>().change_isloading(true);

    await firebase_service.saveUserDataToFirebase(
        name: nameController.text, profilePic: image, context: context);
    context.read<auth_Provider>().change_isloading(false);

    // setState(() {
    //   loading = true;
    // });
    // await ref.read(userRepositoryProvider).create(
    //       name: nameController.text,
    //       avatar: profilePic,
    //       onError: (error) => showSnackbar(context, error),
    //       onSuccess: () => {
    //         Navigator.pushNamedAndRemoveUntil(
    //             context, PageRouter.home, (route) => false),
    //       },
    //     );
    // if (mounted) {
    // setState(() {
    //   loading = false;
    // });
    // }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Create Profile",
        ),
        centerTitle: false,
        elevation: 8,
        shadowColor: Colors.black,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              40.height,
              Stack(
                children: [
                  image == null
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(context
                                  .read<auth_Provider>()
                                  .user_profileImage ??
                              'https://png.pngitem.com/pimgs/s/649-6490124_katie-notopoulos-katienotopoulos-i-write-about-tech-round.png'),
                          radius: 64,
                        )
                      : CircleAvatar(
                          backgroundImage: FileImage(
                            image!,
                          ),
                          radius: 74,
                        ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(
                        Icons.add_a_photo,
                      ),
                    ),
                  ),
                ],
              ),
              8.height,
              Row(
                children: [
                  Container(
                    width: size.width * 0.85,
                    padding: const EdgeInsets.all(20),
                    child: TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your name',
                      ),
                    ),
                  ),
                  context.watch<auth_Provider>().isloading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : IconButton(
                          onPressed: storeUserData,
                          icon: const Icon(
                            Icons.done,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
