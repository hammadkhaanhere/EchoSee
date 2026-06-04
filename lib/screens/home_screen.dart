import 'package:eecho_see/controllers/speech_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SpeechController controller = Get.put(SpeechController());

    return Scaffold(
      appBar: AppBar(title: Text('Echo See'), centerTitle: true),
      body: Center(
        child: Padding(
          padding:  EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  controller.isListening.value
                      ? 'Listening...'
                      : 'Tap the mic to start',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: Stack(
                  children: [
                    Center(
                      child: Obx(
                            () => Text(
                          controller.recognizedText.value,
                          textAlign: TextAlign.center,
                          style:  TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      right: 10,
                      bottom: 20,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'English Subtitles',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Obx(
                                () => Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                controller.translatedText.value.isEmpty
                                    ? '...'
                                    : controller.translatedText.value,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.yellow,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Obx(
        () => FloatingActionButton(
          onPressed: controller.toggleListening,
          backgroundColor: controller.isListening.value
              ? Colors.red
              : Colors.deepPurple,
          child: Icon(
            controller.isListening.value ? Icons.stop : Icons.mic,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
