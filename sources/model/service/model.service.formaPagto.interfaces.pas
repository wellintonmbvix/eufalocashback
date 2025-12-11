unit model.service.formaPagto.interfaces;

interface

uses
  System.JSON;

type
  IFormaPagtoService = interface
    ['{D768D02A-16D3-45C1-BBE2-D6C16CE9857C}']
    function Save(formas_pagto: TJSONArray; out msgError: String)
      : IFormaPagtoService;
  end;

implementation

end.
