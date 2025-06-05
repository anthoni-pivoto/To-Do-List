import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login',
      home: LoginScreen(),
    );
  }
}

class CadastroScreen extends StatefulWidget{
  @override
  _CadastroScreen createState() => _CadastroScreen();
}

class _CadastroScreen extends State<CadastroScreen>{
  final TextEditingController _cadastro_usuarioController = TextEditingController();
  final TextEditingController _cadastro_senhaController = TextEditingController();

  Future<void> _cadastrar() async{
    final url = Uri.parse('http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php');
    final response = await http.post(
      url,
      body: {
        'oper' : 'Inserir',
        'nm_usuario' : _cadastro_usuarioController.text,
        'pwd_usuario' : _cadastro_senhaController.text,
      },
    );
    final Map<String, dynamic> data = json.decode(response.body);
    final mensagem = data['Mensagem'] ?? 'Erro desconhecido';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cadastro'),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // fecha diálogo
              if (data['Mensagem'] == 'ok') {
                Navigator.of(context).pop(); // volta pra tela anterior (login)
              }
            },
            child: Text('OK'),
          ),
        ])
      );
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
              decoration: InputDecoration(labelText: 'Usuário'),
            ),
            TextField(
              controller: _cadastro_senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cadastrar,
              child: Text('Cadastrar'),
            ),
          ],
        ),
      ),
    );
  } //Build
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _senhaController = TextEditingController();

  @override
  
  // Método para realizar o login
  Future<void> _logar() async {
    final url = Uri.parse('http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php');
    final response = await http.post(
      url,
      body: {
        'oper' : 'Login',
        'nm_usuario': _loginController.text,
        'pwd_usuario': _senhaController.text,
      },
    );
    final Map<String, dynamic> responseData = json.decode(response.body);
    var mensagem = responseData['Mensagem'];
    
    if (mensagem == 'ok') {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id_usuario', responseData['id_usuario'].toString());
    mensagem = 'Login realizado com sucesso!';
    } else {
      mensagem = 'Email ou senha inválidos';
    }

    // Exibe um diálogo com a mensagem de resultado
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

    // Se o login for bem-sucedido, armazena o nickname com shared preferences e navega para a tela de perfil
    if (responseData['Mensagem'] == 'ok') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('nickname', responseData['dados']['usuario']);
      
      Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => PerfilScreen(
        nomeUsuario: responseData['dados']['usuario'],
        ),
      ),
      );
    }
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
              controller: _loginController,
              decoration: InputDecoration(labelText: 'Login'),
            ),
            TextField(
              controller: _senhaController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logar,
              child: Text('Logar'),
            ),
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
  final String nomeUsuario; // Torne o campo final

  PerfilScreen({super.key, required this.nomeUsuario});

  @override
  _PerfilScreenState createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late String _nomeUsuario; // Variável local para gerenciar o estado

  @override
  void initState() {
    super.initState();
    _nomeUsuario = widget.nomeUsuario; // Inicialize com o valor do widget
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
    final TextEditingController _novoNomeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Usuário'),
        content: TextField(
          controller: _novoNomeController,
          decoration: InputDecoration(labelText: 'Novo Nome de Usuário'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final url = Uri.parse('http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php');
              final response = await http.post(
                url,
                body: {
                  'oper': 'Alterar',
                  'nm_usuario': _nomeUsuario,
                  'novo_nome': _novoNomeController.text,
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
                  _nomeUsuario = _novoNomeController.text; // Atualize o estado local
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
    final url = Uri.parse('http://200.19.1.19/20222GR.ADS0010/exemploPDM-I/Controller/CrudUsuario.php');
    final response = await http.post(
      url,
      body: {
        'oper': 'Excluir',
        'nm_usuario': _nomeUsuario,
      },
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
            Text('Bem-vindo, ${widget.nomeUsuario}!', style: TextStyle(fontSize: 24)),
            SizedBox(height: 40),
            ElevatedButton(
            onPressed: _editarUsuario,
            child: Text('Editar Usuário'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
            onPressed: _excluirUsuario, // Conecta o método de exclusão
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Excluir Usuário'),
            ),
            ElevatedButton(
            onPressed: _logout, // Conecta o método de logout
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text('Fazer Logout'),
            ),
          ],
        ),
      ),
    );
  }
}