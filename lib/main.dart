import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:universal_platform/universal_platform.dart';

// Services
import 'services/app_state.dart';
import 'services/auth_service.dart';
import 'services/payment_service.dart';
import 'services/ads_service.dart';
import 'services/storage_service.dart';
import 'services/collection_service_v2.dart';
import 'services/unified_ai_service.dart';
import 'services/firebase_service.dart';
import 'firebase_options.dart';

// Screens
import 'screens/unified_home_screen.dart';
import 'config/enhanced_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase for all platforms
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization failed: $e');
  }
  
  // Initialize services
  await _initializeServices();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F23),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const CrystalGrimoireApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize payment service (mobile only)
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await PaymentService.initialize();
    }
    
    // Initialize ads service (mobile only)
    if (UniversalPlatform.isAndroid || UniversalPlatform.isIOS) {
      await AdsService.initialize();
    }
  } catch (e) {
    print('Service initialization failed: $e');
  }
}

class CrystalGrimoireApp extends StatelessWidget {
  const CrystalGrimoireApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        Provider(create: (_) => StorageService()),
        Provider(create: (_) => FirebaseService()),
        ChangeNotifierProvider(create: (_) => CollectionServiceV2()..initialize()),
        ChangeNotifierProxyProvider2<StorageService, CollectionServiceV2, UnifiedAIService>(
          create: (context) => UnifiedAIService(
            storageService: context.read<StorageService>(),
            collectionService: context.read<CollectionServiceV2>(),
          ),
          update: (context, storage, collection, previous) => 
            previous ?? UnifiedAIService(
              storageService: storage,
              collectionService: collection,
            ),
        ),
      ],
      child: MaterialApp(
        title: 'Crystal Grimoire',
        debugShowCheckedModeBanner: false,
        theme: CrystalGrimoireTheme.theme,
        home: const UnifiedHomeScreen(),
        routes: {
          '/home': (context) => const UnifiedHomeScreen(),
        },
      ),
    );
  }
}