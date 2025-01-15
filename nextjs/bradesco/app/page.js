const fs = require('fs');
const jwt = require('jsonwebtoken');

// Carregar a chave privada (privada.pem) para assinar o JWS
const privateKey = fs.readFileSync('C:\\wander\\chaves\\privada\\oxymed.homologacao.key.pem', 'utf8');

// Payload com as credenciais ou informações necessárias
const payload = {
  aud: 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token',
  sub: '9693f06b-b929-4a9c-8182-e25270c4029d',
  iat: 3946127601,
  exp: 3946131201,
  jti: 3946127601000,
  ver: '1.1'
};

// Header do JWS
const header = {
  alg: 'RS256',
  typ: 'JWT'
};

// Gerar o JWS assinando o payload com a chave privada e RS256
const jws = jwt.sign(payload, privateKey, { algorithm: 'RS256', header });

console.log('JWS gerado:', jws);
