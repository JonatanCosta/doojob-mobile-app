import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:do_job_app/geolocation/location.dart';

class AgeConfirmationService {
  final BuildContext context;

  AgeConfirmationService(this.context);

  Future<void> checkAgeConfirmation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isAdult = prefs.getBool('isAdult');

    if (isAdult == null || isAdult == false) {
      // Mostra o popup de confirmação de idade
      _showAgeConfirmationPopup();
    } else {
      // Se já confirmou, solicita permissão de localização
      LocationService locationService = LocationService();
      await locationService.requestLocationPermission(context);
    }
  }

  void _showAgeConfirmationPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Aviso: Conteúdo Adulto 18+'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entendo que o site DooJob apresenta conteúdo explícito destinado a adultos.',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 15),
              Text(
                'A profissão de acompanhante é legalizada no Brasil e deve ser respeitada.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isAdult', true);
                  Navigator.of(context).pop();

                  LocationService locationService = LocationService();
                  await locationService.requestLocationPermission(context);
                },
                child: const Text('Concordo'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  backgroundColor: const Color(0xFFFF5252),
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 20),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}