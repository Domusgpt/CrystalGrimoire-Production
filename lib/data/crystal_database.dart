class CrystalData {
  final String id;
  final String name;
  final String type;
  final String description;
  final List<String> properties;
  final List<String> chakras;
  final String color;
  final String imageUrl;
  final String scientificName;
  final String colorDescription;
  final List<String> metaphysicalProperties;
  final List<String> healing;
  final double hardness;
  final List<String> keywords;
  
  CrystalData({
    required this.id,
    required this.name,
    required this.type,
    required this.description,
    required this.properties,
    required this.chakras,
    required this.color,
    required this.imageUrl,
    this.scientificName = '',
    this.colorDescription = '',
    List<String>? metaphysicalProperties,
    List<String>? healing,
    this.hardness = 7.0,
    List<String>? keywords,
  }) : metaphysicalProperties = metaphysicalProperties ?? properties,
       healing = healing ?? properties,
       keywords = keywords ?? properties;
}

class CrystalDatabase {
  static final List<CrystalData> crystals = [
    CrystalData(
      id: '1',
      name: 'Amethyst',
      type: 'Quartz',
      description: 'A powerful protective stone',
      properties: ['Protection', 'Intuition', 'Clarity'],
      chakras: ['Crown'],
      color: 'Purple',
      imageUrl: 'assets/images/crystals/amethyst.jpg',
      scientificName: 'Silicon Dioxide',
      colorDescription: 'Deep purple, lavender, pale lilac',
      metaphysicalProperties: ['Protection', 'Intuition', 'Clarity', 'Spiritual Awareness'],
      healing: ['Stress Relief', 'Insomnia', 'Headaches', 'Addiction Recovery'],
      hardness: 7.0,
      keywords: ['Protection', 'Intuition', 'Spiritual Growth', 'Peace'],
    ),
    CrystalData(
      id: '2',
      name: 'Rose Quartz',
      type: 'Quartz',
      description: 'The stone of unconditional love',
      properties: ['Love', 'Healing', 'Compassion'],
      chakras: ['Heart'],
      color: 'Pink',
      imageUrl: 'assets/images/crystals/rose_quartz.jpg',
      scientificName: 'Silicon Dioxide',
      colorDescription: 'Soft pink, pale rose, deep pink',
      metaphysicalProperties: ['Love', 'Healing', 'Compassion', 'Self-Love'],
      healing: ['Emotional Healing', 'Heart Conditions', 'Circulation', 'Skin Issues'],
      hardness: 7.0,
      keywords: ['Love', 'Compassion', 'Emotional Healing', 'Heart Chakra'],
    ),
    CrystalData(
      id: '3',
      name: 'Clear Quartz',
      type: 'Quartz',
      description: 'The master healer',
      properties: ['Amplification', 'Clarity', 'Energy'],
      chakras: ['All'],
      color: 'Clear',
      imageUrl: 'assets/images/crystals/clear_quartz.jpg',
      scientificName: 'Silicon Dioxide',
      colorDescription: 'Clear, transparent, white',
      metaphysicalProperties: ['Amplification', 'Clarity', 'Energy', 'Manifestation'],
      healing: ['General Healing', 'Energy Boost', 'Immune System', 'Mental Clarity'],
      hardness: 7.0,
      keywords: ['Amplification', 'Clarity', 'Master Healer', 'Energy'],
    ),
  ];
  
  static CrystalData? getCrystalById(String id) {
    try {
      return crystals.firstWhere((crystal) => crystal.id == id);
    } catch (e) {
      return null;
    }
  }
  
  static List<CrystalData> getCrystalsByColor(String color) {
    return crystals.where((crystal) => 
      crystal.color.toLowerCase().contains(color.toLowerCase())).toList();
  }
}