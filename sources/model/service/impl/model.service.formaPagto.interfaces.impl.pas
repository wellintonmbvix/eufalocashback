unit model.service.formaPagto.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.formaPagto.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TIFormaPagtoService = class(TInterfacedObject, IFormaPagtoService)
  private
    FDConn: IConnectionFirebird;

    function Insert(formas_pagto: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
  public
    class function New: IFormaPagtoService;
    function Save(formas_pagto: TJSONArray; out msgError: String)
      : IFormaPagtoService;
  end;

implementation

{ TIFormaPagtoService }

constructor TIFormaPagtoService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TIFormaPagtoService.Insert(formas_pagto: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;
  codigo: Integer;
  descricao: String;
  ativo: Integer;
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
      sqlBlock.AppendLine('DECLARE VARIABLE vDescricao VARCHAR(50);');
      sqlBlock.AppendLine('DECLARE VARIABLE vAtivo SMALLINT;');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to formas_pagto.Count - 1 do
      begin
        item := formas_pagto.Items[i] as TJSONObject;

        codigo := item.GetValue<Integer>('formaPagamentoCI');
        descricao := item.GetValue<string>('nomeFormaPagamento');
        ativo         := Ord(item.GetValue<Boolean>('ativo'));
        sincronizado := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

        sqlBlock.AppendLine('  vCodigo = ' + IntToStr(codigo) + ';');
        sqlBlock.AppendLine('  vDescricao = ' + QuotedStr(descricao) + ';');
        sqlBlock.AppendLine('  vAtivo = ' + IntToStr(ativo) + ';');
        sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

        sqlBlock.AppendLine('  UPDATE FORMA_PAGTO');
        sqlBlock.AppendLine('     SET DESCRICAO = :vDescricao,');
        sqlBlock.AppendLine('         ATIVO = :vAtivo,');
        sqlBlock.AppendLine('         SINCRONIZADO = :vSincronizado');
        sqlBlock.AppendLine('   WHERE CODIGO = :vCodigo;');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO FORMA_PAGTO (CODIGO, DESCRICAO, ATIVO, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (:vCodigo, :vDescricao, :vAtivo, :vSincronizado);');
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

class function TIFormaPagtoService.New: IFormaPagtoService;
begin
  Result := Self.Create;
end;

function TIFormaPagtoService.Save(formas_pagto: TJSONArray;
  out msgError: String): IFormaPagtoService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(formas_pagto, msg) then
    msgError := msg;
end;

end.
