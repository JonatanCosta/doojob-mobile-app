import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:do_job_app/painel/model/painel_page_service.dart';

class StepForm extends StatefulWidget {
  @override
  _StepFormState createState() => _StepFormState();
}

class _StepFormState extends State<StepForm> {
  int _currentStep = 0;

  // Controladores para os dados dos formulários
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _feetController = TextEditingController();
  final _hairController = TextEditingController();
  final _eyesController = TextEditingController();
  final _waistController = TextEditingController();
  final _hipController = TextEditingController();

  final List<GlobalKey<FormState>> _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Máscara de telefone
  final phoneMaskFormatter = MaskTextInputFormatter(
    mask: '(##) # ####-####', 
    filter: { "#": RegExp(r'[0-9]') },
  );

  List<Step> _steps() => [
        Step(
          title: Text('Dados Básicos'),
          content: Form(
            key: _formKeys[0],
            child: Column(
              children: [
                SizedBox(height: 5),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o nome';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  inputFormatters: [phoneMaskFormatter],
                  keyboardType: TextInputType.phone,
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Telefone',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o telefone';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: Text('Descrição'),
          content: Form(
            key: _formKeys[1],
            child: Column(
              children: [
                SizedBox(height: 5),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    labelText: 'Descrição (Para atrair os clientes)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira uma descrição';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: Text('Dados Físicos'),
          content: Form(
            key: _formKeys[2],
            child: Column(
              children: [
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(
                    labelText: 'Idade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a idade';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: 'Altura (cm)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a altura';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: 'Peso (kg)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o peso';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Tamanho dos pés',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: ['36', '37', '38', '39', '40'].map((String size) {
                    return DropdownMenuItem<String>(
                      value: size,
                      child: Text(size),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _feetController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira o tamanho dos pés';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cor dos Cabelos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: ['Loiro', 'Castanho', 'Preto', 'Ruivo'].map((String color) {
                    return DropdownMenuItem<String>(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _hairController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a cor dos cabelos';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Cor dos Olhos',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  items: ['Azul', 'Castanho', 'Preto', 'Verde'].map((String color) {
                    return DropdownMenuItem<String>(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (value) {
                    _eyesController.text = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a cor dos olhos';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _waistController,
                  decoration: InputDecoration(
                    labelText: 'Cintura (cm)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a medida da cintura';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _hipController,
                  decoration: InputDecoration(
                    labelText: 'Quadril (cm)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, insira a medida do quadril';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          isActive: _currentStep >= 2,
        ),
      ];

  void _submitForm() async {
    if (_formKeys[_currentStep].currentState!.validate()) {
      _formKeys[_currentStep].currentState!.save();

      final response = await PainelPageService().submitGirlData({
        'name': _nameController.text,
        'email': _emailController.text,
        'description': _descriptionController.text,
        'telephone': phoneMaskFormatter.getUnmaskedText(),
        'age': _ageController.text,
        'height': _heightController.text,
        'weight': _weightController.text,
        'feet': _feetController.text,
        'hair': _hairController.text,
        'eyes': _eyesController.text,
        'waist': _waistController.text,
        'hip': _hipController.text,
      });

      if (response != null) {
        // Exibe uma mensagem de sucesso ou redireciona o usuário
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Dados enviados com sucesso!')),
        );
        // Redireciona o usuário após o envio bem-sucedido
        Navigator.pushNamed(context, '/painel');
      } else {
        // Exibe uma mensagem de erro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Falha ao cadastrar. Tente novamente.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 35.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: Text(
                'Finalize seu cadastro!',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.black, // Cor do título
                ),
              ),
            ),
            Expanded(
              child: Theme(
                data: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary: Color(0xFFFF5252), // Cor para os steps ativos
                    secondary: Colors.grey,     // Cor para os steps inativos
                  ),
                ),
                child: Stepper(
                  currentStep: _currentStep,
                  onStepContinue: () {
                    if (_formKeys[_currentStep].currentState!.validate()) {
                      if (_currentStep < _steps().length - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      } else {
                        _submitForm(); // Submete o formulário ao completar o último step
                      }
                    }
                  },
                  onStepCancel: () {
                    if (_currentStep > 0) {
                      setState(() {
                        _currentStep--;
                      });
                    }
                  },
                  steps: _steps(),
                  controlsBuilder: (BuildContext context, ControlsDetails details) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ElevatedButton(
                            onPressed: details.onStepContinue,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFFF5252),
                              minimumSize: Size(150, 50), // Tamanho maior do botão
                            ),
                            child: Text(
                              _currentStep == _steps().length - 1 ? 'Enviar' : 'Próximo',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          if (_currentStep > 0)
                            ElevatedButton(
                              onPressed: details.onStepCancel,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black, // Cor de fundo do botão anterior
                                minimumSize: Size(150, 50),
                              ),
                              child: Text(
                                'Anterior',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}    