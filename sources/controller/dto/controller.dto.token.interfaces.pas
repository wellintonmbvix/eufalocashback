unit controller.dto.token.interfaces;

interface

uses
  model.tokens,

  //** ORMBr
  ormbr.types.blob,
  model.service.interfaces;

type
  IToken = interface
    ['{252471AB-18C5-499E-A790-6A8A88FA9AEE}']

    function userId(value: String): IToken; overload;
    function userId: String; overload;

    function token(value: String): IToken; overload;
    function token: String; overload;

    function expiration(value: TDateTime): IToken; overload;
    function expiration: TDateTime; overload;

    function Build: IService<Ttoken>;
  end;

implementation

end.
