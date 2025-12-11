unit model.cliente;

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
  [Table('clientes', '')]
  [PrimaryKey('codigo', TAutoIncType.NotInc,
                        TGeneratorType.NoneInc,
                        TSortingOrder.NoSort,
                        True, 'Chave primária')]
  [Sequence('')]
  [OrderBy('codigo')]
  Tcliente = class
  private
    Fcodigo: Integer;
    Fnome: nullable<String>;
    Fsexo: nullable<String>;
    FdataNascimento: nullable<String>;
    FdataCadastro: nullable<String>;
    Fcpf: nullable<String>;
    Femail: nullable<String>;
    Floja: nullable<Integer>;
    Flogradouro: nullable<String>;
    Fnumero: nullable<String>;
    Fcomplemento: nullable<String>;
    Fbairro: nullable<String>;
    Fcidade: nullable<String>;
    FsiglaEstado: nullable<String>;
    Fcep: nullable<String>;
    Fpais: nullable<String>;
    Ftelefone1: nullable<String>;
    Ftelefone2: nullable<String>;
    Ftelefone3: nullable<String>;
    Fsincronizado: nullable<TDateTime>;
  public
    constructor Create;
    destructor Destroy; override;

    [Column('codigo', ftInteger)]
    [Dictionary('codigo', 'Mensagem de validação', '', '', '', taCenter)]
    property codigo: Integer read Fcodigo write Fcodigo;

    [Column('nome', ftString, 50)]
    [Dictionary('nome', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property nome: nullable<String> read Fnome write Fnome;

    [Column('sexo', ftString, 1)]
    [Dictionary('sexo', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property sexo: nullable<String> read Fsexo write Fsexo;

    [Column('dataNascimento', ftString, 24)]
    [Dictionary('dataNascimento', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property dataNascimento: nullable<String> read FdataNascimento
      write FdataNascimento;

    [Column('dataCadastro', ftString, 24)]
    [Dictionary('dataCadastro', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property dataCadastro: nullable<String> read FdataCadastro
      write FdataCadastro;

    [Column('cpf', ftString, 11)]
    [Dictionary('cpf', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cpf: nullable<String> read Fcpf write Fcpf;

    [Column('email', ftString, 120)]
    [Dictionary('email', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property email: nullable<String> read Femail write Femail;

    [Column('loja', ftInteger)]
    [Dictionary('loja', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property loja: nullable<Integer> read Floja write Floja;

    [Column('logradouro', ftString, 60)]
    [Dictionary('logradouro', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property logradouro: nullable<String> read Flogradouro write Flogradouro;

    [Column('numero', ftString, 5)]
    [Dictionary('numero', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property numero: nullable<String> read Fnumero write Fnumero;

    [Column('complemento', ftString, 30)]
    [Dictionary('complemento', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property complemento: nullable<String> read Fcomplemento write Fcomplemento;

    [Column('bairro', ftString, 40)]
    [Dictionary('bairro', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property bairro: nullable<String> read Fbairro write Fbairro;

    [Column('cidade', ftString, 40)]
    [Dictionary('cidade', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cidade: nullable<String> read Fcidade write Fcidade;

    [Column('siglaEstado', ftString, 2)]
    [Dictionary('siglaEstado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property siglaEstado: nullable<String> read FsiglaEstado write FsiglaEstado;

    [Column('cep', ftString, 8)]
    [Dictionary('cep', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property cep: nullable<String> read Fcep write Fcep;

    [Column('pais', ftString, 30)]
    [Dictionary('pais', 'Mensagem de validação', '', '', '', taLeftJustify)]
    property pais: nullable<String> read Fpais write Fpais;

    [Column('telefone1', ftString, 12)]
    [Dictionary('telefone1', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property telefone1: nullable<String> read Ftelefone1 write Ftelefone1;

    [Column('telefone2', ftString, 12)]
    [Dictionary('telefone2', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property telefone2: nullable<String> read Ftelefone2 write Ftelefone2;

    [Column('telefone3', ftString, 12)]
    [Dictionary('telefone3', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property telefone3: nullable<String> read Ftelefone3 write Ftelefone3;

    [Column('sincronizado', ftDateTime)]
    [Dictionary('sincronizado', 'Mensagem de validação', '', '', '',
      taLeftJustify)]
    property sincronizado: nullable<TDateTime> read Fsincronizado
      write Fsincronizado;
  end;

implementation

{ Tcliente }

constructor Tcliente.Create;
begin
  //
end;

destructor Tcliente.Destroy;
begin
  inherited;
end;

initialization

TRegisterClass.RegisterEntity(Tcliente)

end.
