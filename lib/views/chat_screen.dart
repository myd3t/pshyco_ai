
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../viewmodels/chat_view_model.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Создаём ViewModel
  ChatViewModel viewModel = ChatViewModel();

  // Контроллер для поля ввода
  TextEditingController controller = TextEditingController();

  // Отправка сообщения
  void sendMessage() {
    String text = controller.text;

    if (text.trim().isEmpty) {
      return;
    }

    controller.clear();

    viewModel.sendMessage(text);
  }

  @override
  void dispose() {
    controller.dispose();
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Мой ИИ'),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, child) {
                return ListView.builder(
                  padding: EdgeInsets.all(12),
                  itemCount: viewModel.messages.length,
                  itemBuilder: (context, index) {
                    ChatMessage message =
                        viewModel.messages[index];

                    return Align(
                      alignment: message.isUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        padding: EdgeInsets.all(12),
                        constraints: BoxConstraints(
                          maxWidth:
                              MediaQuery.of(context).size.width *
                                  0.8,
                        ),
                        decoration: BoxDecoration(
                          color: message.isUser
                              ? Theme.of(context)
                                  .colorScheme
                                  .primaryContainer
                              : Theme.of(context)
                                  .colorScheme
                                  .secondaryContainer,
                          borderRadius:
                              BorderRadius.circular(15),
                        ),
                        child: Text(message.text),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Индикатор ожидания ответа
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) {
              if (viewModel.isLoading) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text('ИИ думает...'),
                    ],
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),

          // Показываем ошибку, если она появилась
          ListenableBuilder(
            listenable: viewModel,
            builder: (context, child) {
              if (viewModel.error.isNotEmpty) {
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    viewModel.error,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .error,
                    ),
                  ),
                );
              }

              return SizedBox.shrink();
            },
          ),

          // Поле ввода и кнопка отправки
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Напиши сообщение...',
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(20),
                      ),
                    ),
                    onSubmitted: (text) {
                      sendMessage();
                    },
                  ),
                ),

                SizedBox(width: 8),

                ListenableBuilder(
                  listenable: viewModel,
                  builder: (context, child) {
                    return IconButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : sendMessage,
                      icon: Icon(Icons.send),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
