unit connection.sqlite.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,

  DATA.DB,

  connection.sqlite.interfaces,

  FireDAC.Phys.SQLiteWrapper.Stat,
  FireDAC.Phys.sqlite,
  FireDAC.Comp.Script,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI;

type
  TIConnectionSQLite = class(TInterfacedObject, IConnectionSQLite)
  private
    FDConnection: TFDConnection;
    FDPhysSQLiteDriverLink: TFDPhysSQLiteDriverLink;
    FDGUIxWaitCursor: TFDGUIxWaitCursor;

    procedure OnBeforeConnect(Sender: TObject);
    constructor Create;
  public
    destructor Destroy; override;
    class function New: IConnectionSQLite;

    function Connected(value: Boolean): IConnectionSQLite; overload;
    function Connected: Boolean; overload;
    function InTransaction: Boolean;
    function StartTransaction: IConnectionSQLite;
    function Commit: IConnectionSQLite;
    function Rollback: IConnectionSQLite;

    function GetQuery: TComponent;
    function GetConnection: TComponent;
    function CheckDB: String;
  end;

implementation

uses
  routines;

{ TIConnectionSQLite }

function TIConnectionSQLite.CheckDB: String;
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

function TIConnectionSQLite.Commit: IConnectionSQLite;
begin
  Result := Self;

  if FDConnection.InTransaction then
    FDConnection.Commit;
end;

function TIConnectionSQLite.Connected(value: Boolean): IConnectionSQLite;
begin
  Result := Self;
  FDConnection.Connected := Value;
end;

function TIConnectionSQLite.Connected: Boolean;
begin
  Result := FDConnection.Connected;
end;

constructor TIConnectionSQLite.Create;
var
  arqCfg : TIniFile;
  banco  : String;
begin
  FDConnection := TFDConnection.Create(nil);
  FDConnection.BeforeConnect := OnBeforeConnect;
  FDConnection.LoginPrompt := False;
  FDPhysSQLiteDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  FDGUIxWaitCursor := TFDGUIxWaitCursor.Create(nil);
end;

destructor TIConnectionSQLite.Destroy;
begin
  FDConnection.Connected := False;
  FreeAndNil(FDConnection);
  FreeAndNil(FDPhysSQLiteDriverLink);
  FreeAndNil(FDGUIxWaitCursor);
  inherited;
end;

function TIConnectionSQLite.GetConnection: TComponent;
begin
  Result := FDConnection;
end;

function TIConnectionSQLite.GetQuery: TComponent;
begin
  Result := TFDQuery.Create(nil);
  TFDQuery(Result).Connection := FDConnection;
end;

function TIConnectionSQLite.InTransaction: Boolean;
begin
  Result := FDConnection.InTransaction;
end;

class function TIConnectionSQLite.New: IConnectionSQLite;
begin
  Result := Self.Create;
end;

procedure TIConnectionSQLite.OnBeforeConnect(Sender: TObject);
var
  arqCfg : TIniFile;
  banco  : String;
begin
  try
    arqCfg := TIniFile.Create('C:\CSSISTEMAS\config.ini');
    try
      banco := arqCfg.ReadString('Dados','SS6', banco);
    Except
      on e: Exception do
        begin
          TRoutines.GenerateLogs(tpError, e.Message);
        end;
    End;

    try
      with FDConnection.Params do
        begin
          Clear;
          Add('DriverID=SQLite');
          Add('Database=' + banco);
          Add('OpenMode=CreateUTF8');
          Add('LockingMode=Normal');
          Add('JournalMode=WAL');
          Add('Synchronous=Normal');
          Add('BusyTimeout=30000');
        end;
    except
      on E: Exception do
        begin
          TRoutines.GenerateLogs(tpError, E.Message);
          raise Exception.Create(E.Message);
        end;
    end;
  finally
    FreeAndNil(arqCfg);
  end;
end;

function TIConnectionSQLite.Rollback: IConnectionSQLite;
begin
  Result := Self;

  if FDConnection.InTransaction then
    FDConnection.Rollback;
end;

function TIConnectionSQLite.StartTransaction: IConnectionSQLite;
begin
  Result := Self;

  FDConnection.Connected := False;
  FDConnection.Connected := True;

  FDConnection.StartTransaction;
end;

end.
