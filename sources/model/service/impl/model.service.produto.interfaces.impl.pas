unit model.service.produto.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.produto.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TIProdutoService = class(TInterfacedObject, IProdutoService)
  private
    FDConn: IConnectionFirebird;

    function Insert(produtos: TJSONArray; out msgError: String)
      : Boolean;
    constructor Create;
  public
    class function New: IProdutoService;
    function Save(produtos: TJSONArray; out msgError: String)
      : IProdutoService;
  end;

implementation

{ TIProdutoService }

constructor TIProdutoService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TIProdutoService.Insert(produtos: TJSONArray;
  out msgError: String): Boolean;
//  function JSONToCurrency(const Value: string): Currency;
//  var
//    S: string;
//  begin
//    S := Trim(Value);
//
//    // troca vírgula por ponto caso venha de API nacional
//    S := StringReplace(S, ',', '.', [rfReplaceAll]);
//
//    // converte manualmente
//    Result := StrToCurrDef(S, 0);
//  end;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;

  produto: String;
  nomeProduto: String;
  ean: String;
  descricao: String;
  preco: String;
  precoPromocao: String;
  estoque: String;
  ativo: Integer;
  codFabricante: String;
  codCategoria: Integer;
  unidade: String;
  unidadeValor: Currency;
  sincronizado: String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  Try
    Try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vProduto VARCHAR(20);');
      sqlBlock.AppendLine('DECLARE VARIABLE vNomeProduto VARCHAR(200);');
      sqlBlock.AppendLine('DECLARE VARIABLE vEAN VARCHAR(50);');
      sqlBlock.AppendLine('DECLARE VARIABLE vDescricao VARCHAR(500);');
      sqlBlock.AppendLine('DECLARE VARIABLE vPreco NUMERIC(15,2);');
      sqlBlock.AppendLine('DECLARE VARIABLE vPrecoPromocao NUMERIC(15,2);');
      sqlBlock.AppendLine('DECLARE VARIABLE vEstoque NUMERIC(15,2);');
      sqlBlock.AppendLine('DECLARE VARIABLE vAtivo SMALLINT;');
      sqlBlock.AppendLine('DECLARE VARIABLE vCodFabricante VARCHAR(50);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCodCategoria INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vUnidade VARCHAR(20);');
      sqlBlock.AppendLine('DECLARE VARIABLE vUnidadeValor NUMERIC(15,2);');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to produtos.Count - 1 do
        begin
          item := produtos.Items[i] as TJSONObject;

          produto       := item.GetValue<String>('produtoCI');
          nomeProduto   := item.GetValue<String>('nomeProduto');
          ean           := item.GetValue<String>('ean');
          descricao     := item.GetValue<String>('descricao');
          preco         := item.GetValue<String>('preco');
          precoPromocao := item.GetValue<String>('precoPromocional');
          estoque       := item.GetValue<String>('estoque');
          ativo         := Ord(item.GetValue<Boolean>('ativo'));
          codFabricante := item.GetValue<String>('fabricanteCI');
          codCategoria  := item.GetValue<Integer>('categoriaProdutoCI');
          unidade       := item.GetValue<String>('produtoUnidadeMedida');
          unidadeValor  := item.GetValue<Currency>('unidadeMedida');
          sincronizado  := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

          sqlBlock.AppendLine('  vProduto = ' + QuotedStr(produto) + ';');
          sqlBlock.AppendLine('  vNomeProduto = ' + QuotedStr(nomeProduto) + ';');
          sqlBlock.AppendLine('  vEAN = ' + QuotedStr(ean) + ';');
          sqlBlock.AppendLine('  vDescricao = ' + QuotedStr(descricao) + ';');
          sqlBlock.AppendLine('  vPreco = ' + StringReplace(preco,
             ',', '.', [rfReplaceAll]) + ';');
          sqlBlock.AppendLine('  vPrecoPromocao = ' +
            StringReplace(precoPromocao, ',',
              '.', [rfReplaceAll]) + ';');
          sqlBlock.AppendLine('  vEstoque = ' +
            StringReplace(estoque, ',', '.',
               [rfReplaceAll]) + ';');
          sqlBlock.AppendLine('  vAtivo = ' + IntToStr(ativo) + ';');
          sqlBlock.AppendLine('  vCodFabricante = ' +
            QuotedStr(codFabricante) + ';');
          sqlBlock.AppendLine('  vCodCategoria = ' +
            IntToStr(codCategoria) + ';');
          sqlBlock.AppendLine('  vUnidade = ' + QuotedStr(unidade) + ';');
          sqlBlock.AppendLine('  vUnidadeValor = ' +
            StringReplace(FloatToStr(unidadeValor), ',', '.',
              [rfReplaceAll]) + ';');
          sqlBlock.AppendLine('  vSincronizado = ' +
            QuotedStr(sincronizado) + ';');

          // UPSERT (método mais rápido possível no Firebird 2.5)

          sqlBlock.AppendLine('  UPDATE PRODUTOS SET');
          sqlBlock.AppendLine('      NOMEPRODUTO = :vNomeProduto,');
          sqlBlock.AppendLine('      EAN = :vEAN,');
          sqlBlock.AppendLine('      DESCRICAO = :vDescricao,');
          sqlBlock.AppendLine('      PRECO = :vPreco,');
          sqlBlock.AppendLine('      PRECO_PROMOCAO = :vPrecoPromocao,');
          sqlBlock.AppendLine('      ESTOQUE = :vEstoque,');
          sqlBlock.AppendLine('      ATIVO = :vAtivo,');
          sqlBlock.AppendLine('      CODFABRICANTE = :vCodFabricante,');
          sqlBlock.AppendLine('      CODCATEGORIA = :vCodCategoria,');
          sqlBlock.AppendLine('      UNIDADE = :vUnidade,');
          sqlBlock.AppendLine('      UNIDADEVALOR = :vUnidadeValor,');
          sqlBlock.AppendLine('      SINCRONIZADO = :vSincronizado');
          sqlBlock.AppendLine('  WHERE PRODUTO = :vProduto;');

          sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
          sqlBlock.AppendLine('    INSERT INTO PRODUTOS (');
          sqlBlock.AppendLine('        PRODUTO, NOMEPRODUTO, EAN, DESCRICAO, PRECO, PRECO_PROMOCAO,');
          sqlBlock.AppendLine('        ESTOQUE, ATIVO, CODFABRICANTE, CODCATEGORIA, UNIDADE, UNIDADEVALOR, SINCRONIZADO');
          sqlBlock.AppendLine('    ) VALUES (');
          sqlBlock.AppendLine('        :vProduto, :vNomeProduto, :vEAN, :vDescricao, :vPreco, :vPrecoPromocao,');
          sqlBlock.AppendLine('        :vEstoque, :vAtivo, :vCodFabricante, :vCodCategoria, :vUnidade, :vUnidadeValor, :vSincronizado');
          sqlBlock.AppendLine('    );');
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

class function TIProdutoService.New: IProdutoService;
begin
  Result := Self.Create;
end;

function TIProdutoService.Save(produtos: TJSONArray;
  out msgError: String): IProdutoService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(produtos, msg) then
    msgError := msg;
end;

end.
