unit model.service.cashback.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.cashback.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TICashBackService = class(TInterfacedObject, ICashBackService)
    private
    FDConn: IConnectionFirebird;

    function Insert(cashbacks: TJSONArray; out msgError: String)
      : Boolean;
    function UpdateSynchronize(cashbacks: TJSONArray; out msgError: String)
      : Boolean;
    function UseCashback(cashbacks: TJSONArray; out msgError: String): Boolean;
    constructor Create;
    public
    class function New: ICashBackService;
    function Save(cashbacks: TJSONArray; out msgError: String)
      : ICashBackService;
    function Synchronize(cashbacks: TJSONArray; out msgError: String)
      : ICashBackService;
    function GetNotSynced: TJSONArray;
    function ReturnUsed(dataVenda: TDateTime; cupom, loja: Integer): TJSONArray;
    function Use(cashbacks: TJSONArray; out msgError: String): ICashBackService;
  end;

implementation

{ TICashBackService }

constructor TICashBackService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TICashBackService.GetNotSynced: TJSONArray;
var
  oJson: TJSONObject;
  lQry: TFDQuery;
begin
  Result := TJSONArray.Create;
  lQry := TFDQuery(FDConn.GetQuery);
  try
    With lQry Do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT CPF,NUMEROVOUCHER,CHAVE,CLIENTE FROM CASHBACKS');
        SQL.Add('WHERE SINCRONIZADO IS NULL');
        Open;

        while not Eof do
          begin oJson := TJSONObject.Create;
            try
              oJson.AddPair('chave', FieldByName('chave').AsString);
              oJson.AddPair('contatoMovimentoCI',
                FieldByName('CLIENTE').AsString);

              Result.AddElement(oJson);

              oJson := nil;
            except
              oJson.Free;
              raise;
            end;

            Next;
          end;
      end;
  finally
    lQry.Close;
    FreeAndNil(lQry);
  end;
end;

function TICashBackService.ReturnUsed(dataVenda: TDateTime; cupom, loja: Integer): TJSONArray;
var
  oJson: TJSONObject;
  lQry: TFDQuery;
  dataInicio, dataFim: TDateTime;
begin
  lQry := TFDQuery(FDConn.GetQuery);
  Result := TJSONArray.Create;
  try
    with lQry Do
      begin
        dataInicio := Trunc(dataVenda);
        dataFim    := dataInicio + 1;

        Close;
        SQL.Clear;
        SQL.Add('SELECT NUMEROVOUCHER');
        SQL.Add('FROM CASHBACKS');
        SQL.Add('WHERE DATAVENDA >= :DataInicio');
        SQL.Add('  AND DATAVENDA <  :DataFim');
        SQL.Add('  AND CUPOM = :Cupom');
        SQL.Add('  AND LOJA = :Loja');
        ParamByName('DataInicio').AsDateTime := dataInicio;
        ParamByName('DataFim').AsDateTime := dataFim;
        ParamByName('Cupom').AsInteger := cupom;
        ParamByName('Loja').AsInteger := loja;
        Open;

        while not Eof do
        begin
          oJson := TJSONObject.Create;
          oJson.AddPair('numeroVoucher', FieldByName('NUMEROVOUCHER').AsString);
          Result.AddElement(oJson);

          Next;
        end;
      end;
  finally
    lQry.Close;
    FreeAndNil(lQry);
  end;
end;

function TICashBackService.Insert(cashbacks: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;
  jsonValue: TJSONValue;

  cliente: Integer;
  cpf: String;
  chave: String;
  numeroVoucher: String;
  data: String;
  prazoEntrega: Integer;
  premio: String;
  valor: String;
  sincronizado: String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  try
    try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vCliente INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vCpf VARCHAR(14);');
      sqlBlock.AppendLine('DECLARE VARIABLE vChave VARCHAR(36);');
      sqlBlock.AppendLine('DECLARE VARIABLE vNumeroVoucher VARCHAR(54);');
      sqlBlock.AppendLine('DECLARE VARIABLE vData TIMESTAMP;');
      sqlBlock.AppendLine('DECLARE VARIABLE vPrazoEntrega INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vPremio VARCHAR(100);');
      sqlBlock.AppendLine('DECLARE VARIABLE vValor NUMERIC(15,2);');
//      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to cashbacks.Count - 1 do
        begin
          item := cashbacks.Items[i] as TJSONObject;
          cliente := 0;

          if item.TryGetValue('contatoCI', jsonValue) then
            begin
              if not (jsonValue is TJSONNull) then
                cliente := jsonValue.AsType<Integer>;
            end;

          cpf           := item.GetValue<String>('cpf');
          chave         := item.GetValue<String>('chave');
          numeroVoucher := item.GetValue<String>('numeroVoucher');
          data          := item.GetValue<string>('data').Replace('T',' ');
          prazoEntrega  := item.GetValue<Integer>('prazoEntrega');
          premio        := item.GetValue<String>('premio');
          valor         := item.GetValue<String>('valor');
//          sincronizado  := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

          sqlBlock.AppendLine('  vCliente = ' + cliente.ToString + ';');
          sqlBlock.AppendLine('  vCpf = ' + QuotedStr(cpf) + ';');
          sqlBlock.AppendLine('  vChave = ' + QuotedStr(chave) + ';');
          sqlBlock.AppendLine('  vNumeroVoucher = ' + QuotedStr(numeroVoucher) + ';');
          sqlBlock.AppendLine('  vData = ' + QuotedStr(data.Replace('t',' ')) + ';');
          sqlBlock.AppendLine('  vPrazoEntrega = ' + prazoEntrega.ToString + ';');
          sqlBlock.AppendLine('  vPremio = ' + QuotedStr(premio) + ';');
          sqlBlock.AppendLine('  vValor = ' + StringReplace(valor, ',', '.',
            [rfReplaceAll]) + ';');
//          sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

          sqlBlock.AppendLine('  UPDATE CASHBACKS SET');
          sqlBlock.AppendLine('      NUMEROVOUCHER = :vNumeroVoucher,');
          sqlBlock.AppendLine('      DATA = :vData,');
          sqlBlock.AppendLine('      PRAZOENTREGA = :vPrazoEntrega,');
          sqlBlock.AppendLine('      PREMIO = :vPremio,');
          sqlBlock.AppendLine('      VALOR = :vValor');
//          sqlBlock.AppendLine('      SINCRONIZADO = :vSincronizado');
          sqlBlock.AppendLine('  WHERE CLIENTE = :vCliente');
          sqlBlock.AppendLine('  AND CPF = :vCpf');
          sqlBlock.AppendLine('  AND NUMEROVOUCHER = :vNumeroVoucher;');

          sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
          sqlBlock.AppendLine('    INSERT INTO CASHBACKS (');
          sqlBlock.AppendLine('        CLIENTE, CPF, CHAVE, NUMEROVOUCHER,');
          sqlBlock.AppendLine('        DATA, PRAZOENTREGA, PREMIO, VALOR');
          sqlBlock.AppendLine('    ) VALUES (');
          sqlBlock.AppendLine('        :vCliente, :vCpf, :vChave, :vNumeroVoucher,');
          sqlBlock.AppendLine('        :vData, :vPrazoEntrega, :vPremio, :vValor');
          sqlBlock.AppendLine('    );');
          sqlBlock.AppendLine('');
        end;

      sqlBlock.AppendLine('END;');

      lQry.Close;
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
    lQry.Close;
    FreeAndNil(sqlBlock);
    FreeAndNil(lQry);
  end;
end;

class function TICashBackService.New: ICashBackService;
begin
  Result := Self.Create;
end;

function TICashBackService.Save(cashbacks: TJSONArray;
  out msgError: String): ICashBackService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(cashbacks, msg) then
    msgError := msg;
end;

function TICashBackService.Synchronize(cashbacks: TJSONArray;
  out msgError: String): ICashBackService;
var
  msg: String;
begin
  Result := Self;
  if not UpdateSynchronize(cashbacks, msg) then
    msgError := msg;
end;

function TICashBackService.UpdateSynchronize(cashbacks: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;

  chave: String;
  sincronizado: String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  try
    try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vChave TIMESTAMP;');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado VARCHAR(36);');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to cashbacks.Count - 1 do
        begin
          item := cashbacks.Items[i] as TJSONObject;

          chave         := item.GetValue<String>('chave');
          sincronizado  := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

          sqlBlock.AppendLine('  vChave = ' + QuotedStr(chave) + ';');
          sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');
          sqlBlock.AppendLine('  UPDATE CASHBACKS SET');
          sqlBlock.AppendLine('      SINCRONIZADO = :vSincronizado');
          sqlBlock.AppendLine('  WHERE CHAVE = :vChave');
          sqlBlock.AppendLine('  AND SINCRONIZADO IS NULL;');
          sqlBlock.AppendLine('');
        end;

      sqlBlock.AppendLine('END;');

      lQry.Close;
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
    lQry.Close;
    FreeAndNil(sqlBlock);
    FreeAndNil(lQry);
  end;
end;

function TICashBackService.Use(cashbacks: TJSONArray;
  out msgError: String): ICashBackService;
var
  msg: String;
begin
  Result := Self;
  if not UseCashback(cashbacks, msg) then
    msgError := msg;
end;

function TICashBackService.UseCashback(cashbacks: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;

  dataVenda, sCupom, sLoja, voucher: String;
  cupom, loja: Integer;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  try
    try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vDataVenda TIMESTAMP;');
      sqlBlock.AppendLine('DECLARE VARIABLE vCupom INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vLoja INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vNumeroVoucher VARCHAR(54);');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to cashbacks.Count - 1 do
        begin
          item := cashbacks.Items[i] as TJSONObject;

          dataVenda  := item.GetValue<string>('dataBaixa').Replace('T',' ');
          sCupom     := item.GetValue<string>('vendaContatoCI').Substring(10,6);
          cupom      := StrToInt(sCupom);
          sLoja      := item.GetValue<string>('vendaContatoCI').Substring(0,2);
          loja       := StrToInt(sLoja);
          voucher    := item.GetValue<string>('numeroVoucher');

          sqlBlock.AppendLine('  vDataVenda = ' + QuotedStr(dataVenda) + ';');
          sqlBlock.AppendLine('  vCupom = ' + cupom.ToString + ';');
          sqlBlock.AppendLine('  vLoja = ' + loja.ToString + ';');
          sqlBlock.AppendLine('  vNumeroVoucher = ' + QuotedStr(voucher) + ';');
          sqlBlock.AppendLine('  UPDATE CASHBACKS SET');
          sqlBlock.AppendLine('      DATAVENDA = :vDataVenda,');
          sqlBlock.AppendLine('      CUPOM = :vCupom,');
          sqlBlock.AppendLine('      LOJA = :vLoja');
          sqlBlock.AppendLine('  WHERE NUMEROVOUCHER = :vNumeroVoucher;');
          sqlBlock.AppendLine('');
        end;

      sqlBlock.AppendLine('END;');

      lQry.Close;
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
    lQry.Close;
    FreeAndNil(sqlBlock);
    FreeAndNil(lQry);
  end;
end;

end.
