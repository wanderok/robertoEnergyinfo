// // pages/api/getApiToken.js
// import fetch from 'node-fetch';

// export default async function handler(req, res) {
//     if (req.method === 'POST') {
//         try {
//             // Defina os dados necessários para autenticação do Bradesco
//             const clientId = '9693f06b-b929-4a9c-8182-e25270c4029d'; // Substitua com seu Client ID
//             const clientSecret = '7cb3d3eb-a2c9-4084-8e03-72230000b4dd'; // Substitua com seu Client Secret
//             const url = 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token'; // URL do endpoint OAuth (substitua se necessário)

//             // Corpo da requisição (exemplo de como fazer uma requisição com credenciais do OAuth)
//             const body = new URLSearchParams();
//             body.append('grant_type', 'client_credentials');
//             body.append('client_id', clientId);
//             body.append('client_secret', clientSecret);

//             // Enviar a requisição para a API de autenticação
//             const response = await fetch(url, {
//                 method: 'POST',
//                 headers: {
//                     'Content-Type': 'application/x-www-form-urlencoded',
//                 },
//                 body: body.toString(),
//             });

//             const data = await response.json();

//             // Verificar se a resposta contém um token
//             if (response.ok && data.access_token) {
//                 // Retorne o API Token como resposta
//                 return res.status(200).json({ apiToken: data.access_token });
//             } else {
//                 throw new Error('Erro ao obter o API Token');
//             }
//         } catch (error) {
//             return res.status(500).json({ error: error.message });
//         }
//     } else {
//         // Se o método não for POST, retornar erro
//         res.status(405).json({ error: 'Método não permitido' });
//     }
// }

// pages/api/getApiToken.js

//import { generatePayload, generateJWT, generateJWS, loadPrivateKey } from '/utils/jwtUtils'; // Ajuste o caminho conforme necessário
//import { generateJWT, generatePayload } from '../../utils/jwtUtils'; // Importando as funções de utilitário

// export default async function handler(req, res) {
//     if (req.method === 'POST') {

//         const clientId = '9693f06b-b929-4a9c-8182-e25270c4029d';
//         const privateKey = loadPrivateKey(); // Carrega a chave privada para assinar o JWT
//         console.log('privateKey', privateKey)

//         const apiToken = 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token';
//         // Gerar o Payload
//         const payload = generatePayload(clientId, apiToken);
//         console.log('payload', payload)

//         // Gerar o Header (você pode definir o header conforme necessário, ou usar um header padrão)
//         const header = {
//             alg: 'RS256',  // Algoritmo de assinatura
//             typ: 'JWT',    // Tipo de token
//         };

//         console.log('header', header)
//         // Gerar o JWT com o payload e a chave privada
//         const jwtToken = generateJWT(header, payload, privateKey);

//         console.log('jwtToken', jwtToken)

//         // Gerar o JWS (aqui você pode usar o JWT diretamente, pois ele é o JWS assinado)
//         const jwsToken = generateJWS(jwtToken);

//         console.log('jwsToken', jwsToken)

//         try {
//             // Defina os dados necessários para autenticação do Bradesco
//             // const clientId = '9693f06b-b929-4a9c-8182-e25270c4029d'; // Substitua com seu Client ID
//             // const clientSecret = '7cb3d3eb-a2c9-4084-8e03-72230000b4dd'; // Substitua com seu Client Secret
//             const url = 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token'; // URL do endpoint OAuth (substitua se necessário)

//             // Corpo da requisição (exemplo de como fazer uma requisição com credenciais do OAuth)
//             // const body = new URLSearchParams();
//             // body.append('grant_type', 'urn:ietf:params:oauth:grant-type:jwt-bearer');
//             // body.append('assertion', JWS Gerado);


//             // Enviar a requisição para a API de autenticação usando o fetch nativo
//             const response = await fetch(url, {
//                 method: 'POST',
//                 headers: {
//                     'Content-Type': 'application/x-www-form-urlencoded',
//                 },
//                 body: new URLSearchParams({
//                     grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',  // Tipo de grant (pode variar conforme a API)
//                     assertion: jwsToken,              // JWS gerado, usado como assertion
//                 }),
//             });

//             const data = await response.json();

//             console.log('response', response)
//             // Verificar se a resposta contém um token
//             if (response.ok && data.access_token) {
//                 // Retorne o API Token como resposta
//                 return res.status(200).json({ apiToken: data.access_token });
//             } else {
//                 throw new Error('Erro ao obter o API Token');
//             }
//         } catch (error) {
//             return res.status(500).json({ error: error.message });
//         }
//     } else {
//         // Se o método não for POST, retornar erro
//         res.status(405).json({ error: 'Método não permitido' });
//     }
// }

import { generateJWT, generatePayload } from '../../utils/jwtUtils'; // Importando as funções de utilitário
import fetch from 'node-fetch';
import fs from 'fs';
import path from 'path';

export default async function handler(req, res) {
    if (req.method === 'POST') {
        try {
            // Obtenha o clientId, apiToken e a chave privada
            const { clientId, apiToken } = req.body; // Certifique-se de enviar esses dados no corpo da requisição
            const privateKeyPath = path.resolve('keys/oxymed.homologacao.key.pem');  // Caminho da sua chave privada
            const privateKey = fs.readFileSync(privateKeyPath, 'utf8');  // Carregar a chave privada

            // Criação do Payload usando os dados fornecidos
            const payload = generatePayload(clientId, apiToken);

            // Criação do Header (usuário sempre utiliza RS256)
            const header = {
                alg: "RS256",
                typ: "JWT"
            };

            // Gerar o JWT com a chave privada
            const jwtToken = generateJWT(header, payload, privateKey);

            // Agora, vamos usar o JWT gerado para enviar a requisição para obter o Access Token
            const response = await fetch('https://proxy.api.prebanco.com.br/auth/server/v1.1/token', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: `assertion=${jwtToken}`  // Passando o JWT gerado no corpo da requisição
            });

            if (!response.ok) {
                //throw new Error('Erro ao obter o token de acesso');
                console.log('response ====>', response);
                throw new Error('response.ok', response.ok);

            }

            const data = await response.json();
            res.status(200).json(data);  // Retorne os dados da resposta da API

        } catch (error) {
            console.error('Erro:', error);
            res.status(500).json({ error: error.message });
        }
    } else {
        res.status(405).json({ error: 'Método não permitido' });
    }
}
