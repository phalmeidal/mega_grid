class TableItems {
  final String nome;
  final int idade;
  final int id;

  TableItems({required this.nome, required this.idade, required this.id});

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      'id': id,
    };
  }
}
