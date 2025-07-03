import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Login', home: LoginScreen());
  }
}

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  _CadastroScreen createState() => _CadastroScreen();
}

class _CadastroScreen extends State<CadastroScreen> {
  final TextEditingController _cadastro_usuarioController =
      TextEditingController();
  final TextEditingController _cadastro_senhaController =
      TextEditingController();
  final TextEditingController _cadastro_emailController =
      TextEditingController();

  Future<void> _cadastrar() async {
    try {
      final url = Uri.parse(
        'http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php',
      );
      final response = await http.post(
        url,
        body: {
          'oper': 'Inserir',
          'nm_usuario': _cadastro_usuarioController.text,
          'em_email': _cadastro_emailController.text,
          'pwd_usuario': _cadastro_senhaController.text,
        },
      );
      // final Map<String, dynamic> data = json.decode(response.body);
      // final mensagem = data['Mensagem'] ?? 'Erro desconhecido';
      String mensagem;
      try {
        final Map<String, dynamic> data = json.decode(response.body);
        mensagem = data['Mensagem'] ?? 'Erro desconhecido';
      } catch (e) {
        mensagem = 'Erro inesperado: ${response.body}';
      }

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Cadastro'),
          content: Text(mensagem),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // fecha diálogo
                if (mensagem.contains('sucesso')) {
                  Navigator.of(
                    context,
                  ).pop(); // volta pra tela anterior (login)
                }
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Erro'),
          content: Text('Erro ao cadastrar: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro de Usuário')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cadastro_usuarioController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _cadastro_emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _cadastro_senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),

            SizedBox(height: 20),
            ElevatedButton(onPressed: _cadastrar, child: Text('Cadastrar')),
          ],
        ),
      ),
    );
  } //Build
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  // Método para realizar o login
  Future<void> _logar() async {
  final url = Uri.parse(
    'http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php',
  );
  final response = await http.post(
    url,
    body: {
      'oper': 'Login',
      'em_email': _emailController.text,
      'pwd_usuario': _senhaController.text,
    },
  );

  final Map<String, dynamic> responseData = json.decode(response.body);
  var mensagem = responseData['Mensagem'];

  print('👉 response.body: ${response.body}');
  print('👉 responseData: $responseData');

  if (mensagem == 'ok') {
    if (responseData['dados'] != null) {
      final dados = responseData['dados'];
      final email = dados['email']?.toString() ?? '';
      final usuario = dados['usuario']?.toString() ?? '';
      final idUsuario = dados['id_usuario']?.toString() ?? '';

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('usuario', usuario);
      await prefs.setString('id_usuario', idUsuario);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PerfilScreen(nomeUsuario: usuario, emailUsuario: email, idUsuario: idUsuario),
        ),
      );

      mensagem = 'Login realizado com sucesso!';
    } else {
      mensagem = 'Dados do usuário ausentes na resposta.';
    }
  } else {
    mensagem = 'Email ou senha inválidos';
  }

  // Exibe diálogo com a mensagem (sucesso ou erro)
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Resultado'),
      content: Text(mensagem),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: _logar, child: Text('Logar')),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => CadastroScreen()),
                );
              },
              child: Text('Criar conta'),
            ),
          ],
        ),
      ),
    );
  }
}

class PerfilScreen extends StatefulWidget {
  final String nomeUsuario;
  final String emailUsuario;
  final String idUsuario; // Torne o campo final

  const PerfilScreen({
    super.key,
    required this.nomeUsuario,
    required this.emailUsuario,
    required this.idUsuario,
  });

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late String _nomeUsuario;
  late String _emailUsuario;
  late String _idUsuario; // Variável local para gerenciar o estado

  @override
  void initState() {
    super.initState();
    _nomeUsuario = widget.nomeUsuario;
    _emailUsuario = widget.emailUsuario;
    _idUsuario = widget.idUsuario; // Inicializa o estado com os dados do widget
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // ou prefs.remove('id_usuario');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  Future<void> _editarUsuario() async {
    final TextEditingController novoNomeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Usuário'),
        content: TextField(
          controller: novoNomeController,
          decoration: InputDecoration(labelText: 'Novo Nome de Usuário'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse(
                'http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php',
              );
              final response = await http.post(
                url,
                body: {
                  'oper': 'Alterar',
                  'em_email': _emailUsuario,
                  'novo_nome': novoNomeController.text,
                },
              );

              final Map<String, dynamic> data = json.decode(response.body);
              final mensagem = data['Mensagem'] ?? 'Erro desconhecido';

              Navigator.of(context).pop();

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Resultado'),
                  content: Text(mensagem),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );

              if (data['Mensagem'] == 'Usuário atualizado com sucesso') {
                setState(() {
                  _nomeUsuario =
                      novoNomeController.text; // Atualize o estado local
                });
              }
            },
            child: Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _excluirUsuario() async {
    final url = Uri.parse(
      'http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php',
    );
    final response = await http.post(
      url,
      body: {'oper': 'Excluir', 'em_email': _emailUsuario},
    );

    final Map<String, dynamic> data = json.decode(response.body);
    final mensagem = data['Mensagem'] ?? 'Erro desconhecido';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Resultado'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (data['Mensagem'] == 'Usuário excluído com sucesso') {
                Navigator.of(context).pop(); // Go back to the previous screen
              }
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bem-vindo, $_nomeUsuario!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _editarUsuario,
              child: Text('Editar Usuário'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _excluirUsuario, // Conecta o método de exclusão
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Excluir Usuário'),
            ),
            ElevatedButton(
              onPressed: _logout, // Conecta o método de logout
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Fazer Logout'),
            ),
          ],
        ),
      ),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {

   Future<List<Map<String, dynamic>>> _buscarTarefas() async {
    final prefs = await SharedPreferences.getInstance();
    final idUsuario = prefs.getString('id_usuario') ?? '';

    final url = Uri.parse(
      'http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudTarefa.php');
      final response = await http.post(url, body: {
      'oper': 'Listar',
      'id_usuario': idUsuario,
      });
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['Mensagem'] == 'ok') {
        return List<Map<String, dynamic>>.from(data['dados'] ?? []);
      } else {
        throw Exception('Erro ao buscar tarefas: ${data['Mensagem']}');
      }
    }

    List<Map<String, dynamic>> _tarefas = _buscarTarefas();


  void _mostrarDialogCadastro() {
    final nomeController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Nova Tarefa'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nomeController,
                decoration: InputDecoration(labelText: 'Nome da Tarefa'),
              ),
              TextField(
                controller: descController,
                decoration: InputDecoration(labelText: 'Descrição da Tarefa'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: Text('Cancelar'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            child: Text('Cadastrar'),
            onPressed: () async {
              final nome = nomeController.text;
              final descricao = descController.text;

              // 🧠 Recupera id_usuario ou outro identificador do usuário
              final prefs = await SharedPreferences.getInstance();
              final usuario = prefs.getString('usuario') ?? '';

              final url = Uri.parse(
                'http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudTarefa.php',
              );
              final response = await http.post(url, body: {
                'oper': 'Inserir',
                'titulo': nome,
                'descricao': descricao,
                'usuario': usuario, // ou id_usuario, se estiver salvo
              });

              String mensagem;
              try {
                final jsonData = json.decode(response.body);
                mensagem = jsonData['Mensagem'] ?? 'Erro desconhecido';
              } catch (_) {
                mensagem = 'Erro inesperado: ${response.body}';
              }

              if (mensagem.contains('sucesso')) {
                setState(() {
                  _tarefas.add({'titulo': nome, 'descricao': descricao});
                });
              }

              Navigator.of(context).pop(); // fecha o diálogo

              // feedback final
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Cadastro'),
                  content: Text(mensagem),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tarefas')),
      body: _tarefas.isEmpty
          ? Center(child: Text('Nenhuma tarefa ainda.'))
          : ListView.builder(
              itemCount: _tarefas.length,
              itemBuilder: (context, index) => ListTile(
                title: Text(_tarefas[index]['titulo'] ?? ''),
                subtitle: Text(_tarefas[index]['descricao'] ?? ''),
              ),
            ),
      floatingActionButton: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 32.0, bottom: 16),
          child: FloatingActionButton(
            onPressed: _mostrarDialogCadastro,
            child: Icon(Icons.add),
          ),
        ),
      ),
    );
  }
}

