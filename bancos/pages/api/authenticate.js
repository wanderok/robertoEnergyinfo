// pages/api/authenticate.js
import axios from 'axios';

export default async function handler(req, res) {
    const { jwt } = req.body; // JWT enviado na requisição

    try {
        // A URL da API de autenticação
        const authUrl = 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token';

        // A requisição para obter o token
        const response = await axios.post(
            authUrl,
            `grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=${jwt}`,
            {
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                    // Caso precise adicionar mais cabeçalhos, como 'Authorization'
                },
            }
        );

        // Retorna o token de acesso
        const accessToken = response.data.access_token;

        // Retorna a resposta para o frontend
        res.status(200).json({ accessToken });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Erro ao obter o API Token' });
    }
}
