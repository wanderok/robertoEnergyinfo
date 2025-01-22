// import jwt from 'jsonwebtoken'; // Para manipulação de JWT
// import axios from 'axios';

// const BASE_URL = 'https://proxy.api.prebanco.com.br'; // URL base da API do Bradesco

// // Função para codificar em base64 URL
// const base64UrlEncode = (data) => {
//   const base64 = Buffer.from(data).toString('base64');
//   return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
// };

// // Função para gerar o Header do JWT
// const createHeader = () => {
//   return {
//     alg: 'RS256',
//     typ: 'JWT',
//   };
// };

// // Função para gerar o Payload do JWT
// const createPayload = (clientKey, apiToken) => {
//   const iat = Math.floor(Date.now() / 1000);
//   const exp = iat + 3600; // Expiração de 1 hora
//   const jti = iat * 1000; // Identificador único do token

//   return {
//     aud: apiToken,
//     sub: clientKey,
//     iat: iat,
//     exp: exp,
//     jti: jti,
//     ver: '1.1',
//   };
// };

// // Função para gerar o JWT (header + payload + assinatura)
// const generateJWT = (header, payload, privateKey) => {
//   const encodedHeader = base64UrlEncode(JSON.stringify(header));
//   const encodedPayload = base64UrlEncode(JSON.stringify(payload));

//   const dataToSign = `${encodedHeader}.${encodedPayload}`;
//   const signature = signData(dataToSign, privateKey); // Assinatura usando chave privada

//   return `${dataToSign}.${signature}`;
// };

// // Função para assinar os dados com a chave privada
// const signData = (data, privateKey) => {
//   const sign = jwt.sign(data, privateKey, { algorithm: 'RS256' });
//   return sign.split('.')[2]; // Retorna a assinatura do JWT
// };

// // Função para gerar o JWS (JSON Web Signature)
// const generateJWS = (jwtToken) => {
//   const [header, payload, signature] = jwtToken.split('.');
//   return `${header}.${payload}.${signature}`;
// };

// // Função para fazer a requisição de token Bearer para a API do Bradesco
// const getBearerToken = async (jwtToken) => {
//   const url = `${BASE_URL}/auth/server/v1.1/token`;

//   try {
//     const response = await axios.post(url, null, {
//       headers: {
//         'Authorization': `Bearer ${jwtToken}`,
//         'Content-Type': 'application/x-www-form-urlencoded',
//       },
//       params: {
//         grant_type: 'urn:ietf:params:oauth:grant-type:jwt-bearer',
//         assertion: jwtToken,
//       },
//     });

//     return response.data.access_token; // Retorna o Bearer Token
//   } catch (error) {
//     console.error('Erro ao obter o Bearer Token:', error);
//     throw new Error('Falha ao obter o Bearer Token');
//   }
// };

// export { createHeader, createPayload, generateJWT, generateJWS, getBearerToken };
// import jwt from 'jsonwebtoken';
// import fs from 'fs';
// import path from 'path';


const crypto = require('crypto');
const fs = require('fs');
const path = require('path');

// Função para codificar para Base64Url
const base64UrlEncode = (str) => {
  return Buffer.from(str).toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=+$/, '');
};

// Função para gerar a assinatura RSA (RS256)
export const generateRSASignature = (data, privateKey) => {
  const sign = crypto.createSign('RSA-SHA256');
  sign.update(data);
  return sign.sign(privateKey, 'base64');
};

// Função para gerar o JWT
export const generateJWT = (header, payload, privateKey) => {
  // Codificar o cabeçalho e o payload
  const encodedHeader = base64UrlEncode(JSON.stringify(header));
  const encodedPayload = base64UrlEncode(JSON.stringify(payload));

  // Concatenar os dois
  const data = `${encodedHeader}.${encodedPayload}`;

  // Gerar a assinatura com a chave privada
  const signature = generateRSASignature(data, privateKey);

  // Gerar o JWT final
  return `${data}.${signature}`;
};

// Função para gerar o Payload
export const generatePayload = (clientId, apiToken) => {
  const iat = Math.floor(Date.now() / 1000); // tempo em segundos
  const exp = iat + 3600; // expira em 1 hora
  const jti = `${iat}000`; // jti é o iat com três zeros no final
  const ver = '1.1'; // versão do token

  return {
    aud: apiToken,  // URL da API Bradesco
    sub: clientId,                       // O client_id que você está usando
    iat,                                 // Hora de emissão do token (em segundos)
    exp,                                 // Hora de expiração do token (em segundos)
    jti,                                 // Identificador único para o token
    ver,                                 // Versão do token
  };
};

// Função para carregar a chave privada
export const loadPrivateKey = () => {
  const privateKeyPath = path.resolve('keys/oxymed.homologacao.key.pem'); // Substitua pelo caminho correto da sua chave privada
  return fs.readFileSync(privateKeyPath, 'utf8');
};

// // Função para gerar o JWT (incluindo a assinatura)
// export const generateJWT = (header, payload, privateKey) => {
//   const options = { algorithm: 'RS256' }; // Usando RS256 para a assinatura
//   return jwt.sign(payload, privateKey, options);
// };

// const generateRSASignature = (data, privateKey) => {
//   const sign = crypto.createSign('RSA-SHA256');
//   sign.update(data);
//   return sign.sign(privateKey, 'base64');
// };

// Função para gerar o JWS a partir do JWT
export const generateJWS = (jwtToken) => {
  const [header, payload, signature] = jwtToken.split('.');

  return {
    header,
    payload,
    signature,
    jws: jwtToken, // JWS é o JWT completo
  };
};

// Função para enviar o JWS e obter o Bearer Token da API
export const getBearerToken = async (jws, apiToken) => {
  const response = await fetch('https://proxy.api.prebanco.com.br/auth/server/v1.1/token', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiToken}`,
    },
    body: JSON.stringify({
      grant_type: 'client_credentials',
      client_id: '9693f06b-b929-4a9c-8182-e25270c4029d',  // Substitua com seu client_id
      client_secret: '7cb3d3eb-a2c9-4084-8e03-72230000b4dd', // Substitua com seu client_secret
      jws, // Enviando o JWS
    }),
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(data.error_description || 'Erro ao obter o Bearer Token');
  }

  return data.access_token; // Retorna o Bearer Token
};
