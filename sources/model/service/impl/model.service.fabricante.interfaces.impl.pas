unit model.service.fabricante.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.fabricante.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TIFabricanteService = class(TInterfacedObject, IFabricanteService)
  private
    FDConn: IConnectionFirebird;

    function Insert(fabricantes: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
  public
    class function New: IFabricanteService;
    function Save(fabricantes: TJSONArray; out msgError: String)
      : IFabricanteService;
  end;

implementation

{ TIFabricanteService }

constructor TIFabricanteService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TIFabricanteService.Insert(fabricantes: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;
  codigo: Integer;
  nomeFabricante: String;
  sincronizado: String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  Try
    Try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vCodigo INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vNomeFabricante VARCHAR(60);');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to fabricantes.Count - 1 do
      begin
        item := fabricantes.Items[i] as TJSONObject;

        codigo := item.GetValue<Integer>('fabricanteId');
        nomeFabricante := item.GetValue<string>('nomeFabricante');
        sincronizado := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

        sqlBlock.AppendLine('  vCodigo = ' + IntToStr(codigo) + ';');
        sqlBlock.AppendLine('  vNomeFabricante = ' + QuotedStr(nomeFabricante) + ';');
        sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

        sqlBlock.AppendLine('  UPDATE FABRICANTES');
        sqlBlock.AppendLine('     SET NOME_FABRICANTE = :vNomeFabricante,');
        sqlBlock.AppendLine('         SINCRONIZADO = :vSincronizado');
        sqlBlock.AppendLine('   WHERE CODIGO = :vCodigo;');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO FABRICANTES (CODIGO, NOME_FABRICANTE, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (:vCodigo, :vNomeFabricante, :vSincronizado);');
        sqlBlock.AppendLine('');
      end;

      sqlBlock.AppendLine('END;');

      lQry.Close;
      lQry.SQL.Text := sqlBlock.ToString;
      lQry.ExecSQL;

      FDConn.Commit;
      Result := True;
    Except
      on E: Exception do
      begin
        FDConn.Rollback;
        msgError := E.Message;
      end;
    End;
  Finally
    FreeAndNil(sqlBlock);
    FreeAndNil(lQry);
  End;
end;

class function TIFabricanteService.New: IFabricanteService;
begin
  Result := Self.Create;
end;

function TIFabricanteService.Save(fabricantes: TJSONArray;
  out msgError: String): IFabricanteService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(fabricantes, msg) then
    msgError := msg;
end;

end.
