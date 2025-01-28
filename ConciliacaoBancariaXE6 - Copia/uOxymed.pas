unit uOxymed;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls, IdGlobal, System.JSON,

  Winapi.ShellAPI,

  System.IOUtils,
  System.Diagnostics,
  System.DateUtils,
  Vcl.Clipbrd,
  ACBrDFeSSL,

IdCoderMIME,
  synacode,

  IdException;



type

  TAmbiente = (aHomologacao, aProducao);

  TBradesco = class
  private
    FRazaoSocial: string;
    FClienteID: Integer;
    FCNPJ: string;
    FCertificadoDigital: string;
    FConta: String;
    FAgencia: String;
    FPastaDeTrabalho: String;
    FJWS: String;
    FJWT: String;
    FJWTBase64: String;
    FBearerToken: String;
    FHeader: String;
    FPayload: String;
    FHeaderBase64: String;
    FPayloadBase64: String;
    FClientKey: String;
    FAssinatura: String;
    FAssinaturaBase64URL: String;

    FRaizHomologacao:String;
    FRaizProducao:String;

    FAPIToken: String;
    FAPISaldo: String;
    FAPIExtrato: String;

    FArquivoChavePrivada: String;
    FArquivoChavePublica: String;

    FAmbiente: TAmbiente;

    procedure GerarParametros;
    procedure CriarHeader;
    procedure CriarHeaderBase64;

    procedure CriarPayload;
    procedure CriarPayloadBase64;

    procedure GerarTokenJWT;
    procedure GerarTokenJWTBase64;

    function GerarAssinatura: string;

    procedure GerarJWS;
    procedure GerarBearerToken;

    procedure GerarAssinaturaJWT;
    procedure RunCommand(const Command: string);
    function GetBase64FromFile(const FileName: string): string;

    procedure GravarParametrosGerados;

    function APIToken: String;
    function APIBarenToken: String;
    function CodificarBase64(const Texto: string): string;

    procedure ExecutarComando(const Comando: string);
    function Base64ToBase64URL(const Base64: string): string;
    procedure CriarRequestTxt(const Metodo, Endpoint, Parametros, Body: string);
    function GetCurrentTimeInMilliseconds: Int64;
    procedure GeraTokenAssinado;

    procedure DefinirEndPoints;

  public
    constructor Create;
    property Ambiente : TAmbiente read FAmbiente  write FAmbiente;
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property ClienteID: Integer read FClienteID write FClienteID;
    property CNPJ: string read FCNPJ write FCNPJ;
    property CertificadoDigital: string read FCertificadoDigital
      write FCertificadoDigital;
    property Conta: string read FConta write FConta;
    property Agencia: string read FAgencia write FAgencia;
    property Header: string read FHeader write FHeader;
    property Payload: string read FPayload write FPayload;
    property HeaderBase64: String read FHeaderBase64 write FHeaderBase64;
    property PayloadBase64: String read FPayloadBase64 write FPayloadBase64;

    property JWS: string read FJWS write FJWS;
    property JWT: string read FJWT write FJWT;
    property JWTBase64: string read FJWTBase64 write FJWTBase64;
    property ClientKey: string read FClientKey write FClientKey;
    property BearerToken: string read FBearerToken write FBearerToken;
    property Assinatura: string read FAssinatura write FAssinatura;
    property PastaDeTrabalho: string read FPastaDeTrabalho
      write FPastaDeTrabalho;

    property ArquivoChavePrivada: string read FArquivoChavePrivada
      write FArquivoChavePrivada;
    property ArquivoChavePublica: string read FArquivoChavePublica
      write FArquivoChavePublica;

    function Extrato(Inicio, Fim: TDateTime): String;
    procedure Iniciar;
  end;

implementation

function TBradesco.APIBarenToken: String;
begin
  if self.FAmbiente = aHomologacao then
  begin
     FAPIToken:= self.FRaizHomologacao+'auth/server/v1.1/token';
     FAPISaldo:= self.FRaizHomologacao+'saldo';
     FAPIExtrato:= self.FRaizHomologacao+'extrato';
  end
  else
  begin
     FAPIToken:= self.FRaizProducao+'auth/server/v1.1/token';
     FAPISaldo:= self.FRaizHomologacao+'saldo';
     FAPIExtrato:= self.FRaizHomologacao+'extrato';
  end;
end;

function TBradesco.APIToken: String;
begin

end;

function TBradesco.Base64ToBase64URL(const Base64: string): string;
begin
  result := StringReplace(Base64, '+', '-', [rfReplaceAll]);
  result := StringReplace(result, '/', '_', [rfReplaceAll]);
  result := StringReplace(result, '=', '', [rfReplaceAll]); // Remove paddings
end;

function TBradesco.CodificarBase64(const Texto: string): string;
begin
  result := EncodeBase64(Texto); // TNetEncoding.Base64.Encode(Texto);
  result := Base64ToBase64URL(result); // Converte de Base64 para Base64URL
end;

constructor TBradesco.Create;
begin
  self.FAmbiente := aHomologacao;
  self.FRaizHomologacao:= 'https://proxy.api.prebanco.com.br/';
  self.FRaizProducao:= 'https://openapi.bradesco.com.br/';
end;

procedure TBradesco.CriarHeader;
var
  Header: TJSONObject;
begin

  Header := TJSONObject.Create;
  try
    Header.AddPair('alg', 'RS256');
    Header.AddPair('typ', 'JWT');
    self.FHeader := Header.ToString;
  finally
    Header.Free;
  end;

end;

procedure TBradesco.CriarHeaderBase64;
begin
  self.FHeaderBase64 := CodificarBase64(self.FHeader);
end;

procedure TBradesco.CriarPayload;
var
  Payload: TJSONObject;
  Pair: TJSONPair;
  IAT, EXP, JTI: Int64; // Alterado para Int64  // Integer;
begin
  // Obter o timestamp atual em segundos
  IAT := Trunc(Now * 86400) + 25569;
  // Converte de "tData" para timestamp em segundos
  EXP := IAT + 3600; // Expira��o de 1 hora
  JTI := IAT * 1000; // jti em milissegundos

  Payload := TJSONObject.Create;
  try
    // Criando pares de chave-valor corretamente com TJSONPair
    Pair := TJSONPair.Create('aud', self.APIToken);
    Payload.AddPair(Pair);

    Pair := TJSONPair.Create('sub', self.ClientKey);
    Payload.AddPair(Pair);

    Pair := TJSONPair.Create('iat', intToStr(IAT));
    Payload.AddPair(Pair);

    Pair := TJSONPair.Create('exp', intToStr(EXP));
    Payload.AddPair(Pair);

    Pair := TJSONPair.Create('jti', intToStr(JTI));
    Payload.AddPair(Pair);

    Pair := TJSONPair.Create('ver', '1.1');
    Payload.AddPair(Pair);

    // Atribuindo o JSON a uma vari�vel string
    self.FPayload := Payload.ToString;
  finally
    Payload.Free;
  end;
end;

procedure TBradesco.CriarPayloadBase64;
begin
  self.FPayloadBase64 := CodificarBase64(self.FPayload);
end;

procedure TBradesco.CriarRequestTxt(const Metodo, Endpoint, Parametros,
  Body: string);
var
  RequestFile: string;
begin
  // Define o caminho do arquivo de request
  RequestFile := self.FPastaDeTrabalho + '\request.txt';
  // Cria o arquivo de request com as informa��es necess�rias
  TFile.WriteAllText(RequestFile, Metodo + #13#10 +
    // M�todo HTTP (exemplo: POST)
    Endpoint + #13#10 + // Endpoint (exemplo: /api/registro)
    Parametros + #13#10 + // Par�metros (se houver, sen�o deixe vazio)
    Body); // Body da requisi��o (se houver, sen�o deixe vazio)
end;

procedure TBradesco.DefinirEndPoints;
begin

end;

procedure TBradesco.ExecutarComando(const Comando: string);
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
  Cmd: string;
begin
  // Inicializa as estruturas
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  // Comando a ser executado
  Cmd := 'cmd.exe /c ' + Comando; // O /c executa e fecha o cmd ap�s a execu��o

  // Cria o processo e executa o comando
  if not CreateProcess(nil, PChar(Cmd), nil, nil, False, 0, nil, nil,
    StartupInfo, ProcessInfo) then
    RaiseLastOSError; // Caso ocorra erro

  // Aguarda o processo terminar
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
end;

function TBradesco.Extrato(Inicio, Fim: TDateTime): String;
var
  IdHTTP: TIdHTTP;
  Response: string;
  BearerToken, Nonce: string;
  RequestStream, ResponseStream: TMemoryStream;
  HeaderBase64Url, PayloadBase64Url, Base64Signature: String;
begin
  try
    // Gera o nonce (pode ser o JTI ou timestamp)
    Nonce := intToStr(GetCurrentTimeInMilliseconds); // Exemplo com timestamp

    // Cria um objeto HttpClient
    IdHTTP := TIdHTTP.Create(nil);

    // Adicionando cabe�alhos personalizados
    IdHTTP.Request.CustomHeaders.Add('Authorization: Bearer ' +
      self.FBearerToken);
    IdHTTP.Request.CustomHeaders.Add('X-Brad-Nonce: ' + Nonce);
    IdHTTP.Request.CustomHeaders.Add('X-Brad-Signature: ' + self.FAssinatura);

    try
      Response := IdHTTP.Get(self.FAPIExtrato);
      Writeln('Resposta: ' + Response);
    except
      on E: EIdHTTPProtocolException do
        Writeln('Erro HTTP: ' + E.Message);
      on E: Exception do
        Writeln('Erro geral: ' + E.Message);
    end;

  finally
    IdHTTP.Free;
  end;
end;

function TBradesco.GerarAssinatura: string;
var
  CmdLine, OutputFile, InputFile: string;
  Base64Signature: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  ExitCode: DWORD;
  Buffer: array [0 .. 1023] of AnsiChar;
  BytesRead: DWORD;
  OpenSSLPath: string;
  CmdOutputFile: string;
  TempSignatureFile: string;
  HeaderBase64Url, PayloadBase64Url: string;
begin
  // Caminhos dos arquivos
  InputFile := self.FPastaDeTrabalho + '\jwt.txt'; // O arquivo de entrada
  TempSignatureFile := self.FPastaDeTrabalho + '\signature.bin';
  // Arquivo tempor�rio para assinatura bin�ria
  CmdOutputFile := self.FPastaDeTrabalho + '\signature.base64.bin';
  // Arquivo final com assinatura em base64

  // Caminho completo para o OpenSSL (adapte conforme a sua instala��o)
  OpenSSLPath := '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe"';
  // Exemplo, substitua pelo seu caminho real

  // Comando OpenSSL para assinar o conte�do
  CmdLine := OpenSSLPath + ' dgst -sha256 -keyform pem -sign "' +
    self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "' +
    InputFile + '" > "' + TempSignatureFile + '"';

  TFile.WriteAllText(self.FPastaDeTrabalho + '\CmdLine2.txt', CmdLine);

  // Inicializa as estruturas para o CreateProcess
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  // Cria o processo para executar o comando OpenSSL
  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  // Aguarda a execu��o do comando
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  // Verifica o c�digo de sa�da do OpenSSL
//   if ExitCode <> 0 then
//   begin
//   ShowMessage('Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode));
//   Exit;
//   end;

  // Fechar handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  // Agora, vamos usar o CertUtil para codificar a assinatura bin�ria em Base64
  CmdLine := 'certutil -encode "' + TempSignatureFile + '" "' +
    CmdOutputFile + '"';

  // Inicializa novamente o processo para rodar o CertUtil
  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShowMessage('Erro ao executar CertUtil: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  // Aguarda a execu��o do comando CertUtil
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  // Verifica o c�digo de sa�da do CertUtil
  // if ExitCode <> 0 then
  // begin
  // ShowMessage('Erro ao executar CertUtil. C�digo de sa�da: ' + IntToStr(ExitCode));
  // Exit;
  // end;

  // Fechar handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  // L� a assinatura Base64 do arquivo de sa�da
  Base64Signature := TFile.ReadAllText(CmdOutputFile);

  // Opcional: Remover a linha extra gerada pelo certutil (essa linha pode ser removida se estiver em formato certutil)
  // Base64Signature := Copy(Base64Signature, Pos(#13#10, Base64Signature) + 2, MaxInt);
  Base64Signature := Base64ToBase64URL(Base64Signature);

  // Salva a assinatura gerada
  self.FAssinatura := Base64Signature;
end;

procedure TBradesco.GerarParametros;
begin

  DefinirEndPoints;

  CriarHeader;
  CriarHeaderBase64;

  CriarPayload;
  CriarPayloadBase64;

  GerarTokenJWT;
  GerarTokenJWTBase64;

  GerarAssinatura;
  //GerarAssinaturaJWT;
  GerarJWS;

  GerarBearerToken;

  GravarParametrosGerados;
end;

procedure TBradesco.GerarBearerToken;
var
  IdHTTP: TIdHTTP;
  Response: string;
  Body: string;
  StringStream: TStringStream;
  SSLHandler: TIdSSLIOHandlerSocketOpenSSL;
begin
  IdHTTP := TIdHTTP.Create(nil);
  SSLHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  StringStream := TStringStream.Create('');

  try
    // Configurar o IOHandler para o IdHTTP
    IdHTTP.IOHandler := SSLHandler;

    // For�ar o uso do protocolo TLS 1.2
    SSLHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];  // Usando TLS 1.2



    Body := 'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&' +
            'assertion=' + self.FJWS;

    // Carregando o corpo na TStringStream
    StringStream.WriteString(Body);
    StringStream.Position := 0;  // Importante: Reiniciar a posi��o

    // Adicionar o cabe�alho Content-Type corretamente
    IdHTTP.Request.CustomHeaders.Add('Content-Type: application/x-www-form-urlencoded');

    try
      // Enviando a requisi��o POST com o corpo
      Response := IdHTTP.Post(self.APIBarenToken, StringStream);
      self.FBearerToken := Response;
    except
      on E: EIdHTTPProtocolException do
        self.FBearerToken := 'Erro HTTP: ' + E.Message;
      on E: Exception do
        self.FBearerToken := 'Erro geral: ' + E.Message;
    end;

  finally
    StringStream.Free;
    SSLHandler.Free;
    IdHTTP.Free;
  end;
end;


procedure TBradesco.GerarTokenJWT;
begin
  self.FJWT := self.FHeader + '.' + self.FPayload;
end;

procedure TBradesco.GerarTokenJWTBase64;
begin
  self.FJWTBase64 := CodificarBase64(self.FJWT);
end;

procedure TBradesco.GeraTokenAssinado;
begin
end;

function TBradesco.GetCurrentTimeInMilliseconds: Int64;
begin
  // Obt�m o n�mero de milissegundos desde a "�poca" (01/01/1970)
  result := DateTimeToUnix(Now) * 1000;
end;

procedure TBradesco.GravarParametrosGerados;
begin
  TFile.WriteAllText(self.FPastaDeTrabalho + '\header.txt', self.FHeader);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\payload.txt', self.FPayload);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\headerBase64.txt',
    self.FHeaderBase64);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\payloadBase64.txt',
    self.FPayloadBase64);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\jwt.txt', self.FJWT);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\jwtBase64.txt', self.FJWTBase64);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\AssinaturaOK.txt',
    self.FAssinatura);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\jws.txt', self.FJWS);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\BearerToken.txt',
    self.FBearerToken);
end;

procedure TBradesco.Iniciar;
begin
  GerarParametros;
end;

procedure TBradesco.GerarJWS;
begin
  // Concatenando Header, Payload e a Assinatura Base64Url para formar o JWS
  self.FJWS := self.FHeaderBase64 + '.' + self.FPayloadBase64 + '.' + self.FAssinatura; // self.FAssinaturaBase64URL;
end;

procedure TBradesco.GerarAssinaturaJWT;
var
  HeaderBase64Url, PayloadBase64Url, Combined, Command: string;
  OpenSSLPath: string;
  Base64Signature: string;
  ResultCode: Integer;
  PayloadJson: string;
  JsonFileName: string;

procedure CreateTemporaryJsonFile(const AJsonContent: string; const AFileName: string);
var
  JsonFile: TextFile;
begin
  AssignFile(JsonFile, AFileName);
  Rewrite(JsonFile);
  WriteLn(JsonFile, AJsonContent);
  CloseFile(JsonFile);
end;

begin
  try
    // Caminho do OpenSSL
    OpenSSLPath := self.FPastaDeTrabalho + '\OpenSSL-Win64\bin\openssl.exe';

    PayloadJson := self.FHeader +'.' +self.FPayload;

    // Caminho para o arquivo tempor�rio
    JsonFileName := self.FPastaDeTrabalho + '\temp_payload.json';

    // Criando o arquivo tempor�rio com o conte�do JSON
    CreateTemporaryJsonFile(PayloadJson, JsonFileName);

    // Codificando em Base64URL
    HeaderBase64Url := Base64ToBase64URL(self.FHeader);
    PayloadBase64Url := Base64ToBase64URL(self.FPayload);

    // Combina Header e Payload
    Combined := HeaderBase64Url + '.' + PayloadBase64Url;

// Montando o comando (usando o comando correto 'dgst')
  Command := OpenSSLPath + ' dgst -sha256 -sign "' +
             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" ' +
             '-out "' + self.FPastaDeTrabalho + '\signatureJWS.bin" ' +
             '"' + JsonFileName + '"';
    // Execute o comando no terminal
    RunCommand(Command);

    // Ap�s executar o comando OpenSSL, vamos converter a assinatura para Base64URL
    if not FileExists(self.FPastaDeTrabalho + '\signatureJWS.bin') then
    begin
      ShowMessage('Arquivo de assinatura n�o encontrado!');
      Exit;
    end;

    // Converte a assinatura bin�ria para Base64URL
    Base64Signature := GetBase64FromFile(self.FPastaDeTrabalho + '\signatureJWS.bin');
    self.FAssinaturaBase64URL := Base64ToBase64URL(Base64Signature);

    // A assinatura gerada � armazenada
    self.FAssinatura := self.FAssinaturaBase64URL;
  except
    ShowMessage('Erro ao gerar assinatura JWT');
  end;
end;
procedure TBradesco.RunCommand(const Command: string);
var
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  ExitCode: DWORD;
begin
  // Inicializa as estruturas para o CreateProcess
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  // Cria o processo para executar o comando
  if not CreateProcess(nil, PChar('cmd.exe /C ' + Command), nil, nil, False,
    CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShowMessage('Erro ao executar o comando: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  // Aguarda a execu��o do comando
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  // Verifica o c�digo de sa�da do processo
  if ExitCode <> 0 then
  begin
    ShowMessage('Erro ao executar o comando. C�digo de sa�da: ' +
      intToStr(ExitCode));
    Exit;
  end;

  // Fechar handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
end;

//function TBradesco.GetBase64FromFile(const FileName: string): string;
//var
//  FileStream: TFileStream;
//  MemoryStream: TMemoryStream;
//begin
//  // Cria um stream para ler o arquivo
//  FileStream := TFileStream.Create(FileName, fmOpenRead);
//  try
//    // Cria um MemoryStream para armazenar o conte�do do arquivo
//    MemoryStream := TMemoryStream.Create;
//    try
//      // Copia o conte�do do arquivo para o MemoryStream
//      MemoryStream.CopyFrom(FileStream, FileStream.Size);
//
//      // Converte o conte�do do MemoryStream para Base64
//      // Result := TNetEncoding.Base64.EncodeBytesToString(MemoryStream.Memory, MemoryStream.Size);
//    finally
//      MemoryStream.Free;
//    end;
//  finally
//    FileStream.Free;
//  end;
//end;

function TBradesco.GetBase64FromFile(const FileName: string): string;
var
  FileStream: TFileStream;
  MemoryStream: TMemoryStream;
  Encoder: TIdEncoderMIME;
begin
  // Cria um stream para ler o arquivo
  FileStream := TFileStream.Create(FileName, fmOpenRead);
  try
    // Cria um MemoryStream para armazenar o conte�do do arquivo
    MemoryStream := TMemoryStream.Create;
    try
      // Copia o conte�do do arquivo para o MemoryStream
      MemoryStream.CopyFrom(FileStream, FileStream.Size);

      // Agora, criamos o encoder MIME
      Encoder := TIdEncoderMIME.Create(nil);
      try
        // Codifica os dados do MemoryStream diretamente em Base64
        Result := Encoder.Encode(MemoryStream);
      finally
        Encoder.Free;
      end;
    finally
      MemoryStream.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

end.

  Comando bradesco:

  echo - n " $
(cat JWT.txt " | openssl dgst - sha256 - keyform pem -
  sign oxymed.homologacao.key.pem | Base64 | td - d '=[space:]' | tr '+/' '-_'

  erro: 'base64' n�o � reconhecido como um Comando interno ou externo,
  um programa oper�vel ou um arquivo em lotes.

  { https://jwt.io/ }
{
  As credenciais do ambiente de homologa��o j� foram criadas, segue abaixo:
  Client Key: 9693f06b-b929-4a9c-8182-e25270c4029d
  Client Secret: 7cb3d3eb-a2c9-4084-8e03-72230000b4dd
  https://proxy.api.prebanco.com.br/auth/server/v1.1/token
}

//c:\wander\OpenSSL-Win64\bin\openssl.exe dgst -sha256 -keyform pem -sign "c:\wander\chaves\privada\oxymed.homologacao.key.pem" < "{"alg":"RS256","typ":"JWT"}.{"aud":"https:__proxy.api.prebanco.com.br_auth_server_v1.1_token","sub":"9693f06b-b929-4a9c-8182-e25270c4029d","iat":"3946727048","exp":"3946730648","jti":"3946727048000","ver":"1.1"}" > "c:\wander\signatureJWS.bin"
//c:\wander\OpenSSL-Win64\bin\openssl.exe dgst -sha256 -keyform pem -sign "c:\wander\chaves\privada\oxymed.homologacao.key.pem" -in "c:\wander\temp_payload.json" -out "c:\wander\signatureJWS.bin"


o payload precisa ter as seguintes pares:
aud
sub
iat
exp
jti
ver
