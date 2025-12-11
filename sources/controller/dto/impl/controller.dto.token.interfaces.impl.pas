unit controller.dto.token.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.tokens,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.token.interfaces;

type
  TIToken = class(TInterfacedObject, IToken)
  private
    FEntity: Ttoken;
    FService: IService<Ttoken>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IToken;

    function userId(value: String): IToken; overload;
    function userId: String; overload;

    function token(value: String): IToken; overload;
    function token: String; overload;

    function expiration(value: TDateTime): IToken; overload;
    function expiration: TDateTime; overload;

    function Build: IService<Ttoken>;
  end;

implementation

{ TIToken }

function TIToken.Build: IService<Ttoken>;
begin
  Result := FService;
end;

constructor TIToken.Create;
begin
  FEntity := Ttoken.Create;
  FService := TServiceORMBr<Ttoken>.New(FEntity);
end;

destructor TIToken.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

function TIToken.expiration: TDateTime;
begin
  Result := FEntity.expiration;
end;

class function TIToken.New: IToken;
begin
  Result := Self.Create;
end;

function TIToken.expiration(value: TDateTime): IToken;
begin
  Result := Self;
  FEntity.expiration := value;
end;

function TIToken.token(value: String): IToken;
begin
  Result := Self;
  FEntity.token := value;
end;

function TIToken.token: String;
begin
  Result := FEntity.token;
end;

function TIToken.userId(value: String): IToken;
begin
  Result := Self;
  FEntity.userId := value;
end;

function TIToken.userId: String;
begin
  Result := FEntity.userId;
end;

end.
