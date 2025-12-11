unit routines;

interface

uses
  System.SysUtils,
  System.Classes,
  System.JSON,
  System.TypInfo,

  FireDAC.Comp.Client,
  FireDAC.Comp.BatchMove,
  FireDAC.Comp.BatchMove.Text,
  FireDAC.Comp.BatchMove.DataSet,

  Winapi.ActiveX;

type
  TTipoLog = (tpNormal, tpError, tpWarning);

type
  TRoutines = class
    public
    class procedure ReadFileData(vFile: String; table: TFDMemTable;
      hasTitle: Boolean = false; charSeparator: Char = ';');
    class function MascaraCpfCnpj(Valor: String): String;
    class function AbreviaNome(fNome : String) : String;
    class function TemAtributo(Attr, Val: Integer): Boolean;
    class function ValidaGTIN(AGTIN: string): boolean;
    class function GuidCreate: String;
    class function GetInterval: Integer;
    class procedure ListarArquivos(Diretorio: string; Sub:Boolean; sList: TStringList);
    class procedure GenerateLogs(tipoLog: TTipoLog; msg: String = 'Evento de log.');
  end;

implementation

{ TRoutines }

class function TRoutines.AbreviaNome(fNome: String): String;
var
  Nomes: array of string;
  i, n: integer;
begin
  Result := fNome;
  fNome := Trim(fNome);
  fNome := fNome + #32;
  i := Pos(#32, fNome);
  if i > 0 then
  begin

    n := 0;

    { Separa os Nomes }
    while i > 0 do
    begin
      SetLength(Nomes, Length(fNome) + 1);
      Nomes[n] := Copy(fNome, 1, i - 1);
      Delete(fNome, 1, i);
      i := Pos(#32, fNome);
      inc(n);
    end;

    if n > 1 then
    begin

      { Abreviar a partir do segundo nome, exceto o último. }
      for i := 1 to n - 2 do
        { Contém mais de 3 letras? (ignorar de, da, das, do, dos, etc.) }
        if Length(Nomes[i]) > 3 then
          Nomes[i] := Nomes[i][1] + '.';

      Result := '';
      for i := 0 to n - 1 do
        Result := Result + Trim(Nomes[i]) + #32;

    end;
  end;
end;

class procedure TRoutines.GenerateLogs(tipoLog: TTipoLog; msg: String);
var
  fileLog: TextFile;
  tipo: String;
begin
  ForceDirectories('C:\CSSISTEMAS\Logs');

  AssignFile(fileLog, 'C:\CSSISTEMAS\Logs\CashBackEuFalo.log');
  {$I-}
    Reset(fileLog);
  {$I+}

  if (IOResult <> 0) then
    Rewrite(fileLog)
  else
    begin
      CloseFile(fileLog);
      Append(fileLog);
    end;

  case tipoLog of
    tpNormal: tipo := 'Status Normal - ';
    tpError: tipo := 'Status Erro - ';
    tpWarning: tipo := 'Status Atenção - ';
  end;

  WriteLn(fileLog,
  '===================================================================='+
  '============================================================================='
  );
  WriteLn(fileLog,FormatDateTime('[YYYY-mm-dd HH:mm:ss.zzz]: ',now()) + tipo + msg);

  CloseFile(fileLog);
end;

class function TRoutines.GetInterval: Integer;
var
  oJson : TJSONObject;
  vJson : TJSONValue;
  stringList: TStringList;
  errorLog: TextFile;
begin
  Result := 1; // Intervalo em minutos
  if Not FileExists('C:\CSSISTEMAS\CashBackEuFalo.json') then
    begin
      AssignFile(errorLog, 'C:\CSSISTEMAS\Logs\CashBackEuFalo_error.log');
      {$I-}
        Reset(errorLog);
      {$I+}

      if (IOResult <> 0) then
        Rewrite(errorLog)
      else
        begin
          CloseFile(errorLog);
          Append(errorLog);
        end;

      WriteLn(errorLog,
        FormatDateTime('[YYYY-mm-dd HH:mm:ss.zzz]', now())+
        ': Arquivo "C:\CSSISTEMAS\CashBackEuFalo.json" não encontrado.'
      );

      CloseFile(errorLog);
      Exit;
    end;

  stringList := TStringList.Create;
  stringList.LoadFromFile('C:\CSSISTEMAS\CashBackEuFalo.json', TEncoding.UTF8);
  oJson := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(stringList.Strings[0]), 0) as TJSONObject;

  if oJson = nil then
    begin
      AssignFile(errorLog, 'C:\CSSISTEMAS\Logs\CashBackEuFalo_error.log');
      {$I-}
        Reset(errorLog);
      {$I+}

      if (IOResult <> 0) then
        Rewrite(errorLog)
      else
        begin
          CloseFile(errorLog);
          Append(errorLog);
        end;

      WriteLn(errorLog,
        FormatDateTime('[YYYY-mm-dd HH:mm:ss.zzz]', now())+
        ': O arquivo "C:\CSSISTEMAS\CashBackEuFalo.json" é inválido.'
      );

      CloseFile(errorLog);
    end;

  vJson := oJson.GetValue('intervalo');
  if not Assigned(vJson) then
    begin
      AssignFile(errorLog, 'C:\CSSISTEMAS\Logs\CashBackEuFalo_error.log');
      {$I-}
        Reset(errorLog);
      {$I+}

      if (IOResult <> 0) then
        Rewrite(errorLog)
      else
        begin
          CloseFile(errorLog);
          Append(errorLog);
        end;

      WriteLn(errorLog,
        FormatDateTime('[YYYY-mm-dd HH:mm:ss.zzz]', now())+
        ': O parametro "intervalo" inexistente!'
      );

      CloseFile(errorLog);
    end;
  FreeAndNil(stringList);
  Result := vJson.Value.ToInteger;
end;

class function TRoutines.GuidCreate: String;
var
  ID: TGUID;
begin
  Result := EmptyStr;
  if CoCreateGuid(ID) = S_OK then
    Result := GUIDToString(ID);
end;

class procedure TRoutines.ListarArquivos(Diretorio: string; Sub: Boolean;
  sList: TStringList);
var
  F: TSearchRec;
  Ret: Integer;
  TempNome: string;
begin
  Ret := FindFirst(Diretorio+'\*_pagamento_recebido_PEDIDO.csv', faAnyFile, F);
  try
    while Ret = 0 do
    begin
      if TemAtributo(F.Attr, faDirectory) then
      begin
        if (F.Name <> '.') And (F.Name <> '..') then
          if Sub = True then
          begin
            TempNome := Diretorio+'\' + F.Name;
            ListarArquivos(TempNome, True, sList);
          end;
      end
      else
      begin
        sList.Add(Diretorio+'\'+F.Name);
      end;
        Ret := FindNext(F);
    end;
  finally
    FindClose(F);
  end;
end;

class function TRoutines.MascaraCpfCnpj(Valor: String): String;
var
  mascara: String;
  contador1, contador2: Integer;
begin
  if Length(Valor) = 14 then
    mascara := '**.***.***/****-**'
  else
    mascara := '***.***.***-**';
  contador2 := 1;
  Result := '';
  mascara := mascara + '****';
  For contador1 := 1 To Length(mascara) Do
  Begin
    IF Copy(mascara, contador1, 1) = '*' Then
      Result := Result + Copy(Valor, contador2, 1);
    IF Copy(mascara, contador1, 1) <> '*' Then
      Result := Result + Copy(mascara, contador1, 1);
    IF Copy(mascara, contador1, 1) = '*' Then
      contador2 := contador2 + 1;
  End;
  Result := Trim(Result);
end;

class procedure TRoutines.ReadFileData(vFile: String; table: TFDMemTable;
  hasTitle: Boolean; charSeparator: Char);
var
  FDBatchMove: TFDBatchMove;
begin
  FDBatchMove := TFDBatchMove.Create(nil);
  Try
    Try
      With TFDBatchMoveTextReader.Create(table) Do
        begin
          FileName := vFile; // Arquivo a ser lido
          DataDef.Separator := charSeparator; // Caractere separador de colunas
          DataDef.WithFieldNames := hasTitle; // Primeira linha é titulo
        end;

      with TFDBatchMoveDataSetWriter.Create(FDBatchMove) do
        begin
          DataSet := table;
          Optimise := False; // Não definir Optimise para "True" se dataset está anexado a UI
        end;

      FDBatchMove.GuessFormat();
      FDBatchMove.Execute;

      table.Active;
    Except
      on e: Exception do
        raise Exception.Create(e.Message);
    End;
  Finally
    FreeAndNil(FDBatchMove);
  End;
end;

class function TRoutines.TemAtributo(Attr, Val: Integer): Boolean;
begin
  Result := Attr and Val = Val;
end;

class function TRoutines.ValidaGTIN(AGTIN: string): boolean;
var
  i, soma, resultado, base10: integer;
begin
  //Verifica se todos os caracteres de AGTIN são números
  for i:= 1 to Length(AGTIN) do
   if not (CharInSet(AGTIN[i], ['0'..'9'])) then // if not (AGTIN[i] in ['0'..'9']) then
    begin
      Result:= False;
      Exit;
    end;
  //Verifica se AGTIN tem o tamanho necessário
  if Length(AGTIN) in [8,12,13,14] then
  begin
    soma:= 0;
    for i:= 1 to (Length(AGTIN) -1) do
    begin
      if Length(AGTIN) = 13 then
      begin
        if Odd(i) then
          soma:= soma + (strtoint(AGTIN[i]) * 1)
        else
          soma:= soma + (strtoint(AGTIN[i]) * 3);
      end
      else
      begin
        if Odd(i) then
          soma:= soma + (strtoint(AGTIN[i]) * 3)
        else
          soma:= soma + (strtoint(AGTIN[i]) * 1);
      end;
    end;
    base10:= soma;
    //Verifica se base10 é múltiplo de 10
    if not (base10 mod 10 = 0) then
    begin
      while not (base10 mod 10 = 0) do
      begin
        base10:= base10 + 1;
      end;
    end;
    resultado:= base10 - soma;
    //Verifica se o resultado encontrado é igual ao caractere de controle
    if resultado = strtoint(AGTIN[Length(AGTIN)]) then
      Result:= True
    else
      Result:= False;
  end
  else
    Result:= False;
end;

end.
