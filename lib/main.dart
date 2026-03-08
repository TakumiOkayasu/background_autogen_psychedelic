import 'package:flutter/material.dart';

import 'package:psychedelic_bg/manager/background_manager.dart';
import 'package:psychedelic_bg/provider/shader_provider.dart';
import 'package:psychedelic_bg/widget/color_overlay_widget.dart';
import 'package:psychedelic_bg/widget/debug_overlay_widget.dart';
import 'package:psychedelic_bg/widget/psychedelic_background_widget.dart';

void main() {
  runApp(const PsychedelicApp());
}

class PsychedelicApp extends StatefulWidget {
  const PsychedelicApp({super.key});

  @override
  State<PsychedelicApp> createState() => _PsychedelicAppState();
}

class _PsychedelicAppState extends State<PsychedelicApp>
    with WidgetsBindingObserver {
  final _manager = BackgroundManager();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        _manager.pause();
      case AppLifecycleState.resumed:
        _manager.resume();
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderProvider(
      manager: _manager,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(
          body: Stack(
            children: [
              PsychedelicBackgroundWidget(),
              ColorOverlayWidget(),
              DebugOverlayWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
