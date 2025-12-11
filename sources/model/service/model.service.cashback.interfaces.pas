unit model.service.cashback.interfaces;

interface

uses
  System.JSON;

type
  ICashBackService = interface
    ['{536F0A87-7F49-40F1-95D7-9F0676530F36}']
    function Save(cashbacks: TJSONArray; out msgError: String): ICashBackService;
  end;

implementation

end.
