unit uOxymed;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IdHTTP, IdSSL, IdSSLOpenSSL,
  Vcl.StdCtrls,
  IdGlobal,
  System.JSON;

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

function TBradesco.Extrato(Inicio, Fim: TDateTime): String;
var
  HttpClient: TIdHTTP;
  Response: string;
  SSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
  Retorno : TStringList;
begin

  Retorno := TStringList.Create;
  HttpClient := TIdHTTP.Create(nil);
  SSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

  // Atribuir o manipulador SSL
    HttpClient.IOHandler := SSLIOHandler;
    SSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1_2];
  try
    // Configurar para lidar com SSL (caso seja necessário para APIs HTTPS)
    HttpClient.IOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(HttpClient);

    try
      // Realizar a requisição GET
      //Response := HttpClient.Get('http://localhost:3000/api/grafico001');
      Response := HttpClient.Get('https://dicas-on-line.vercel.app/api/dicas');
      Retorno.Text := Response;
    except
      on E: Exception do
      begin
        Retorno.Text := E.Message;
        ShowMessage('Erro: ' + E.Message);
      end;
    end;
    result := Retorno.Text;
  finally
    Retorno.Free;
    HttpClient.Free;
  end;
end;

end.
