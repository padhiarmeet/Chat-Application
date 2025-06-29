import 'dart:ui';

import 'package:chat_application/data/repositries/auth_repository.dart';
import 'package:chat_application/data/repositries/contact_repository.dart';
import 'package:chat_application/data/services/service_locator.dart';
import 'package:chat_application/logic/cubits/auth/auth_cubit.dart';
import 'package:chat_application/prasantation/chat/chat_message_screen.dart';
import 'package:chat_application/prasantation/screens/auth/login_screen.dart';
import 'package:chat_application/prasantation/widgets/chat_list_tile.dart';
import 'package:chat_application/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../data/repositries/chat_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ContactRepository _contactRepository;
  late final ChatRepository _chatRepository;
  late final String _currentUserId;

  @override
  void initState() {
    _contactRepository = getIt<ContactRepository>();
    _chatRepository = getIt<ChatRepository>();
    _currentUserId = getIt<AuthRepository>().currentUser?.uid ?? '';
    super.initState();
  }

  //some extra logout button


  void _showContactList(BuildContext context) {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17),side: BorderSide(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),style: BorderStyle.solid,width: 1.5),),
      enableDrag: true,
      barrierColor: Theme.of(context).colorScheme.surface.withOpacity(0.7),
      backgroundColor: Theme.of(context).colorScheme.surface,
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Contacts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),thickness: 1.5,),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _contactRepository.getRegisterContacts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData) {
                      return Skeletonizer(
                        containersColor: Colors.black12,
                        effect: ShimmerEffect(baseColor: Colors.black12),
                        textBoneBorderRadius: TextBoneBorderRadius(
                            BorderRadius.all(Radius.circular(12))),
                        enabled: true,
                        child: ListView.builder(
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.2),
                                ),
                                title: Text('__________________________') // Placeholder for title
                                );
                          },
                        ),
                      );
                    }
                    final contacts = snapshot.data!;
                    if (contacts.isEmpty) {
                      return const Center(
                        child: Text(
                            'No contact found in Application (no one has Registered😿)'),
                      );
                    }
                    return ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                Theme.of(context).primaryColor.withOpacity(0.2),
                            backgroundImage: contact['photo'] != null
                                ? MemoryImage(contact['photo']!)
                                : null,
                            child: contact['photo'] == null
                                ? Text(contact['name'][0].toUpperCase())
                                : null,
                          ),
                          title: Text(contact['name']),
                          onTap: () {
                            getIt<AppRouter>().push(ChatMessageScreen(
                                receiverId: contact['id'],
                                receiverName: contact['name']));
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: Theme.of(context).primaryColor,
      //   title: Text('ChatApp',style: TextStyle(color:Theme.of(context).colorScheme.onSurface,),),
      //   actions: [
      //     IconButton(
      //       icon: Icon(
      //         Icons.logout_rounded,
      //         // color: Theme.of(context)
      //         //     .primaryColor
      //         //     .withOpacity(0.5), // Adjust color to match your app's theme
      //         color: Color(0xffFFFECE),
      //         size: 28, // Slightly larger icon
      //       ),
      //       onPressed: () async {
      //         await getIt<AuthCubit>().signOut();
      //         getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
      //       },
      //       splashRadius: 24,
      //       tooltip: 'Logout', // Accessibility feature
      //     ),
      //   ],
      // ),




        // appBar: AppBar(
        //   backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
        //   elevation: 0,
        //   title: Text(
        //     'ChatApp',
        //     style: TextStyle(
        //       color: Theme.of(context).colorScheme.onSurface,
        //       fontWeight: FontWeight.bold,
        //       fontSize: 20,
        //       letterSpacing: 0.5,
        //     ),
        //   ),
        //   actions: [
        //     Container(
        //       margin: EdgeInsets.only(right: 16),
        //       decoration: BoxDecoration(
        //         color: Colors.white.withOpacity(0.1),
        //         borderRadius: BorderRadius.circular(20),
        //       ),
        //       child: IconButton(
        //         icon: Icon(
        //           Icons.logout_rounded,
        //           color: Color(0xffFFFECE),
        //           size: 28,
        //         ),
        //         onPressed: () async {
        //           await getIt<AuthCubit>().signOut();
        //           getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
        //         },
        //         splashRadius: 24,
        //         tooltip: 'Logout',
        //       ),
        //     ),
        //   ],
        // ),
      appBar: AppBar(
        backgroundColor:
        Colors.transparent.withOpacity(0.5) ??
            Theme.of(context).primaryColor.withOpacity(0.7),
        elevation: 0,
        titleSpacing: 0,
        flexibleSpace: Stack(
          children: [
            // First layer: Colored background that will be blurred
            Container(
              color: Colors.transparent.withOpacity(0.6), // Or any color you want blurred
            ),

            // Second layer: Blur effect on the background
            ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 30),
                child: Container(color: Colors.black.withOpacity(0.2)),
              ),
            ),

            // Third layer: Doodle with transparent background
          ],
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text( 'ChatApp',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 0.5,
        ),),
        ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.logout_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () async {
                  await getIt<AuthCubit>().signOut();
                  getIt<AppRouter>().pushAndRemoveUntil(LoginScreen());
                },
                splashRadius: 24,
                tooltip: 'Logout',
              ),
            ),
          ],
      ),
      body: Container(
        color: Colors.black,
        child: StreamBuilder(
            stream: _chatRepository.getChatRooms(_currentUserId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('error :${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                ///TODO:also for displaying loading screen
                return Center(child: CircularProgressIndicator());
              }
              final chats = snapshot.data!;
              if (chats.isEmpty) {
                return Center(
                  child: Text('No recent Chats'),
                );
              }
              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ChatListTile(
                      chat: chat,
                      currentUserId: _currentUserId,
                      ontap: () {
                        final otherUserId = chat.participants.firstWhere((id) => id != _currentUserId);
                        final otherUserName = chat.participantsName![otherUserId] ??'Unknown';
                        getIt<AppRouter>().push(ChatMessageScreen(receiverId:otherUserId , receiverName: otherUserName));
                      });
                },
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showContactList(context),
        child: Icon(
          Icons.chat,
          color: Colors.white,
        ),
        elevation: 0,
      ),
    );
  }
}
