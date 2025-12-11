unit model.service.loja.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.loja.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TILojaService = class(TInterfacedObject, ILojaService)
    private
    FDConn: IConnectionFirebird;

    function Insert(lojas: TJSONArray; out msgError: String)
      : Boolean;
    constructor Create;
    public
    class function New: ILojaService;
    function Save(lojas: TJSONArray; out msgError: String)
      : ILojaService;
  end;

implementation

{ TILojaService }

constructor TILojaService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TILojaService.Insert(lojas: TJSONArray; out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;

  codigo       : Integer;
  razao        : String;
  fantasia     : String;
  cnpj         : String;
  logradouro   : String;
  numero       : String;
  complemento  : String;
  bairro       : String;
  cidade       : String;
  estado       : String;
  cep          : String;
  dddFixo      : String;
  foneFixo     : String;
  dddCel       : String;
  foneCel      : String;
  sincronizado : String;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  Try
    Try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vCodigo INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vRazao VARCHAR(60);');
      sqlBlock.AppendLine('DECLARE VARIABLE vFantasia VARCHAR(50);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCnpj VARCHAR(14);');
      sqlBlock.AppendLine('DECLARE VARIABLE vLogradouro VARCHAR(60);');
      sqlBlock.AppendLine('DECLARE VARIABLE vNumero VARCHAR(7);');
      sqlBlock.AppendLine('DECLARE VARIABLE vComplemento VARCHAR(30);');
      sqlBlock.AppendLine('DECLARE VARIABLE vBairro VARCHAR(40);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCidade VARCHAR(40);');
      sqlBlock.AppendLine('DECLARE VARIABLE vEstado VARCHAR(2);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCep VARCHAR(8);');
      sqlBlock.AppendLine('DECLARE VARIABLE vDddFixo VARCHAR(3);');
      sqlBlock.AppendLine('DECLARE VARIABLE vFoneFixo VARCHAR(8);');
      sqlBlock.AppendLine('DECLARE VARIABLE vDddCel VARCHAR(3);');
      sqlBlock.AppendLine('DECLARE VARIABLE vFoneCel VARCHAR(9);');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to lojas.Count - 1 do
        begin
          item := lojas.Items[i] as TJSONObject;

          codigo        := item.GetValue<Integer>('filialCI');
          razao         := item.GetValue<String>('razaoSocial');
          fantasia      := item.GetValue<String>('nomeFantasia');
          cnpj          := item.GetValue<String>('cnpj');
          logradouro    := item.GetValue<String>('logradouro');
          numero        := item.GetValue<String>('numero');
          complemento   := item.GetValue<String>('complemento');
          bairro        := item.GetValue<String>('bairro');
          cidade        := item.GetValue<String>('cidade');
          estado        := item.GetValue<String>('estado');
          cep           := item.GetValue<String>('cep');
          dddFixo       := item.GetValue<String>('dddTelefone');
          foneFixo      := item.GetValue<String>('numeroTelefone');
          dddCel        := item.GetValue<String>('dddWhatsApp');
          foneCel       := item.GetValue<String>('numeroWhatsApp');
          sincronizado  := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

          sqlBlock.AppendLine('  vCodigo = ' + codigo.ToString + ';');
          sqlBlock.AppendLine('  vRazao = ' + QuotedStr(razao) + ';');
          sqlBlock.AppendLine('  vFantasia = ' + QuotedStr(fantasia) + ';');
          sqlBlock.AppendLine('  vCnpj = ' + QuotedStr(cnpj) + ';');
          sqlBlock.AppendLine('  vLogradouro = ' + QuotedStr(logradouro) + ';');
          sqlBlock.AppendLine('  vNumero = ' + QuotedStr(numero) + ';');
          sqlBlock.AppendLine('  vComplemento = ' + QuotedStr(complemento) + ';');
          sqlBlock.AppendLine('  vBairro = ' + QuotedStr(bairro) + ';');
          sqlBlock.AppendLine('  vCidade = ' + QuotedStr(cidade) + ';');
          sqlBlock.AppendLine('  vEstado = ' + QuotedStr(estado) + ';');
          sqlBlock.AppendLine('  vCep = ' + QuotedStr(cep) + ';');
          sqlBlock.AppendLine('  vDddFixo = ' + QuotedStr(dddFixo) + ';');
          sqlBlock.AppendLine('  vFoneFixo = ' + QuotedStr(foneFixo) + ';');
          sqlBlock.AppendLine('  vDddCel = ' + QuotedStr(dddCel) + ';');
          sqlBlock.AppendLine('  vFoneCel = ' + QuotedStr(foneCel) + ';');
          sqlBlock.AppendLine('  vSincronizado = ' +
            QuotedStr(sincronizado) + ';');

          sqlBlock.AppendLine('  UPDATE LOJAS SET');
          sqlBlock.AppendLine('      RAZAO = :vRazao,');
          sqlBlock.AppendLine('      FANTASIA = :vFantasia,');
          sqlBlock.AppendLine('      CNPJ = :vCnpj,');
          sqlBlock.AppendLine('      LOGRADOURO = :vLogradouro,');
          sqlBlock.AppendLine('      NUMERO = :vNumero,');
          sqlBlock.AppendLine('      COMPLEMENTO = :vComplemento,');
          sqlBlock.AppendLine('      BAIRRO = :vBairro,');
          sqlBlock.AppendLine('      CIDADE = :vCidade,');
          sqlBlock.AppendLine('      ESTADO = :vEstado,');
          sqlBlock.AppendLine('      CEP = :vCep,');
          sqlBlock.AppendLine('      DDDFIXO = :vDddFixo,');
          sqlBlock.AppendLine('      FONEFIXO = :vFoneFixo,');
          sqlBlock.AppendLine('      DDDCEL = :vDddCel,');
          sqlBlock.AppendLine('      FONECEL = :vFoneCel,');
          sqlBlock.AppendLine('      SINCRONIZADO = :vSincronizado');
          sqlBlock.AppendLine('  WHERE CODIGO = :vCodigo;');

          sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
          sqlBlock.AppendLine('    INSERT INTO LOJAS (');
          sqlBlock.AppendLine('        CODIGO, RAZAO, FANTASIA, CNPJ, LOGRADOURO, NUMERO, COMPLEMENTO, BAIRRO,');
          sqlBlock.AppendLine('        CIDADE, ESTADO, CEP, DDDFIXO, FONEFIXO, DDDCEL, FONECEL, SINCRONIZADO');
          sqlBlock.AppendLine('    ) VALUES (');
          sqlBlock.AppendLine('        :vCodigo, :vRazao, :vFantasia, :vCnpj, :vLogradouro, :vNumero, :vComplemento, :vBairro,');
          sqlBlock.AppendLine('        :vCidade, :vEstado, :vCep, :vDddFixo, :vFoneFixo, :vDddCel, :vFoneCel, :vSincronizado');
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
    lQry.Close;
    FreeAndNil(sqlBlock);
    FreeAndNil(lQry);
  End;
end;

class function TILojaService.New: ILojaService;
begin
  Result := Self.Create;
end;

function TILojaService.Save(lojas: TJSONArray;
  out msgError: String): ILojaService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(lojas, msg) then
    msgError := msg;
end;

end.
