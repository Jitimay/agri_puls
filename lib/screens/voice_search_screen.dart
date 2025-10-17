import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late stt.SpeechToText _speech;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  bool _isListening = false;
  bool _speechEnabled = false;
  bool _isLoading = false;
  String _recognizedText = '';
  String _selectedLanguage = 'rn'; // Default to Kirundi
  String? _aiResponse;
  String? _error;

  final List<Map<String, String>> _languages = [
    {'code': 'rn', 'name': 'Kirundi', 'display': 'Kirundi'},
    {'code': 'en', 'name': 'English', 'display': 'English'},
    {'code': 'fr', 'name': 'French', 'display': 'Français'},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _initSpeech() async {
    _speech = stt.SpeechToText();
    _speechEnabled = await _speech.initialize(
      onError: (error) {
        setState(() {
          _error = 'Ikibazo mu kwumva ijwi: ${error.errorMsg}';
          _isListening = false;
        });
        _animationController.stop();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() {
            _isListening = false;
          });
          _animationController.stop();
        }
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (!_speechEnabled) {
      setState(() {
        _error = 'Ijwi ntirirashobora kwumvikana';
      });
      return;
    }

    setState(() {
      _recognizedText = '';
      _aiResponse = null;
      _error = null;
      _isListening = true;
    });

    _animationController.repeat(reverse: true);

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _recognizedText = result.recognizedWords;
        });
      },
      localeId: _getLocaleId(_selectedLanguage),
      listenOptions: stt.SpeechListenOptions(
        listenMode: stt.ListenMode.confirmation,
      ),
    );
  }

  void _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
    _animationController.stop();

    if (_recognizedText.isNotEmpty) {
      _askAI(_recognizedText);
    }
  }

  String _getLocaleId(String languageCode) {
    switch (languageCode) {
      case 'rn':
        return 'rn-BI'; // Kirundi (Burundi)
      case 'en':
        return 'en-US';
      case 'fr':
        return 'fr-FR';
      default:
        return 'en-US';
    }
  }

  Future<void> _askAI(String question) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _apiService.askAI(question, language: _selectedLanguage);
      setState(() {
        _aiResponse = response;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Ikibazo mu kubaza AI: $e';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baza mu ijwi (Voice Search)'),
        backgroundColor: AppTheme.coffeeBrown,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLanguageSelector(),
            const SizedBox(height: 20),
            _buildMicrophoneButton(),
            const SizedBox(height: 20),
            _buildRecognizedText(),
            const SizedBox(height: 12),
            _buildAIResponse(),
            const SizedBox(height: 20),
            _buildQuickQuestions(),
            const SizedBox(height: 20), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hitamo ururimi (Select Language):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _languages.map((lang) {
                final isSelected = _selectedLanguage == lang['code'];
                return ChoiceChip(
                  label: Text(lang['display']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedLanguage = lang['code']!;
                      });
                    }
                  },
                  selectedColor: AppTheme.coffeeBrown,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return Center(
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _scaleAnimation.value : 1.0,
            child: GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? AppTheme.alertRed : AppTheme.coffeeBrown,
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? AppTheme.alertRed : AppTheme.coffeeBrown)
                          .withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.stop : Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecognizedText() {
    if (_recognizedText.isEmpty && !_isListening) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.hearing, color: AppTheme.coffeeBrown),
                const SizedBox(width: 8),
                const Text(
                  'Icyo wavuze:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _isListening ? 'Ndumva...' : _recognizedText,
              style: TextStyle(
                fontSize: 16,
                fontStyle: _isListening ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIResponse() {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              CircularProgressIndicator(color: AppTheme.coffeeBrown),
              SizedBox(width: 16),
              Text('AI irasubiza...'),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        color: Colors.red[50],
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
            ],
          ),
        ),
      );
    }

    if (_aiResponse != null) {
      return Card(
        color: AppTheme.coffeeGreen.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.smart_toy, color: AppTheme.coffeeBrown),
                  SizedBox(width: 8),
                  Text(
                    'Igisubizo cya AI:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _aiResponse!,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildQuickQuestions() {
    final quickQuestions = [
      'Igiciro cy\'ikawa ni angahe?',
      'Ikirere kizaba gite ejo?',
      'Hari amakuru mashya?',
      'Ni ryari nzaguza ikawa?',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ibibazo byoroshye:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: quickQuestions.map((question) {
                return ActionChip(
                  label: Text(question),
                  onPressed: () {
                    setState(() {
                      _recognizedText = question;
                    });
                    _askAI(question);
                  },
                  backgroundColor: AppTheme.coffeeBrown.withValues(alpha: 0.1),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}