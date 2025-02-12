import { salvarErro } from '/components/uteis/MyFunctions'
import { pool } from "/config/db";
import axios from "axios";
import { getCookies } from 'cookies-next';

export default async function handler(req, res) {
  switch (req.method) {
    case "GET":
      return await getServico(req, res);
    case "DELETE":
      return await deleteServico(req, res);
    case "PUT":
      return await updateServico(req, res);
    default:
      return res.status(400).json({ message: "bad request" });
  }
}

const getServico = async (req, res) => {
  try {
    const result = await pool.query(`SELECT * 
                                       FROM Servicos_SER 
                                 INNER JOIN Atividades_ATI
                                         ON ATI_id = SER_atividade_id
                                 INNER JOIN Clientes_CLI
                                         ON CLI_id = SER_cliente_id
                            LEFT OUTER JOIN EnderecosServicos_ES 
                                         ON ES_id = SER_enderecoID
                            LEFT OUTER JOIN Agentes_AGE
                                         ON AGE_id = SER_agente_id 
                            LEFT OUTER JOIN Usuarios_USU
                                         ON USU_id = SER_criadoPor
                            LEFT OUTER JOIN EtiquetasServicos_ETISER
                                         ON ETISER_servico_id = SER_id                                         
                                      WHERE SER_id = ?`, [
      req.query.id,
    ]);
    return res.status(200).json(result[0]);
  } catch (e) {
    console.log('e1 pages/api/servicos/vincularNovoServico/[id].js');
    console.log('Erro 1:'+ e.message);
    //salvarErro'Erro 1:'+ e.message);
    //salvarErro'Em pages/api/servicos/[id].js')    
    return res.status(500).json({ message: e.message });
  }
};

const deleteServico = async (req, res) => {
  try {
    const date = new Date();
    await pool.query(`UPDATE Servicos_SER 
                         SET SER_ativo = 0, 
                         SER_canceladoAT = ? 
                       WHERE SER_id = ?`,
      [date, req.query.id]);

    await insertHistorico('O serviço foi cancelado', req);

    return res.status(204).json();
  } catch (e) {
    console.log('e2 pages/api/servicos/vincularNovoServico/[id].js');
    console.log('Erro 2:'+ e.message);
    //salvarErro'Erro 2:'+ e.message);
    //salvarErro'Em pages/api/servicos/[id].js')
    return res.status(500).json({ message: e.message });
  }
};

const alterarStatusDoServicoParaAguardandoAceiteDoAgente = async (id, req, res) => {
  try{
  await pool.query(`UPDATE Servicos_SER 
                       SET SER_aceitoPeloAgente = 0,
                           SER_emDeslocamento = 0
                    WHERE SER_id = ${id}`);

  await insertHistorico('Status do Serviço alterado para aguardando aceite do agente.', req);
  } catch(e){
    console.log('e3 pages/api/servicos/vincularNovoServico/[id].js');
    console.log('Erro 3:'+ e.message);
  }
}

// const mudouOagente = async (req, res) => {
//   // recupera o agente atual
//   // Mudou o agente: retorna TRUE
//   await insertHistorico('Agente alterado.', req);
//   console.log('004')
//   return 1;
// };

const updateServico = async (req, res) => {
  try {
    const cookies = getCookies({ req, res });
    const tipoUsuarioAux = cookies.tipoUsuario;
    const nomeUsuario = cookies.userName;
    console.log('tipoUsuarioAux', tipoUsuarioAux)
    if (tipoUsuarioAux === 'usuario') {
      var tipoUsuario = 'Gestor'
    }
    else {
      var tipoUsuario = 'Agente';
    }

    const texto = 'Serviço alterado pelo ' + tipoUsuario + ' ' + nomeUsuario;
    console.log('texto', texto)
    await insertHistorico(texto, req);

    delete req.body.tipoUsuario;
    delete req.body.nomeUsuario;

    const SER_agente_id = await pool.query(`SELECT SER_agente_id 
                                                  FROM Servicos_SER 
                                                 WHERE SER_id = ${req.query.id}`);

    var nomeAgenteAtual = '';
    if (req.body.SER_agente_id) {
      var agenteAtual = await pool.query(`SELECT AGE_nome
        FROM Agentes_AGE
       WHERE AGE_id = ${req.body.SER_agente_id}`);
      var nomeAgenteAtual = agenteAtual[0].AGE_nome;
      console.log('nomeAgenteAtual', nomeAgenteAtual)
    }
    console.log('SER_agente_id[0].SER_agente_id',SER_agente_id[0].SER_agente_id);
    console.log('req.body.SER_agente_id',req.body.SER_agente_id);

    if ((SER_agente_id[0].SER_agente_id) && (req.body.SER_agente_id)) {
      if (SER_agente_id[0].SER_agente_id !== req.body.SER_agente_id) {
        const agenteAnterior = await pool.query(`SELECT AGE_nome
                                                  FROM Agentes_AGE
                                                 WHERE AGE_id = ${SER_agente_id[0].SER_agente_id}`);
        const nomeAgenteAnterior = agenteAnterior[0].AGE_nome;
        console.log('nomeAgenteAnterior',nomeAgenteAnterior);

        var texto2 = tipoUsuario + ' ' + nomeUsuario + ' tirou do Agente ' + nomeAgenteAnterior;
        console.log('texto2a',texto2);
        await insertHistorico(texto2, req);
        var texto2 = tipoUsuario + ' ' + nomeUsuario + ' passou para o Agente ' + nomeAgenteAtual;
        console.log('texto2b',texto2);
        await insertHistorico(texto2, req);

        console.log('req.query.id ======> ',req.query.id);
        await pool.query(`UPDATE Servicos_SER 
          SET SER_concluido = 0,
              SER_aceitoPeloAgente = 0,
              SER_emDeslocamento = 0,
              SER_iniciado = 0,
              SER_pausado = 0,
              SER_reiniciado = 0
              WHERE SER_id = ?`,
          [req.query.id,]);
          console.log('req.query.id ======> ',req.query.id);

      }
    }
    if (!SER_agente_id[0].SER_agente_id) {
      if (req.body.SER_agente_id) {
        var texto2 = tipoUsuario + ' ' + nomeUsuario + ' passou para o Agente ' + nomeAgenteAtual;
        await insertHistorico(texto2, req);
      }
    }
    console.log('008')
    console.log('req.body',req.body);
    const { format } = require('date-fns'); // Se estiver usando date-fns

    // Converter a data para o formato 'YYYY-MM-DD'
    // const SER_agendadoParaData = format(new Date(req.body.SER_agendadoParaData), 'yyyy-MM-dd');
    const SER_agendadoParaData = req.body.SER_agendadoParaData
      ? format(new Date(req.body.SER_agendadoParaData), 'yyyy-MM-dd') // Formatar para o formato adequado
      : null; // Ou definir um valor padrão se necessário

    // Garantir que o horário esteja no formato correto 'HH:MM:SS'
    const SER_agendadoParaHora = req.body.SER_agendadoParaHora
      ? req.body.SER_agendadoParaHora.trim()
      : '00:00:00'; // Caso não exista o horário, definir um padrão
    
      const SER_autoReagendadoDataOriginal = req.body.SER_autoReagendadoDataOriginal === '0000-00-00' 
  ? null 
  : req.body.SER_autoReagendadoDataOriginal;
    // Montar o novo objeto com a data formatada
    const updatedData = {
      ...req.body,
      SER_agendadoParaData,
      SER_agendadoParaHora,
      SER_autoReagendadoDataOriginal,
      SER_aceitoPeloAgente:0,
      SER_concluido:0,
      SER_emDeslocamento:0,
      SER_iniciado:0,
      SER_pausado:0,
      SER_reiniciado:0,
      SER_valorReceber: req.body.SER_valorReceber === '' ? 0 : req.body.SER_valorReceber,
    };
    console.log('req.updatedData',updatedData);
    // Realizar a query com os dados atualizados
    await pool.query("UPDATE Servicos_SER SET ? WHERE SER_id = ?", [
      updatedData,
      req.query.id,
    ]);
    await pool.query("UPDATE Servicos_SER SET SER_aceitoPeloAgente = 0 WHERE SER_id = ? and SER_aceitoPeloAgente = 2", [
      req.query.id,
    ]);
    
    console.log('009')
    // await pool.query("UPDATE Servicos_SER SET ? WHERE SER_id = ?", [
    //   req.body,
    //   req.query.id,
    // ]);

    atualizarTabelaLinhaDoTempoDoAgente();
    return res.status(204).json();
  } catch (e) {
    console.log('Erro 4:'+ e.message);
    //salvarErro'Erro 4:'+ e.message);
    //salvarErro'Em pages/api/servicos/[id].js')    
    return res.status(500).json({ message: e.message });
  }
};

const atualizarTabelaLinhaDoTempoDoAgente = async () => {
  try{
  const baseURL = process.env.NEXT_PUBLIC_API_URL + "/api/servicos/atualizarlinhadotempodosagentes";
  axios.get(baseURL);
  } catch(e){
    console.log('Erro 5:', e.message);   
  }
};

const insertHistorico = async (texto, req) => {
  try {
    const parametros = {
      SERHIS_SER_id: req.query.id,
      SERHIS_Texto: texto,
      SERHIS_USU_id: req.body.USU_id,
      SERHIS_AGE_id: req.body.AGE_id
    }

    const baseURL = process.env.NEXT_PUBLIC_API_URL + "/api/historico/";
    await axios.post(baseURL, parametros);
  } catch (e) {
    console.log('Erro 6:'+ e.message);
    //salvarErro'Erro 6:'+ e.message);
    //salvarErro'Em pages/api/servicos/[id].js')    
  }
}