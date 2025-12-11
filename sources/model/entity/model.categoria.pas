unit model.categoria;

interface

uses
  DB,
  Classes,
  SysUtils,
  Generics.Collections,

  // ormbr
  ormbr.types.blob,
  ormbr.types.lazy,
  ormbr.objects.helper,
  dbcbr.types.mapping,
  ormbr.types.nullable,
  dbcbr.mapping.Classes,
  dbcbr.mapping.register,
  dbcbr.mapping.attributes;

type

  [Entity]
  [Table('categoria', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('codigo')]
  Tcategoria = class
  private
    Fcodigo: Integer;
    FnomeCategoria: String;
    FcategoriaPai: Integer;
    Fsincronizado: nullable<TDateTime>;

  public
    constructor Create;
    destructor Destroy; override;

    [Column('codigo', ftInteger)]
    [Dictionary('codigo', 'Mensagem de validação', '', '', '', taCenter)]
    property codigo: Integer read Fcodigo write Fcodigo;

    [Column('nomeCategoria', ftString, 50)]
    [Dictionary('nomeCategoria', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property nomeCategoria: String read FnomeCategoria write FnomeCategoria;

    [Column('categoriaPai', ftInteger)]
    [Dictionary('categoriaPai', 'Mensagem de validação', '', '', '', taCenter)]
    property categoriaPai: Integer read FcategoriaPai write FcategoriaPai;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado
      write Fsincronizado;
  end;

implementation

{ Tcategoria }

constructor Tcategoria.Create;
begin
  //
end;

destructor Tcategoria.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tcategoria)

end.
