import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumoFinanceiro extends StatelessWidget {
  final double totalReceitas;
  final double totalDespesas;
  final String nomeUsuario;

  const ResumoFinanceiro({
    super.key,
    required this.totalReceitas,
    required this.totalDespesas,
    required this.nomeUsuario,
  });

  @override
  Widget build(BuildContext context) {
    final saldo = totalReceitas - totalDespesas;
    final formatador = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final dataAtual = DateFormat('dd/MM/yyyy').format(DateTime.now());

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Resumo Financeiro - $nomeUsuario, em $dataAtual",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Receitas:", style: TextStyle(color: Colors.green)),
                Text(formatador.format(totalReceitas),
                    style: const TextStyle(color: Colors.green)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Despesas:", style: TextStyle(color: Colors.red)),
                Text(formatador.format(totalDespesas),
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Saldo:",
                    style: TextStyle(fontWeight: FontWeight.bold, color: saldo >= 0 ? Colors.green : Colors.red)),
                Text(
                  formatador.format(saldo),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: saldo >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}