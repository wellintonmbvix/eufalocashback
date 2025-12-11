unit controller.dto.vendedor.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.vendedor,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.vendedor.interfaces;

type
  TIVendedor = class(TInterfacedObject, IVendedor)
  private
    FEntity: Tvendedor;
    FService: IService<Tvendedor>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: IVendedor;

    function codigo(value: Integer): IVendedor; overload;
    function codigo: Integer; overload;

    function nome(value: String): IVendedor; overload;
    function nome: String; overload;

    function ativo(value: Boolean): IVendedor; overload;
    function ativo: Boolean; overload;

    function sincronizado(value: TDateTime): IVendedor; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tvendedor>;
  end;

implementation

{ TIVendedor }

function TIVendedor.ativo(value: Boolean): IVendedor;
begin
  Result := Self;
  FEntity.ativo := value;
end;

function TIVendedor.ativo: Boolean;
begin
  Result := FEntity.ativo;
end;

function TIVendedor.Build: IService<Tvendedor>;
begin
  Result := FService;
end;

function TIVendedor.codigo(value: Integer): IVendedor;
begin
  Result := Self;
  FEntity.codigo := value;
end;

function TIVendedor.codigo: Integer;
begin
  Result := FEntity.codigo;
end;

constructor TIVendedor.Create;
begin
  FEntity := Tvendedor.Create;
  FService := TServiceORMBr<Tvendedor>.New(FEntity);
end;

destructor TIVendedor.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

class function TIVendedor.New: IVendedor;
begin
  Result := Self.Create;
end;

function TIVendedor.nome(value: String): IVendedor;
begin
  Result := Self;
  FEntity.nome := value;
end;

function TIVendedor.nome: String;
begin
  Result := FEntity.nome;
end;

function TIVendedor.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TIVendedor.sincronizado(value: TDateTime): IVendedor;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

end.
