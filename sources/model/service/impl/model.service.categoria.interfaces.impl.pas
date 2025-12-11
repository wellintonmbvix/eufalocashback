unit model.service.categoria.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.categoria.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TICategoriaService = class(TInterfacedObject, ICategoriaService)
  private
    FDConn: IConnectionFirebird;

    function Insert(categorias: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
  public
    class function New: ICategoriaService;
    function Save(categorias: TJSONArray; out msgError: String)
      : ICategoriaService;
  end;

implementation

{ TICategoriaService }

constructor TICategoriaService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TICategoriaService.Insert(categorias: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;
  codigo, categoriaPai: Integer;
  nomeCategoria: String;
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
      sqlBlock.AppendLine('DECLARE VARIABLE vCategoriaPai INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vNomeCategoria VARCHAR(200);');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to categorias.Count - 1 do
      begin
        item := categorias.Items[i] as TJSONObject;

        codigo := item.GetValue<Integer>('produtoCategoriaCI');
        categoriaPai := item.GetValue<Integer>('produtoCategoriaPaiCI');
        nomeCategoria := item.GetValue<string>('nomeProdutoCategoria');
        sincronizado := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

        sqlBlock.AppendLine('  vCodigo = ' + IntToStr(codigo) + ';');
        sqlBlock.AppendLine('  vCategoriaPai = ' + IntToStr(categoriaPai) + ';');
        sqlBlock.AppendLine('  vNomeCategoria = ' + QuotedStr(nomeCategoria) + ';');
        sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

        sqlBlock.AppendLine('  UPDATE CATEGORIA');
        sqlBlock.AppendLine('     SET NOME_CATEGORIA = :vNomeCategoria,');
        sqlBlock.AppendLine('         SINCRONIZADO = :vSincronizado');
        sqlBlock.AppendLine('   WHERE CODIGO = :vCodigo');
        sqlBlock.AppendLine('     AND CATEGORIA_PAI = :vCategoriaPai;');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO CATEGORIA (CODIGO, CATEGORIA_PAI, NOME_CATEGORIA, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (:vCodigo, :vCategoriaPai, :vNomeCategoria, :vSincronizado);');
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

class function TICategoriaService.New: ICategoriaService;
begin
  Result := Self.Create;
end;

function TICategoriaService.Save(categorias: TJSONArray; out msgError: String)
  : ICategoriaService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(categorias, msg) then
    msgError := msg;
end;

end.
