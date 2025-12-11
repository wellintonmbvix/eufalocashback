unit controller.dto.categoria.interfaces.impl;

interface

uses
  System.SysUtils,

  model.service.interfaces,
  model.service.interfaces.impl,
  model.categoria,

  ormbr.objects.helper,
  dbcbr.mapping.explorer,
  ormbr.json,
  ormbr.rtti.helper,

  controller.dto.categoria.interfaces;

type
  TICategoria = class(TInterfacedObject, ICategoria)
  private
    FEntity: Tcategoria;
    FService: IService<Tcategoria>;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: ICategoria;

    function codigo(value: Integer): ICategoria; overload;
    function codigo: Integer; overload;

    function nomeCategoria(value: String): ICategoria; overload;
    function nomeCategoria: String; overload;

    function categoriaPai(value: Integer): ICategoria; overload;
    function categoriaPai: Integer; overload;

    function sincronizado(value: TDateTime): ICategoria; overload;
    function sincronizado: TDateTime; overload;

    function Build: IService<Tcategoria>;
  end;

implementation

{ TICategoria }

function TICategoria.Build: IService<Tcategoria>;
begin
  Result := FService;
end;

function TICategoria.categoriaPai: Integer;
begin
  Result := FEntity.categoriaPai;
end;

function TICategoria.categoriaPai(value: Integer): ICategoria;
begin
  Result := Self;
  FEntity.categoriaPai := value;
end;

function TICategoria.codigo(value: Integer): ICategoria;
begin
  Result := Self;
  FEntity.codigo := value;
end;

function TICategoria.codigo: Integer;
begin
  Result := FEntity.codigo;
end;

constructor TICategoria.Create;
begin
  FEntity := Tcategoria.Create;
  FService := TServiceORMBr<Tcategoria>.New(FEntity);
end;

destructor TICategoria.Destroy;
begin
  FreeAndNil(FEntity);
  inherited;
end;

class function TICategoria.New: ICategoria;
begin
  Result := Self.Create;
end;

function TICategoria.nomeCategoria: String;
begin
  Result := FEntity.nomeCategoria;
end;

function TICategoria.sincronizado: TDateTime;
begin
  Result := FEntity.sincronizado;
end;

function TICategoria.sincronizado(value: TDateTime): ICategoria;
begin
  Result := Self;
  FEntity.sincronizado := value;
end;

function TICategoria.nomeCategoria(value: String): ICategoria;
begin
  Result := Self;
  FEntity.nomeCategoria := value;
end;

end.
