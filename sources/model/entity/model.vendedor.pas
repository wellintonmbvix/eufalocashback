unit model.vendedor;

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
  [Table('vendedores', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('codigo')]
  Tvendedor = class
  private
    Fcodigo: Integer;
    Fnome: String;
    Fativo: Boolean;
    Fsincronizado: nullable<TDateTime>;
  public
    constructor Create;
    destructor Destroy; override;

    [Column('codigo', ftInteger)]
    [Dictionary('codigo', 'Mensagem de validação', '', '', '', taCenter)]
    property codigo: Integer read Fcodigo write Fcodigo;

    [Column('nome', ftString, 50)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: String read Fnome write Fnome;

    [Column('ativo', ftBoolean)]
    [Dictionary('ativo', 'Mensagem de validação', '0', '', '', taCenter)]
    property ativo: Boolean read Fativo write Fativo;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado write Fsincronizado;
  end;

implementation

{ Tvendedor }

constructor Tvendedor.Create;
begin
  //
end;

destructor Tvendedor.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tvendedor)

end.
