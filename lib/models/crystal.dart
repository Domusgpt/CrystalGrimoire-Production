import 'dart:convert';

enum ConfidenceLevel {
  uncertain,
  low,
  medium,
  high,
  certain,
}

enum ChakraAssociation {
  root,
  sacral,
  solarPlexus,
  heart,
  throat,
  thirdEye,
  crown,
  all,
}

class Crystal {
  final String id;
  final String name;
  final String scientificName;
  final String group;
  final String description; // This can be the longer, detailed description
  final List<String> metaphysicalProperties; // Can be kept for general terms
  final List<String> healingProperties; // Can be kept for general terms
  final List<String> chakras;
  final List<String> elements;
  final Map<String, dynamic> properties; // General properties from crystal_details
  final String colorDescription;
  final String hardness;
  final String formation;
  final String careInstructions;
  final DateTime? identificationDate; // Renamed from identifiedAt to match existing field
  final List<String> imageUrls;
  final ConfidenceLevel? confidence;
  final String? userNotes;

  // New fields for richer data model
  final String? variantOrSpecificName;
  final String? mainColor;
  final String? briefDescription; // Shorter description
  final DateTime? savedAt;
  final List<String>? zodiacSigns;
  final List<String>? planetaryInfluences;
  final String? numerologyConnection;
  final List<String>? healingApplications; // More specific than healingProperties
  final String? crystalSystem;
  final String? spiritualMessage;
  final Map<String, dynamic>? crystalDetailsRaw; // Store the raw crystal_details from backend

  Crystal({
    required this.id,
    required this.name,
    required this.scientificName,
    this.group = 'Unknown',
    required this.description,
    this.metaphysicalProperties = const [],
    this.healingProperties = const [],
    this.chakras = const [],
    this.elements = const [],
    this.properties = const {},
    this.colorDescription = '',
    this.hardness = '',
    this.formation = '',
    required this.careInstructions,
    this.identificationDate,
    this.imageUrls = const [],
    this.confidence,
    this.userNotes,
    // New optional fields in constructor
    this.variantOrSpecificName,
    this.mainColor,
    this.briefDescription,
    this.savedAt,
    this.zodiacSigns,
    this.planetaryInfluences,
    this.numerologyConnection,
    this.healingApplications,
    this.crystalSystem,
    this.spiritualMessage,
    this.crystalDetailsRaw,
  });

  factory Crystal.fromJson(Map<String, dynamic> json) {
    return Crystal(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Crystal',
      scientificName: json['scientificName'] ?? '',
      group: json['group'] ?? 'Unknown',
      description: json['description'] ?? '',
      metaphysicalProperties: List<String>.from(json['metaphysicalProperties'] ?? []),
      healingProperties: List<String>.from(json['healingProperties'] ?? []),
      chakras: List<String>.from(json['chakras'] ?? []),
      elements: List<String>.from(json['elements'] ?? []),
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      colorDescription: json['colorDescription'] ?? '',
      hardness: json['hardness'] ?? '',
      formation: json['formation'] ?? '',
      careInstructions: json['careInstructions'] ?? '',
      identificationDate: json['identificationDate'] != null 
          ? DateTime.tryParse(json['identificationDate'])
          : null,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      confidence: json['confidence'] != null 
          ? ConfidenceLevel.values.byName(json['confidence']) 
          : null,
      userNotes: json['userNotes'],
      // New fields from JSON
      variantOrSpecificName: json['variantOrSpecificName'],
      mainColor: json['mainColor'],
      briefDescription: json['briefDescription'],
      savedAt: json['savedAt'] != null ? DateTime.tryParse(json['savedAt']) : null,
      zodiacSigns: List<String>.from(json['zodiacSigns'] ?? []),
      planetaryInfluences: List<String>.from(json['planetaryInfluences'] ?? []),
      numerologyConnection: json['numerologyConnection'],
      healingApplications: List<String>.from(json['healingApplications'] ?? []),
      crystalSystem: json['crystalSystem'],
      spiritualMessage: json['spiritualMessage'],
      crystalDetailsRaw: json['crystalDetailsRaw'] != null
          ? Map<String, dynamic>.from(json['crystalDetailsRaw'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientificName': scientificName,
      'group': group,
      'description': description,
      'metaphysicalProperties': metaphysicalProperties,
      'healingProperties': healingProperties,
      'chakras': chakras,
      'elements': elements,
      'properties': properties,
      'colorDescription': colorDescription,
      'hardness': hardness,
      'formation': formation,
      'careInstructions': careInstructions,
      'identificationDate': identificationDate?.toIso8601String(),
      'imageUrls': imageUrls,
      'confidence': confidence?.name,
      'userNotes': userNotes,
      // New fields for JSON
      'variantOrSpecificName': variantOrSpecificName,
      'mainColor': mainColor,
      'briefDescription': briefDescription,
      'savedAt': savedAt?.toIso8601String(),
      'zodiacSigns': zodiacSigns,
      'planetaryInfluences': planetaryInfluences,
      'numerologyConnection': numerologyConnection,
      'healingApplications': healingApplications,
      'crystalSystem': crystalSystem,
      'spiritualMessage': spiritualMessage,
      'crystalDetailsRaw': crystalDetailsRaw,
    };
  }

  Crystal copyWith({
    String? id,
    String? name,
    String? scientificName,
    String? group,
    String? description,
    List<String>? metaphysicalProperties,
    List<String>? healingProperties,
    List<String>? chakras,
    List<String>? elements,
    Map<String, dynamic>? properties,
    String? colorDescription,
    String? hardness,
    String? formation,
    String? careInstructions,
    DateTime? identificationDate,
    List<String>? imageUrls,
    ConfidenceLevel? confidence,
    String? userNotes,
    // New fields for copyWith
    String? variantOrSpecificName,
    String? mainColor,
    String? briefDescription,
    DateTime? savedAt,
    List<String>? zodiacSigns,
    List<String>? planetaryInfluences,
    String? numerologyConnection,
    List<String>? healingApplications,
    String? crystalSystem,
    String? spiritualMessage,
    Map<String, dynamic>? crystalDetailsRaw,
  }) {
    return Crystal(
      id: id ?? this.id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      group: group ?? this.group,
      description: description ?? this.description,
      metaphysicalProperties: metaphysicalProperties ?? this.metaphysicalProperties,
      healingProperties: healingProperties ?? this.healingProperties,
      chakras: chakras ?? this.chakras,
      elements: elements ?? this.elements,
      properties: properties ?? this.properties,
      colorDescription: colorDescription ?? this.colorDescription,
      hardness: hardness ?? this.hardness,
      formation: formation ?? this.formation,
      careInstructions: careInstructions ?? this.careInstructions,
      identificationDate: identificationDate ?? this.identificationDate,
      imageUrls: imageUrls ?? this.imageUrls,
      confidence: confidence ?? this.confidence,
      userNotes: userNotes ?? this.userNotes,
      // New fields
      variantOrSpecificName: variantOrSpecificName ?? this.variantOrSpecificName,
      mainColor: mainColor ?? this.mainColor,
      briefDescription: briefDescription ?? this.briefDescription,
      savedAt: savedAt ?? this.savedAt,
      zodiacSigns: zodiacSigns ?? this.zodiacSigns,
      planetaryInfluences: planetaryInfluences ?? this.planetaryInfluences,
      numerologyConnection: numerologyConnection ?? this.numerologyConnection,
      healingApplications: healingApplications ?? this.healingApplications,
      crystalSystem: crystalSystem ?? this.crystalSystem,
      spiritualMessage: spiritualMessage ?? this.spiritualMessage,
      crystalDetailsRaw: crystalDetailsRaw ?? this.crystalDetailsRaw,
    );
  }
}

class CrystalIdentification {
  final String sessionId;
  final String fullResponse;
  final Crystal? crystal;
  final double confidence; // Changed to double for compatibility
  final bool needsMoreInfo;
  final List<String> suggestedAngles;
  final List<String> observedFeatures;
  final String mysticalMessage; // Renamed from spiritualMessage
  final DateTime timestamp;

  CrystalIdentification({
    required this.sessionId,
    required this.fullResponse,
    this.crystal,
    required this.confidence,
    this.needsMoreInfo = false,
    this.suggestedAngles = const [],
    this.observedFeatures = const [],
    required this.mysticalMessage,
    required this.timestamp,
  });

  factory CrystalIdentification.fromJson(Map<String, dynamic> json) {
    return CrystalIdentification(
      sessionId: json['sessionId'] ?? '',
      fullResponse: json['fullResponse'] ?? '',
      crystal: json['crystal'] != null ? Crystal.fromJson(json['crystal']) : null,
      confidence: (json['confidence'] ?? 0.5).toDouble(),
      needsMoreInfo: json['needsMoreInfo'] ?? false,
      suggestedAngles: List<String>.from(json['suggestedAngles'] ?? []),
      observedFeatures: List<String>.from(json['observedFeatures'] ?? []),
      mysticalMessage: json['mysticalMessage'] ?? json['spiritualMessage'] ?? '',
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'fullResponse': fullResponse,
      'crystal': crystal?.toJson(),
      'confidence': confidence,
      'needsMoreInfo': needsMoreInfo,
      'suggestedAngles': suggestedAngles,
      'observedFeatures': observedFeatures,
      'mysticalMessage': mysticalMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

// Extension methods for convenience
extension ConfidenceLevelExtension on ConfidenceLevel {
  String get displayName {
    switch (this) {
      case ConfidenceLevel.uncertain:
        return 'Uncertain';
      case ConfidenceLevel.low:
        return 'Low';
      case ConfidenceLevel.medium:
        return 'Medium';
      case ConfidenceLevel.high:
        return 'High';
      case ConfidenceLevel.certain:
        return 'Certain';
    }
  }

  double get percentage {
    switch (this) {
      case ConfidenceLevel.uncertain:
        return 0.2;
      case ConfidenceLevel.low:
        return 0.4;
      case ConfidenceLevel.medium:
        return 0.6;
      case ConfidenceLevel.high:
        return 0.8;
      case ConfidenceLevel.certain:
        return 1.0;
    }
  }
}

extension ChakraAssociationExtension on ChakraAssociation {
  String get displayName {
    switch (this) {
      case ChakraAssociation.root:
        return 'Root Chakra';
      case ChakraAssociation.sacral:
        return 'Sacral Chakra';
      case ChakraAssociation.solarPlexus:
        return 'Solar Plexus Chakra';
      case ChakraAssociation.heart:
        return 'Heart Chakra';
      case ChakraAssociation.throat:
        return 'Throat Chakra';
      case ChakraAssociation.thirdEye:
        return 'Third Eye Chakra';
      case ChakraAssociation.crown:
        return 'Crown Chakra';
      case ChakraAssociation.all:
        return 'All Chakras';
    }
  }

  String get emoji {
    switch (this) {
      case ChakraAssociation.root:
        return '🔴';
      case ChakraAssociation.sacral:
        return '🟠';
      case ChakraAssociation.solarPlexus:
        return '🟡';
      case ChakraAssociation.heart:
        return '💚';
      case ChakraAssociation.throat:
        return '🔵';
      case ChakraAssociation.thirdEye:
        return '🟣';
      case ChakraAssociation.crown:
        return '🤍';
      case ChakraAssociation.all:
        return '🌈';
    }
  }
}