import 'package:flutter/material.dart';
import 'painel_page_service.dart'; // Certifique-se de que esse serviço está correto.
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({Key? key}) : super(key: key);

  @override
  _PreferencesPageState createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  Map<String, dynamic>? girlData; // Dados que serão carregados
  bool isLoading = true; // Para controlar o estado de carregamento

  @override
  void initState() {
    super.initState();
    _fetchGirlData(); // Carregar os dados quando a página for inicializada
  }

  Future<void> _fetchGirlData() async {
    try {
      final painelService = PainelPageService(); // Instancia o serviço
      final data = await painelService.fetchGirl(); // Busca os dados da modelo
      setState(() {
        girlData = data; // Armazena os dados carregados
        isLoading = false; // Para de carregar
      });
    } catch (e) {
      print('Erro ao buscar os dados: $e');
      setState(() {
        isLoading = false; // Mesmo em caso de erro, para de carregar
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferências'),
        backgroundColor: const Color(0xFFFF5252), // Cor de fundo do AppBar
        foregroundColor: Colors.white, // Cor do texto
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
              ),
            ) // Exibe um loader enquanto carrega
          : Padding(
              padding: const EdgeInsets.only(top: 50.0), // Margem abaixo do AppBar
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.location_city, color: Colors.black), // Ícone da cidade
                    title: Row(
                      children: [
                        const Text('Editar Cidade Ativa'),
                        if (girlData?['cities']?.isEmpty ?? true)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.error,
                              color: Colors.red, // Ícone de exclamação vermelho
                            ),
                          ),
                      ],
                    ),
                    onTap: () {
                     __showActiveCityPopup(context);
                    },
                  ),
                  Divider(color: Colors.grey[400]), // Linha sutil de separação

                  ListTile(
                    leading: const Icon(Icons.price_change, color: Colors.black), // Ícone antes do texto
                    title: const Text('Editar Preços'),
                    onTap: () {
                      __showEditPrices(context);
                    },
                  ),
                  Divider(color: Colors.grey[400]),

                  ListTile(
                    leading: Icon(Icons.place, color: Colors.black), // Ícone antes do texto
                    title: const Text('Editar Locais de Atendimento'),
                    onTap: () {
                      __showEditLocalsPopup(context);
                    },
                  ),
                  Divider(color: Colors.grey[400]), // Linha sutil de separação

                  ListTile(
                    leading: Icon(Icons.payment, color: Colors.black), // Ícone antes do texto
                    title: const Text('Editar Pagamentos Aceitos'),
                    onTap: () {
                      __showPaymentSelectionPopup(context);
                    },
                  ),
                  Divider(color: Colors.grey[400]), // Linha sutil de separação

                  ListTile(
                    leading: Icon(Icons.build, color: Colors.black), // Ícone antes do texto
                    title: const Text('Editar Serviços'),
                    onTap: () {
                      __showServicesPopup(context);
                    },
                  ),
                  Divider(color: Colors.grey[400]), // Linha sutil de separação
                ],
              ),
            ),
    );
  }

  void __showActiveCityPopup(BuildContext context) {
    List<Map<String, String>> cities = [
      {'text': 'Porto Alegre', 'value': 'Porto Alegre'},
      {'text': 'São Paulo', 'value': 'São Paulo'},
      {'text': 'Rio de Janeiro', 'value': 'Rio de Janeiro'},
    ];

    //Map<String, String> selectedCity = cities[0]; // Cidade padrão selecionada
    Map<String, String> selectedCity = (girlData?['cities'] != null && girlData!['cities'].isNotEmpty)
    ? cities.firstWhere((city) => city['text'] == girlData!['cities'][0][0], orElse: () => cities[0])
    : cities[0];
    bool isLoading = false; // Variável para controlar o estado de carregamento

    showDialog(
      context: context,
      barrierDismissible: false, // Impede o fechamento ao clicar fora do popup
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecione a Cidade onde você atua:'),
              content: DropdownButton<Map<String, String>>(
                value: selectedCity,
                isExpanded: true, // Para garantir que o dropdown ocupe toda a largura
                items: cities.map<DropdownMenuItem<Map<String, String>>>((Map<String, String> city) {
                  return DropdownMenuItem<Map<String, String>>(
                    value: city,
                    child: Text(city['text']!), // Exibe o nome da cidade
                  );
                }).toList(),
                onChanged: (Map<String, String>? newCity) {
                  if (newCity != null) {
                    setState(() {
                      selectedCity = newCity; // Atualiza a cidade selecionada
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o popup ao cancelar
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null // Desativa o botão enquanto o loader é exibido
                      : () async {
                          // Inicia o loader
                          setState(() {
                            isLoading = true;
                          });

                          // Simula uma ação de envio (substitua com sua lógica)
                          await PainelPageService().updateGirlCity({
                            'city_name': selectedCity['value']!
                          });

                          // Finaliza o loader e fecha o popup
                          setState(() {
                            isLoading = false;
                          });

                          Navigator.of(context).pop(); // Fecha o popup

                          _fetchGirlData();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Cidade atualizada com sucesso",
                                style: TextStyle(color: Colors.white), // Define a cor do texto como branco
                              ),
                              backgroundColor: Colors.green, // Define o fundo verde
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252), // Fundo branco
                    foregroundColor: Colors.white, // Texto vermelho
                    padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0)
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void __showEditLocalsPopup(BuildContext context) {
    // Lista de locais padrão
    List<Map<String, dynamic>> allLocals = [
      {'id': 1, 'name': 'Hótel'},
      {'id': 2, 'name': 'Motéis'},
      {'id': 3, 'name': 'Residência'},
      {'id': 4, 'name': 'Virtual'},
    ];

    // Verificar quais locais já estão selecionados no `girlData['locals']`
    List<int> selectedLocalIds = girlData?['locals'] != null
      ? (girlData!['locals'] as List).map<int>((local) => local['id'] as int).toList()
      : [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        bool isLoading = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Editar Locais de Atendimento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: allLocals.map((local) {
                  return CheckboxListTile(
                    title: Text(local['name']),
                    value: selectedLocalIds.contains(local['id']),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedLocalIds.add(local['id']);
                        } else {
                          selectedLocalIds.remove(local['id']);
                        }
                      });
                    },
                    activeColor: const Color(0xFFFF5252),
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fecha o popup
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: selectedLocalIds.isEmpty
                      ? null // Desabilita o botão se nenhum local foi selecionado
                      : () async {
                          setState(() {
                            isLoading = true; // Exibe o loader
                          });
                          
                          await PainelPageService().updateGirlLocals({
                            'local_ids': selectedLocalIds
                          });
                          
                          setState(() {
                            isLoading = false;
                          });

                          await _fetchGirlData();
                          
                          Navigator.of(context).pop(); // Fecha o popup
                          // Aqui, você pode adicionar a lógica para salvar os locais selecionados
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252), // Cor do botão
                    foregroundColor: Colors.white, // Cor do texto (branco)
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void __showPaymentSelectionPopup(BuildContext context) {
    // Lista de métodos de pagamento padrão
    List<Map<String, dynamic>> payments = [
      {'id': 1, 'name': 'Dinheiro'},
      {'id': 2, 'name': 'Cartão de Crédito'},
      {'id': 3, 'name': 'Cartão de Débito'},
      {'id': 4, 'name': 'Pix'},
    ];

    // Cria uma lista de pagamentos selecionados com base no girlData
    List<int> selectedPayments = [];
    bool isLoading = false; // Variável para controlar o estado do loader

    if (girlData?['payments'] != null) {
      for (var payment in girlData!['payments']) {
        selectedPayments.add(payment['id']);
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Selecione os Métodos de Pagamento'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: payments.map((payment) {
                  return CheckboxListTile(
                    title: Text(payment['name']),
                    value: selectedPayments.contains(payment['id']),
                    activeColor: const Color(0xFFFF5252), // Define a cor do checkbox
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedPayments.add(payment['id']);
                        } else {
                          selectedPayments.remove(payment['id']);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252), // Cor do botão de salvar
                    foregroundColor: Colors.white,
                  ),
                  onPressed: selectedPayments.isEmpty || isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                          });

                          await PainelPageService().updateGirlPayments({
                            'payment_ids': selectedPayments
                          });

                          // Após finalizar, desabilitar o loader e fechar o popup
                          setState(() {
                            isLoading = false;
                          });

                          await _fetchGirlData();

                          Navigator.of(context).pop();
                        },
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Salvar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void __showServicesPopup(BuildContext context) {
    // Converte os serviços para uma lista de mapas com o status atualizado
    final List<Map<String, dynamic>> services = List<Map<String, dynamic>>.from(girlData?['services'] ?? []);

    showDialog(
      context: context,
      barrierDismissible: false, // Impede que o usuário feche o popup tocando fora
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Editar Serviços'),
                backgroundColor: Colors.black,
                actions: [
                  Container(
                    color: Colors.white, // Fundo branco
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black), // Ícone preto
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Fecha o popup
                      },
                    ),
                  )
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: services.map((service) {
                    String serviceName = service['name'];
                    String selectedValue = service['status'];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          serviceName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: ["Sim", "Talvez", "Não"].map((option) {
                            return Expanded(
                              child: RadioListTile<String>(
                                title: Text(option),
                                value: option,
                                groupValue: selectedValue,
                                onChanged: (value) {
                                  setState(() {
                                    service['status'] = value!;
                                  });
                                },
                                activeColor: const Color(0xFFFF5252),
                              ),
                            );
                          }).toList(),
                        ),
                        const Divider(thickness: 1, color: Colors.grey), // Linha divisória
                      ],
                    );
                  }).toList(),
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                      try {
                        setState(() {
                        isLoading = true;
                      });

                      girlData?['services'] = services;

                      await PainelPageService().updateGirlServices({
                        'services': services
                      });

                      setState(() {
                        isLoading = false;
                      });

                      Navigator.of(dialogContext).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Serviços atualizados com sucesso',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      _fetchGirlData();
                    } catch (e) {
                      print('Erro ao salvar os serviços: $e');
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Erro ao salvar os serviços, tente novamente',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    foregroundColor: Colors.white,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Salvar Serviços'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void __showEditPrices(BuildContext context) {
    final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    if (girlData?['prices'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados de preços não encontrados.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    List<Map<String, dynamic>> prices = List<Map<String, dynamic>>.from(girlData!['prices']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Edição de Preços'),
                backgroundColor: Colors.black,
                actions: [
                  Container(
                    color: Colors.white, // Fundo branco
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black), // Ícone preto
                      onPressed: () {
                        Navigator.of(dialogContext).pop(); // Fecha o popup
                      },
                    ),
                  )
                ],
              ),
              body: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        'Edição de Preços:',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...prices.map((price) {
                      TextEditingController priceController = TextEditingController(
                        text: currencyFormat.format(price['price'] ?? 0),
                      );

                      return Column(
                        children: [
                          Row(
                            children: [
                              Switch(
                                value: price['enabled'] == 1,
                                onChanged: (bool value) {
                                  setState(() {
                                    price['enabled'] = value ? 1 : 0;
                                  });
                                },
                                activeColor: Colors.green,
                                inactiveThumbColor: Colors.grey,
                              ),
                              Expanded(
                                child: Text(
                                  price['description'],
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ),
                              SizedBox(
                                width: 150,
                                child: TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    TextInputFormatter.withFunction(
                                      (oldValue, newValue) {
                                        final number = double.tryParse(newValue.text.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
                                        final formatted = currencyFormat.format(number / 100);
                                        return TextEditingValue(
                                          text: formatted,
                                          selection: TextSelection.collapsed(offset: formatted.length),
                                        );
                                      },
                                    ),
                                  ],
                                  readOnly: price['enabled'] == 0,
                                  decoration: const InputDecoration(
                                    labelText: 'Preço',
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green),
                                    ),
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    String formattedValue = value.replaceAll(RegExp(r'[^0-9]'), '');
                                    double parsedValue = double.tryParse(formattedValue) ?? 0.0;
                                    parsedValue /= 100.0; // Dividido para incluir centavos
                                    price['price'] = parsedValue; // Atualiza o preço no objeto
                                  },
                                ),
                              ),
                            ],
                          ),
                          const Divider(thickness: 1, color: Colors.grey),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            try {
                              bool atLeastOneEnabled = prices.any((price) => price['enabled'] == 1);
                              if (!atLeastOneEnabled) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Pelo menos um serviço deve estar habilitado.'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }

                              setState(() {
                                isLoading = true;
                              });

                              await PainelPageService().updateGirlPrices({
                                'prices': prices
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Preços atualizados com sucesso!'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              await _fetchGirlData();

                              Navigator.of(context).pop();
                            } catch (e) {
                              setState(() {
                                isLoading = false;
                              });
                              print('Erro ao salvar os preços: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Erro ao salvar os preços, tente novamente.'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLoading ? Colors.grey : const Color(0xFFFF5252),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Salvar Alterações',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}