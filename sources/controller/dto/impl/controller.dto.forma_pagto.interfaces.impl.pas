unit controller.dto.forma_pagto.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.forma_pagto,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.forma_pagto.interfaces;

type
  TIFormaPagto = class(TInterfacedObject, IFormaPagto)
    private
      FEntity: Tforma_pagto;
      FService: IService<Tforma_pagto>;
    public
      constructor Create;
      destructor Destroy; override;
      class function New: IFormaPagto;

    function codigo(value: Integer): IFormaPagto; overload;
    function codigo: Integer; overload;

    function descricao(value: String): IFormaPagto; overload;
    function descricao: String; overload;

    function ativo(value: Boolean): IFormaPagto; overload;
    function ativo: Boolean; overload;

    function sincronizado(value: TDateTime): IFormaPagto; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tforma_pagto>;
  end;

implementation

{ TIFormaPagto }

function TIFormaPagto.ativo(value: Boolean): IFormaPagto;
begin
  Result := Self;
  FEntity.ativo := value;
end;

function TIFormaPagto.ativo: Boolean;
begin
  Result := FEntity.ativo;
end;

function TIFormaPagto.Build: IService<Tforma_pagto>;
begin
  Result := FService;
end;

function TIFormaPagto.codigo: Integer;
begin
  Result := FEntity.codigo;
end;

function TIFormaPagto.codigo(value: Integer): IFormaPagto;
begin
  Result := Self;
  FEntity.codigo := value;
end;

constructor TIFormaPagto.Create;
begin
  FEntity := Tforma_pagto.Create;
  FService := TServiceORMBr<Tforma_pagto>.New(FEntity);
end;

function TIFormaPagto.descricao: String;
begin
  Result := FEntity.descricao;
end;

function TIFormaPagto.descricao(value: String): IFormaPagto;
begin
  Result := Self;
  FEntity.descricao := value;
end;

destructor TIFormaPagto.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

class function TIFormaPagto.New: IFormaPagto;
begin
  Result := Self.Create;
end;

function TIFormaPagto.sincronizado(value: TDateTime): IFormaPagto;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

function TIFormaPagto.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

end.
