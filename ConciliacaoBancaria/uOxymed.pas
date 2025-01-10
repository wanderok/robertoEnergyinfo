{
  As credenciais do ambiente de homologa��o j� foram criadas, segue abaixo:
  Client Key: 9693f06b-b929-4a9c-8182-e25270c4029d
  Client Secret: 7cb3d3eb-a2c9-4084-8e03-72230000b4dd

  https://slproweb.com/products/Win32OpenSSL.html

  Boleto Hibrido Bradesco no Delphi, Pix e C�digo de Barras, Gerando o JWS
  https://youtu.be/QZ8a5T-OVxA?si=xTvTrc2y561Un72u
  git clone https://github.com/HelioNeto/delphi-api-bradesco.git
}

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
    FJWS: String;
    FJWT: String;
    FToken: String;
    FHeader: String;
    FPayload: String;
    FClientKey: String;
    function CriarHeader: string;
    function CriarPayload: string;
    // function ClientKey:String;
    function APIToken: String;
    function CodificarBase64(const Texto: string): string;
    function GerarAssinatura(const JWS: string): string;
//    function GerarAssinatura(Aut: TStream): string;
    function MontarJWS: string;
    function ObterBearerToken(const JWS: string): string;
    function GerarToken: String;
    procedure ExecutarComando(const Comando: string);
    procedure SaveJWTToFile;
    function Base64ToBase64URL(const Base64: string): string;
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
    function Extrato(Inicio, Fim: TDateTime): String;

  end;

implementation

function TBradesco.APIToken: String;
begin
  result := 'https://proxy.api.prebanco.com.br/auth/server/v1.1/token';
end;

function TBradesco.Base64ToBase64URL(const Base64: string): string;
begin
  Result := StringReplace(Base64, '+', '-', [rfReplaceAll]);
  Result := StringReplace(Result, '/', '_', [rfReplaceAll]);
  Result := StringReplace(Result, '=', '', [rfReplaceAll]);  // Remove paddings
end;

// function TBradesco.ClientKey: String;
// begin
// result := '9693f06b-b929-4a9c-8182-e25270c4029d';
// end;

function TBradesco.CodificarBase64(const Texto: string): string;
begin
  result := TNetEncoding.Base64.Encode(Texto);
end;

constructor TBradesco.Create;
begin
  // FJWS := Self.MontarJWS;
  // FToken := self.GerarToken;
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
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  StringStream: TStringStream;
  JsonBody, FormBody: string;
  JsonResponse: TJSONObject;
begin
  self.FJWS := self.MontarJWS;
  HttpClient := THTTPClient.Create;

  try
    // Configura��o do TLS 1.2 (se necess�rio)
    HttpClient.AcceptEncoding := 'gzip, deflate';
    HttpClient.UserAgent := 'Delphi HTTP Client';

    // Configurar os headers personalizados (por exemplo, token Bearer)
    // HttpClient.CustomHeaders['Authorization'] := 'Bearer ' + self.FJWS;  // O seu JWS ou token JWT
    HttpClient.CustomHeaders['Content-Type'] :=
      'application/x-www-form-urlencoded';
    // ou 'application/json' dependendo da API

    // Montar o corpo da requisi��o com os par�metros necess�rios
    FormBody :=
      'grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&assertion=' +
      self.FJWS;

    // Criar o StringStream a partir do corpo da requisi��o
    StringStream := TStringStream.Create(FormBody, TEncoding.UTF8);

    try
      // Realizando a requisi��o GET
      Response := HttpClient.Post(self.APIToken, StringStream);

      // Verificando a resposta
      if Response.StatusCode = 200 then
      begin
        // Se a resposta for bem-sucedida, processar o JSON
        JsonResponse := TJSONObject.ParseJSONValue(Response.ContentAsString)
          as TJSONObject;
        try
          // Verificar se o campo "access_token" existe
          if Assigned(JsonResponse) and
            (JsonResponse.GetValue('access_token') <> nil) then
          begin
            // Retornar o Bearer Token
            result := JsonResponse.GetValue('access_token').Value;
          end
          else
          begin
            // Se o campo "access_token" n�o for encontrado
            result := 'Erro: "access_token" n�o encontrado na resposta.';
          end;
        finally
          JsonResponse.Free;
        end;
      end
      else
      begin
        // Caso haja erro HTTP
        result := 'Erro HTTP: ' + IntToStr(Response.StatusCode) + ' - ' +
          Response.StatusText;
      end;
      // A resposta ser� recebida diretamente
      // Result := Response.ContentAsString;
    except
      on E: Exception do
      begin
        result := 'Erro: ' + E.Message;
      end;
    end;
  finally
    StringStream.Free;
    HttpClient.Free;
  end;
end;

function TBradesco.GerarAssinatura(const JWS: string): string;
var
  Cmd, OutputFile, InputFile: string;
  // Process: TProcess;
begin
  // Salva o JWS (Header + Payload) em um arquivo tempor�rio
  InputFile := 'C:\wander\assinaturas\jwt.txt';
  OutputFile := 'C:\wander\assinaturas\signature.txt';

  // Cria o arquivo com o conte�do do JWS
  TFile.WriteAllText(InputFile, JWS);

  // Monta o comando para executar o OpenSSL
  // Cmd := 'openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem -out ' + OutputFile + ' ' + InputFile;
  // Cmd := 'echo -n "$(cat jwt.txt)" | openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem|base64|tr -d"=[space:]" | tr "+/" "-_";

  // Cmd := 'echo -n "$(cat jwt.txt)" | openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem|base64|tr -d"=[space:]" | tr "+/" "-_"';
  Cmd := 'openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem -out '
    + OutputFile + ' ' + InputFile;

  // Executa o comando
  ShellExecute(0, 'open', 'cmd.exe', PChar('/c ' + Cmd), nil, SW_HIDE);

  // L� a assinatura gerada
  result := TFile.ReadAllText(OutputFile);
end;

//function TBradesco.GerarAssinatura(Aut: TStream): string;
//var
//  Cmd, OutputFile, InputFile: string;
//  // Process: TProcess;
//  DFeSSL: TDFeSSL;
//begin
////  DFeSSL := TDFeSSL.Create;
////  DFeSSL.SSLCryptLib := cryOpenSSL;
////  DFeSSL.SSLHttpLib  := httpOpenSSL;
////  DFeSSL.SSLXmlSignLib:= xsLibXml2;
////  DFeSSL.ArquivoPFX:= 'chaves/privada/oxymed.homologacao.key.pem';
////  //DFeSSL.Senha := '7cb3d3eb-a2c9-4084-8e03-72230000b4dd';
////  DFeSSL.CarregarCertificado;
////  result := DFeSSL.calchash(Aut,dgstSHA256,outBase64,True);
////  DFeSSL.Free;
////  exit;
//
//  // Salva o JWS (Header + Payload) em um arquivo tempor�rio
//  InputFile := 'C:\wander\assinaturas\jwt.txt';
//  OutputFile := 'C:\wander\assinaturas\signature.txt';
//
//  // Cria o arquivo com o conte�do do JWS
//  TFile.WriteAllText(InputFile, JWS);
//
//  // Monta o comando para executar o OpenSSL
//  // Cmd := 'openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem -out ' + OutputFile + ' ' + InputFile;
//  // Cmd := 'echo -n "$(cat jwt.txt)" | openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem|base64|tr -d"=[space:]" | tr "+/" "-_";
//
//  // Cmd := 'echo -n "$(cat jwt.txt)" | openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem|base64|tr -d"=[space:]" | tr "+/" "-_"';
//  Cmd := 'openssl dgst -sha256 -keyform pem -sign chaves\privada\oxymed.homologacao.key.pem -out '
//    + OutputFile + ' ' + InputFile;
//
//  // Executa o comando
//  ShellExecute(0, 'open', 'cmd.exe', PChar('/c ' + Cmd), nil, SW_HIDE);
//
//  // L� a assinatura gerada
//  result := TFile.ReadAllText(OutputFile);
//end;

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

function TBradesco.MontarJWS: string;
var
  Header, Payload, Signature: string;
  Stream :TStringStream;
begin
  Header := CriarHeader;
  self.FHeader := Header;
  Payload := CriarPayload;
  self.FPayload := Payload;

  // Codifica o Header e Payload em Base64
  Header := CodificarBase64(Header);
  Payload := CodificarBase64(Payload);

  self.FJWT := Header + '.' + Payload;
  SaveJWTToFile;

  // Gera a assinatura (JWS)
   Signature := GerarAssinatura(self.FJWT);
//  Stream := TStringStream.Create(Header + '.' + Payload);
//  Signature := GerarAssinatura(Stream);


  // Concatena tudo para formar o JWS completo
  result := Header + '.' + Payload + '.' + Signature;
end;

// function TBradesco.ObterBearerToken(const JWS: string): string;
// var
// HttpClient: THttpClient;
// Response: IHTTPResponse;
// Params: TStringList;
// Body: string;
// begin
// HttpClient := THttpClient.Create;
// Params := TStringList.Create;
// try
// // Definir os par�metros do corpo da requisi��o
// Params.Add('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer');
// Params.Add('assertion=' + self.JWS);
//
// // Codificando os par�metros para 'application/x-www-form-urlencoded'
// Body := Params.DelimitedText;
//
// // Definir os cabe�alhos da requisi��o
// HttpClient.ContentType := 'application/x-www-form-urlencoded';
//
// // Enviar a requisi��o POST para obter o Bearer Token
// Response := HttpClient.Post(self.APIToken, Params);
/// /    // Retornar o corpo da resposta, que deve ser o Bearer Token
/// /    Result := Response.ContentAsString();
//
// // Exibindo a resposta (aqui voc� pode verificar a resposta da API)
// if Response.StatusCode = 200 then
// begin
// result := Response.ContentAsString();
// end
// else
// begin
// result := 'Erro na requisi��o: ' + Response.StatusCode.ToString;
// end;
// finally
// HttpClient.Free;
// Params.Free;
// end;
// end;

function TBradesco.ObterBearerToken(const JWS: string): string;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
  Params: TStringList;
begin
  HttpClient := THTTPClient.Create;
  Params := TStringList.Create;
  try
    // Definir os par�metros do corpo da requisi��o
    Params.Add('grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer');
    Params.Add('assertion=' + self.JWS);

    // Definir o cabe�alho Content-Type
    HttpClient.ContentType := 'application/x-www-form-urlencoded';

    // Enviar a requisi��o POST para obter o Bearer Token
    Response := HttpClient.Post(self.APIToken, Params);

    // Verificar se a resposta � bem-sucedida
    if Response.StatusCode = 200 then
    begin
      // Se sucesso, retornar o conte�do da resposta
      result := Response.ContentAsString();
    end
    else
    if Response.StatusCode = 500 then
    begin
      // Exibir o corpo da resposta para obter mais detalhes sobre o erro
      result := 'Erro HTTP 500: ' + Response.ContentAsString();
    end
    else
    begin
      result := 'Erro HTTP: ' + IntToStr(Response.StatusCode) + ' - ' +
        Response.StatusText;
    end;

  finally
    HttpClient.Free;
    Params.Free;
  end;
end;

procedure TBradesco.SaveJWTToFile;
begin
  // Salva o conte�do de self.FJW em um arquivo chamado jwt.txt
  TFile.WriteAllText('jwt.txt', CodificarBase64(self.FJWT));
end;

end.
