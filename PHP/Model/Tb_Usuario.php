<?php

require_once('..' . DIRECTORY_SEPARATOR . 'Model' . DIRECTORY_SEPARATOR . 'Base.php');

class Tb_Usuario extends Base
{
    private $id_usuario;
    private $em_email;
    private $nm_usuario;
    private $pwd_usuario;
    private $novo_nome;


    public function SetNovoNome($novo_nome) {
        $this->novo_nome = $novo_nome;
    }

    public function GetNovoNome() {
        return $this->novo_nome;
    }

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    function SetNmUsuario($p_NmUsuario)
    {
        $this->nm_usuario = $p_NmUsuario;
    }
    function SetEmail($p_Email)
    {
        $this->em_email = $p_Email;
    }
    function SetIdUsuario($p_IdUsuario)
    {
        $this->id_usuario = $p_IdUsuario;
    }
    function SetPwdUsuario($p_PwdUsuario)
    {
        $this->pwd_usuario = $p_PwdUsuario;
    }
 

    public function verificaExistencia()
    {
        $consulta = $this->conexao->query(
            "SELECT 1 FROM Tb_Usuario where em_email = ". $this->em_email);

        $ret = $consulta->fetch(PDO::FETCH_ASSOC);
        if (!$ret) 
        {
            throw new Exception("Email nao Localizado");
        }

        return $ret;
    }
    public function verificaLogin()
    {
        try
        {
            $stmt = $this->conexao->prepare(
            "SELECT * FROM Tb_Usuario WHERE em_email = :email AND pwd_usuario = :senha"
            );
        
            $stmt->bindParam(':email', $this->em_email);
            $stmt->bindParam(':senha', $this->pwd_usuario);
            $stmt->execute();
        
            $ret = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($ret) {
            $this->id_usuario = $ret['id_usuario'];
            $this->nm_usuario = $ret['nm_usuario'];
            $this->em_email = $ret['em_email'];
        }
        }
        catch(Exception $e)
        {
            $this->banco->setMensagem(0, "Usuario ou senha incorretos");
            
        }
        return $ret;
    }

    public function buscaUsuario()
    {

        $sql = "SELECT * FROM tb_usuario WHERE id_usuario = " . $this->id_usuario;

        $consulta = $this->conexao->query($sql);
        $ret = $consulta->fetch(PDO::FETCH_ASSOC);
        if (!$ret) 
        {
            throw new Exception("Usuario nao Localizado");
        }
        return $ret;
    }

    public function Inserir(){
        try 
        {
            $this->verificaExistencia();
            $this->banco->setMensagem(0, "Usuario ja Cadastrado");
        } 
        catch (Exception $e) 
        {
            try{
                $stmt = $this->conexao->prepare("INSERT INTO TB_USUARIO(id_usuario, nm_usuario,pwd_usuario, em_email) VALUES (nextval('seq_id_user'), :NmUsuario, :PwdUsuario, :email)");
            $stmt->bindValue(':email', $this->em_email, PDO::PARAM_STR);        
            $stmt->bindValue(':NmUsuario' , $this->nm_usuario , PDO::PARAM_STR);
            $stmt->bindValue(':PwdUsuario' , $this->pwd_usuario , PDO::PARAM_STR);

           
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit(); 
    
            $this->banco->setMensagem(1, "Usuario incluso com sucesso");
            } catch (Exception $e) 
            {
                echo json_encode(['Mensagem']["Erro ao inserir usuario: " . $e->getMessage()]);
            }
            
        }
    }

    public function AlterarDadosUsuario(){
        try 
        {
            $stmt = $this->conexao->prepare("UPDATE TB_Usuario  set  nm_usuario = :NovoNome WHERE nm_usuario = :NmUsuario");
            $stmt->bindValue(':NovoNome', $this->novo_nome, PDO::PARAM_STR);
            $stmt->bindValue(':NmUsuario', $this->nm_usuario, PDO::PARAM_STR);
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();
            $this->banco->setMensagem(1, "Dados do usuario Alterados");
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }
 
    public function Excluir()
    {
        try 
        {
            $stmt = $this->conexao->prepare(
                'Delete From TB_Usuario WHERE em_email = :email'
            );

            $stmt->bindValue(':email', $this->em_email, PDO::PARAM_STR);
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();
            $this->banco->setMensagem(1, "Usuario Excluido com Sucesso");
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }

    public function Consultar()
    {
        try 
        {
            $ret = $this->buscaUsuario();
            $this->banco->setMensagem(1, "Consulta efetuada com Sucesso");
            $this->banco->setDados(count($ret), $ret);
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }

    public function Listar()
    {
        $ret = $this->conexao->query("SELECT id_usuario, nm_usuario, pwd_usuario FROM Tb_Usuario;");
        $ret = $ret->fetchAll();
        $this->banco->setMensagem(1, "Sucesso na Pesquisa");
        $this->banco->setDados(count($ret), $ret);
    }

    public function Login()
    {
        try
        {
            $this->verificaLogin();
            $this->banco->setMensagem(1, "ok");
            $this->banco->setDados(1, ["email" => $this->em_email,
                                       "usuario" => $this->nm_usuario,
                                       "id_usuario" => $this->id_usuario]);
        }
        catch (Exception $e) 
        {
            $this->banco->setMensagem(0, $e->getMessage());
        }
    }
}
