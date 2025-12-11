unit model.service.vendedor.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.vendedor.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TIVendedorService = class(TInterfacedObject, IVendedorService)
  private
    FDConn: IConnectionFirebird;

    function Insert(vendedores: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
  public
    class function New: IVendedorService;
    function Save(vendedores: TJSONArray; out msgError: String)
      : IVendedorService;
  end;

implementation

{ TIVendedorService }

constructor TIVendedorService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TIVendedorService.Insert(vendedores: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;
  codigo: Integer;
  nome: String;
  ativo: Integer;
  sincronizado: String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  try
    try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vCodigo INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vNome VARCHAR(50);');
      sqlBlock.AppendLine('DECLARE VARIABLE vAtivo SMALLINT;');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to vendedores.Count - 1 do
      begin
        item := vendedores.Items[i] as TJSONObject;

        codigo := item.GetValue<Integer>('vendedorCI');
        nome := item.GetValue<string>('nomeVendedor');
        ativo := item.GetValue<Integer>('ativo');
        sincronizado := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

        sqlBlock.AppendLine('  vCodigo = ' + IntToStr(codigo) + ';');
        sqlBlock.AppendLine('  vNome = ' + QuotedStr(nome) + ';');
        sqlBlock.AppendLine('  vAtivo = ' + IntToStr(ativo) + ';');
        sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

        sqlBlock.AppendLine('  UPDATE VENDEDORES');
        sqlBlock.AppendLine('     SET NOME = :vNome,');
        sqlBlock.AppendLine('         ATIVO = :vAtivo,');
        sqlBlock.AppendLine('         SINCRONIZADO = :vSincronizado');
        sqlBlock.AppendLine('   WHERE CODIGO = :vCodigo;');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO VENDEDORES (CODIGO, NOME, ATIVO, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (:vCodigo, :vNome, :vAtivo, :vSincronizado);');
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

class function TIVendedorService.New: IVendedorService;
begin
  Result := Self.Create;
end;

function TIVendedorService.Save(vendedores: TJSONArray; out msgError: String)
  : IVendedorService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(vendedores, msg) then
    msgError := msg;
end;

end.
