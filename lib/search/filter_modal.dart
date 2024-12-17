import 'package:flutter/material.dart';
import 'package:do_job_app/feed/api_service.dart';

class FilterModal extends StatefulWidget {
  final Map<String, List<Map<String, dynamic>>> filters;
  final Function(Map<String, List<Map<String, dynamic>>>) onApplyFilters;

  const FilterModal({
    Key? key,
    required this.filters,
    required this.onApplyFilters,
  }) : super(key: key);

  @override
  _FilterModalState createState() => _FilterModalState();
}

class _FilterModalState extends State<FilterModal> {
  final ApiService apiService = ApiService();
  bool isLoading = false; 
  late Map<String, List<Map<String, dynamic>>> localFilters;


  @override
  void initState() {
    super.initState();

    localFilters = {
      for (var key in widget.filters.keys)
        key: widget.filters[key]!.map((filter) => {...filter}).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      height: MediaQuery.of(context).size.height * 0.9, // Ocupa 90% da tela
      decoration: const BoxDecoration(
        color: Colors.white, // Fundo branco
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)), // Borda superior arredondada
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
                const Text('Locais:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: localFilters['locals']!
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
                            color: local['selected'] ?? false
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Services
                const Text('Serviços:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: widget.filters['services']
                      !.map<Widget>(
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
                            color: service['selected'] ?? false
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Payments
                const Text('Pagamentos:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: localFilters['payments']
                      !.map<Widget>(
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
                            color: payment['selected'] ?? false
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 16),

                // Prices
                const Text('Duração:',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: localFilters['prices']
                      !.map<Widget>(
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
                            color: price['selected'] ?? false
                                ? Colors.white
                                : Colors.black,
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
                      // Dispara o callback com os filtros atualizados
                      widget.onApplyFilters(localFilters);
                      Navigator.pop(context);
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
