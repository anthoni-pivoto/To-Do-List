<?php
ini_set('display_errors', '1');
ini_set('display_startup_errors', '1');
error_reporting(E_ALL);

header('Content-Type: application/json; charset=utf-8');

require_once __DIR__ . '/../Model/Tb_Tarefa.php';
require_once __DIR__ . '/../Model/Banco.php';

// Parâmetros recebidos via HTTP
$i_id_tarefa    = isset($_REQUEST['id_tarefa']) ? $_REQUEST['id_tarefa'] : "";
$i_id_usuario   = isset($_REQUEST['id_usuario']) ? $_REQUEST['id_usuario'] : "";
$s_nm_tarefa    = isset($_REQUEST['nm_tarefa']) ? $_REQUEST['nm_tarefa'] : "";
$s_txt_descricao = isset($_REQUEST['txt_descricao']) ? $_REQUEST['txt_descricao'] : "";
$s_dt_criacao   = isset($_REQUEST['dt_criacao']) ? $_REQUEST['dt_criacao'] : "";
$b_status       = isset($_REQUEST['status']) ? filter_var($_REQUEST['status'], FILTER_VALIDATE_BOOLEAN) : false;

$Oper = isset($_REQUEST['oper']) ? $_REQUEST['oper'] : "";

try {
    $banco = new Banco(null, null, null, null, null, null);
    $Tb_Tarefa = new Tb_Tarefa($banco);

    $Tb_Tarefa->setOper($Oper);
    $Tb_Tarefa->setIdTarefa($i_id_tarefa);
    $Tb_Tarefa->setIdUsuario($i_id_usuario);
    $Tb_Tarefa->setNmTarefa($s_nm_tarefa);
    $Tb_Tarefa->setTxtDescricao($s_txt_descricao);
    $Tb_Tarefa->setDtCriacao($s_dt_criacao);
    $Tb_Tarefa->setStatus($b_status);

    switch ($Oper) {
        case 'Inserir':
            $Tb_Tarefa->Inserir();
            break;
        case 'Alterar':
            $Tb_Tarefa->Alterar();
            break;
        case 'Excluir':
            $Tb_Tarefa->Excluir();
            break;
        case 'Consultar':
            $Tb_Tarefa->Consultar();
            break;
        case 'Listar':
            $Tb_Tarefa->ListarPorUsuario();
            break;
        default:
            $banco->setMensagem(1, 'Operação informada não tratada');
            break;
    }

    echo $banco->getRetorno();
    unset($banco);
} catch (Exception $e) {
    if (isset($banco)) {
        $banco->setMensagem(1, $e->getMessage());
        echo $banco->getRetorno();
        unset($banco);
    } else {
        echo $e->getMessage();
    }
}
?>