import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import '../models/transacao.dart';

class DetalhesFinanceirosScreen extends StatelessWidget {
  const DetalhesFinanceirosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado")),
      );
    }

    // Paleta de cores para as categorias
    final cores = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.brown,
      Colors.cyan,
      Colors.indigo,
      Colors.pink,
      Colors.grey,
      Colors.black,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Resumo de Gastos")),
      body: StreamBuilder<List<Transacao>>(
        stream: FirestoreService().listarTransacoes(user.uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final transacoes = snapshot.data!;
          final despesas = transacoes
              .where((t) => t.tipo.toLowerCase() == 'despesa')
              .toList();

          // 🔹 Agrupar por categoria
          final Map<String, double> despesasPorCategoria = {};
          for (var d in despesas) {
            despesasPorCategoria[d.categoria] =
                (despesasPorCategoria[d.categoria] ?? 0) + d.valor;
          }

          // 🔹 Criar gráfico
          final sections = despesasPorCategoria.entries
              .toList()
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key;
                final e = entry.value;
                final cor =
                    cores[index %
                        cores.length]; // alterna cores se tiver mais categorias

                return PieChartSectionData(
                  value: e.value,
                  showTitle: false, // 🔹 sem título dentro da fatia
                  color: cor, // 🔹 cor aplicada na fatia
                  radius: 40, // tamanho da fatia
                );
              })
              .toList();

          final reais = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

          return Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: PieChart(PieChartData(sections: sections)),
              ),

              const SizedBox(height: 12),
              // 🔹 Legenda
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: despesasPorCategoria.entries
                    .toList()
                    .asMap()
                    .entries
                    .map((entry) {
                      final index = entry.key;
                      final e = entry.value;
                      final cor = cores[index % cores.length];

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, color: cor, size: 14),
                          const SizedBox(width: 4),
                          Text(e.key),
                          //Text("${e.key} - R\$ ${e.value.toStringAsFixed(2)}"),
                        ],
                      );
                    })
                    .toList(),
              ),

              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: despesas.length,
                  itemBuilder: (context, index) {
                    final d = despesas[index];
                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10.0), // 🔹 controla espaçamento
                      title: Row(
                        children: [
                          Expanded(
                            flex: 1, // largura fixa proporcional
                            child: Text(d.categoria, 
                            textAlign: TextAlign.left, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              DateFormat('dd/MM/yyyy').format(d.data),
                              textAlign: TextAlign.left, style: TextStyle(fontSize: 14),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              reais.format(d.valor),
                              textAlign: TextAlign.right, style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
