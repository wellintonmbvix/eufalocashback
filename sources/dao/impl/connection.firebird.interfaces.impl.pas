unit connection.firebird.interfaces.impl;

interface

uses
  System.SysUtils,
  System.Classes,
  System.IniFiles,

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
begin
  FDConnection := TFDConnection.Create(nil);
  FDConnection.BeforeConnect := OnBeforeConnect;
  FDConnection.LoginPrompt := False;
  FDPhysFBDriverLink := TFDPhysFBDriverLink.Create(nil);
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
  arqCfg : TIniFile;
  banco  : String;
begin
  try
    arqCfg := TIniFile.Create('C:\CSSISTEMAS\config.ini');
    try
      banco := arqCfg.ReadString('Dados','SS6', '');
    except
      on e: Exception do
      begin
        TRoutines.GenerateLogs(tpError, e.Message);
      end;
    end;

    try
      with FDConnection.Params do
      begin
        Clear;

        Add('DriverID=FB');
        Add('Database=' + banco);
        Add('User_Name=sysdba');
        Add('Password=masterkey');
        Add('Server=');            //Add('Server=localhost');
        Add('Protocol=Embedded');  //Add('Protocol=TCPIP');
        Add('CharacterSet=UTF8');
                                   //Add('Port=3050');
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
