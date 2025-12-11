unit model.service.token.interfaces;

interface

uses
  model.tokens,
  System.JSON;

type
  ITokenService = interface
    ['{FBB17556-6417-45CD-9C3D-262312B4D853}']
    function Save(tokens: TJSONArray; out msgError: String): ITokenService;
    function GetModelToken(userID: String; out modelToken: Ttoken; out msgError): ITokenService;
  end;
implementation

end.
