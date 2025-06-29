import 'package:chat_application/data/models/chat_room_model.dart';
import 'package:chat_application/data/repositries/chat_repository.dart';
import 'package:chat_application/data/services/service_locator.dart';
import 'package:flutter/material.dart';

class ChatListTile extends StatelessWidget {
  final ChatRoomModel chat;
  final String currentUserId;
  final VoidCallback ontap;
  const ChatListTile(
      {super.key,
      required this.chat,
      required this.currentUserId,
      required this.ontap});

  String _getOtherUserName(){
    final otherUserId = chat.participants.firstWhere((id) => id != currentUserId);
    return chat.participantsName![otherUserId] ?? "Unknown";
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: ontap,
      shape: Border(bottom: BorderSide(width: 0.5,color: Colors.white.withOpacity(0.9),),),
      leading:  CircleAvatar(
        radius: 25,
        backgroundColor: Theme.of(context).primaryColor,
        // backgroundImage: contact['photo'] != null ?MemoryImage(contact['photo']!): null,
        child: Text(_getOtherUserName()[0].toUpperCase(),style: TextStyle(fontSize: 19,color:Colors.white),),
      ),
        visualDensity: VisualDensity(horizontal: -3, vertical: 0),
        title: Text(_getOtherUserName(),style: const TextStyle(
        fontWeight: FontWeight.bold,color: Colors.white
      ),
      ),
      subtitle: Row(
        children: [
          Expanded(child: Text(chat.lastMessage ??'',maxLines: 1,overflow: TextOverflow.ellipsis
            ,style: TextStyle(
              color: Colors.grey[500],
            ),),),
        ],
      ),
        trailing: StreamBuilder<int>(stream: getIt<ChatRepository>().getUnreadCount(chat.id, currentUserId),
            builder: (context, snapshot) {
              if(!snapshot.hasData ||snapshot.data == 0){
                return SizedBox();
              }
              return Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
                child: Text(snapshot.data.toString(),style: TextStyle(color: Colors.white),),
              );
            },)
    );
  }
}
