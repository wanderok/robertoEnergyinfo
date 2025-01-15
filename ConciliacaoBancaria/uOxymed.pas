unit uOxymed;

{
https://jwt.io/
}

interface

uses

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls, IdGlobal, System.JSON,
  System.Net.HttpClient, System.Net.URLClient,
  Winapi.ShellAPI,
  System.Net.HttpClientComponent,
  System.NetEncoding,
  System.IOUtils,
  System.Diagnostics,
  System.DateUtils,
  ACBrDFeSSL;

type
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

    procedure GerarParametros;
    procedure CriarHeader;
    procedure CriarHeaderBase64;

    procedure CriarPayload;
    procedure CriarPayloadBase64;

    procedure GerarTokenJWT;
    procedure GerarTokenJWTBase64;

    procedure GerarJWS;
    procedure GerarBearerToken;

    function GerarAssinatura: string;

    procedure GravarParametrosGerados;

    function APIToken: String;
    function APIBarenToken: String;
    function CodificarBase64(const Texto: string): string;

    procedure ExecutarComando(const Comando: string);
    function Base64ToBase64URL(const Base64: string): string;
    procedure CriarRequestTxt(const Metodo, Endpoint, Parametros, Body: string);
    function GetCurrentTimeInMilliseconds: Int64;
    procedure GeraTokenAssinado;

  public
    constructor Create;
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
    function Extrato(Inicio, Fim: TDateTime): String;
    procedure Iniciar;
  end;

implementation


function TBradesco.APIBarenToken: String;
begin
  result := 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token';
end;

function TBradesco.APIToken: String;
begin
  result := 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token';
end;

function TBradesco.Base64ToBase64URL(const Base64: string): string;
begin
  result := StringReplace(Base64, '+', '-', [rfReplaceAll]);
  result := StringReplace(result, '/', '_', [rfReplaceAll]);
  result := StringReplace(result, '=', '', [rfReplaceAll]); // Remove paddings
end;

function TBradesco.CodificarBase64(const Texto: string): string;
begin
  result := TNetEncoding.Base64.Encode(Texto);
  result := Base64ToBase64URL(result); // Converte de Base64 para Base64URL
end;

constructor TBradesco.Create;
begin
   self.FHeader :='';
   self.FPayload :='';

   self.FHeaderBase64 :='';
   self.FPayloadBase64 :='';
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
  IAT, EXP, JTI: Int64; // Alterado para Int64  // Integer;
begin
  // Obter o timestamp atual em segundos
  IAT := Trunc(Now * 86400) + 25569;
  // Converte de "tData" para timestamp em segundos
  EXP := IAT + 3600; // Expiração de 1 hora
  JTI := IAT * 1000; // jti em milissegundos

  Payload := TJSONObject.Create;
  try
    Payload.AddPair('aud', self.APIToken);
    Payload.AddPair('sub', self.ClientKey);
    Payload.AddPair('iat', IAT);
    Payload.AddPair('exp', EXP);
    Payload.AddPair('jti', JTI);
    Payload.AddPair('ver', '1.1');
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
  // 'C:\wander\request.txt';

  // Cria o arquivo de request com as informações necessárias
  TFile.WriteAllText(RequestFile, Metodo + #13#10 +
    // Método HTTP (exemplo: POST)
    Endpoint + #13#10 + // Endpoint (exemplo: /api/registro)
    Parametros + #13#10 + // Parâmetros (se houver, senão deixe vazio)
    Body); // Body da requisição (se houver, senão deixe vazio)
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
  Cmd := 'cmd.exe /c ' + Comando; // O /c executa e fecha o cmd após a execução

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
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  BearerToken, Nonce: string;
  Headers: TNetHeaders;
  RequestStream, ResponseStream: TMemoryStream;
  HeaderBase64Url ,PayloadBase64Url, Base64Signature: String;

begin


  // Gera o nonce (pode ser o JTI ou timestamp)
  Nonce := IntToStr(GetCurrentTimeInMilliseconds); // Exemplo com timestamp


  // Verificar os valores dos cabeçalhos antes de enviar a requisição
  //ShowMessage('Bearer Token: ' + BearerToken);
  //ShowMessage('Nonce: ' + Nonce);
  //ShowMessage('Signature: ' + Signature);


  // Cria um objeto HttpClient
  HttpClient := THttpClient.Create;
  try
    // Define os cabeçalhos da requisição
    SetLength(Headers, 3);

    Headers[0].Name := 'Authorization';
    Headers[0].Value := 'Bearer ' + self.FBearerToken;

    Headers[1].Name := 'X-Brad-Nonce';
    Headers[1].Value := Nonce;

    Headers[2].Name := 'X-Brad-Signature';
    Headers[2].Value := self.FAssinatura;

    // Criação do stream de requisição (isso pode variar dependendo de como seu corpo de requisição deve ser montado)
    RequestStream := TMemoryStream.Create;
    try
      // Aqui você pode adicionar o conteúdo do corpo da requisição no RequestStream

      // Criação do stream de resposta (onde a resposta será lida)
      ResponseStream := TMemoryStream.Create;
      try
        // Envia a requisição POST para o endpoint desejado
        Response := HttpClient.Post(self.APIToken, RequestStream,
          ResponseStream, Headers);

        if Response.StatusCode = 200 then
        begin
          ShowMessage('Requisição realizada com sucesso.');
        end
        else
        begin
          ShowMessage('Erro ao realizar a requisição: ' +
            Response.StatusCode.ToString + #13#10 + Response.ContentAsString());
        end;

      finally
        ResponseStream.Free;
      end;
    finally
      RequestStream.Free;
    end;
  finally
    HttpClient.Free;
  end;
end;


//function TBradesco.GerarAssinatura: string;
//var
//  CmdLine, OutputFile, InputFile: string;
//  Base64Signature: string;
//  ProcessInfo: TProcessInformation;
//  StartupInfo: TStartupInfo;
//    ExitCode: DWORD;
//
//  HeaderBase64Url, PayloadBase64Url:String;
//begin
//
//  // Codifique o Header e Payload em Base64Url
//  HeaderBase64Url := CodificarBase64(self.Header);
//  PayloadBase64Url := CodificarBase64(self.Payload);
//
//  // Concatenar o Header e o Payload para formar o conteúdo do JWT
//  // Isso é o que será assinado
//  // Aqui, não é necessário codificar novamente, já que já fizemos a codificação antes
//  TFile.WriteAllText('c:\wander\jwt.txt', HeaderBase64Url + '.' + PayloadBase64Url);  // Salvar conteúdo em arquivo

//
//  // Salva o JWS (Header + Payload) em um arquivo temporário
//  InputFile := self.FPastaDeTrabalho + '\jwt.txt';
//  OutputFile := self.FPastaDeTrabalho + '\signature.bin';
//
//// Comando OpenSSL para assinar o conteúdo
//  CmdLine := 'openssl dgst -sha256 -keyform pem -sign "' +
//             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "c:\wander\jwt.txt" | base64 | tr -d "=[:space:]" | tr "+/" "-_"';
//
//
////  // Cria o arquivo com o conteúdo do JWS
////  //TFile.WriteAllText(InputFile, self.FJWS);
////
////  // Comando OpenSSL para gerar a assinatura
////  //CmdLine := 'openssl dgst -sha256 -keyform pem -sign ' + self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem -out '
////  //           + OutputFile + ' ' + InputFile;
////
//////  CmdLine := 'echo -n "$cat '+ self.FPastaDeTrabalho +'\jwt.txt)"// | openssl dgst -sha256 -keyform pem -sign ' + self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem|base64|tr -d'=[:space:] | tr '+/' '-_';
////
////// Montar o comando corretamente
////  CmdLine := 'echo -n "' + self.FPastaDeTrabalho + '\jwt.txt" | openssl dgst -sha256 -keyform pem -sign "' +
////              self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" | ' +
////              'base64 | tr -d ''=[:space:]'' | tr ''+/'' ''-_''';
////  // Criação das estruturas necessárias
////  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
////  StartupInfo.cb := SizeOf(StartupInfo);
////
////  // Comando a ser executado
////  if not CreateProcess(nil, PChar('cmd.exe /c ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
////  begin
////    Result := 'Erro ao executar o OpenSSL: ' + SysErrorMessage(GetLastError);
////    Exit;
////  end;
////
////  // Aguarda a execução do comando
////  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
////  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
////  CloseHandle(ProcessInfo.hProcess);
////  CloseHandle(ProcessInfo.hThread);
////
////  // Verifica o código de saída do OpenSSL
////  if ExitCode <> 0 then
////  begin
////    Result := 'Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode);
////    Exit;
////  end;
////
////  // Lê a assinatura gerada
////  if FileExists(OutputFile) then
////  begin
////    // Converte a assinatura binária para Base64
////    Base64Signature := TNetEncoding.Base64.EncodeBytesToString(TFile.ReadAllBytes(OutputFile));
////    Result := Base64Signature;
////  end
////  else
////  begin
////    Result := 'Erro: Arquivo de assinatura não encontrado.';
////  end;
//
// // Inicializa as estruturas para o CreateProcess
//  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
//  StartupInfo.cb := SizeOf(StartupInfo);
//
//  // Cria o processo para executar o comando OpenSSL
//  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
//  begin
//    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
//    Exit;
//  end;
//
//  // Aguarda a execução do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o código de saída do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode));
//    Exit;
//  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // Lê a assinatura gerada
//  ShowMessage('Assinatura gerada com sucesso!');
//
//end;


//function TBradesco.GerarAssinatura: string;
//var
//  CmdLine, OutputFile, InputFile: string;
//  Base64Signature: string;
//  ProcessInfo: TProcessInformation;
//  StartupInfo: TStartupInfo;
//    ExitCode: DWORD;
//
//  HeaderBase64Url, PayloadBase64Url:String;
//begin
//
//  // Codifique o Header e Payload em Base64Url
//  HeaderBase64Url := CodificarBase64(self.Header);
//  PayloadBase64Url := CodificarBase64(self.Payload);
//
//  // Concatenar o Header e o Payload para formar o conteúdo do JWT
//  // Isso é o que será assinado
//  // Aqui, não é necessário codificar novamente, já que já fizemos a codificação antes
//  TFile.WriteAllText('c:\wander\jwt.txt', HeaderBase64Url + '.' + PayloadBase64Url);  // Salvar conteúdo em arquivo

//
//  // Salva o JWS (Header + Payload) em um arquivo temporário
//  InputFile := self.FPastaDeTrabalho + '\jwt.txt';
//  OutputFile := self.FPastaDeTrabalho + '\signature.bin';
//
//// Comando OpenSSL para assinar o conteúdo
//  CmdLine := 'openssl dgst -sha256 -keyform pem -sign "' +
//             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "c:\wander\jwt.txt" | base64 | tr -d "=[:space:]" | tr "+/" "-_"';
//
//
//
// // Inicializa as estruturas para o CreateProcess
//  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
//  StartupInfo.cb := SizeOf(StartupInfo);
//
//  // Cria o processo para executar o comando OpenSSL
//  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
//  begin
//    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
//    Exit;
//  end;
//
//  // Aguarda a execução do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o código de saída do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode));
//    Exit;
//  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // Lê a assinatura gerada
//  ShowMessage('Assinatura gerada com sucesso!');
//
//end;


//function TBradesco.GerarAssinatura: string;
//var
//  CmdLine, OutputFile, InputFile: string;
//  Base64Signature: string;
//  ProcessInfo: TProcessInformation;
//  StartupInfo: TStartupInfo;
//  ExitCode: DWORD;
//  Buffer: array[0..1023] of AnsiChar;
//  BytesRead: DWORD;
//  OpenSSLPath: string;
//   HeaderBase64Url, PayloadBase64Url: string;
//begin
//  // Codifique o Header e Payload em Base64Url
//  HeaderBase64Url := CodificarBase64(self.Header);
//  PayloadBase64Url := CodificarBase64(self.Payload);
//
//  // Concatenar Header + Payload e salvar em um arquivo
//  TFile.WriteAllText('c:\wander\jwt.txt', HeaderBase64Url + '.' + PayloadBase64Url);
//
//  // Caminhos dos arquivos
//  InputFile := 'c:\wander\jwt.txt';  // O arquivo de entrada
//  OutputFile := self.FPastaDeTrabalho + '\signature.bin';  // O arquivo de saída
//
//  // Caminho completo para o OpenSSL (adapte conforme a sua instalação)
//  OpenSSLPath := '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe"';  // Exemplo, substitua pelo seu caminho real
//
//  // Comando OpenSSL para assinar o conteúdo
////  CmdLine := '"' + OpenSSLPath + '" dgst -sha256 -keyform pem -sign "' +
////             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "' +
////             InputFile + '" | base64 | tr -d "=[:space:]" | tr "+/" "-_"';
////
//
//
// CmdLine := 'echo -n "$(' + self.FPastaDeTrabalho + '\jwt.txt)" | '+OpenSSLPath+ ' dgst -sha256 -keyform pem -sign ' +
//              self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem"|' +
//              'base64|tr -d ''=[:space:]'' | tr ''+/'' ''-_''';
//
//   TFile.WriteAllText(self.FPastaDeTrabalho + '\CmdLine.txt', CmdLine);
//  // Inicializa as estruturas para o CreateProcess
//  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
//  StartupInfo.cb := SizeOf(StartupInfo);
//
//  // Cria o processo para executar o comando OpenSSL
//  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
//  begin
//    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
//    Exit;
//  end;
//
//  // Aguarda a execução do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o código de saída do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    // Leitura da saída de erro
//    ReadFile(ProcessInfo.hProcess, Buffer, SizeOf(Buffer), BytesRead, nil);
//    ShowMessage('Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode) + #13#10 + String(Buffer));
//    Exit;
//  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // Lê a assinatura gerada
//  ShowMessage('Assinatura gerada com sucesso!');
//end;
//



//ok ok ok ok ok ok ok ok ok ok ok ok ok ok
function TBradesco.GerarAssinatura: string;
var
  CmdLine, OutputFile, InputFile: string;
  Base64Signature: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  ExitCode: DWORD;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead: DWORD;
  OpenSSLPath: string;
  CmdOutputFile: string;
  TempSignatureFile: string;
  HeaderBase64Url, PayloadBase64Url: string;
begin
  // Caminhos dos arquivos
  InputFile := 'c:\wander\jwt.txt';  // O arquivo de entrada
  TempSignatureFile := 'c:\wander\signature.bin';  // Arquivo temporário para assinatura binária
  CmdOutputFile := 'c:\wander\signature.base64.bin';  // Arquivo final com assinatura em base64

  // Caminho completo para o OpenSSL (adapte conforme a sua instalação)
  OpenSSLPath := '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe"';  // Exemplo, substitua pelo seu caminho real

  // Comando OpenSSL para assinar o conteúdo
  CmdLine := OpenSSLPath + ' dgst -sha256 -keyform pem -sign "' +
             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "' +
             InputFile + '" > "' + TempSignatureFile + '"';

  TFile.WriteAllText(self.FPastaDeTrabalho + '\CmdLine2.txt', CmdLine);

  // Inicializa as estruturas para o CreateProcess
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  // Cria o processo para executar o comando OpenSSL
  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  // Aguarda a execução do comando
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  // Verifica o código de saída do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode));
//    Exit;
//  end;

  // Fechar handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  // Agora, vamos usar o CertUtil para codificar a assinatura binária em Base64
  CmdLine := 'certutil -encode "' + TempSignatureFile + '" "' + CmdOutputFile + '"';

  // Inicializa novamente o processo para rodar o CertUtil
  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShowMessage('Erro ao executar CertUtil: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  // Aguarda a execução do comando CertUtil
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  // Verifica o código de saída do CertUtil
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar CertUtil. Código de saída: ' + IntToStr(ExitCode));
//    Exit;
//  end;

  // Fechar handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);

  // Lê a assinatura Base64 do arquivo de saída
  Base64Signature := TFile.ReadAllText(CmdOutputFile);

  // Opcional: Remover a linha extra gerada pelo certutil (essa linha pode ser removida se estiver em formato certutil)
  //Base64Signature := Copy(Base64Signature, Pos(#13#10, Base64Signature) + 2, MaxInt);
  Base64Signature := Base64ToBase64URL(Base64Signature);

  // Salva a assinatura gerada
  self.FAssinatura := Base64Signature;
end;



procedure TBradesco.GerarParametros;
begin
  CriarHeader;
  CriarHeaderBase64;

  CriarPayload;
  CriarPayloadBase64;

  GerarTokenJWT;
  GerarTokenJWTBase64;

  GerarAssinatura;
  GerarJWS;

  GerarBearerToken;

  GravarParametrosGerados;

end;

//function TBradesco.GerarAssinatura: string;
//var
//  CmdLine: string;
//  ProcessInfo: TProcessInformation;
//  StartupInfo: TStartupInfo;
//  ExitCode: DWORD;
//  PipeRead, PipeWrite: THandle;
//  Buffer: array[0..1023] of AnsiChar;
//  BytesRead: DWORD;
//  StdErrString: string;
//begin
//  // Caminhos dos arquivos
//  CmdLine := 'cmd.exe /C echo -n "' + self.FPastaDeTrabalho + '\jwt.txt" | ' +
//             '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe" dgst -sha256 -keyform pem -sign "' +
//             'C:\WANDER\chaves\privada\oxymed.homologacao.key.pem" | ' +
//             'base64 | tr -d "=[:space:]" | tr "+/" "-_"';
//
//  // Cria o pipe para capturar a saída do comando
////  if not CreatePipe(PipeRead, PipeWrite) then
//  if not CreatePipe(PipeRead, PipeWrite, nil, 4096) then
//  begin
//    ShowMessage('Erro ao criar o pipe');
//    Exit;
//  end;
//
//  // Inicializa as estruturas para o CreateProcess
//  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
//  StartupInfo.cb := SizeOf(StartupInfo);
//
//  // Inicializa as propriedades para redirecionamento da saída padrão
//  StartupInfo.dwFlags := STARTF_USESTDHANDLES;
//  StartupInfo.hStdOutput := PipeWrite;
//  StartupInfo.hStdError := PipeWrite;
//  StartupInfo.hStdInput := PipeRead;
//
//  // Cria o processo para executar o comando OpenSSL
//  if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
//  begin
//    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
//    Exit;
//  end;
//
//  // Aguarda a execução do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o código de saída do OpenSSL
////  if ExitCode <> 0 then
////  begin
////    ShowMessage('Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode));
////    Exit;
////  end;
//
//  // Lê a saída do processo (a assinatura gerada)
//  StdErrString := '';
//  while ReadFile(PipeRead, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) do
//  begin
//    SetString(StdErrString, PAnsiChar(@Buffer), BytesRead);
//  end;
//
//  // Exibe a assinatura gerada
// // ShowMessage('Assinatura gerada com sucesso! A assinatura é: ' + StdErrString);
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//  CloseHandle(PipeRead);
//  CloseHandle(PipeWrite);
//end;

//function TBradesco.GerarAssinatura: string;
//var
//  CmdLine: string;
//  ProcessInfo: TProcessInformation;
//  StartupInfo: TStartupInfo;
//  ExitCode: DWORD;
//  PipeRead, PipeWrite: THandle;
//  Buffer: array[0..1023] of AnsiChar;
//  BytesRead: DWORD;
//  StdErrString: string;
//  StartTime: DWORD;
//begin
//  // Caminhos dos arquivos
//  CmdLine := 'cmd.exe /C echo -n "' + self.FPastaDeTrabalho + '\jwt.txt" | ' +
//             '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe" dgst -sha256 -keyform pem -sign "' +
//             'C:\WANDER\chaves\privada\oxymed.homologacao.key.pem" | ' +
//             'base64 | tr -d "=[:space:]" | tr "+/" "-_"';
//
//  // Cria o pipe para capturar a saída do comando
//  if not CreatePipe(PipeRead, PipeWrite, nil, 4096) then
//  begin
//    ShowMessage('Erro ao criar o pipe');
//    Exit;
//  end;
//
//  // Inicializa as estruturas para o CreateProcess
//  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
//  StartupInfo.cb := SizeOf(StartupInfo);
//
//  // Inicializa as propriedades para redirecionamento da saída padrão
//  StartupInfo.dwFlags := STARTF_USESTDHANDLES;
//  StartupInfo.hStdOutput := PipeWrite;
//  StartupInfo.hStdError := PipeWrite;
//  StartupInfo.hStdInput := PipeRead;
//
//  // Cria o processo para executar o comando OpenSSL
//  if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
//  begin
//    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
//    Exit;
//  end;
//
//  // Aguarda a execução do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o código de saída do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. Código de saída: ' + IntToStr(ExitCode));
//    Exit;
//  end;
//
//  // Lê a saída do processo (a assinatura gerada)
//  StdErrString := '';
//  StartTime := GetTickCount;  // Obtém o tempo atual em milissegundos
//
//  while True do
//  begin
//    // Tenta ler do pipe
//    if ReadFile(PipeRead, Buffer, SizeOf(Buffer), BytesRead, nil) then
//    begin
//      if BytesRead > 0 then
//      begin
//        // Adiciona os dados lidos à string de erro
//        SetString(StdErrString, PAnsiChar(@Buffer), BytesRead);
//      end
//      else
//        Break;  // Se não há mais dados para ler, sai do loop
//    end
//    else
//    begin
//      // Em caso de erro na leitura do pipe
//      ShowMessage('Erro ao ler o pipe: ' + SysErrorMessage(GetLastError));
//      Break;
//    end;
//
//    // Verifica se o tempo de leitura ultrapassou 10 segundos (timeout)
//    if (GetTickCount - StartTime) > 10000 then
//    begin
//      ShowMessage('Leitura do pipe demorou mais de 10 segundos.');
//      Break;  // Encerra a leitura após 10 segundos
//    end;
//  end;
//
//  // Exibe a assinatura gerada
//  ShowMessage('Assinatura gerada com sucesso! A assinatura é: ' + StdErrString);
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//  CloseHandle(PipeRead);
//  CloseHandle(PipeWrite);
//end;

procedure TBradesco.GerarBearerToken;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  Params: TStringList;
begin
  HttpClient := THTTPClient.Create;
  Params := TStringList.Create;
  try
    // Adiciona os parâmetros para a requisição
    Params.Add('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer');
    Params.Add('assertion=' + self.FJWS);

    // Define o cabeçalho Content-Type
    HttpClient.ContentType := 'application/x-www-form-urlencoded';

    // Envia a requisição POST para obter o Bearer Token
    Response := HttpClient.Post(self.APIToken, Params);

    // Verificar a resposta da API
    if Response.StatusCode = 200 then
    begin
      // Se a resposta for 200 OK, o Bearer Token é extraído
      self.FBearerToken := Response.ContentAsString;
    end
    else
    begin
      // Se não for sucesso, exibe a resposta para depuração
      self.FBearerToken := 'Erro HTTP ' + IntToStr(Response.StatusCode) + ': ' + Response.ContentAsString();
    end;
  finally
    HttpClient.Free;
    Params.Free;
  end;
end;


procedure TBradesco.GerarTokenJWT;
begin

  self.FJWT := self.FHeader + '.' + self.FPayload;




  // Exibir o Header e Payload codificados para verificar
  //ShowMessage('Header codificado: ' + Header);
  //ShowMessage('Payload codificado: ' + Payload);

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
  // Obtém o número de milissegundos desde a "época" (01/01/1970)
  result := DateTimeToUnix(Now) * 1000;
end;

procedure TBradesco.GravarParametrosGerados;
begin
  TFile.WriteAllText(self.FPastaDeTrabalho + '\header.txt', self.FHeader);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\payload.txt', self.FPayload);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\headerBase64.txt', self.FHeaderBase64);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\payloadBase64.txt', self.FPayloadBase64);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\jwt.txt', self.FJWT);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\jwtBase64.txt', self.FJWTBase64);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\AssinaturaOK.txt', self.FAssinatura);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\jws.txt', self.FJWS);

  TFile.WriteAllText(self.FPastaDeTrabalho + '\BearerToken.txt', self.FBearerToken);

end;

procedure TBradesco.Iniciar;
begin
   GerarParametros;
end;

procedure TBradesco.GerarJWS;
begin
  //Base64ToBase64URL(Signature);
  self.FJWS := self.FHeaderBase64 + '.' + self.FPayloadBase64 + '.' + self.FAssinatura;
end;



end.



// CmdLine := 'echo -n "(' + self.FPastaDeTrabalho + '\jwt.txt)" | openssl dgst -sha256 -keyform pem -sign "' +
//              self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" | ' +
//              'base64 | tr -d ''=[:space:]'' | tr ''+/'' ''-_''';

  // Gera a assinatura JWS
  //Signature := selfGerarAssinatura;
  //Signature := Base64ToBase64URL(Signature);

