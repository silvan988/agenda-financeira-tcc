import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firestore_service.dart';
import '../models/transacao.dart';
import '../widgets/export_util.dart';
import '../widgets/resumo_financeiro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _nomeUsuario = 'Usuário';

  @override
  void initState() {
    super.initState();
    _carregarUsuario(); // Move async call here
  }

  Future<void> _carregarUsuario() async {
    // 🔹 Recupera UID do usuário logado
    final firestore = FirebaseFirestore.instance;

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // 🔹 Busca documento do usuário no Firestore
    final docUsuario = await firestore.collection('usuarios').doc(uid).get();

    final dadosUsuario = docUsuario.data();
    final nomeCompleto = dadosUsuario?['nome'] ?? 'Usuário';
    final nnomeUsuario = nomeCompleto.split(' ').first;
    if (!mounted) return;
    setState(() {
      _nomeUsuario = nnomeUsuario;
    });
  }

  /// 🔹 Método para exportar PDF
  Future<void> _exportarPDF() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final transacoes = await FirestoreService()
        .listarTransacoes(user.uid)
        .first;

    await ExportUtils().exportarPDF(transacoes);
  }

  /// 🔹 Método para logout
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return; // garante que o State ainda existe
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("Usuário não autenticado")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Controle de Gastos"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: StreamBuilder<List<Transacao>>(
        stream: FirestoreService().listarTransacoes(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Nenhuma transação cadastrada"));
          }

          final transacoes = snapshot.data!;
          double totalReceitas = 0;
          double totalDespesas = 0;

          for (var t in transacoes) {
            if (t.tipo.toLowerCase() == 'receita') {
              totalReceitas += t.valor;
            } else {
              totalDespesas += t.valor;
            }
          }

          double percentual = 0;
          if (totalReceitas > 0) {
            percentual = (totalDespesas / totalReceitas) * 100;
          }
          Color corAlerta;
          String mensagemAlerta;

          if (totalDespesas > totalReceitas) {
            corAlerta = Colors.red;
            mensagemAlerta = "Pare!! Gastos ultrapassaram a receita!";
          } else if (percentual == 100) {
            corAlerta = Colors.red;
            mensagemAlerta = "Pare!! Saldo 0,00 para o mês!";
          }else if (percentual >= 85) {
            corAlerta = const Color.fromARGB(255, 235, 133, 126);
            mensagemAlerta = "Gastos passaram de 85% da receita!";
          } else if (percentual >= 60) {
            corAlerta = const Color.fromARGB(255, 228, 226, 148);
            mensagemAlerta = "Gastos passaram de 60% da receita.";
          } else {
            corAlerta = const Color.fromARGB(255, 132, 192, 134);
            mensagemAlerta = "Situação sob controle.";
          }

          final reais = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              ResumoFinanceiro(
                totalReceitas: totalReceitas,
                totalDespesas: totalDespesas,
                nomeUsuario: _nomeUsuario,
              ),

              Card(
                color: corAlerta.withValues(alpha: 0.9),
                margin: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 4,
                  bottom: 8,
                ),
                // shadowColor: corAlerta.withValues(alpha: 0.4),
                elevation: 4,
                child: ListTile(
                  //leading: Icon(Icons.flag, color: corAlerta),
                  title: Text(
                    mensagemAlerta,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  //subtitle: Text("Percentual atual: ${percentual.toStringAsFixed(1)}%", textAlign: TextAlign.center,
                  //style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  //trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ),

              Row(
                children: [
                  const SizedBox(width: 60),
                  // gráfico
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: PieChart(
                      PieChartData(
                        sections: [
                          PieChartSectionData(
                            value: totalReceitas,
                            title: "Receitas",
                            color: Colors.green,
                            showTitle: false,
                          ),
                          PieChartSectionData(
                            value: totalDespesas,
                            title: "Despesas",
                            color: Colors.red,
                            showTitle: false,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 45),

                  Card(
                    elevation: 4,
                    shadowColor: Colors.grey[400],
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Text("Receitas"),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Text("Despesas"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: transacoes.length,
                  itemBuilder: (context, index) {
                    final t = transacoes[index];
                    return ListTile(
                      leading: Icon(
                        t.tipo.toLowerCase() == 'despesa'
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        color: t.tipo.toLowerCase() == 'despesa'
                            ? Colors.red
                            : Colors.green,
                      ),
                      title: Text(reais.format(t.valor)),
                      subtitle: Text(
                        "${t.categoria} - ${DateFormat('dd/MM/yyyy').format(t.data)}",
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 230, 122, 122),
                        ),
                        onPressed: () async {
                          await FirestoreService().deleteTransacao(t.id);
                        },
                      ),
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.blueGrey[50],
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(5),
                            ),
                          ),
                          builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Detalhes da Transação",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  Text("Valor: ${reais.format(t.valor)}"),
                                  Text("Tipo: ${t.tipo}"),
                                  Text("Categoria: ${t.categoria}"),
                                  Text(
                                    "Data: ${DateFormat('dd/MM/yyyy').format(t.data)}",
                                  ),
                                  if (t.complemento != null &&
                                      t.complemento!.isNotEmpty) ...[
                                    const SizedBox(height: 14),
                                    Text("Obs.: ${t.complemento}"),
                                  ],
                                  const SizedBox(height: 20),
                                  ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.close),
                                    label: const Text("Fechar"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }, //onTap
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 2, //Adicionar como padrão
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/categorias');
              break;
            case 2:
              Navigator.pushNamed(context, '/addTransacao');
              break;
            case 3:
              Navigator.pushNamed(context, '/detalhes');
              break;
            case 4:
              _exportarPDF();
              break;
          }
        },
        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home), 
            label: 'Início'),

          BottomNavigationBarItem(
            icon: Icon(Icons.folder),
            label: 'Categorias',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Adicionar',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart),
            label: 'Resumo',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.picture_as_pdf),
            label: 'PDF',
          ),
        ],
      ),
    );
  }
}
