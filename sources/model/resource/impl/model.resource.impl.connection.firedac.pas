unit model.resource.impl.connection.firedac;

interface

uses
  routines,

  FireDAC.UI.Intf,

  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Stan.Param,

  FireDAC.Phys,
  FireDAC.Phys.Intf,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Phys.SQLiteWrapper,

  FireDAC.DatS,

  FireDAC.VCLUI.Wait,
  FireDAC.Comp.Client,
  FireDAC.Comp.UI,
  FireDAC.Comp.DataSet,
  FireDAC.DApt,
  FireDAC.DApt.Intf,

  Data.DB,
  model.resource.interfaces;

type
  TConnection = class(TInterfacedObject, IConnection)
    private
      FConfiguration: IConfiguration;
      FConn: TFDConnection;
      FDPhysSQLiteDriverLink : TFDPhysSQLiteDriverLink;
    public
      constructor Create(aConfiguration: IConfiguration);
      destructor Destroy; override;
      class function New(aConfiguration: IConfiguration): IConnection;

      function Connect: TCustomConnection;
  end;

implementation

uses
  SysUtils;

{ TConnection }

function TConnection.Connect: TCustomConnection;
begin
  Result := FConn;
  try
    FConn.Params.DriverID := FConfiguration.DriverID;
    FConn.Params.Database := FConfiguration.Database;
    FConn.Params.UserName := FConfiguration.Username;
    FConn.Params.Password := FConfiguration.Password;
    FConn.Params.Add('Port=' + FConfiguration.Port);
    FConn.Params.Add('Server=' + FConfiguration.Server);

    if not FConfiguration.Schema.IsEmpty then
    begin
      FConn.Params.Add('MetaCurSchema=' + FConfiguration.Schema);
      FConn.Params.Add('MetaDefSchema=' + FConfiguration.Schema);
    end;

    FConn.Connected := True;
  except
    On e: Exception do
      begin
        TRoutines.GenerateLogs(tpError,
          'Falha ao conectar com banco de dados: '+e.Message);
      end;
  end;
end;

constructor TConnection.Create(aConfiguration: IConfiguration);
begin
  FConn := TFDConnection.Create(nil);
  FDPhysSQLiteDriverLink := TFDPhysSQLiteDriverLink.Create(nil);
  FDPhysSQLiteDriverLink.VendorLib := GetCurrentDir + '\sqlite3.dll';
  FConfiguration := aConfiguration;
end;

destructor TConnection.Destroy;
begin
  FreeAndNil(FDPhysSQLiteDriverLink);
  FreeAndNil(FConn);
  inherited;
end;

class function TConnection.New(aConfiguration: IConfiguration): IConnection;
begin
  Result := Self.Create(aConfiguration);
end;

end.
