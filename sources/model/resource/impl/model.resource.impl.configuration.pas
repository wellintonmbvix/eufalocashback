unit model.resource.impl.configuration;

interface

uses
  System.IniFiles,
  System.SysUtils,
  System.StrUtils,
  routines,
  model.resource.interfaces;

  type
  TConfiguration = class(TInterfacedObject, IConfiguration)
    private
    FServidor: String;
    FPorta: Integer;
    FUserName: String;
    FPassword: String;
    FDataBase: String;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IConfiguration;

      function DriverID(aValue: String): IConfiguration; overload;
      function DriverID: String; overload;

      function Database(aValue: String): IConfiguration; overload;
      function Database: String; overload;

      function Username(aValue: String): IConfiguration; overload;
      function Username: String; overload;

      function Password(aValue: String): IConfiguration; overload;
      function Password: String; overload;

      function Port(aValue: String): IConfiguration; overload;
      function Port: String; overload;

      function Server(aValue: String): IConfiguration; overload;
      function Server: String; overload;

      function Schema(aValue: String): IConfiguration; overload;
      function Schema: String; overload;
  end;


implementation

{ TConfiguration }

constructor TConfiguration.Create;
var
  arqCfg  : TIniFile;
  banco,
  textdecript: String;
  i,
  codigo     : Integer;
  caracter   : Char;
begin
  Try
    arqCfg := TIniFile.Create('C:\CSSISTEMAS\config.ini');
    Try
      banco    := arqCfg.ReadString('Dados','SS6', banco);

      FDataBase := banco;
    Except
      on e: Exception do
        begin
          TRoutines.GenerateLogs(tpError, e.Message);
        end;
    End;
  Finally
    FreeAndNil(arqCfg);
  End;
end;

function TConfiguration.Database(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

function TConfiguration.Database: String;
begin
  Result := FDataBase; //Puxar do INI
end;

destructor TConfiguration.Destroy;
begin

  inherited;
end;

function TConfiguration.DriverID: String;
begin
  Result := 'SQLite'; //Puxar do INI
end;

function TConfiguration.DriverID(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

class function TConfiguration.New: IConfiguration;
begin
  Result := Self.Create;
end;

function TConfiguration.Password(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

function TConfiguration.Password: String;
begin
  Result := FPassword; //Puxar do INI
end;

function TConfiguration.Port(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

function TConfiguration.Port: String;
begin
  Result := '1433'; //Puxar do INI
end;

function TConfiguration.Schema: String;
begin
  Result := ''; //Puxar do INI
end;

function TConfiguration.Schema(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

function TConfiguration.Server(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

function TConfiguration.Server: String;
begin
  Result := FServidor; //Puxar do INI
end;

function TConfiguration.Username: String;
begin
  Result := FUserName; //Puxar do INI
end;

function TConfiguration.Username(aValue: String): IConfiguration;
begin
  Result := Self;
  //Gravar no INI
end;

end.
