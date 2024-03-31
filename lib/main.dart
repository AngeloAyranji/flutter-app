import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:geminiApp/repositories/geminy.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Color.fromARGB(255, 59, 210, 244),
            brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _selectedOption = "normal";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "gemini.png",
              height: 24,
            ),
            const SizedBox(width: 8),
            Text(
              "Ask me anything",
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Color.fromARGB(255, 59, 210, 244),
                fontSize: 22,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              initialValue: _selectedOption,
              offset: Offset(
                  70, 0), // Set offset to shift the menu towards the right
              itemBuilder: (BuildContext context) {
                return <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'normal',
                    child: Text('Normal'),
                  ),
                  PopupMenuItem<String>(
                    value: 'funny',
                    child: Text('Funny'),
                  ),
                  PopupMenuItem<String>(
                    value: 'sarcastic',
                    child: Text('Sarcastic'),
                  ),
                  PopupMenuItem<String>(
                    value: 'professional',
                    child: Text('Professional'),
                  ),
                ];
              },
              onSelected: (String value) {
                setState(() {
                  _selectedOption = value;
                });
              },
            ),
          ],
        ),
      ),
      body: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final GeminiRepository geminiRepository =
      GeminiRepository(apiKey: dotenv.env['API_KEY'] ?? '');

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  String _selectedOption = "normal";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool hasApiKey =
        dotenv.env['API_KEY'] != null && dotenv.env['API_KEY']!.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: hasApiKey
                ? ListView.builder(
                    controller: _scrollController,
                    itemBuilder: (context, idx) {
                      final content =
                          geminiRepository.chat.history.toList()[idx];
                      final text = content.parts
                          .whereType<TextPart>()
                          .map<String>((e) => e.text)
                          .join('');
                      return MessageWidget(
                        text: text,
                        isFromUser: content.role == 'user',
                      );
                    },
                    itemCount: geminiRepository.chat.history.length,
                  )
                : ListView(
                    children: const [
                      Text('No API key found. Please provide an API Key.'),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 25,
              horizontal: 15,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    autofocus: true,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(15),
                      hintText: 'Enter a prompt...',
                      hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 0.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(14),
                        ),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.secondary,
                          width: 0.4,
                        ),
                      ),
                    ),
                    onFieldSubmitted: (String value) {
                      _sendChatMessage(value, _selectedOption);
                    },
                  ),
                ),
                const SizedBox.square(
                  dimension: 15,
                ),
                if (!_loading)
                  IconButton(
                    onPressed: () async {
                      _sendChatMessage(_textController.text, _selectedOption);
                    },
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                else
                  const CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendChatMessage(String message, String mode) async {
    setState(() => _loading = true);

    try {
      final text = await geminiRepository.sendMessage(message, mode);
      setState(() => _loading = false);
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      _textController.clear();
      setState(() => _loading = false);
    }
  }
}

class MessageWidget extends StatelessWidget {
  final String text;
  final bool isFromUser;

  const MessageWidget({
    super.key,
    required this.text,
    required this.isFromUser,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            decoration: BoxDecoration(
              color: isFromUser
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Theme.of(context).colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 20,
            ),
            margin: const EdgeInsets.only(bottom: 8),
            child: MarkdownBody(
              selectable: true,
              data: text,
            ),
          ),
        ),
      ],
    );
  }
}
