import 'package:flutter/material.dart';          // Widgets e UI
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Autenticação

class CategoriasScreen extends StatelessWidget {
  const CategoriasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Minhas Categorias")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .collection('categorias')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                child: ListTile(
                  title: Text(doc['nome']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(uid)
                          .collection('categorias')
                          .doc(doc.id)
                          .delete();
                    },
                  ),
                  onTap: () {
                    _editarCategoria(context, uid, doc.id, doc['nome']);
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _adicionarCategoria(context, uid),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _adicionarCategoria(BuildContext context, String uid) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nova Categoria"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "Nome")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .collection('categorias')
                  .add({'nome': controller.text});
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }

  void _editarCategoria(BuildContext context, String uid, String id, String nomeAtual) {
    final controller = TextEditingController(text: nomeAtual);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Editar Categoria"),
        content: TextField(controller: controller, decoration: const InputDecoration(labelText: "Nome")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance
                  .collection('usuarios')
                  .doc(uid)
                  .collection('categorias')
                  .doc(id)
                  .update({'nome': controller.text});
              Navigator.pop(context);
            },
            child: const Text("Salvar"),
          ),
        ],
      ),
    );
  }
}
