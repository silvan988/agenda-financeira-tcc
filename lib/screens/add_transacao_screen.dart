import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTransacaoScreen extends StatefulWidget {
  const AddTransacaoScreen({super.key});

  @override
  State<AddTransacaoScreen> createState() => _AddTransacaoScreenState();
}

class _AddTransacaoScreenState extends State<AddTransacaoScreen> {
  final _valorController = TextEditingController();
  String? _categoriaSelecionada;
  String _tipo = "despesa";
  final DateTime _data = DateTime.now();
  final _complementoController = TextEditingController(); 

  Future<void> _salvarTransacao() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final textoLimpo = _valorController.text.replaceAll(',', '.').trim();
    final valor = double.tryParse(textoLimpo);
    if (valor == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Digite um valor válido")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('transacoes')
        .add({
          'tipo': _tipo,
          'valor': valor,
          'categoria': _categoriaSelecionada, // ✅ salva como String'
          'data': Timestamp.fromDate(_data), // ✅ salva como Timestamp
          'complemento': _complementoController.text, // 🔹 salva complemento
    });
    if (!mounted) return; 
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Adicionar Transação")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextField(
                controller: _valorController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: r"Valor (R$)",
               /// OU  labelText: r"Valor (R$)",
                  hintText: "Ex: 10,50)",
                  ),
                
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('usuarios')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection('categorias')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final categorias = snapshot.data!.docs.map((doc) => doc['nome'] as String).toList();

                  return DropdownButtonFormField<String>(
                    initialValue: _categoriaSelecionada,
                    decoration: const InputDecoration(
                      labelText: "Categoria",
                      border: OutlineInputBorder(),
                    ),
                    items: categorias.map((String categoria) {
                      return DropdownMenuItem<String>(
                        value: categoria,
                        child: Text(categoria),
                      );
                    }).toList(),
                    onChanged: (novaCategoria) {
                      _categoriaSelecionada = novaCategoria;
                    },
                    validator: (value) => value == null ? "Selecione uma categoria" : null,
                  );
                },
              ),

              const SizedBox(height: 10),
              TextField(
                controller: _complementoController,
                maxLength: 100, // 🔹 Limita a 100 caracteres
                decoration: const InputDecoration(
                  labelText: "Complemento (opcional)",
                  hintText: "Adicione detalhes sobre a transação...",
                ),
              ),
              const SizedBox(height: 10),
              DropdownButton<String>(
                value: _tipo,
                items: const [
                  DropdownMenuItem(value: "despesa", child: Text("Despesa")),
                  DropdownMenuItem(value: "receita", child: Text("Receita")),
                ],
                onChanged: (value) {
                  setState(() {
                    _tipo = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvarTransacao,
                style: ElevatedButton.styleFrom(                  
                  backgroundColor: const Color.fromARGB(255, 59, 131, 240),  // cor pastel diferente
                  foregroundColor: Colors.white, // cor do texto
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // cantos arredondados
                  ),
                ),
                child: Text("Salvar",
                  style: const TextStyle(
                    fontSize: 18, // aumenta a fonte
                    fontWeight: FontWeight.bold, // deixa em negrito
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}