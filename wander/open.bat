rem echo -n "$(cat jwt.txt)" | openssl dgst -sha256 -keyform pem -sign oxymed.homologacao.key.pem > teste.txt


echo -n "$(cat jwt.txt)" | c:\wander\openssl\openssl dgst -sha256 -keyform pem -sign oxymed.homologacao.key.pem|base64|tr -d '=[:space:]' | tr '+/' '-_'

rem open.bat
rem JWT.txt
rem oxymed.homologacao.key.pem
