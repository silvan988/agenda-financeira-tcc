import 'package:cloud_firestore/cloud_firestore.dart'; // 🔹 necessário para Timestamp

class Transacao {
  final String id;
  final String uid;
  final String tipo;
  final double valor;
  final String categoria;
  final DateTime data;
  final String? complemento; // 🔹 nova propriedade opcional

  Transacao({
    required this.id,
    required this.uid,
    required this.tipo,
    required this.valor,
    required this.categoria,
    required this.data,
    this.complemento,
  });

  factory Transacao.fromFirestore(DocumentSnapshot doc) {
    final dados = doc.data() as Map<String, dynamic>;

    return Transacao(
      id: doc.id,
      uid: dados['uid']?.toString() ?? '',
      tipo: dados['tipo']?.toString() ?? '',
      categoria: dados['categoria']?.toString() ?? '',
      valor: (dados['valor'] is int || dados['valor'] is double)
          ? (dados['valor'] as num).toDouble()
          : double.tryParse(dados['valor'].toString()) ?? 0.0,
      data: dados['data'] is Timestamp
          ? (dados['data'] as Timestamp).toDate()
          : DateTime.tryParse(dados['data'].toString()) ?? DateTime.now(),
      complemento: dados['complemento']?.toString(), // 🔹 nova propriedade
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'tipo': tipo,
      'valor': valor.toDouble(),
      'categoria': categoria,
      'data': Timestamp.fromDate(data), // 🔹 sempre salva como Timestamp
    };
  }
}