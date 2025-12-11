unit model.service.vendas.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.vendas.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TIVendaService = class(TInterfacedObject, IVendaService)
  private
    FDConn: IConnectionFirebird;

    function Insert(vendas: TJSONArray; out msgError: String)
      : Boolean; overload;
    function Del(vendas: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
  public
    class function New: IVendaService;
    function Save(vendas: TJSONArray; out msgError: String)
      : IVendaService;
    function Delete(vendas: TJSONArray; out msgError: String)
      : IVendaService;
  end;

implementation

{ TIVendaService }

constructor TIVendaService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TIVendaService.Del(vendas: TJSONArray; out msgError: String): Boolean;
var
  lQry: TFDQuery;
  vendaContato: string;
  dataStr: string;
  cupomStr: string;
  dia, mes, ano: Word;
  datavenda: TDate;
  cupom: Integer;
  i: Integer;
begin
  Result := False;
  msgError := '';

  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);

  try
    try
      for i := 0 to vendas.Count - 1 do
      begin
        // Cada item do array é uma string
        vendaContato := TJSONString(vendas.Items[i]).Value;

        // Quebra vendaContatoCI
        dataStr  := Copy(vendaContato, 3, 8);      // DDMMYYYY
        cupomStr := Copy(vendaContato, 11, MaxInt);

        // Converte data
        dia := StrToInt(Copy(dataStr, 1, 2));
        mes := StrToInt(Copy(dataStr, 3, 2));
        ano := StrToInt(Copy(dataStr, 5, 4));
        datavenda := EncodeDate(ano, mes, dia);

        // Converte cupom
        cupom := StrToInt(cupomStr);

        // -----------------------------------------------------------
        // DELETE 1 — VENDAS_ITENS
        // -----------------------------------------------------------
        lQry.SQL.Text :=
          'DELETE FROM VENDAS_ITENS ' +
          ' WHERE DATAVENDA = :DATAVENDA AND CUPOM = :CUPOM';
        lQry.ParamByName('DATAVENDA').AsDate := datavenda;
        lQry.ParamByName('CUPOM').AsInteger := cupom;
        lQry.ExecSQL;

        // -----------------------------------------------------------
        // DELETE 2 — VENDAS_PAGTOS
        // -----------------------------------------------------------
        lQry.SQL.Text :=
          'DELETE FROM VENDAS_PAGTOS ' +
          ' WHERE DATAVENDA = :DATAVENDA AND CUPOM = :CUPOM';
        lQry.ParamByName('DATAVENDA').AsDate := datavenda;
        lQry.ParamByName('CUPOM').AsInteger := cupom;
        lQry.ExecSQL;

        // -----------------------------------------------------------
        // DELETE 3 — VENDAS
        // -----------------------------------------------------------
        lQry.SQL.Text :=
          'DELETE FROM VENDAS ' +
          ' WHERE DATAVENDA = :DATAVENDA AND CUPOM = :CUPOM';
        lQry.ParamByName('DATAVENDA').AsDate := datavenda;
        lQry.ParamByName('CUPOM').AsInteger := cupom;
        lQry.ExecSQL;
      end;

      FDConn.Commit;
      Result := True;

    except
      on E: Exception do
      begin
        FDConn.Rollback;
        msgError := E.Message;
      end;
    end;

  finally
    lQry.Free;
  end;
end;

function TIVendaService.Delete(vendas: TJSONArray;
  out msgError: String): IVendaService;
var
  msg: String;
begin
  Result := Self;
  if not Del(vendas, msg) then
    msgError := msg;
end;

function TIVendaService.Insert(vendas: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item, itemObj, formaObj: TJSONObject;
  itensArray, formasArray: TJSONArray;
  sqlBlock: TStringBuilder;
  cupom, cliente, loja, vendedor, itemProd: Integer;
  datavenda: String;
  cpf: String;
  valor: String;
  desconto: String;
  comissao: String;
  formapagto: String;
  frete: String;
  sincronizado: String;

  produto: String;
  qtde: String;
  valorLiquido: String;
  descontoUnit: String;
  comissaoUnit: String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  try
    try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to vendas.Count - 1 do
      begin

        item := vendas.Items[i] as TJSONObject;

        dataVenda     := item.GetValue<string>('dataVenda').Replace('T',' ');
        cupom         := item.GetValue<Integer>('numero');
        cliente       := item.GetValue<Integer>('contatoCI');
        cpf           := item.GetValue<string>('contatoCPF');
        valor         := item.GetValue<string>('valor');
        desconto      := item.GetValue<string>('desconto');
        comissao      := item.GetValue<string>('comissao');
        formaPagto    := item.GetValue<string>('formaPagamentoCI');
        loja          := item.GetValue<Integer>('filialCI');
        frete         := item.GetValue<string>('valorFrete');
        vendedor      := item.GetValue<Integer>('vendedorCI');
        sincronizado  := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now);

        itensArray := item.GetValue<TJSONArray>('item');
        formasArray := item.GetValue<TJSONArray>('formasPagamento');

        sqlBlock.AppendLine('  UPDATE VENDAS SET');
        sqlBlock.AppendLine('     VALOR = ' + StringReplace(valor,
             ',', '.', [rfReplaceAll]) + ',');
        sqlBlock.AppendLine('     DESCONTO = ' + StringReplace(desconto,
             ',', '.', [rfReplaceAll]) + ',');
        sqlBlock.AppendLine('     COMISSAO = ' + StringReplace(comissao,
             ',', '.', [rfReplaceAll]) + ',');
        sqlBlock.AppendLine('     FORMAPAGTO = ' + QuotedSTr(formaPagto) + ',');
        sqlBlock.AppendLine('     LOJA = ' + IntToStr(loja) + ',');
        sqlBlock.AppendLine('     FRETE = ' + StringReplace(frete,
             ',', '.', [rfReplaceAll]) + ',');
        sqlBlock.AppendLine('     VENDEDOR = ' + IntToStr(vendedor) + ',');
        sqlBlock.AppendLine('     SINCRONIZADO = ' + QuotedStr(sincronizado));
        sqlBlock.AppendLine('  WHERE DATAVENDA = ' + QuotedStr(dataVenda) +
                            ' AND CUPOM = ' + IntToStr(cupom) +
                            ' AND CLIENTE = ' + IntToStr(cliente) +
                            ' AND CPF = ' + QuotedStr(cpf) + ';');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO VENDAS (DATAVENDA, CUPOM,'+
        ' CLIENTE, CPF, VALOR, DESCONTO, COMISSAO, FORMAPAGTO, LOJA,'+
        ' FRETE, VENDEDOR, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (' +
          QuotedStr(dataVenda.Replace('T',' ')) + ',' +
          IntToStr(cupom) + ',' +
          IntToStr(cliente) + ',' +
          QuotedStr(cpf) + ',' +
          StringReplace(valor,
             ',', '.', [rfReplaceAll]) + ',' +
          StringReplace(desconto,
             ',', '.', [rfReplaceAll]) + ',' +
          StringReplace(comissao,
             ',', '.', [rfReplaceAll]) + ',' +
          QuotedStr(formaPagto) + ',' +
          IntToStr(loja) + ',' +
          StringReplace(frete,
             ',', '.', [rfReplaceAll]) + ',' +
          IntToStr(vendedor) + ',' +
          QuotedStr(sincronizado) + ');');

        sqlBlock.AppendLine('');

        for var j := 0 to itensArray.Count - 1 do
        begin
          itemObj := itensArray.Items[j] as TJSONObject;

          sqlBlock.AppendLine('  UPDATE VENDAS_ITENS SET');
          sqlBlock.AppendLine('      PRODUTO = ' + QuotedStr(itemObj.GetValue<string>('produtoCI')) + ',');
          sqlBlock.AppendLine('      QTDE = ' + itemObj.GetValue<string>('quantidade') + ',');
          sqlBlock.AppendLine('      VALORLIQUIDO = ' + StringReplace(itemObj.GetValue<string>('valor'),
             ',', '.', [rfReplaceAll]) + ',');
          sqlBlock.AppendLine('      DESCONTO = ' + StringReplace(itemObj.GetValue<string>('desconto'),
             ',', '.', [rfReplaceAll]) + ',');
          sqlBlock.AppendLine('      COMISSAO = ' + StringReplace(itemObj.GetValue<string>('comissao'),
             ',', '.', [rfReplaceAll]));
          sqlBlock.AppendLine('  WHERE DATAVENDA = ' + QuotedStr(dataVenda) +
                              ' AND CUPOM = ' + IntToStr(cupom) +
                              ' AND CLIENTE = ' + IntToStr(cliente) +
                              ' AND CPF = ' + QuotedStr(cpf) +
                              ' AND ITEM = ' + itemObj.GetValue<string>('vendaContatoItemCI') + ';');

          sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
          sqlBlock.AppendLine('    INSERT INTO VENDAS_ITENS (DATAVENDA, CUPOM, CLIENTE, CPF, ITEM, PRODUTO, QTDE, VALORLIQUIDO, DESCONTO, COMISSAO)');
          sqlBlock.AppendLine('    VALUES (' +
            QuotedStr(dataVenda) + ',' +
            IntToStr(cupom) + ',' +
            IntToStr(cliente) + ',' +
            QuotedStr(cpf) + ',' +
            itemObj.GetValue<string>('vendaContatoItemCI') + ',' +
            QuotedStr(itemObj.GetValue<string>('produtoCI')) + ',' +
            itemObj.GetValue<string>('quantidade') + ',' +
            StringReplace(itemObj.GetValue<string>('valor'),
             ',', '.', [rfReplaceAll]) + ',' +
            StringReplace(itemObj.GetValue<string>('desconto'),
             ',', '.', [rfReplaceAll]) + ',' +
            StringReplace(itemObj.GetValue<string>('comissao'),
             ',', '.', [rfReplaceAll]) + ');');

          sqlBlock.AppendLine('');
        end;

        for var j := 0 to formasArray.Count - 1 do
        begin
          formaObj := formasArray.Items[j] as TJSONObject;

          sqlBlock.AppendLine('  UPDATE VENDAS_PAGTOS SET');
          sqlBlock.AppendLine('      VALOR = ' + StringReplace(formaObj.GetValue<string>('valor'),
             ',', '.', [rfReplaceAll]) + ',');
          sqlBlock.AppendLine('      FORMA_PAGTO = ' +
            QuotedStr(formaObj.GetValue<string>('nomeFormaPagamento')));
          sqlBlock.AppendLine('  WHERE DATAVENDA = ' + QuotedStr(dataVenda) +
                              '  AND CUPOM = ' + IntToStr(cupom) + ';');
          sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
          sqlBlock.AppendLine('    INSERT INTO VENDAS_PAGTOS (DATAVENDA, CUPOM, CLIENTE, CPF, FORMA_PAGTO, VALOR)');
          sqlBlock.AppendLine('    VALUES (' +
            QuotedStr(dataVenda) + ',' +
            IntToStr(cupom) + ',' +
            IntToStr(cliente) + ',' +
            QuotedStr(cpf) + ',' +
            QuotedStr(formaObj.GetValue<string>('nomeFormaPagamento')) + ',' +
            StringReplace(formaObj.GetValue<string>('valor'),
             ',', '.', [rfReplaceAll]) + ');');

          sqlBlock.AppendLine('');
        end;

      end;


      sqlBlock.AppendLine('END;');

      var textSQL := sqlBlock.ToString;

      lQry.SQL.Text := sqlBlock.ToString;
      lQry.ExecSQL;

      FDConn.Commit;
      Result := True;

    except
      on E: Exception do
      begin
        FDConn.Rollback;
        msgError := E.Message;
      end;
    end;
  finally
    FreeAndNil(sqlBlock);
    FreeAndNil(lQry);
  end;
end;

class function TIVendaService.New: IVendaService;
begin
  Result := Self.Create;
end;

function TIVendaService.Save(vendas: TJSONArray;
  out msgError: String): IVendaService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(vendas, msg) then
    msgError := msg;
end;

end.
