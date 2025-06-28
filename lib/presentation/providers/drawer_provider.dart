import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track drawer open/close state
final drawerStateProvider = StateProvider<bool>((ref) => false);
