<?php

require_once('..' . DIRECTORY_SEPARATOR . 'Model' . DIRECTORY_SEPARATOR . 'Base.php');

class Tb_Tarefa extends Base
{
    private $id_tarefa;
    private $id_usuario;
    private $nm_tarefa;
    private $txt_descricao;
    private $dt_criacao;
    private $status;

    function __construct($p_banco)
    {
        parent::__construct($p_banco);
    }

    // Setters
    function SetIdTarefa($i_id_tarefa) {
        $this->id_tarefa = $i_id_tarefa;
    }

    function SetIdUsuario($i_id_usuario) {
        $this->id_usuario = $i_id_usuario;
    }

    function SetNmTarefa($nome) {
        $this->nm_tarefa = $nome;
    }

    function SetTxtDescricao($descricao) {
        $this->txt_descricao = $descricao;
    }

    function SetDtCriacao($data) {
        $this->dt_criacao = $data;
    }

    function SetStatus($status) {
        $this->status = $status;
    }

    // Métodos
    public function Inserir()
    {
        try 
        {
            $stmt = $this->conexao->prepare("
                INSERT INTO tb_tarefa (id_usuario, id_tarefa, nm_tarefa, txt_descricao, status)
                VALUES (:id_usuario, nextval('seq_id_tarefa'), :nm_tarefa, :txt_descricao, :status)
            ");
            $stmt->bindValue(':id_usuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->bindValue(':nm_tarefa', $this->nm_tarefa, PDO::PARAM_STR);
            $stmt->bindValue(':txt_descricao', $this->txt_descricao, PDO::PARAM_STR);
            $stmt->bindValue(':status', $this->status, PDO::PARAM_BOOL);
            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();

            $this->banco->setMensagem(1, "Tarefa inserida com sucesso");
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }

    public function Alterar()
    {
        try 
        {
            $stmt = $this->conexao->prepare("
                UPDATE tb_tarefa SET 
                    nm_tarefa = :nm_tarefa, 
                    txt_descricao = :txt_descricao,
                    status = :status
                WHERE id_tarefa = :id_tarefa
            ");
            $stmt->bindValue(':nm_tarefa', $this->nm_tarefa, PDO::PARAM_STR);
            $stmt->bindValue(':txt_descricao', $this->txt_descricao, PDO::PARAM_STR);
            $stmt->bindValue(':status', $this->status, PDO::PARAM_BOOL);
            $stmt->bindValue(':id_tarefa', $this->id_tarefa, PDO::PARAM_INT);

            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();

            $this->banco->setMensagem(1, "Tarefa alterada com sucesso");
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
            $stmt = $this->conexao->prepare("DELETE FROM tb_tarefa WHERE id_tarefa = :id_tarefa");
            $stmt->bindValue(':id_tarefa', $this->id_tarefa, PDO::PARAM_INT);

            $this->conexao->beginTransaction();
            $stmt->execute();
            $this->conexao->commit();

            $this->banco->setMensagem(1, "Tarefa excluída com sucesso");
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
            $sql = "SELECT * FROM tb_tarefa WHERE id_tarefa = " . $this->id_tarefa;
            $consulta = $this->conexao->query($sql);
            $ret = $consulta->fetch(PDO::FETCH_ASSOC);

            if (!$ret) {
                throw new Exception("Tarefa não localizada");
            }

            $this->banco->setMensagem(1, "Consulta realizada com sucesso");
            $this->banco->setDados(1, $ret);
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }

    public function ListarPorUsuario()
    {
        try 
        {
            $stmt = $this->conexao->prepare("SELECT * FROM tb_tarefa WHERE id_usuario = :id_usuario ORDER BY dt_criacao DESC");
            $stmt->bindValue(':id_usuario', $this->id_usuario, PDO::PARAM_INT);
            $stmt->execute();
            $ret = $stmt->fetchAll();

            $this->banco->setMensagem(1, "Tarefas listadas com sucesso");
            $this->banco->setDados(count($ret), $ret);
        } 
        catch (Exception $e) 
        {
            throw new Exception($e->getMessage());
        }
    }
}