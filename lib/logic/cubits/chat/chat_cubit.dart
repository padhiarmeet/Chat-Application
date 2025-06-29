import 'dart:async';

import 'package:chat_application/data/repositries/chat_repository.dart';
import 'package:chat_application/data/repositries/notification_repository.dart';
import 'package:chat_application/logic/cubits/chat/chat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepository _chatRepository;
  final String currentUserId;
  bool _isInChat = false;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _onlineStatusSubscription;
  StreamSubscription? _typingSubscription;
  Timer? typingTimer;

  ChatCubit(
      {required ChatRepository chatRepository, required this.currentUserId})
      : _chatRepository = chatRepository,
        super(const ChatState());

  void enterChat(String receiverId)async{
    _isInChat = true;
    emit(state.copyWith(status: ChatStatus.loading));
    try{
      final chatRoom = await _chatRepository.getOrCreateChatRoom(currentUserId,receiverId);
      emit(state.copyWith(chatRoomId: chatRoom.id,receiverId: receiverId,status: ChatStatus.loaded));
      subscribeToMessages(chatRoom.id);
      _subscribeToOnlineStatus(receiverId);
      _subscribeToTypingStatus(chatRoom.id);

      await _chatRepository.updateOnlineStatus(currentUserId, true);
    }catch(e){
      emit(state.copyWith(status: ChatStatus.error,error: 'failed to create room for ${e}'));
    }
  }

  Future<void> sendMessage({required String content,required String receiverId})async{
    if(state.chatRoomId == null) return;

    try{
      await _chatRepository.sendMessage(chatRoomId: state.chatRoomId!, senderId: currentUserId, reciverId: receiverId, content: content);
    }catch(e){
      emit(state.copyWith(error: "failed to send message"));

    }
  }

  void subscribeToMessages(String chatRoomId){
    _messageSubscription?.cancel();
    _messageSubscription = _chatRepository.getMessages(chatRoomId).listen((messages){
      if(_isInChat){
        _markMessagesAsRead(chatRoomId);
      }
      emit(state.copyWith(
        messages: messages,error: null,
      ));
    },onError:(error){
      emit(state.copyWith(error: 'Failed to load messages',status: ChatStatus.error));
    });
  }

  void _subscribeToOnlineStatus(String userId){
    _onlineStatusSubscription?.cancel();
    _onlineStatusSubscription = ChatRepository(notificationRepository: NotificationRepository()).getUserOnlineStatus(userId).listen((status) {
      final isOnline = status['isOnline'] as bool;
      final lastSeen = status['lastSeen'] as Timestamp?;

      emit(state.copyWith(
        isReceiverOnline: isOnline,
        receiverLastSeen: lastSeen
      ));
    },
    onError:(e){print('error getting online status......${e}');});
  }

  void _subscribeToTypingStatus(String chatRoomId){
    _typingSubscription?.cancel();
    _typingSubscription = ChatRepository(notificationRepository: NotificationRepository()).getTypingStatus(chatRoomId).listen((status) {
      final isTyping = status['isTyping'] as bool;
      final typingUserId = status['typingUserId'] as String?;

      emit(state.copyWith(
        isReceiverTyping: isTyping && typingUserId != currentUserId
      ));
    },
    onError:(e){print('error getting online status......${e}');});
  }

  Future<void> _updateTypingStatus(bool isTyping)async{
    if(state.chatRoomId == null) return;
    try{
      await _chatRepository.updateTypingStatus(state.chatRoomId!, currentUserId, isTyping);
    }catch(e){
      print('error in typing ${e}');
    }
  }

  void startTyping(){
    if(state.chatRoomId == null) return;
    typingTimer?.cancel();
    _updateTypingStatus(true);
    typingTimer = Timer(Duration(seconds: 3), () {
      _updateTypingStatus(false);
    },);
  }

  Future<void> _markMessagesAsRead(String chatRoomId)async{
    try{
      await _chatRepository.markMessageAsRead(chatRoomId,currentUserId);
    }catch(e){
      print('error marking message as read $e');
    }
  }

  Future<void> leaveChat()async{
    _isInChat = false;
  }
}
