class Tarefa {
  final int idTarefa;
  final int idUsuario;
  final String nome;
  final String descricao;
  final String dataCriacao;
  final bool status;

  Tarefa({
    required this.idTarefa,
    required this.idUsuario,
    required this.nome,
    required this.descricao,
    required this.dataCriacao,
    required this.status,
  });

  factory Tarefa.fromJson(Map<String, dynamic> json) {
    return Tarefa(
      idTarefa: int.parse(json['id_tarefa'].toString()),
      idUsuario: int.parse(json['id_usuario'].toString()),
      nome: json['nm_tarefa'],
      descricao: json['txt_descricao'],
      dataCriacao: json['dt_criacao'],
      status: json['status'].toString() == 'true',
    );
  }
}

// Class tarefa para representar uma tarefa, facilitando o modo como são acessados e manupulados os dados.