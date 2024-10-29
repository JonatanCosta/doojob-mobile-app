import 'package:geocoding/geocoding.dart'; // Para geocodificação
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';

class LocationService {
  // Solicita a permissão de localização e aguarda a resposta do navegador
  Future<void> requestLocationPermission(BuildContext context) async {
    bool hasCity = await hasCitySaved();

    if (hasCity){
      return;
    }

    // Verifica se a permissão já foi concedida
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Se já está permitida, obtém a localização diretamente
      await getCityFromLocation(context);
      return;  // Não abre o popup se a permissão já foi concedida
    }

    // Exibe o popup para solicitar permissão
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Permitir localização'),
          content: const Text(
              'Deseja permitir o acesso à sua localização para oferecer serviços personalizados com base na sua cidade?'),
          actions: [
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Solicita a permissão e aguarda a resposta do navegador
                      await _handleLocationPermission(context);
                    },
                    child: const Text('Permitir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      //Navigator.of(context).pop();
                      await showCitySelectionPopup(context);

                      context.pushReplacement('/feed');
                    },
                    child: const Text('Não, selecionar cidade'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF212121),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  // Função para obter a cidade salva
  Future<String?> getSavedCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userCity');
  }

  // Lida com a solicitação de permissão e aguarda a resposta do navegador
  Future<void> _handleLocationPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    // Caso a permissão não tenha sido concedida, solicita ao usuário
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    // Espera pela ação do usuário para conceder ou negar a permissão
    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      // Permissão concedida, fechar o popup e obter a localização
      Navigator.of(context).pop();  // Fecha o popup
      await getCityFromLocation(context);
    } else {
      // Permissão negada, exibe o popup para selecionar cidade
      Navigator.of(context).pop();  // Fecha o popup
      await showCitySelectionPopup(context);
    }
  }

 Future<void> showCitySelectionPopup(BuildContext context) async {
  Map<String, String> selectedCity = {
    'text': 'Porto Alegre',
    'value': 'POA'
  }; // Cidade padrão selecionada

  List<Map<String, String>> cities = [
    {'text': 'Porto Alegre', 'value': 'POA'},
    {'text': 'São Paulo', 'value': 'SP'},
    {'text': 'Rio de Janeiro', 'value': 'RJ'},
    // Adicione outras cidades aqui, se necessário
  ];

  // Use um Completer para permitir o uso de await
  final Completer<void> completer = Completer<void>();

  showDialog(
    context: context,
    barrierDismissible: false, // Impede que o popup seja fechado sem ação
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Selecione sua cidade'),
            content: DropdownButton<Map<String, String>>(
              value: cities.firstWhere((city) => city['value'] == selectedCity['value']),
              items: cities.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> city) {
                return DropdownMenuItem<Map<String, String>>(
                  value: city,
                  child: Text(city['text']!), // Exibe o nome da cidade
                );
              }).toList(),
              onChanged: (Map<String, String>? newCity) {
                if (newCity != null) {
                  setState(() {
                    selectedCity = newCity; // Atualiza o valor da cidade selecionada
                  });
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  // Salva o objeto de cidade selecionada
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  await prefs.setString('userCity', selectedCity['text']!);
                  await prefs.setString('userCityValue', selectedCity['value']!);

                  Navigator.of(context).pop();

                  completer.complete(); // Completa a Future quando a ação for concluída
                },
                child: const Text('Confirmar'),
              ),
            ],
          );
        },
      );
    },
  );

  return completer.future; // Retorna a Future que será completada
}

  // Salva a cidade manualmente em SharedPreferences
  Future<void> _saveCityManually(BuildContext context, String city) async {
    if (city.isNotEmpty) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userCity', city);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cidade $city salva com sucesso!')),
      );
    }
  }

  // Obtém a cidade com base na localização
  Future<void> getCityFromLocation(BuildContext context) async {
    try {
      print('Tentando obter a posição atual...');
      
      // Obtém a posição atual do usuário
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      print('Posição obtida: ${position.latitude}, ${position.longitude}');

      // Verifica se há conexão com a internet (opcional, mas recomendado)
      if (!(await _checkInternetConnection())) {
        throw 'Sem conexão com a internet';
      }

      // Usa o pacote geocoding para obter a cidade a partir das coordenadas (latitude e longitude)
      print('Tentando fazer geocodificação...');
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      print('Placemarks obtidos: $placemarks');

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;

        // Verifica se "locality" (cidade) está disponível
        String city = place.locality ?? "Cidade não encontrada";

        // Se a cidade não for encontrada, tenta buscar outros campos, como região administrativa ou sub-localidade
        if (city == "Cidade não encontrada") {
          city = place.administrativeArea ?? place.subAdministrativeArea ?? "Localidade desconhecida";
        }

        print('Cidade obtida: $city');

        // Salva a cidade detectada
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userCity', city);

        // Exibe a cidade detectada
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Localização detectada'),
              content: Text('Você está acessando de $city.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Ok'),
                ),
              ],
            );
          },
        );
      } else {
        // Caso nenhum placemark seja encontrado, exibe um erro
        throw 'Nenhum dado de localização encontrado';
      }
    } catch (e, stacktrace) {
      // Em caso de erro, imprime o erro completo para depuração
      print('Erro ao obter localização: $e');
      print('Stacktrace: $stacktrace');

      // Exibe mensagem de erro ao usuário
      //Navigator.of(context).pop();  // Fecha o popup
      await showCitySelectionPopup(context);
    }
  }

  // Função para verificar se há conexão com a internet (opcional)
  Future<bool> _checkInternetConnection() async {
    try {
      final result = await Geolocator.isLocationServiceEnabled();
      return result; // Retorna true se o serviço de localização estiver ativo
    } catch (e) {
      print('Erro ao verificar conexão com a internet: $e');
      return false;
    }
  }

  Future<bool> hasCitySaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('userCity');
  }

  Future<String?> getCity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('userCity');
  }
}