unit model.service.token.interfaces.impl;

interface

uses
  System.SysUtils,
  System.JSON,

  model.tokens,
  model.service.token.interfaces,

  connection.firebird.interfaces,
  connection.firebird.interfaces.impl,

  FireDAC.Comp.Client;

type
  TITokenService = class(TInterfacedObject, ITokenService)
  private
    FDConn: IConnectionFirebird;

    function Insert(tokens: TJSONArray; out msgError: String)
      : Boolean; overload;
    constructor Create;
  public
    class function New: ITokenService;
    function Save(tokens: TJSONArray; out msgError: String): ITokenService;
    function GetModelToken(userID: String; out modelToken: Ttoken;
      out msgError): ITokenService;
  end;

implementation

{ TITokenService }

constructor TITokenService.Create;
begin
  FDConn := TIConnectionFirebird.New;
end;

function TITokenService.GetModelToken(userID: String; out modelToken: Ttoken;
  out msgError): ITokenService;
var
  lQry: TFDQuery;
begin
  Result := Self;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);

  try
    With lQry Do
      begin
        Close;
        SQL.Clear;
        SQL.Add('SELECT * FROM TOKENS');
        SQL.Add('WHERE USERID = ' + QuotedStr(userID));
        Open;

        if Not IsEmpty then
          begin
            modelToken.userId := userId;
            modelToken.token := FieldByName('TOKEN').AsString;
            modelToken.expiration := FieldByName('EXPIRATION').AsDateTime;
          end;
      end;
    FDConn.Commit;
  finally
    lQry.Close;
    FreeAndNil(lQry);
  end;
end;

function TITokenService.Insert(tokens: TJSONArray;
  out msgError: String): Boolean;
var
  lQry: TFDQuery;
  item: TJSONObject;
  sqlBlock: TStringBuilder;
  userID: String;
  token: String;
  expiration: String;
  sincronizado: String;
  jv: TJSONValue;
begin
  Result := False;
  FDConn.StartTransaction;
  lQry := TFDQuery(FDConn.GetQuery);
  sqlBlock := TStringBuilder.Create;

  Try
    Try
      sqlBlock.AppendLine('EXECUTE BLOCK AS');
      sqlBlock.AppendLine('DECLARE VARIABLE vUserId VARCHAR(80);');
      sqlBlock.AppendLine('DECLARE VARIABLE vToken BLOB SUB_TYPE TEXT;');
      sqlBlock.AppendLine('DECLARE VARIABLE vExpiration TIMESTAMP;');
      sqlBlock.AppendLine('DECLARE VARIABLE vSincronizado TIMESTAMP;');
      sqlBlock.AppendLine('BEGIN');

      for var i := 0 to tokens.Count - 1 do
      begin
        item := tokens.Items[i] as TJSONObject;

        userID := item.GetValue<String>('userID');
        token := item.GetValue<string>('accessToken');
        sincronizado := FormatDateTime('yyyy-mm-dd hh:nn:ss', Now());

        var FS := TFormatSettings.Create;
        FS.DateSeparator := '-';
        FS.TimeSeparator := ':';
        FS.ShortDateFormat := 'yyyy-mm-dd';
        FS.LongTimeFormat := 'hh:nn:ss';
        if item.TryGetValue('expiration', jv) then
          expiration := FormatDateTime('yyyy-mm-dd hh:nn:ss',
            StrToDateTime(jv.Value, FS));

        sqlBlock.AppendLine('  vUserId = ' + QuotedStr(userID) + ';');
        sqlBlock.AppendLine('  vToken = ' + QuotedStr(token) + ';');
        sqlBlock.AppendLine('  vExpiration = ' + QuotedStr(expiration) + ';');
        sqlBlock.AppendLine('  vSincronizado = ' + QuotedStr(sincronizado) + ';');

        sqlBlock.AppendLine('  UPDATE TOKENS');
        sqlBlock.AppendLine('     SET TOKEN = :vToken,');
        sqlBlock.AppendLine('         EXPIRATION = :vExpiration,');
        sqlBlock.AppendLine('         SINCRONIZADO = :vSincronizado');
        sqlBlock.AppendLine('   WHERE USERID = :vUserId;');

        sqlBlock.AppendLine('  IF (ROW_COUNT = 0) THEN');
        sqlBlock.AppendLine('    INSERT INTO TOKENS (USERID, TOKEN, EXPIRATION, SINCRONIZADO)');
        sqlBlock.AppendLine('    VALUES (:vUserId, :vToken, :vExpiration, :vSincronizado);');
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

class function TITokenService.New: ITokenService;
begin
  Result := Self.Create;
end;

function TITokenService.Save(tokens: TJSONArray; out msgError: String): ITokenService;
var
  msg: String;
begin
  Result := Self;
  if not Insert(tokens, msg) then
    msgError := msg;
end;

end.
