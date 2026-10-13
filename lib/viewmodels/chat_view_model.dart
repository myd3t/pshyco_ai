
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';

class ChatViewModel extends ChangeNotifier {
  // Список сообщений
  List<ChatMessage> messages = [];

  // Наш сервис для работы с ИИ
  AiService aiService = AiService();

  // Показывает, отвечает ли сейчас ИИ
  bool isLoading = false;

  // Текст ошибки, если что-то пошло не так
  String error = '';

  // Отправка сообщения
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) {
      return;
    }

    if (isLoading) {
      return;
    }

    // Добавляем сообщение пользователя
    messages.add(
      ChatMessage(
        text: text.trim(),
        isUser: true,
      ),
    );

    isLoading = true;
    error = '';

    // Обновляем экран
    notifyListeners();

    try {
      // Получаем ответ от ИИ с учётом истории
      String answer = await aiService.sendMessage(messages);

      // Добавляем ответ ИИ
      messages.add(
        ChatMessage(
          text: answer,
          isUser: false,
        ),
      );
    } catch (e) {
      error = e.toString();
    }

    // ИИ закончил работу
    isLoading = false;

    // Снова обновляем экран
    notifyListeners();
  }
}
