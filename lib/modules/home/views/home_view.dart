import 'package:eecho_see/modules/home/controllers/home_controller.dart';
import 'package:eecho_see/widgets/microphone%20button.dart';
import 'package:eecho_see/widgets/status_indicator.dart';
import 'package:eecho_see/widgets/subtitle_panel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Text('EchoSee'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 700;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isWide ? 680 : double.infinity,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Obx(
                            () => StatusIndicator(
                          status: controller.statusMessage.value,
                          isListening: controller.isListening.value,
                          isInitializing: controller.isInitializing.value,
                        ),
                      ),
                       SizedBox(height: 10),
                      Expanded(
                        child: SubtitlePanel(
                          colorScheme: Theme.of(context).colorScheme,
                        ),
                      ),
                       SizedBox(height: 24),
                      Obx(
                            () => MicrophoneButton(
                          isListening: controller.isListening.value,
                          isInitializing: controller.isInitializing.value,
                          onPressed: controller.toggleListening,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}