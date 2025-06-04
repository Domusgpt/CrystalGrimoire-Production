import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_state.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';

class LLMLabScreen extends StatefulWidget {
  const LLMLabScreen({Key? key}) : super(key: key);

  @override
  State<LLMLabScreen> createState() => _LLMLabScreenState();
}

class _LLMLabScreenState extends State<LLMLabScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _typewriterController;
  late Animation<double> _fadeAnimation;
  
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _chatController = ScrollController();
  
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _selectedModel = 'Spiritual Guide (GPT-4)';
  String _selectedCategory = 'General Guidance';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _typewriterController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    
    _fadeController.forward();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _typewriterController.dispose();
    _questionController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "🔮 Welcome to the Crystal Grimoire AI Lab! I'm your spiritual guide, ready to help you on your metaphysical journey. Ask me about crystals, astrology, healing, meditation, or any spiritual topic.",
        isUser: false,
        timestamp: DateTime.now(),
        model: 'Spiritual Guide',
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: Text(
          'AI Spiritual Lab',
          style: GoogleFonts.cinzel(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: _showModelSettings,
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 20,
              color: Colors.deepPurple,
            ),
          ),
          
          // Main content
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                _buildModelSelector(),
                Expanded(
                  child: _buildChatArea(),
                ),
                _buildInputArea(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModelSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.indigo.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.psychology, color: Colors.purple),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedModel,
                dropdownColor: const Color(0xFF1A1A3A),
                style: GoogleFonts.cinzel(color: Colors.white),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                items: _getModelOptions(),
                onChanged: (value) {
                  setState(() {
                    _selectedModel = value!;
                  });
                },
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getModelTierColor().withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _getModelTierColor()),
            ),
            child: Text(
              _getModelTier(),
              style: GoogleFonts.cinzel(
                fontSize: 10,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white24),
      ),
      child: _messages.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _chatController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return FadeScaleIn(
                  delay: Duration(milliseconds: index * 100),
                  child: _buildMessageBubble(_messages[index]),
                );
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CrystalSparkle(
            size: 60,
            color: Colors.purple,
          ),
          const SizedBox(height: 24),
          Text(
            'Your spiritual AI awaits',
            style: GoogleFonts.cinzel(
              color: Colors.white70,
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Ask questions about crystals, astrology,\nhealing, or your spiritual journey',
            textAlign: TextAlign.center,
            style: GoogleFonts.crimsonText(
              color: Colors.white54,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.purple, Colors.indigo],
                ),
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: message.isUser
                      ? [Colors.blue.withOpacity(0.6), Colors.blue.withOpacity(0.4)]
                      : [Colors.purple.withOpacity(0.4), Colors.indigo.withOpacity(0.3)],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: message.isUser 
                      ? Colors.blue.withOpacity(0.5) 
                      : Colors.purple.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!message.isUser && message.model != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.model!,
                        style: GoogleFonts.cinzel(
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  Text(
                    message.text,
                    style: GoogleFonts.crimsonText(
                      fontSize: 16,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTimestamp(message.timestamp),
                    style: GoogleFonts.crimsonText(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.cyan],
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 16,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F23),
        border: Border(
          top: BorderSide(color: Colors.white24),
        ),
      ),
      child: Column(
        children: [
          // Category selector
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.purple.withOpacity(0.5)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCategory,
                dropdownColor: const Color(0xFF1A1A3A),
                style: GoogleFonts.cinzel(color: Colors.white, fontSize: 14),
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
                items: _getCategoryOptions(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Input field and send button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _questionController,
                  maxLines: null,
                  style: GoogleFonts.crimsonText(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask about crystals, astrology, healing...',
                    hintStyle: GoogleFonts.crimsonText(
                      color: Colors.white54,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.white24),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide(color: Colors.purple),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.indigo],
                  ),
                ),
                child: IconButton(
                  onPressed: _isLoading ? null : _sendMessage,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<DropdownMenuItem<String>> _getModelOptions() {
    return [
      DropdownMenuItem(
        value: 'Spiritual Guide (GPT-4)',
        child: Text('Spiritual Guide (GPT-4)'),
      ),
      DropdownMenuItem(
        value: 'Crystal Expert (Claude)',
        child: Text('Crystal Expert (Claude)'),
      ),
      DropdownMenuItem(
        value: 'Astrology Master (Gemini)',
        child: Text('Astrology Master (Gemini)'),
      ),
      DropdownMenuItem(
        value: 'Basic Assistant (Free)',
        child: Text('Basic Assistant (Free)'),
      ),
    ];
  }

  List<DropdownMenuItem<String>> _getCategoryOptions() {
    return [
      DropdownMenuItem(value: 'General Guidance', child: Text('General Guidance')),
      DropdownMenuItem(value: 'Crystal Healing', child: Text('Crystal Healing')),
      DropdownMenuItem(value: 'Astrology', child: Text('Astrology')),
      DropdownMenuItem(value: 'Meditation', child: Text('Meditation')),
      DropdownMenuItem(value: 'Chakras', child: Text('Chakras')),
      DropdownMenuItem(value: 'Moon Phases', child: Text('Moon Phases')),
      DropdownMenuItem(value: 'Dream Work', child: Text('Dream Work')),
    ];
  }

  Color _getModelTierColor() {
    if (_selectedModel.contains('GPT-4') || _selectedModel.contains('Claude')) {
      return Colors.amber;
    } else if (_selectedModel.contains('Gemini')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  String _getModelTier() {
    if (_selectedModel.contains('GPT-4') || _selectedModel.contains('Claude')) {
      return 'PRO';
    } else if (_selectedModel.contains('Gemini')) {
      return 'PREMIUM';
    } else {
      return 'FREE';
    }
  }

  void _sendMessage() {
    if (_questionController.text.trim().isEmpty || _isLoading) return;

    final userMessage = _questionController.text.trim();
    
    setState(() {
      _messages.add(ChatMessage(
        text: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _questionController.clear();
    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: _generateAIResponse(userMessage),
            isUser: false,
            timestamp: DateTime.now(),
            model: _selectedModel,
          ));
          _isLoading = false;
        });
        _scrollToBottom();
        
        // Update app state
        context.read<AppState>().incrementUsage('ai_guidance');
      }
    });
  }

  String _generateAIResponse(String question) {
    // Mock AI responses based on question content
    final lowerQuestion = question.toLowerCase();
    
    if (lowerQuestion.contains('amethyst')) {
      return "🔮 Amethyst is a powerful protective stone that enhances spiritual awareness and intuition. Based on your current energy, I sense you would benefit from placing amethyst under your pillow for enhanced dream work. The stone's violet ray connects you to your crown chakra, facilitating deeper meditation and psychic development.\n\n✨ For your specific situation, try holding amethyst during full moon meditations to amplify its cleansing properties.";
    } else if (lowerQuestion.contains('healing') || lowerQuestion.contains('chakra')) {
      return "🌈 Chakra healing is a beautiful journey of energy alignment. Each chakra responds to specific crystals and frequencies. I recommend starting with a simple chakra meditation using corresponding stones:\n\n• Root: Red Jasper for grounding\n• Sacral: Carnelian for creativity\n• Solar Plexus: Citrine for confidence\n• Heart: Rose Quartz for love\n• Throat: Blue Lace Agate for communication\n• Third Eye: Amethyst for intuition\n• Crown: Clear Quartz for spiritual connection\n\nPlace each stone on its corresponding chakra while lying down and breathe deeply.";
    } else if (lowerQuestion.contains('astrology') || lowerQuestion.contains('birth chart')) {
      return "⭐ Your birth chart is a cosmic blueprint of your soul's journey. The planetary positions at your birth reveal your spiritual gifts and life lessons. Based on astrological patterns, I sense you're currently in a period of spiritual awakening.\n\n🌙 The current lunar cycle suggests this is an excellent time for introspection and setting intentions. Consider working with moonstone during this phase to enhance your intuitive abilities and emotional healing.";
    } else if (lowerQuestion.contains('meditation')) {
      return "🧘‍♀️ Meditation is the gateway to inner wisdom. For your spiritual development, I recommend starting with crystal-enhanced meditation:\n\n1. Create a sacred space with your favorite crystals\n2. Hold a clear quartz point to amplify your intention\n3. Focus on your breath and allow thoughts to flow\n4. Visualize white light entering through your crown chakra\n5. End with gratitude and grounding\n\n✨ The crystals will help stabilize your energy and deepen your practice.";
    } else {
      return "🔮 Thank you for your spiritual inquiry. The universe has guided you to ask this question at the perfect time. Based on the cosmic energies surrounding you, I sense you're seeking deeper understanding and connection.\n\n✨ Every spiritual journey is unique, and your path is unfolding exactly as it should. Trust your intuition and remain open to the signs and synchronicities around you. Consider working with crystals that resonate with your current energy - they will help amplify your natural spiritual gifts.\n\n🌟 Remember, you already have all the wisdom you need within you. The crystals and spiritual practices simply help you access and trust that inner knowing.";
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_chatController.hasClients) {
        _chatController.animateTo(
          _chatController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showModelSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A3A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: const BorderSide(color: Colors.purple),
        ),
        title: Text(
          'AI Model Settings',
          style: GoogleFonts.cinzel(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Model: $_selectedModel',
              style: GoogleFonts.crimsonText(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Model Features:',
              style: GoogleFonts.cinzel(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getModelFeatures(),
              style: GoogleFonts.crimsonText(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
              ),
              child: Text(
                '💡 Tip: Premium models provide more detailed and personalized spiritual guidance based on your profile and crystal collection.',
                style: GoogleFonts.crimsonText(
                  color: Colors.amber,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.cinzel(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getModelFeatures() {
    if (_selectedModel.contains('GPT-4')) {
      return '• Advanced spiritual reasoning\n• Personalized crystal recommendations\n• Deep astrological insights\n• Complex healing protocols';
    } else if (_selectedModel.contains('Claude')) {
      return '• Empathetic guidance\n• Detailed crystal properties\n• Meditation instructions\n• Ethical spiritual advice';
    } else if (_selectedModel.contains('Gemini')) {
      return '• Creative healing suggestions\n• Multi-modal insights\n• Innovative practices\n• Visual meditation guides';
    } else {
      return '• Basic crystal information\n• Simple guidance\n• Limited daily usage\n• Standard responses';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${timestamp.day}/${timestamp.month}';
    }
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? model;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.model,
  });
}