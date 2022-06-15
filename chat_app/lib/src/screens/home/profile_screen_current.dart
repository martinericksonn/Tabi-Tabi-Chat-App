// ignore_for_file: prefer_const_constructors

import 'package:chat_app/src/controllers/auth_controller.dart';
import 'package:chat_app/src/models/chat_user_model.dart';
import 'package:chat_app/src/screens/home/blocked_user_screen.dart';
import 'package:chat_app/src/screens/home/edit_profile_screen.dart';

import 'package:chat_app/src/service_locators.dart';
import 'package:chat_app/src/services/image_service.dart';
import 'package:chat_app/src/settings/settings_controller.dart';
import 'package:chat_app/src/widgets/avatar.dart';
import 'package:chat_app/src/widgets/profile_card.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../controllers/geolocation_controller.dart';
import '../../controllers/user_settings_controller.dart';

// ignore: must_be_immutable
class ProfileScreen extends StatefulWidget {
  ProfileScreen(
      {Key? key, required this.settingsController, required this.geoCon})
      : super(key: key);
  SettingsController settingsController;
  GeolocationController geoCon;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SettingsController get settingsController => widget.settingsController;
  GeolocationController get geoCon => widget.geoCon;

  final UserSettingsController userSC = UserSettingsController();
  final AuthController _auth = locator<AuthController>();

  ChatUser? user;

  @override
  void initState() {
    ChatUser.fromUid(uid: _auth.currentUser!.uid).then((value) {
      if (mounted) {
        setState(() {
          user = value;
        });
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              profilePic(context),
              userName(context),
              emailCard(),
              ageCard(),
              genderCard(),
              dateJoinedCard(),
              ListTile(
                title: Text(
                  "Settings",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              themeChange(context),
              accountPrivacyChange(context),
              // locationChange(context),
              ListTile(
                onTap: () => {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => BlockedUserScreen(
                        blockeduser: user!.blocklist,
                      ),
                    ),
                  )
                },
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.block_outlined),
                ),
                title: Text(
                  "Blocked User",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ListTile(
                onTap: () => {geoCon.dispose(), _auth.logout()},
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  child: Icon(Icons.login_rounded),
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w500,
                    // color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListTile themeChange(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).colorScheme.primary,
        child: Icon(Icons.dark_mode_rounded),
      ),
      title: Text("Theme"),
      trailing: DropdownButton<ThemeMode>(
        elevation: 1,
        underline: SizedBox(),
        value: settingsController.themeMode,
        onChanged: settingsController.updateThemeMode,
        items: const [
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Text(
              'System Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Text(
              'Light Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Text(
              'Dark Theme',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        ],
      ),
    );
  }

  // ListTile locationChange(BuildContext context) {
  //   return ListTile(
  //     leading: CircleAvatar(
  //       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
  //       foregroundColor: Theme.of(context).colorScheme.primary,
  //       child: Icon(Icons.location_on_rounded),
  //     ),
  //     title: Text("Location"),
  //     trailing: DropdownButton<String>(
  //       elevation: 1,

  //       underline: SizedBox(),
  //       // Read the selected themeMode from the controller
  //       value: settingsController.themeMode,
  //       // Call the updateThemeMode method any time the user selects a theme.
  //       onChanged: settingsController.updateThemeMode,
  //       items: const [
  //         DropdownMenuItem(
  //           value: ThemeMode.system,
  //           child: Text(
  //             'Disabled',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //         DropdownMenuItem(
  //           value: ThemeMode.light,
  //           child: Text(
  //             'Enabled',
  //             style: TextStyle(
  //               fontSize: 16,
  //               fontWeight: FontWeight.w500,
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  void dropDownCallBack(String? value) {
    setState(() {
      print("dropDownCallBack " + value.toString());
      UserSettingsController.togglePrivate(value == "Private" ? true : false);
    });
    // print("insideeeeeeee"); // print(value ?? 'test');
  }

  Widget accountPrivacyChange(BuildContext context) {
    // return FutureBuilder(
    //     future: FirebaseFirestore.instance
    //         .collection('users')
    //         .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
    //         .get(),
    //     builder: ((context, snapshot) {
    //       print(FirebaseAuth.instance.currentUser!.uid);
    //       if (!snapshot.hasData) return CircularProgressIndicator();
    //       return SizedBox(
    //         child: Column(
    //           children: [
    //           for (var doc in snapshot.data!.docs)

    //           ],

    //           snapshot.data!),
    //       );
    //     }));

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .snapshots(),
        builder:
            (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snap) {
          //  var user = snap.data!.docs[0];
          if (!snap.hasData) {
            return CircularProgressIndicator();
          }
          for (var doc in snap.data!.docs) {
            print("Account: " + doc["isPrivate"].toString());
            return ListTile(
              // textColor: Colors.red,
              title: Text(
                "Account Type",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                foregroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(Icons.shield_rounded),
              ),
              trailing: DropdownButton<String>(
                dropdownColor: Theme.of(context).colorScheme.tertiary,
                elevation: 1,
                underline: SizedBox(),

                // Read the selected themeMode from the controller
                value: doc['isPrivate'] ? "Private" : "Public",
                // Call the updateThemeMode method any time the user selects a theme.
                onChanged: dropDownCallBack,

                // ignore: prefer_const_literals_to_create_immutables
                items: [
                  DropdownMenuItem(
                    value: "Public",
                    child: Text(
                      'Public',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  DropdownMenuItem(
                    value: "Private",
                    child: Text(
                      'Private',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          return SizedBox();
        });
  }

  ProfileCard dateJoinedCard() {
    return ProfileCard(
        icon: Icons.date_range,
        title: 'Date Joined',
        subtitle:
            '...'); //DateFormat("MMMM dd, yyyy").format(user!.created.toDate()));
  }

  ProfileCard emailCard() {
    return ProfileCard(
        icon: Icons.email, title: 'Email', subtitle: user?.email ?? '...');
  }

  ProfileCard ageCard() {
    return ProfileCard(
        icon: Icons.calendar_month, title: 'Age', subtitle: user?.age ?? '...');
  }

  ProfileCard genderCard() {
    return ProfileCard(
        icon: Icons.animation,
        title: 'Gender',
        subtitle: user?.gender ?? '...');
  }

  Padding userName(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        user?.username ?? '...',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }

  Padding profilePic(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Stack(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: AvatarImage(uid: FirebaseAuth.instance.currentUser!.uid),
          ),
          Positioned(
            right: 15,
            bottom: 0,
            child: InkWell(
              onTap: () {
                ImageService.updateProfileImage();
              },
              child: CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  Icons.camera_alt,
                  size: 30,
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar appBar() {
    return AppBar(
      elevation: 0,
      centerTitle: true,
      title: Text(
        "Profile",
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditProfile(),
              ),
            );
          },
          icon: const Icon(Icons.edit),
          color: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}