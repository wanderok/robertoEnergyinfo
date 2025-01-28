# Criar um arquivo contendo certificado de chave e auto-assinado
OpenSSL req -x509 -nodes -days 365 -newkey RSA: 1024 -keyout mycert.pem out mycert.pem


# Export mycert.pem como PKCS # 12, mycert.pfx
openssl pkcs12 -export out mycert.pfx -em mycert.pem -name "Meu Certificado"

pause