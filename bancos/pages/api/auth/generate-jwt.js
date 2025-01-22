// import jwt from 'jsonwebtoken';
// import fs from 'fs';
// import path from 'path';

// // Função para ler a chave privada a partir do arquivo .pem
// const getPrivateKey = () => {
//     const privateKeyPath = path.join(process.cwd(), 'keys', 'private.key.pem');
//     return fs.readFileSync(privateKeyPath, 'utf8');
// };

// // Função para gerar o JWT
// const generateJWT = (header, payload, privateKey) => {
//     // Geração do JWT com assinatura RS256 (assinatura com chave privada)
//     const token = jwt.sign(payload, privateKey, {
//         algorithm: 'RS256',
//         header: header, // Adiciona o header customizado no JWT
//         expiresIn: '1h',
//     });
//     return token;
// };

// // Função para gerar o JWS (JWT + assinatura)
// const generateJWS = (header, payload, privateKey) => {
//     const jwtToken = generateJWT(header, payload, privateKey);
//     return jwtToken; // O JWS é basicamente o JWT assinado
// };

// export default function handler(req, res) {
//     if (req.method === 'POST') {
//         // Definir o header (dessa forma você pode customizar, exemplo: JWT Header)
//         const header = {
//             alg: 'RS256', // Algoritmo de assinatura
//             typ: 'JWT',   // Tipo de token
//         };

//         // Definir o payload
//         const payload = {
//             userId: '12345', // Exemplo de usuário
//             clientId: '9693f06b-b929-4a9c-8182-e25270c4029d', // Exemplo de client id
//             // Outros dados que você precise
//         };

//         // Ler a chave privada do arquivo
//         const privateKey = getPrivateKey();

//         // Gerar o JWS (JWT assinado)
//         const jws = generateJWS(header, payload, privateKey);

//         // Enviar a resposta com o JWS
//         res.status(200).json({ jws });
//     } else {
//         res.status(405).json({ error: 'Método não permitido' });
//     }
// }

import jwt from 'jsonwebtoken';
import fs from 'fs';
import path from 'path';

// Função para ler a chave privada a partir do arquivo .pem
const getPrivateKey = () => {
    const privateKeyPath = path.join(process.cwd(), 'keys', 'private.key.pem');
    return fs.readFileSync(privateKeyPath, 'utf8');
};

// Função para gerar o JWT
const generateJWT = (header, payload, privateKey) => {
    // Geração do JWT com assinatura RS256 (assinatura com chave privada)
    const token = jwt.sign(payload, privateKey, {
        algorithm: 'RS256',
        header: header, // Adiciona o header customizado no JWT
        expiresIn: '1h',
    });
    return token;
};

// Função para gerar o JWS (JWT + assinatura)
const generateJWS = (header, payload, privateKey) => {
    const jwtToken = generateJWT(header, payload, privateKey);
    return jwtToken; // O JWS é basicamente o JWT assinado
};

export default function handler(req, res) {
    if (req.method === 'POST') {
        // Definir o header (dessa forma você pode customizar, exemplo: JWT Header)
        const header = {
            alg: 'RS256', // Algoritmo de assinatura
            typ: 'JWT',   // Tipo de token
        };

        // Definir o payload com os novos parâmetros
        const payload = {
            aud: 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token',  // A quem o JWT é destinado (ex: serviço Bradesco)
            sub: '9693f06b-b929-4a9c-8182-e25270c4029d',    // O identificador do principal (ex: ID do usuário ou cliente)
            iat: Math.floor(Date.now() / 1000), // Timestamp de quando o JWT foi emitido
            exp: Math.floor(Date.now() / 1000) + (60 * 60), // Expiração em 1 hora
            jti: `${iat}000`, // Identificador único para o JWT
            ver: '1.1', // Versão do JWT ou do sistema
        };

        // Ler a chave privada do arquivo
        const privateKey = getPrivateKey();

        // Gerar o JWS (JWT assinado)
        const jws = generateJWS(header, payload, privateKey);

        // Enviar a resposta com o JWS
        res.status(200).json({ jws });
    } else {
        res.status(405).json({ error: 'Método não permitido' });
    }
}
