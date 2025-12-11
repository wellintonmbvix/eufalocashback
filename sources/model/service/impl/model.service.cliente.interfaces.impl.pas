unit model.service.cliente.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.service.cliente.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TIClienteService = class(TInterfacedObject, IClienteService)
    private
    FDConn: IConnectionFirebird;

    function Insert(clientes: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
    public
    class function New: IClienteService;
    function Save(clientes: TJSONArray; out msgError: String): IClienteService;
  end;

implementation


{ TIClienteService }

constructor TIClienteService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TIClienteService.Insert(clientes: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  endereco: TJSONObject;
  TelefonesArray: TJSONArray;
  sqlBlock: TStringBuilder;
  codigo: Integer;
  nome: String;
  sexo: String;
  nascimento: String;
  data_cadastro: String;
  cpf: String;
  email: String;
  loja: Integer;
  logradouro: String;
  numero: String;
  complemento: String;
  bairro: String;
  cidade: String;
  estado: String;
  cep: String;
  pais: String;
  tel1: String;
  tel2: String;
  tel3: String;
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
      sqlBlock.AppendLine('DECLARE VARIABLE vNome VARCHAR(50);');
      sqlBlock.AppendLine('DECLARE VARIABLE vSexo CHAR(1);');
      sqlBlock.AppendLine('DECLARE VARIABLE vDataNascimento VARCHAR(24);');
      sqlBlock.AppendLine('DECLARE VARIABLE vDataCadastro VARCHAR(24);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCpf VARCHAR(11);');
      sqlBlock.AppendLine('DECLARE VARIABLE vEmail VARCHAR(110);');
      sqlBlock.AppendLine('DECLARE VARIABLE vLoja INTEGER;');
      sqlBlock.AppendLine('DECLARE VARIABLE vLogradouro VARCHAR(60);');
      sqlBlock.AppendLine('DECLARE VARIABLE vNumero VARCHAR(5);');
      sqlBlock.AppendLine('DECLARE VARIABLE vComplemento VARCHAR(30);');
      sqlBlock.AppendLine('DECLARE VARIABLE vBairro VARCHAR(40);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCidade VARCHAR(40);');
      sqlBlock.AppendLine('DECLARE VARIABLE vEstado VARCHAR(2);');
      sqlBlock.AppendLine('DECLARE VARIABLE vCep VARCHAR(8);');
      sqlBlock.AppendLine('DECLARE VARIABLE vPais VARCHAR(30);');
      sqlBlock.AppendLine('DECLARE VARIABLE vTel1 VARCHAR(12);');
      sqlBlock.AppendLine('DECLARE VARIABLE vTel2 VARCHAR(12);');
      sqlBlock.AppendLine('DECLARE VARIABLE vTel3 VARCHAR(12);');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to clientes.Count - 1 do
      begin
        item := clientes.Items[i] as TJSONObject;

        tel1 := '';
        tel2 := '';
        tel3 := '';

        codigo := item.GetValue<Integer>('contatoCI');
        nome := item.GetValue<string>('nome');
        sexo := item.GetValue<string>('sexo');
        nascimento := item.GetValue<string>('dataNascimento');
        data_cadastro := item.GetValue<string>('dataCadastro');
        cpf := item.GetValue<string>('cpf');
        email := item.GetValue<string>('email');
        loja := item.GetValue<Integer>('filialCI');

        endereco    := item.GetValue('endereco') as TJSONObject;
        logradouro  := endereco.GetValue<string>('logradouro');
        numero      := endereco.GetValue<string>('numero');
        complemento := endereco.GetValue<string>('complemento');
        bairro      := endereco.GetValue<string>('bairro');
        cidade      := endereco.GetValue<string>('cidade');
        estado      := endereco.GetValue<string>('siglaEstado');
        cep         := endereco.GetValue<string>('cep');
        pais        := endereco.GetValue<string>('pais');

        TelefonesArray := item.GetValue<TJSONArray>('telefone');
        if Assigned(TelefonesArray) then
          begin
            if TelefonesArray.Count > 0 then
              tel1 := TelefonesArray.Items[0].GetValue<string>('numero');

            if TelefonesArray.Count > 1 then
              tel2 := TelefonesArray.Items[1].GetValue<string>('numero');

            if TelefonesArray.Count > 2 then
              tel3 := TelefonesArray.Items[2].GetValue<string>('numero');
          end;

        sincronizado := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

        sqlBlock.AppendLine('  vCodigo = ' + IntToStr(codigo) + ';');
        sqlBlock.AppendLine('  vNome = ' + QuotedStr(nome) + ';');
        sqlBlock.AppendLine('  vSexo = ' + QuotedStr(sexo) + ';');
        sqlBlock.AppendLine('  vDataNascimento = ' + QuotedStr(nascimento) + ';');
        sqlBlock.AppendLine('  vDataCadastro = ' + QuotedStr(data_cadastro) + ';');
        sqlBlock.AppendLine('  vCpf = ' + QuotedStr(cpf) + ';');
        sqlBlock.AppendLine('  vEmail = ' + QuotedStr(email) + ';');
        sqlBlock.AppendLine('  vLoja = ' + loja.ToString + ';');
        sqlBlock.AppendLine('  vLogradouro = ' + QuotedStr(logradouro) + ';');
        sqlBlock.AppendLine('  vNumero = ' + QuotedStr(numero) + ';');
        sqlBlock.AppendLine('  vComplemento = ' + QuotedStr(complemento) + ';');
        sqlBlock.AppendLine('  vBairro = ' + QuotedStr(bairro) + ';');
        sqlBlock.AppendLine('  vCidade = ' + QuotedStr(cidade) + ';');
        sqlBlock.AppendLine('  vEstado = ' + QuotedStr(estado) + ';');
        sqlBlock.AppendLine('  vCep = ' + QuotedStr(cep) + ';');
        sqlBlock.AppendLine('  vPais = ' + QuotedStr(pais) + ';');
        sqlBlock.AppendLine('  vTel1 = ' + QuotedStr(tel1) + ';');
        sqlBlock.AppendLine('  vTel2 = ' + QuotedStr(tel2) + ';');
        sqlBlock.AppendLine('  vTel3 = ' + QuotedStr(tel3) + ';');
        sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

        sqlBlock.AppendLine('  UPDATE CLIENTES');
        sqlBlock.AppendLine('     SET NOME = :vNome,');
        sqlBlock.AppendLine('         SEXO = :vSexo,');
        sqlBlock.AppendLine('         DATA_NASCIMENTO = :vDataNascimento,');
        sqlBlock.AppendLine('         DATA_CADASTRO = :vDataCadastro,');
        sqlBlock.AppendLine('         CPF = :vCpf,');
        sqlBlock.AppendLine('         EMAIL = :vEmail,');
        sqlBlock.AppendLine('         LOJA = :vLoja,');
        sqlBlock.AppendLine('         LOGRADOURO = :vLogradouro,');
        sqlBlock.AppendLine('         NUMERO = :vNumero,');
        sqlBlock.AppendLine('         COMPLEMENTO = :vComplemento,');
        sqlBlock.AppendLine('         BAIRRO = :vBairro,');
        sqlBlock.AppendLine('         CIDADE = :vCidade,');
        sqlBlock.AppendLine('         SIGLA_ESTADO = :vEstado,');
        sqlBlock.AppendLine('         CEP = :vCep,');
        sqlBlock.AppendLine('         PAIS = :vPais,');
        sqlBlock.AppendLine('         TELEFONE1 = :vTel1,');
        sqlBlock.AppendLine('         TELEFONE2 = :vTel2,');
        sqlBlock.AppendLine('         TELEFONE3 = :vTel3,');
        sqlBlock.AppendLine('         SINCRONIZADO = :vSincronizado');
        sqlBlock.AppendLine('   WHERE CODIGO = :vCodigo;');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO CLIENTES (CODIGO, NOME, SEXO,'+
        ' DATA_NASCIMENTO, DATA_CADASTRO, CPF, EMAIL, LOJA, LOGRADOURO, NUMERO,'+
        ' COMPLEMENTO, BAIRRO, CIDADE, SIGLA_ESTADO, CEP, PAIS, TELEFONE1,'+
        ' TELEFONE2, TELEFONE3, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (:vCodigo, :vNome, :vSexo,'+
        ' :vDataNascimento, :vDataCadastro, :vCpf, :vEmail, :vLoja,'+
        ' :vLogradouro, :vNumero, :vComplemento, :vBairro, :vCidade,'+
        ' :vEstado, :vCep, :vPais, :vTel1, :vTel2, :vTel3, :vSincronizado);');
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

class function TIClienteService.New: IClienteService;
begin
  Result := Self.Create;
end;

function TIClienteService.Save(clientes: TJSONArray;
  out msgError: String): IClienteService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(clientes, msg) then
    msgError := msg;
end;

end.
