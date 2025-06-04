import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../services/app_state.dart';
import '../services/unified_ai_service.dart';
import '../widgets/common/mystical_button.dart';
import '../widgets/animations/mystical_animations.dart';
import '../data/crystal_database.dart';
import 'dart:typed_data';
import 'dart:html' as html;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isProcessing = false;
  String? _result;
  Uint8List? _imageData;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F23),
      appBar: AppBar(
        title: const Text('Crystal Identification'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          // Background particles
          const Positioned.fill(
            child: FloatingParticles(
              particleCount: 30,
              color: Colors.deepPurple,
            ),
          ),
          
          // Main content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Camera preview area
                Expanded(
                  flex: 2,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.purple.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: _imageData != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Image.memory(
                              _imageData!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 80,
                                  color: Colors.purple,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Take a photo of your crystal',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Result area
                if (_result != null)
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purple.withOpacity(0.3),
                            Colors.deepPurple.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.purple.withOpacity(0.5),
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _result!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 20),
                
                // Control buttons
                Row(
                  children: [
                    Expanded(
                      child: MysticalButton(
                        text: 'Camera',
                        icon: Icons.camera_alt,
                        onPressed: _isProcessing ? () {} : _takePicture,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MysticalButton(
                        text: 'Gallery',
                        icon: Icons.photo_library,
                        onPressed: _isProcessing ? () {} : _pickFromGallery,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Identify button
                if (_imageData != null)
                  SizedBox(
                    width: double.infinity,
                    child: MysticalButton(
                      text: _isProcessing ? 'Identifying...' : 'Identify Crystal',
                      icon: _isProcessing ? null : Icons.search,
                      onPressed: _isProcessing ? () {} : _identifyCrystal,
                      color: Colors.purple,
                    ),
                  ),
              ],
            ),
          ),
          
          // Loading overlay
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Analyzing crystal...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageData = bytes;
          _result = null;
        });
      }
    } catch (e) {
      _showError('Failed to take picture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _imageData = bytes;
          _result = null;
        });
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _identifyCrystal() async {
    if (_imageData == null) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      // Get the AI service for real crystal identification
      final aiService = context.read<UnifiedAIService>();
      
      // Check if AI service is configured
      if (!aiService.isConfigured) {
        // Fallback to mock identification if AI is not configured
        await _mockIdentification();
        return;
      }
      
      // Convert image to base64 for AI analysis
      final imageBase64 = base64Encode(_imageData!);
      
      // Extract basic visual features (this would be more sophisticated in production)
      final visualFeatures = {
        'image_size': '${_imageData!.length} bytes',
        'timestamp': DateTime.now().toIso8601String(),
        'camera_mode': 'identification',
      };
      
      // Use AI service for real crystal identification
      final identificationResult = await aiService.identifyCrystal(
        imageBase64: imageBase64,
        visualFeatures: visualFeatures,
      );
      
      // Format the AI response for display
      final result = _formatIdentificationResult(identificationResult);
      
      setState(() {
        _result = result;
        _isProcessing = false;
      });
      
      // Update app state
      if (mounted) {
        context.read<AppState>().incrementUsage('crystal_identification');
      }
      
    } catch (e) {
      print('Crystal identification error: $e');
      
      // Fallback to mock identification on error
      try {
        await _mockIdentification();
      } catch (fallbackError) {
        setState(() {
          _isProcessing = false;
        });
        _showError('Failed to identify crystal: $e');
      }
    }
  }
  
  /// Fallback mock identification when AI service is unavailable
  Future<void> _mockIdentification() async {
    await Future.delayed(const Duration(seconds: 2));
    
    // Return a random crystal from the database with AI-style formatting
    final crystals = CrystalDatabase.crystals;
    final randomCrystal = crystals[DateTime.now().millisecond % crystals.length];
    
    final result = '''
🔮 Crystal Identified: ${randomCrystal.name}

Type: ${randomCrystal.type}
Color: ${randomCrystal.color}
Confidence: 85% (Mock Mode)

Description:
${randomCrystal.description}

Properties:
${randomCrystal.properties.map((p) => '• $p').join('\n')}

Chakras:
${randomCrystal.chakras.map((c) => '• $c').join('\n')}

✨ This crystal resonates with your current energy. Consider adding it to your collection for enhanced spiritual protection and clarity.

ℹ️ This is a mock identification. Configure AI services for real crystal recognition.
''';
    
    setState(() {
      _result = result;
      _isProcessing = false;
    });
  }
  
  /// Format AI identification result for display
  String _formatIdentificationResult(Map<String, dynamic> result) {
    final name = result['name'] ?? 'Unknown Crystal';
    final confidence = result['confidence'] ?? 0.0;
    final properties = result['properties'] as List? ?? [];
    final chakras = result['chakras'] as List? ?? [];
    final personalizedSuggestions = result['personalized_suggestions'] as Map? ?? {};
    
    String formattedResult = '''
🔮 Crystal Identified: $name

Confidence: ${confidence.toStringAsFixed(1)}%
''';
    
    if (properties.isNotEmpty) {
      formattedResult += '''

Properties:
${properties.map((p) => '• $p').join('\n')}''';
    }
    
    if (chakras.isNotEmpty) {
      formattedResult += '''

Chakras:
${chakras.map((c) => '• $c').join('\n')}''';
    }
    
    // Add personalized suggestions if available
    if (personalizedSuggestions.isNotEmpty) {
      if (personalizedSuggestions['ritual_ideas'] != null) {
        final ritualIdeas = personalizedSuggestions['ritual_ideas'] as List;
        formattedResult += '''

✨ Personalized Suggestions:
${ritualIdeas.map((idea) => '• $idea').join('\n')}''';
      }
      
      if (personalizedSuggestions['pairing_suggestions'] != null) {
        final pairings = personalizedSuggestions['pairing_suggestions'] as List;
        if (pairings.isNotEmpty) {
          formattedResult += '''

🔗 Crystal Pairings:
${pairings.map((pair) => '• $pair').join('\n')}''';
        }
      }
      
      if (personalizedSuggestions['care_instructions'] != null) {
        final careInstructions = personalizedSuggestions['care_instructions'] as List;
        formattedResult += '''

🧼 Care Instructions:
${careInstructions.map((care) => '• $care').join('\n')}''';
      }
    }
    
    formattedResult += '''

🌟 This identification was powered by advanced AI analysis of your crystal's visual properties and your personal collection context.''';
    
    return formattedResult;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}