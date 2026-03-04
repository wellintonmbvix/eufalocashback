unit connection.firebird.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,
  IdTCPClient,
  IdGlobal,

  DATA.DB,

  connection.firebird.interfaces,

  FireDAC.Phys.FB,
  FireDAC.Phys.FBDef,

  FireDAC.Comp.Script,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI;

type
  TIConnectionFirebird = class(TInterfacedObject, IConnectionFirebird)
  private
    FDConnection: TFDConnection;
    FDPhysFBDriverLink:TFDPhysFBDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;

    procedure OnBeforeConnect(Sender: TObject);
    constructor Create;
  public
    destructor Destroy; override;
    class function New: IConnectionFirebird;

    function Connected(value: Boolean): IConnectionFirebird; overload;
    function Connected: Boolean; overload;
    function InTransaction: Boolean;
    function StartTransaction: IConnectionFirebird;
    function Commit: IConnectionFirebird;
    function Rollback: IConnectionFirebird;

    function GetQuery: TComponent;
    function GetConnection: TComponent;
    function CheckDB: String;
  end;

implementation

uses
  routines;

{ TIConnectionFirebird }

function TIConnectionFirebird.CheckDB: String;
begin
  Try
    FDConnection.Connected := False;
    FDConnection.Connected := True;
    FDConnection.Connected := False;
  Except
    on E: exception do
      begin
        TRoutines.GenerateLogs(tpError, E.Message);
        raise Exception.Create(E.Message);
      end;
  End;
end;

function TIConnectionFirebird.Commit: IConnectionFirebird;
begin
  Result := Self;

  if FDConnection.InTransaction then
    FDConnection.Commit;
end;

function TIConnectionFirebird.Connected(value: Boolean): IConnectionFirebird;
begin
  Result := Self;
  FDConnection.Connected := Value;
end;

function TIConnectionFirebird.Connected: Boolean;
begin
  Result := FDConnection.Connected;
end;

constructor TIConnectionFirebird.Create;
var
  arqCfg : TIniFile;
  caminhoEXE: String;
begin
  caminhoExe := ExtractFilePath(ParamStr(0));
  FDPhysFBDriverLink := TFDPhysFBDriverLink.Create(nil);
  FDPhysFBDriverLink.VendorLib := caminhoEXE + 'fbembed.dll';
  FDConnection := TFDConnection.Create(nil);
  FDConnection.BeforeConnect := OnBeforeConnect;
  FDConnection.LoginPrompt := False;
  FDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);
end;

destructor TIConnectionFirebird.Destroy;
begin
  FDConnection.Connected := False;
  FreeAndNil(FDConnection);
  FreeAndNil(FDPhysFBDriverLink);
  FreeAndNil(FDGUIxWaitCursor);
  inherited;
end;

function TIConnectionFirebird.GetConnection: TComponent;
begin
  Result := FDConnection;
end;

function TIConnectionFirebird.GetQuery: TComponent;
begin
  Result := TFDQuery.Create(nil);
  TFDQuery(Result).Connection := FDConnection;
end;

function TIConnectionFirebird.InTransaction: Boolean;
begin
  Result := FDConnection.InTransaction;
end;

class function TIConnectionFirebird.New: IConnectionFirebird;
begin
  Result := Self.Create;
end;

procedure TIConnectionFirebird.OnBeforeConnect(Sender: TObject);
var
  arqCfg   : TIniFile;
  banco    : string;
  servidor : string;
  tipoConexao : string;
  tcpTest     : TIdTCPClient;
  usarTCPIP   : Boolean;
begin
  arqCfg := nil;
  try
    arqCfg := TIniFile.Create('C:\CSSISTEMAS\config.ini');
    tcpTest := TIdTCPClient.Create(nil);

    // Lê o caminho do banco e o endereço do servidor
    banco    := arqCfg.ReadString('Dados','SS6','');
    servidor := arqCfg.ReadString('Dados','SS2','localhost'); // default localhost
    tipoConexao := arqCfg.ReadString('Dados','SS3','TCPIP'); // default TCPIP

    if banco = '' then
      raise Exception.Create('Caminho do banco não configurado no INI.');

    usarTCPIP := False;

    if servidor <> '' then
    begin
      try
        tcpTest.Host := servidor;
        tcpTest.Port := 3050; // porta default do Firebird
        tcpTest.ConnectTimeout := 2000; // 2 segundos
        tcpTest.Connect;
        usarTCPIP := tcpTest.Connected;
      except
        usarTCPIP := False;
      end;

      if tcpTest.Connected then
        tcpTest.Disconnect;
    end;

    if usarTCPIP then
      TRoutines.GenerateLogs(tpNormal, 'Conectado via TCPIP')
    else
      TRoutines.GenerateLogs(tpNormal, 'Conectado via Embedded');

    try
      with FDConnection.Params do
      begin
        Clear;
        Add('DriverID=FB');
        Add('Database=' + banco);
        Add('User_Name=sysdba');
        Add('Password=masterkey');
        Add('CharacterSet=UTF8');

        if usarTCPIP then
          begin
            Add('Protocol=TCPIP');
            Add('Server=' + servidor);
            Add('Port=3050');
          end
          else
          begin
            Add('Protocol=Embedded');
            // Não informar Server nem Port
          end;

      end;
    except
      on E: Exception do
      begin
        TRoutines.GenerateLogs(tpError, E.Message);
        raise; // Repassa o erro para a aplicação tratar
      end;
    end;

  finally
    tcpTest.Free;
    FreeAndNil(arqCfg);
  end;
end;

function TIConnectionFirebird.Rollback: IConnectionFirebird;
begin
  Result := Self;

  if FDConnection.InTransaction then
    FDConnection.Rollback;
end;

function TIConnectionFirebird.StartTransaction: IConnectionFirebird;
begin
  Result := Self;

  FDConnection.Connected := False;
  FDConnection.Connected := True;

  FDConnection.StartTransaction;
end;

end.
