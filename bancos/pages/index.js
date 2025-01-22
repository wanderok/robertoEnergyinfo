// import { useState } from 'react';

// export default function Home() {
//   const [token, setToken] = useState('');
//   const [bearerToken, setBearerToken] = useState('');
//   const [error, setError] = useState('');

//   // Função para gerar o Token e consumir a API
//   const handleGenerateToken = async () => {
//     try {
//       // Chamada para a API que retorna o API Token
//       const response = await fetch('/api/getApiToken', {
//         method: 'POST',
//       });

//       console.log(response)
//       if (!response.ok) {
//         throw new Error('Erro ao obter o API Token');
//       }

//       const data = await response.json();
//       const apiToken = data.apiToken;  // Aqui é onde obtemos o API Token

//       // Aqui você pode fazer a geração do JWT, usando o apiToken
//       console.log('API Token obtido:', apiToken);

//       // Agora que você tem o API Token, pode usá-lo nas próximas requisições
//       // Exemplo: buscar o Bearer Token usando o API Token

//       setToken(apiToken); // Atualiza o estado com o API Token

//       // Aqui você pode chamar outra função para fazer a requisição para obter o Bearer Token
//       // e usar esse token para acessar outras APIs

//       setError('');
//     } catch (err) {
//       setError('Erro ao gerar o token ou obter o Bearer Token: ' + err.message);
//       setToken('');
//       setBearerToken('');
//     }
//   };

//   return (
//     <div style={{ padding: '20px' }}>
//       <h1>Gerador de Token JWT e JWS</h1>

//       <button onClick={handleGenerateToken}>Gerar Token</button>

//       {error && <p style={{ color: 'red' }}>{error}</p>}

//       {token && (
//         <div>
//           <h3>API Token:</h3>
//           <textarea value={token} readOnly rows={6} cols={80} />
//         </div>
//       )}

//       {bearerToken && (
//         <div>
//           <h3>Bearer Token:</h3>
//           <textarea value={bearerToken} readOnly rows={6} cols={80} />
//         </div>
//       )}
//     </div>
//   );
// }

import { useState } from 'react';

export default function Home() {
  const [token, setToken] = useState('');
  const [error, setError] = useState('');

  const handleGenerateToken = async () => {
    try {
      // Dados do cliente e da API
      const clientId = 'seu-client-id';
      const apiToken = 'seu-api-token';

      // Enviar dados para o endpoint para gerar o token de acesso
      const response = await fetch('/api/getApiToken', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ clientId, apiToken }),  // Enviar clientId e apiToken
      });

      const data = await response.json();

      if (response.ok) {
        setToken(data.accessToken);  // Supondo que o access token esteja na resposta
        setError('');
      } else {
        setError('Erro ao obter o token de acesso');
      }
    } catch (err) {
      setError('Erro ao gerar o token ou obter o Bearer Token: ' + err.message);
      setToken('');
    }
  };

  return (
    <div>
      <button onClick={handleGenerateToken}>Gerar Token</button>
      {error && <p style={{ color: 'red' }}>{error}</p>}
      {token && (
        <div>
          <h3>Access Token:</h3>
          <textarea value={token} readOnly rows={6} cols={80} />
        </div>
      )}
    </div>
  );
}
