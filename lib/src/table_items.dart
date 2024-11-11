class TableItems {
  final String nome;
  final int idade;
  final int id;
  final String profession;

  TableItems({required this.nome, required this.idade, required this.id, required this.profession});

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'idade': idade,
      'id': id,
      'profession': profession,
    };
  }
}
