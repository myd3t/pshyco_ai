
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat_message.dart';

class AiService {
  // Адрес Ollama на твоём компьютере
  String url = 'http://192.168.1.73:11434/api/chat';

  // Название нашей модели
  String model = 'support-chat';

  Future<String> sendMessage(List<ChatMessage> history) async {
    // Инструкция для ИИ
    List<Map<String, String>> messages = [
      {
        'role': 'system',
        'content': '''
Ты — русскоязычный ИИ-собеседник для эмоциональной поддержки.
Отвечай тепло, спокойно и уважительно.
Старайся понять чувства человека.
Не обесценивай его переживания.
Сначала выслушай человека, а потом предлагай советы.
Задавай не больше одного вопроса за раз.
Пиши простыми и понятными сообщениями.
Не ставь диагнозы и не назначай лечение.
Не притворяйся настоящим человеком или психологом.
Не придумывай факты о пользователе.
Если человек в непосредственной опасности,
предложи ему обратиться к близкому человеку
или в экстренную службу.
Отвечай на русском языке.
''',
      },
    ];

    // Добавляем историю переписки
    for (int i = 0; i < history.length; i++) {
      messages.add({
        'role': history[i].isUser ? 'user' : 'assistant',
        'content': history[i].text,
      });
    }

    try {
      // Отправляем запрос в Ollama
      var response = await http
          .post(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': model,
              'messages': messages,
              'stream': false,
              'think': false,
            }),
          )
          .timeout(Duration(minutes: 3));

      // Проверяем, успешно ли прошёл запрос
      if (response.statusCode != 200) {
        throw Exception(
          'Ошибка сервера: ${response.statusCode}',
        );
      }

      // Читаем ответ сервера
      var data = jsonDecode(
        utf8.decode(response.bodyBytes),
      );

      String answer = data['message']['content'];

      if (answer.trim().isEmpty) {
        throw Exception('ИИ вернул пустой ответ');
      }

      return answer.trim();
    } catch (e) {
      throw Exception(
        'Не удалось получить ответ от ИИ. '
        'Проверь, запущена ли Ollama и доступен ли сервер.\n$e',
      );
    }
  }
}
