import { useState } from 'react';
import { createHeader, createPayload, generateJWT, generateJWS, getBearerToken } from '../utils/jwtUtils';

export default function Home() {
  const [token, setToken] = useState(''); // Estado para armazenar o JWT gerado
  const [bearerToken, setBearerToken] = useState(''); // Estado para armazenar o Bearer Token
  const [error, setError] = useState(''); // Estado para armazenar erros

  const handleGenerateToken = async () => {
    try {
      // Dados do cliente e da API
      const clientKey = '9693f06b-b929-4a9c-8182-e25270c4029d'; // Substitua com seu ClientKey
      const apiToken = 'API_TOKEN'; // Substitua com seu APIToken
      const privateKey = `-----BEGIN PRIVATE KEY-----
      ... // Sua chave privada aqui ...
      -----END PRIVATE KEY-----`;

      // Criação do Header e Payload
      const header = createHeader();
      const payload = createPayload(clientKey, apiToken);

      // Gerar o JWT
      const jwtToken = generateJWT(header, payload, privateKey);
      const jwsToken = generateJWS(jwtToken);

      // Obter o Bearer Token usando o JWS gerado
      const token = await getBearerToken(jwsToken);

      // Atualizar estado com os resultados
      setToken(jwtToken);        // Atualiza o estado com o JWT gerado
      setBearerToken(token);     // Atualiza o estado com o Bearer Token
      setError('');              // Limpa mensagens de erro
    } catch (err) {
      setError('Erro ao gerar o token ou obter o Bearer Token: ' + err.message); // Exibe erro
      setToken('');              // Limpa o JWT em caso de erro
      setBearerToken('');       // Limpa o Bearer Token em caso de erro
    }
  };

  return (
    <div style={{ padding: '20px' }}>
      <h1>Gerador de Token JWT e JWS</h1>

      <button onClick={handleGenerateToken}>Gerar Token</button>

      {/* Exibição de erro caso ocorra */}
      {error && <p style={{ color: 'red' }}>{error}</p>}

      {/* Exibição do JWT gerado */}
      {token && (
        <div>
          <h3>JWT Gerado:</h3>
          <textarea value={token} readOnly rows={6} cols={80} />
        </div>
      )}

      {/* Exibição do Bearer Token gerado */}
      {bearerToken && (
        <div>
          <h3>Bearer Token:</h3>
          <textarea value={bearerToken} readOnly rows={6} cols={80} />
        </div>
      )}
    </div>
  );
}
