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
    constructor Create;
    public
    class function New: ICashBackService;
    function Save(cashbacks: TJSONArray; out msgError: String)
      : ICashBackService;
  end;

implementation

{ TICashBackService }

constructor TICashBackService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TICashBackService.Insert(cashbacks: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;

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
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to cashbacks.Count - 1 do
        begin
          item := cashbacks.Items[i] as TJSONObject;

          cliente       := item.GetValue<Integer>('contatoCI');
          cpf           := item.GetValue<String>('cpf');
          chave         := item.GetValue<String>('chave');
          numeroVoucher := item.GetValue<String>('chave');
          data          := item.GetValue<string>('data').Replace('T',' ');
          prazoEntrega  := item.GetValue<Integer>('prazoEntrega');
          premio        := item.GetValue<String>('premio');
          valor         := item.GetValue<String>('valor');
          sincronizado  := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

          sqlBlock.AppendLine('  vCliente = ' + cliente.ToString + ';');
          sqlBlock.AppendLine('  vCpf = ' + QuotedStr(cpf) + ';');
          sqlBlock.AppendLine('  vChave = ' + QuotedStr(chave) + ';');
          sqlBlock.AppendLine('  vNumeroVoucher = ' + QuotedStr(numeroVoucher) + ';');
          sqlBlock.AppendLine('  vData = ' + QuotedStr(data.Replace('t',' ')) + ';');
          sqlBlock.AppendLine('  vPrazoEntrega = ' + prazoEntrega.ToString + ';');
          sqlBlock.AppendLine('  vPremio = ' + QuotedStr(premio) + ';');
          sqlBlock.AppendLine('  vValor = ' + StringReplace(valor, ',', '.',
            [rfReplaceAll]) + ';');
          sqlBlock.AppendLine('  vSincronizado = ' +
            QuotedStr(sincronizado) + ';');

          sqlBlock.AppendLine('  UPDATE CASHBACKS SET');
          sqlBlock.AppendLine('      NUMEROVOUCHER = :vNumeroVoucher,');
          sqlBlock.AppendLine('      DATA = :vData,');
          sqlBlock.AppendLine('      PRAZOENTREGA = :vPrazoEntrega,');
          sqlBlock.AppendLine('      PREMIO = :vPremio,');
          sqlBlock.AppendLine('      VALOR = :vValor,');
          sqlBlock.AppendLine('      SINCRONIZADO = :vSincronizado,');
          sqlBlock.AppendLine('  WHERE CLIENTE = :vCliente');
          sqlBlock.AppendLine('  AND CPF = :vCpf;');

          sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
          sqlBlock.AppendLine('    INSERT INTO CASHBACKS (');
          sqlBlock.AppendLine('        CLIENTE, CPF, CHAVE, NUMEROVOUCHER,');
          sqlBlock.AppendLine('        DATA, PRAZOENTREGA, PREMIO, VALOR, SINCRONIZADO');
          sqlBlock.AppendLine('    ) VALUES (');
          sqlBlock.AppendLine('        :vCliente, :vCpf, :vChave, :vNumeroVoucher,');
          sqlBlock.AppendLine('        :vData, :vPrazoEntrega, :vPremio, :vValor, :vSincronizado');
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

end.
