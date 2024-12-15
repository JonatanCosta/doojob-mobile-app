import 'package:flutter/material.dart';
import 'package:do_job_app/feed/api_service.dart';

class FilterModal extends StatefulWidget {
  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final ApiService apiService = ApiService();
  bool isLoading = true; // Estado do loader
  Map<String, dynamic> filters = {}; // Armazena os filtros retornados do backend

  @override
  void initState() {
    super.initState();
    fetchFilters(); // Chama o fetch dos filtros ao iniciar
  }

  Future<void> fetchFilters() async {
    try {
      final response = await apiService.fetchFilters();
      setState(() {
        filters = response; // Atualiza os filtros
        isLoading = false; // Desativa o loader
      });
    } catch (error) {
      print('Erro ao buscar os filtros: $error');
      setState(() {
        isLoading = false; // Desativa o loader mesmo em caso de erro
      });
    }
  }

  @override
Widget build(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16.0),
    height: MediaQuery.of(context).size.height * 0.9, // Ocupa 90% da tela
    decoration: const BoxDecoration(
      color: Colors.white, // Fundo branco
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // Borda superior arredondada
    ),
    child: isLoading
        ? const Center(
            child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
          )) // Loader enquanto busca os filtros
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              const Text(
                'Filtros',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              // Locals
              const Text('Locais:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: filters['locals']
                    .map<Widget>(
                      (local) => FilterChip(
                        label: Text(local['name']),
                        selected: local['selected'] ?? false,
                        onSelected: (isSelected) {
                          setState(() {
                            local['selected'] = isSelected;
                          });
                        },
                        selectedColor: Colors.green, 
                        checkmarkColor: Colors.white, 
                        labelStyle: TextStyle(
                          color: local['selected'] ?? false ? Colors.white : Colors.black,
                        ), 
                      ),
                      
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Services
              const Text('Serviços:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: filters['services']
                    .map<Widget>(
                      (service) => FilterChip(
                        label: Text(service['name']),
                        selected: service['selected'] ?? false,
                        onSelected: (isSelected) {
                          setState(() {
                            service['selected'] = isSelected;
                          });
                        },
                        selectedColor: Colors.green, 
                        checkmarkColor: Colors.white, 
                        labelStyle: TextStyle(
                          color: service['selected'] ?? false ? Colors.white : Colors.black,
                        ), 
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Payments
              const Text('Pagamentos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: filters['payments']
                    .map<Widget>(
                      (payment) => FilterChip(
                        label: Text(payment['name']),
                        selected: payment['selected'] ?? false,
                        onSelected: (isSelected) {
                          setState(() {
                            payment['selected'] = isSelected;
                          });
                        },
                        selectedColor: Colors.green, 
                        checkmarkColor: Colors.white, 
                        labelStyle: TextStyle(
                          color: payment['selected'] ?? false ? Colors.white : Colors.black,
                        ),
                      ),
                    )
                    .toList(),
              ),

              const SizedBox(height: 16),

              // Prices
              const Text('Duração:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: filters['prices']
                    .map<Widget>(
                      (price) => FilterChip(
                        label: Text(price['name']),
                        selected: price['selected'] ?? false,
                        onSelected: (isSelected) {
                          setState(() {
                            price['selected'] = isSelected;
                          });
                        },
                        selectedColor: Colors.green, 
                        checkmarkColor: Colors.white, 
                        labelStyle: TextStyle(
                          color: price['selected'] ?? false ? Colors.white : Colors.black,
                        ), 
                      ),
                    )
                    .toList(),
              ),

              const Spacer(),

              // Botão de Aplicar Filtros
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para aplicar os filtros
                    Navigator.pop(context, filters); // Retorna os filtros atualizados
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5252),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: const Text(
                    'Aplicar Filtros',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
  );
}
}