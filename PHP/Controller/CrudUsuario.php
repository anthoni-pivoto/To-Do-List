<?php
        ini_set('display_errors', '1');
        ini_set('display_startup_errors', '1');
        // define o nível de relatório para todos os erros
        error_reporting(E_ALL);
        
        require_once __DIR__ . '/../Model/Tb_Usuario.php';
        require_once __DIR__ . '/../Model/Banco.php';
        
        $s_nm_usuario   =  isset($_REQUEST['nm_usuario'])?$_REQUEST['nm_usuario']:"";
        $i_id_usuario   =  isset($_REQUEST['id_usuario'])?$_REQUEST['id_usuario']:"";
        $s_pwd_usuario = isset($_REQUEST['pwd_usuario'])?$_REQUEST['pwd_usuario']:"";
        $s_novo_nome = isset($_REQUEST['novo_nome']) ? $_REQUEST['novo_nome'] : "";

      

       /*-------------------------------------------------------------*/

        $Oper = isset($_REQUEST['oper'])    ?$_REQUEST['oper'] :"";
        // $Oper = 'Listar';
       
        try
        {  
            $banco = new Banco(null,null,null,null,null,null);
           
            $Tb_Usuario = new Tb_Usuario($banco);

            $Tb_Usuario->setOper($Oper);
            $Tb_Usuario->SetNmUsuario($s_nm_usuario);
            $Tb_Usuario->SetIdUsuario($i_id_usuario);
            $Tb_Usuario->SetPwdUsuario($s_pwd_usuario);
            $Tb_Usuario->SetNovoNome($s_novo_nome);
     
            switch ($Oper) {
                case 'Inserir':
                    $Tb_Usuario->Inserir();
                    break;  
                case 'Alterar':
                    $Tb_Usuario->AlterarDadosUsuario();
                    break;   
                case 'Excluir':
                    $Tb_Usuario->Excluir();
                    break; 
                case 'Consultar':
                    $Tb_Usuario->Consultar();
                    break;   
                case 'Listar':
                    $Tb_Usuario->Listar();
                    break; 
                case 'Login':
                    $Tb_Usuario->Login();
                    break;   
                default:
                    $banco->setMensagem(1,'Operacao informada nao tratada');
                    break;
            }
            echo $banco->getRetorno();
            unset($banco);
        }
        catch(Exception $e)
        {   
            if (isset($banco))
            {   $banco->setMensagem(1,$e->getMessage());
                echo $banco->getRetorno();
                unset($banco);
            }   
            else
            {
                echo $e->getMessage();
            }
        }
          
?>