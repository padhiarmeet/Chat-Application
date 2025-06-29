import 'dart:ui';

import 'package:chat_application/data/services/service_locator.dart';
import 'package:chat_application/logic/cubits/chat/chat_cubit.dart';
import 'package:chat_application/logic/cubits/chat/chat_state.dart';
import 'package:chat_application/prasantation/widgets/loading)dots.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:popover/popover.dart';

import '../../data/models/chat_message.dart';

class ChatMessageScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  const ChatMessageScreen(
      {super.key, required this.receiverId, required this.receiverName});

  @override
  State<ChatMessageScreen> createState() => _ChatMessageScreenState();
}

class _ChatMessageScreenState extends State<ChatMessageScreen> {
  final TextEditingController messageController = TextEditingController();
  late final ChatCubit _chatCubit;

  bool _isComposing = false;

  @override
  void initState() {
    _chatCubit = getIt<ChatCubit>();
    _chatCubit.enterChat(widget.receiverId);
    messageController.addListener(_onTextChange);
    super.initState();
  }


  Future<void> _handleSendMessage() async {
    final messageText = messageController.text.trim();
    messageController.clear();

    if(messageText !=''){
      await _chatCubit.sendMessage(
          content: messageText, receiverId: widget.receiverId);
    }
  }


  void _onTextChange(){
    final isComposing = messageController.text.isNotEmpty;
    if(isComposing != _isComposing){
      setState(() {
        _isComposing = isComposing;
      });
      if(isComposing){
        _chatCubit.startTyping();
      }
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    messageController.dispose();
    _chatCubit.leaveChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ChatCubit, ChatState>(
          bloc: _chatCubit,
          builder: (context, state) {
            return Container(
              decoration:
                  BoxDecoration(image: DecorationImage(image: NetworkImage('https://i.pinimg.com/736x/b0/72/03/b0720367a0c7d142ea9d0b92c138042b.jpg'),fit: BoxFit.cover,),),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      physics: BouncingScrollPhysics(decelerationRate: ScrollDecelerationRate.normal,),
                      reverse: true,
                      itemCount: state.messages.length,
                      itemBuilder: (context, index) {
                        final message = state.messages[index];
                        final isMe =
                            message.senderId == _chatCubit.currentUserId;

                        if (state.status == ChatStatus.loading) {
                          ///TODO: to display loading in message screen
                          return Center(
                              child: const CircularProgressIndicator());
                        }
                        if (state.status == ChatStatus.error) {
                          Center(
                            child: Text(state.error ?? 'something went wrong'),
                          );
                        }
                        return MessageBubble(message: message, isMe: isMe);
                      },
                    ),
                  ),

                  // Parent container with transparency and blur
                  Container(
                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(28),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            // borderRadius: BorderRadius.circular(28),
                          ),
                          // Solid inner container
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8.0, vertical: 4.0),
                            child: Row(
                              children: [
                                // Emoji button
                                IconButton(
                                  onPressed: () {},
                                  icon: Icon(
                                    Icons.emoji_emotions_outlined,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  splashRadius: 20,
                                ),

                                const SizedBox(width: 2),

                                // Text field
                                Expanded(
                                  child: TextField(
                                    controller: messageController,
                                    keyboardType: TextInputType.multiline,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    maxLines: null,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Type a message...',
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).hintColor,
                                      ),
                                      filled: false,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 10,
                                      ),
                                      border: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                    ),
                                  ),
                                ),

                                const SizedBox(width: 8),

                                // Send button
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(22),
                                      onTap: _handleSendMessage,
                                      child: Center(
                                        child: Icon(
                                          Icons.send_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
      appBar: AppBar(
        backgroundColor: Colors.transparent.withOpacity(0.5) ??
            Theme.of(context).primaryColor.withOpacity(0.7),
        elevation: 0,
        titleSpacing: 0,
        flexibleSpace: Stack(
          children: [
            // First layer: Colored background that will be blurred
            Container(
              color: Colors.transparent
                  .withOpacity(0.6), // Or any color you want blurred
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
          child: Row(
            children: [
              // Modern avatar with gradient background
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withBlue(
                          (Theme.of(context).primaryColor.blue + 40)
                              .clamp(0, 255)),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Center(
                  child: Text(
                    widget.receiverName[0].toUpperCase(),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12),

              // User info with improved typography
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 155,
                    child: Text(
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      widget.receiverName,
                      softWrap: false,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                        color: Colors.white
                      ),
                    ),
                  ),
                  BlocBuilder<ChatCubit, ChatState>(
                    bloc: _chatCubit,
                    builder: (context, state) {
                      if (state.isReceiverTyping) {
                        return Row(
                          children: [
                            LoadingDots(),
                            Text(
                              'typing',
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.primary),
                            )
                          ],
                        );
                      }
                      if (state.isReceiverOnline) {
                        return Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Online',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      }
                      if (state.receiverLastSeen != null) {
                        final lastSeen = state.receiverLastSeen!.toDate();
                        return Text(
                          'Last seen at ${DateFormat('h:mm a').format(lastSeen)}',
                          style: TextStyle(color: Colors.grey[500],fontSize: 12,fontWeight: FontWeight.w400),
                        );
                      }
                      return SizedBox();
                    },
                  )
                ],
              ),
            ],
          ),
        ),
        actions: [
          // Modern menu button with container
          Container(
            margin: EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.transparent.withOpacity(0.1)
                  : Colors.black.withOpacity(0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(Icons.more_vert_rounded,color: Colors.white,),
              onPressed: () {},
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  // final bool showTime;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    // required this.showTime
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onLongPress: () {
      onLongPress: () {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: const Text("Delete this message?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                // Ensure you have the correct chatRoomId and messageId
                final chatRoomId =message.senderId.hashCode <= message.receiverId.hashCode
                    ? '$message.senderId-$message.receiverId'
                    : '$message.senderId-$message.receiverId';
                final messageId = message.id;

                // Delete the message from Firebase
                await FirebaseFirestore.instance
                    .collection('chatRoom')
                    .doc(chatRoomId)
                    .collection('messages')
                    .doc(messageId)
                    .delete();

                print("Message deleted successfully");
              } catch (e) {
                print("Error deleting message: $e");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      );
    },
  );
};
    },
      // child: Align(
      //   alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      //   child: Container(
      //     padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //     decoration: BoxDecoration(
      //       color: isMe
      //           ? Theme.of(context).colorScheme.primary.withOpacity(0.95)
      //           : Theme.of(context).colorScheme.secondary.withOpacity(1),
      //       borderRadius: isMe
      //           ? BorderRadius.only(
      //               bottomRight: Radius.circular(3),
      //               topRight: Radius.circular(16),
      //               topLeft: Radius.circular(16),
      //               bottomLeft: Radius.circular(16))
      //           : BorderRadius.only(
      //               bottomRight: Radius.circular(16),
      //               topRight: Radius.circular(16),
      //               topLeft: Radius.circular(3),
      //               bottomLeft: Radius.circular(16)),
      //     ),
      //     margin: EdgeInsets.only(
      //         left: isMe ? 64 : 8, right: isMe ? 8 : 64, bottom: 4),
      //     child: Column(
      //       crossAxisAlignment:
      //           isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      //       children: [
      //         Text(
      //           message.content,
      //           style: TextStyle(color: isMe ? Colors.white : Colors.black),
      //         ),
      //         SizedBox(
      //           height: 5,
      //         ),
      //         Row(
      //           mainAxisSize: MainAxisSize.min,
      //           children: [
      //             Text(
      //               DateFormat('h:mm a').format(message.timestamp.toDate()),
      //               style: TextStyle(
      //                   color: isMe ? Colors.white : Colors.black, fontSize: 12),
      //             ),
      //             SizedBox(
      //               width: 5,
      //             ),
      //             if (isMe)
      //               Icon(
      //                 Icons.done_all_rounded,
      //                 color: message.status == MessageStatus.read
      //                     ? Colors.black.withOpacity(0.6)
      //                     : Colors.white,
      //                 size: 17,
      //               )
      //           ],
      //         )
      //       ],
      //     ),
      //   ),
      // ),
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: EdgeInsets.only(
              left: isMe ? 64 : 8, right: isMe ? 8 : 64, bottom: 4),
          padding: EdgeInsets.all(1), // Space for gradient border
          decoration: BoxDecoration(
            borderRadius: isMe
                ? BorderRadius.only(
                bottomRight: Radius.circular(3),
                topRight: Radius.circular(16),
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16))
                : BorderRadius.only(
                bottomRight: Radius.circular(16),
                topRight: Radius.circular(16),
                topLeft: Radius.circular(3),
                bottomLeft: Radius.circular(16)),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color:isMe?Color(0xFF5BBCFF).withOpacity(0.9):Color(0xFF8576FF),//------------------Chat bubble color
              borderRadius: isMe
                  ? BorderRadius.only(
                  bottomRight: Radius.circular(3),
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16))
                  : BorderRadius.only(
                  bottomRight: Radius.circular(16),
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(16)),
            ),
            child: Column(
              crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.content,
                  style: isMe?TextStyle(color: Colors.white):TextStyle(color: Colors.white),
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('h:mm a').format(message.timestamp.toDate()),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    SizedBox(width: 5),
                    if (isMe)
                      Icon(
                        Icons.done_all_rounded,
                        color: message.status == MessageStatus.read
                            ? Colors.lightGreenAccent
                            : Colors.white,
                        size: 17,
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),

    );
  }
}


