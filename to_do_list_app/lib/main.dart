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

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', email);
      await prefs.setString('usuario', usuario);

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              PerfilScreen(nomeUsuario: usuario, emailUsuario: email),
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
  final String emailUsuario; // Torne o campo final

  const PerfilScreen({
    super.key,
    required this.nomeUsuario,
    required this.emailUsuario,
  });

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late String _nomeUsuario;
  late String _emailUsuario; // Variável local para gerenciar o estado

  @override
  void initState() {
    super.initState();
    _nomeUsuario = widget.nomeUsuario;
    _emailUsuario =
        widget.emailUsuario; // Inicializa o estado com os dados do widget
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
