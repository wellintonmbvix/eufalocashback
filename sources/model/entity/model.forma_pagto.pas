unit model.forma_pagto;

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
  [Table('forma_pagto', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('codigo')]
  Tforma_pagto = class
  private
    Fcodigo: Integer;
    Fdescricao: nullable<String>;
    Fativo: nullable<Boolean>;
    Fsincronizado: nullable<TDateTime>;
  public
    constructor Create;
    destructor Destroy; override;

    [Column('codigo', ftInteger)]
    [Dictionary('codigo', 'Mensagem de validação', '', '', '', taCenter)]
    property codigo: Integer read Fcodigo write Fcodigo;

    [Column('descricao', ftString, 50)]
    [Dictionary('descricao', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property descricao: nullable<String> read Fdescricao write Fdescricao;

    [Column('ativo', ftBoolean)]
    [Dictionary('ativo', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property ativo: nullable<Boolean> read Fativo write Fativo;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado write Fsincronizado;
  end;

implementation

{ Tforma_pagto }

constructor Tforma_pagto.Create;
begin
  //
end;

destructor Tforma_pagto.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tforma_pagto)

end.
