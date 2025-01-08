{
As credenciais do ambiente de homologa��o j� foram criadas, segue abaixo:
Client Key: 9693f06b-b929-4a9c-8182-e25270c4029d
Client Secret: 7cb3d3eb-a2c9-4084-8e03-72230000b4dd

https://slproweb.com/products/Win32OpenSSL.html
}

unit uOxymed;

interface

uses

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls,
  IdGlobal,
  System.JSON,

   System.Net.HttpClient, System.Net.URLClient;

type
  TBradesco = class
  private
    FRazaoSocial: string;
    FClienteID: Integer;
    FCNPJ: string;
    FCertificadoDigital: string;
    FConta: String;
    FAgencia: String;
  public
    property RazaoSocial: string read FRazaoSocial write FRazaoSocial;
    property ClienteID: Integer read FClienteID write FClienteID;
    property CNPJ: string read FCNPJ write FCNPJ;
    property CertificadoDigital: string read FCertificadoDigital
      write FCertificadoDigital;
    property Conta: string read FConta write FConta;
    property Agencia: string read FAgencia write FAgencia;
    function Extrato(Inicio, Fim: TDateTime): String;
  end;

implementation

//function TBradesco.Extrato(Inicio, Fim: TDateTime): String;
//var
//  HttpClient: TIdHTTP;
//  Response: string;
//  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
//  Retorno : TStringList;
//begin
//
//  Retorno := TStringList.Create;
//  HttpClient := TIdHTTP.Create(nil);
//
//  //HttpClient.IOHandler := SSLIOHandler;
//  //SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
//
//
//  // Atribuir o manipulador SSL
//  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);
//  HttpClient.IOHandler := SSLIOHandler;
//  SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
//
//  try
//    // Configurar para lidar com SSL (caso seja necess�rio para APIs HTTPS)
//    //HttpClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);
//
//    try
//      // Realizar a requisi��o GET
//      //Response := HttpClient.Get('http://localhost:3000/api/grafico001');
//      Response := HttpClient.Get('https://dicas-on-line.vercel.app/api/dicas');
//      Retorno.Text := Response;
//    except
//      on E: Exception do
//      begin
//        Retorno.Text := E.Message;
//        ShowMessage('Erro: ' + E.Message);
//      end;
//    end;
//    result := Retorno.Text;
//  finally
//    Retorno.Free;
//    HttpClient.Free;
//  end;
//end;

function TBradesco.Extrato(Inicio, Fim: TDateTime): String;
var
  HttpClient: THTTPClient;
  Response: IHTTPResponse;
begin
  HttpClient := THTTPClient.Create;
  try
    // Configura��o do TLS 1.2 (se necess�rio)
    HttpClient.AcceptEncoding := 'gzip, deflate';
    HttpClient.UserAgent := 'Delphi HTTP Client';

    try
      // Realizando a requisi��o GET
      Response := HttpClient.Get('https://dicas-on-line.vercel.app/api/dicas');

      // A resposta ser� recebida diretamente
      Result := Response.ContentAsString;
    except
      on E: Exception do
      begin
        Result := 'Erro: ' + E.Message;
      end;
    end;
  finally
    HttpClient.Free;
  end;
end;
end.
