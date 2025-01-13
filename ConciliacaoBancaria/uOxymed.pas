unit uOxymed;

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
    FToken: String;
    FHeader: String;
    FPayload: String;
    FClientKey: String;
    function CriarHeader: string;
    function CriarPayload: string;
    // function ClientKey:String;

    procedure GerarTokenJWT_01;

    function APIToken: String;
    function APIBarenToken: String;
    function CodificarBase64(const Texto: string): string;
    function GerarAssinatura: string;
    // function GerarAssinatura(Aut: TStream): string;
    function MontarJWS: string;
    function ObterBearerToken(const JWS: string): string;
    function GerarToken: String;
    procedure ExecutarComando(const Comando: string);
    procedure SaveJWTToFile;
    function Base64ToBase64URL(const Base64: string): string;
    procedure CriarRequestTxt(const Metodo, Endpoint, Parametros, Body: string);
    function GetCurrentTimeInMilliseconds: Int64;

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
    property JWS: string read FJWS write FJWS;
    property ClientKey: string read FClientKey write FClientKey;
    property Token: string read FToken write FToken;
    property PastaDeTrabalho: string read FPastaDeTrabalho
      write FPastaDeTrabalho;
    function Extrato(Inicio, Fim: TDateTime): String;

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
end;

function TBradesco.CriarHeader: string;
var
  Header: TJSONObject;
begin
  Header := TJSONObject.Create;
  try
    Header.AddPair('alg', 'RS256');
    Header.AddPair('typ', 'JWT');
    result := Header.ToString;
  finally
    Header.Free;
  end;
end;

function TBradesco.CriarPayload: string;
var
  Payload: TJSONObject;
  IAT, EXP, JTI: Int64; // Alterado para Int64  // Integer;
begin
  // Obter o timestamp atual em segundos
  IAT := Trunc(Now * 86400) + 25569;
  // Converte de "tData" para timestamp em segundos
  EXP := IAT + 3600; // Expira��o de 1 hora
  JTI := IAT * 1000; // jti em milissegundos

  Payload := TJSONObject.Create;
  try
    Payload.AddPair('aud', self.APIToken);
    Payload.AddPair('sub', self.ClientKey);
    Payload.AddPair('iat', IAT);
    Payload.AddPair('exp', EXP);
    Payload.AddPair('jti', JTI);
    Payload.AddPair('ver', '1.1');
    result := Payload.ToString;
  finally
    Payload.Free;
  end;
end;

procedure TBradesco.CriarRequestTxt(const Metodo, Endpoint, Parametros,
  Body: string);
var
  RequestFile: string;
begin
  // Define o caminho do arquivo de request
  RequestFile := self.FPastaDeTrabalho + '\request.txt';
  // 'C:\wander\request.txt';

  // Cria o arquivo de request com as informa��es necess�rias
  TFile.WriteAllText(RequestFile, Metodo + #13#10 +
    // M�todo HTTP (exemplo: POST)
    Endpoint + #13#10 + // Endpoint (exemplo: /api/registro)
    Parametros + #13#10 + // Par�metros (se houver, sen�o deixe vazio)
    Body); // Body da requisi��o (se houver, sen�o deixe vazio)
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
  HttpClient: THttpClient;
  Response: IHTTPResponse;
  BearerToken, Nonce, Signature: string;
  Headers: TNetHeaders;
  RequestStream, ResponseStream: TMemoryStream;
  HeaderBase64Url ,PayloadBase64Url, Base64Signature: String;

begin
  // Recupera o Bearer Token
  //GerarToken;

  GerarTokenJWT_01;

  // Gera a assinatura JWS
  Signature := GerarAssinatura;
  //Signature := Base64ToBase64URL(Signature);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\assinatura.txt', Signature);
  Signature := TFile.ReadAllText(self.FPastaDeTrabalho + '\assinaturaOK.txt');

  HeaderBase64Url := Base64ToBase64URL(self.FHeader);
  PayloadBase64Url := Base64ToBase64URL(self.FPayload);
  Base64Signature:= Base64ToBase64URL(Signature);

  //self.FJWS := CodificarBase64(Header) + '.' + CodificarBase64(Payload) + Signature;
  //self.FJWS := self.FHeader + '.' + self.FPayload +  '.' + Base64ToBase64URL(Signature);
  self.FJWS := HeaderBase64Url + '.' + PayloadBase64Url + '.' + Base64Signature;
  TFile.WriteAllText(self.FPastaDeTrabalho + '\JWS.txt', self.FJWS);


  BearerToken := ObterBearerToken(self.FJWS); //self.FToken;

  // Gera o nonce (pode ser o JTI ou timestamp)
  Nonce := IntToStr(GetCurrentTimeInMilliseconds); // Exemplo com timestamp


  // Verificar os valores dos cabe�alhos antes de enviar a requisi��o
ShowMessage('Bearer Token: ' + BearerToken);
ShowMessage('Nonce: ' + Nonce);
ShowMessage('Signature: ' + Signature);


  // Cria um objeto HttpClient
  HttpClient := THttpClient.Create;
  try
    // Define os cabe�alhos da requisi��o
    SetLength(Headers, 3);

    Headers[0].Name := 'Authorization';
    Headers[0].Value := 'Bearer ' + BearerToken;

    Headers[1].Name := 'X-Brad-Nonce';
    Headers[1].Value := Nonce;

    Headers[2].Name := 'X-Brad-Signature';
    Headers[2].Value := Signature;

    // Cria��o do stream de requisi��o (isso pode variar dependendo de como seu corpo de requisi��o deve ser montado)
    RequestStream := TMemoryStream.Create;
    try
      // Aqui voc� pode adicionar o conte�do do corpo da requisi��o no RequestStream

      // Cria��o do stream de resposta (onde a resposta ser� lida)
      ResponseStream := TMemoryStream.Create;
      try
        // Envia a requisi��o POST para o endpoint desejado
        Response := HttpClient.Post(self.APIToken, RequestStream,
          ResponseStream, Headers);

        if Response.StatusCode = 200 then
        begin
          ShowMessage('Requisi��o realizada com sucesso.');
        end
        else
        begin
          ShowMessage('Erro ao realizar a requisi��o: ' +
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
//  // Concatenar o Header e o Payload para formar o conte�do do JWT
//  // Isso � o que ser� assinado
//  // Aqui, n�o � necess�rio codificar novamente, j� que j� fizemos a codifica��o antes
//  TFile.WriteAllText('c:\wander\jwt.txt', HeaderBase64Url + '.' + PayloadBase64Url);  // Salvar conte�do em arquivo

//
//  // Salva o JWS (Header + Payload) em um arquivo tempor�rio
//  InputFile := self.FPastaDeTrabalho + '\jwt.txt';
//  OutputFile := self.FPastaDeTrabalho + '\signature.bin';
//
//// Comando OpenSSL para assinar o conte�do
//  CmdLine := 'openssl dgst -sha256 -keyform pem -sign "' +
//             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "c:\wander\jwt.txt" | base64 | tr -d "=[:space:]" | tr "+/" "-_"';
//
//
////  // Cria o arquivo com o conte�do do JWS
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
////  // Cria��o das estruturas necess�rias
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
////  // Aguarda a execu��o do comando
////  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
////  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
////  CloseHandle(ProcessInfo.hProcess);
////  CloseHandle(ProcessInfo.hThread);
////
////  // Verifica o c�digo de sa�da do OpenSSL
////  if ExitCode <> 0 then
////  begin
////    Result := 'Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode);
////    Exit;
////  end;
////
////  // L� a assinatura gerada
////  if FileExists(OutputFile) then
////  begin
////    // Converte a assinatura bin�ria para Base64
////    Base64Signature := TNetEncoding.Base64.EncodeBytesToString(TFile.ReadAllBytes(OutputFile));
////    Result := Base64Signature;
////  end
////  else
////  begin
////    Result := 'Erro: Arquivo de assinatura n�o encontrado.';
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
//  // Aguarda a execu��o do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o c�digo de sa�da do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode));
//    Exit;
//  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // L� a assinatura gerada
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
//  // Concatenar o Header e o Payload para formar o conte�do do JWT
//  // Isso � o que ser� assinado
//  // Aqui, n�o � necess�rio codificar novamente, j� que j� fizemos a codifica��o antes
//  TFile.WriteAllText('c:\wander\jwt.txt', HeaderBase64Url + '.' + PayloadBase64Url);  // Salvar conte�do em arquivo

//
//  // Salva o JWS (Header + Payload) em um arquivo tempor�rio
//  InputFile := self.FPastaDeTrabalho + '\jwt.txt';
//  OutputFile := self.FPastaDeTrabalho + '\signature.bin';
//
//// Comando OpenSSL para assinar o conte�do
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
//  // Aguarda a execu��o do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o c�digo de sa�da do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode));
//    Exit;
//  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // L� a assinatura gerada
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
//  OutputFile := self.FPastaDeTrabalho + '\signature.bin';  // O arquivo de sa�da
//
//  // Caminho completo para o OpenSSL (adapte conforme a sua instala��o)
//  OpenSSLPath := '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe"';  // Exemplo, substitua pelo seu caminho real
//
//  // Comando OpenSSL para assinar o conte�do
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
//  // Aguarda a execu��o do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o c�digo de sa�da do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    // Leitura da sa�da de erro
//    ReadFile(ProcessInfo.hProcess, Buffer, SizeOf(Buffer), BytesRead, nil);
//    ShowMessage('Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode) + #13#10 + String(Buffer));
//    Exit;
//  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // L� a assinatura gerada
//  ShowMessage('Assinatura gerada com sucesso!');
//end;
//



//ok ok ok ok ok ok ok ok ok ok ok ok ok ok
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
//  CmdOutputFile: string;
//  TempSignatureFile: string;
//  HeaderBase64Url, PayloadBase64Url: string;
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
//  TempSignatureFile := 'c:\wander\signature.bin';  // Arquivo tempor�rio para assinatura bin�ria
//  CmdOutputFile := 'c:\wander\signature.base64';  // Arquivo final com assinatura em base64
//
//  // Caminho completo para o OpenSSL (adapte conforme a sua instala��o)
//  OpenSSLPath := '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe"';  // Exemplo, substitua pelo seu caminho real
//
//  // Comando OpenSSL para assinar o conte�do
//  CmdLine := OpenSSLPath + ' dgst -sha256 -keyform pem -sign "' +
//             self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" < "' +
//             InputFile + '" > "' + TempSignatureFile + '"';
//
//  TFile.WriteAllText(self.FPastaDeTrabalho + '\CmdLine2.txt', CmdLine);
//
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
//  // Aguarda a execu��o do comando
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o c�digo de sa�da do OpenSSL
////  if ExitCode <> 0 then
////  begin
////    ShowMessage('Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode));
////    Exit;
////  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // Agora, vamos usar o CertUtil para codificar a assinatura bin�ria em Base64
//  CmdLine := 'certutil -encode "' + TempSignatureFile + '" "' + CmdOutputFile + '"';
//
//  // Inicializa novamente o processo para rodar o CertUtil
//  if not CreateProcess(nil, PChar('cmd.exe /C ' + CmdLine), nil, nil, False, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
//  begin
//    ShowMessage('Erro ao executar CertUtil: ' + SysErrorMessage(GetLastError));
//    Exit;
//  end;
//
//  // Aguarda a execu��o do comando CertUtil
//  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
//  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
//
//  // Verifica o c�digo de sa�da do CertUtil
////  if ExitCode <> 0 then
////  begin
////    ShowMessage('Erro ao executar CertUtil. C�digo de sa�da: ' + IntToStr(ExitCode));
////    Exit;
////  end;
//
//  // Fechar handles
//  CloseHandle(ProcessInfo.hProcess);
//  CloseHandle(ProcessInfo.hThread);
//
//  // L� a assinatura Base64 do arquivo de sa�da
//  Base64Signature := TFile.ReadAllText(CmdOutputFile);
//
//  // Opcional: Remover a linha extra gerada pelo certutil (essa linha pode ser removida se estiver em formato certutil)
//  // Base64Signature := Copy(Base64Signature, Pos(#13#10, Base64Signature) + 2, MaxInt);
//
//  TFile.WriteAllText(self.FPastaDeTrabalho + '\AssinaturaOK.txt', Base64Signature);
//  // Exibe a assinatura gerada
//  ShowMessage('Assinatura gerada com sucesso! Base64: ' + Base64Signature);
//end;
//


function TBradesco.GerarAssinatura: string;
var
  CmdLine: string;
  ProcessInfo: TProcessInformation;
  StartupInfo: TStartupInfo;
  ExitCode: DWORD;
  PipeRead, PipeWrite: THandle;
  Buffer: array[0..1023] of AnsiChar;
  BytesRead: DWORD;
  StdErrString: string;
begin
  // Caminhos dos arquivos
  CmdLine := 'cmd.exe /C echo -n "' + self.FPastaDeTrabalho + '\jwt.txt" | ' +
             '"C:\Program Files\OpenSSL-Win64\bin\openssl.exe" dgst -sha256 -keyform pem -sign "' +
             'C:\WANDER\chaves\privada\oxymed.homologacao.key.pem" | ' +
             'base64 | tr -d "=[:space:]" | tr "+/" "-_"';

  // Cria o pipe para capturar a sa�da do comando
//  if not CreatePipe(PipeRead, PipeWrite) then
//  begin
//    ShowMessage('Erro ao criar o pipe');
//    Exit;
//  end;

  // Inicializa as estruturas para o CreateProcess
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);

  // Inicializa as propriedades para redirecionamento da sa�da padr�o
  StartupInfo.dwFlags := STARTF_USESTDHANDLES;
  StartupInfo.hStdOutput := PipeWrite;
  StartupInfo.hStdError := PipeWrite;
  StartupInfo.hStdInput := PipeRead;

  // Cria o processo para executar o comando OpenSSL
  if not CreateProcess(nil, PChar(CmdLine), nil, nil, True, CREATE_NO_WINDOW, nil, nil, StartupInfo, ProcessInfo) then
  begin
    ShowMessage('Erro ao executar OpenSSL: ' + SysErrorMessage(GetLastError));
    Exit;
  end;

  // Aguarda a execu��o do comando
  WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);

  // Verifica o c�digo de sa�da do OpenSSL
//  if ExitCode <> 0 then
//  begin
//    ShowMessage('Erro ao executar OpenSSL. C�digo de sa�da: ' + IntToStr(ExitCode));
//    Exit;
//  end;

  // L� a sa�da do processo (a assinatura gerada)
  StdErrString := '';
  while ReadFile(PipeRead, Buffer, SizeOf(Buffer), BytesRead, nil) and (BytesRead > 0) do
  begin
    SetString(StdErrString, PAnsiChar(@Buffer), BytesRead);
  end;

  // Exibe a assinatura gerada
  ShowMessage('Assinatura gerada com sucesso! A assinatura �: ' + StdErrString);

  // Fechar handles
  CloseHandle(ProcessInfo.hProcess);
  CloseHandle(ProcessInfo.hThread);
  CloseHandle(PipeRead);
  CloseHandle(PipeWrite);
end;





function TBradesco.GerarToken: String;
var
  JWS, BearerToken: string;
begin
  // Criar o JWS
  JWS := MontarJWS;

  // Obter o Bearer Token
  BearerToken := ObterBearerToken(JWS);

  // Exibir o Bearer Token
  self.FToken := BearerToken;
end;

procedure TBradesco.GerarTokenJWT_01;
var
  Header, Payload: string;
begin
  // Cria��o do Header e Payload
  Header := CriarHeader;

  self.FHeader := Header;
  Payload := CriarPayload;
  self.FPayload := Payload;

  // Codifica o Header e Payload em Base64
  //Header := CodificarBase64(Header);
  //Payload := CodificarBase64(Payload);

  self.FHeader := CodificarBase64(Header);
  self.FPayload := CodificarBase64(Payload);

  //Header := Header;
  //Payload := Payload;

  //grava para conrerencia
  TFile.WriteAllText(self.FPastaDeTrabalho + '\header.txt', self.Header);
  TFile.WriteAllText(self.FPastaDeTrabalho + '\payload.txt', self.Payload);

  self.FJWT := self.Header + '.' + self.Payload;


  // Exibir o Header e Payload codificados para verificar
  //ShowMessage('Header codificado: ' + Header);
  //ShowMessage('Payload codificado: ' + Payload);

  SaveJWTToFile;

end;

function TBradesco.GetCurrentTimeInMilliseconds: Int64;
begin
  // Obt�m o n�mero de milissegundos desde a "�poca" (01/01/1970)
  result := DateTimeToUnix(Now) * 1000;
end;

function TBradesco.MontarJWS: string;
var Signature: string;
begin
  // Gera a assinatura (JWS)
  Signature := GerarAssinatura;

  // Exibir a assinatura antes de codificar para Base64URL
  ShowMessage('Assinatura gerada (Base64): ' + Signature);

  // Converte a assinatura para Base64URL
  Signature := Base64ToBase64URL(Signature);
  //Signature := CodificarBase64(Signature);
  //Signature := CodificarBase64(Signature);

  // Exibir a assinatura em Base64URL
  ShowMessage('Assinatura em Base64URL: ' + Signature);

  // Concatena tudo para formar o JWS completo
  result := Header + '.' + Payload + '.' + Signature;
//  result := base64Url(Header) + '.' + base64Url(Payload) + '.' + base64Url(Signature)
  self.JWS := result;

  // Exibir o JWS completo antes de retornar
  ShowMessage('JWS completo: ' + result);
end;



function TBradesco.ObterBearerToken(const JWS: string): string;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  Params: TStringList;
begin
  HttpClient := THTTPClient.Create;
  Params := TStringList.Create;
  try
    // Adiciona os par�metros para a requisi��o
    Params.Add('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer');
    Params.Add('assertion=' + JWS);  // O JWS gerado

    // Define o cabe�alho Content-Type
    HttpClient.ContentType := 'application/x-www-form-urlencoded';

    // Envia a requisi��o POST para obter o Bearer Token
    Response := HttpClient.Post(self.APIToken, Params);

    // Verificar a resposta da API
    if Response.StatusCode = 200 then
    begin
      // Se a resposta for 200 OK, o Bearer Token � extra�do
      result := Response.ContentAsString;
    end
    else
    begin
      // Se n�o for sucesso, exibe a resposta para depura��o
      result := 'Erro HTTP ' + IntToStr(Response.StatusCode) + ': ' + Response.ContentAsString();
    end;
  finally
    HttpClient.Free;
    Params.Free;
  end;
end;


procedure TBradesco.SaveJWTToFile;
begin
  // Salva o conte�do de self.FJW em um arquivo chamado jwt.txt
  TFile.WriteAllText(self.FPastaDeTrabalho + '\jwt.txt', self.FJWT);
end;

end.



 CmdLine := 'echo -n "(' + self.FPastaDeTrabalho + '\jwt.txt)" | openssl dgst -sha256 -keyform pem -sign "' +
              self.FPastaDeTrabalho + '\chaves\privada\oxymed.homologacao.key.pem" | ' +
              'base64 | tr -d ''=[:space:]'' | tr ''+/'' ''-_''';

