program CashBackEuFalo;

uses
  {$IFDEF DEBUG}
  FastMM4,
  {$ENDIF }
  Vcl.Forms,
  uPrincipal in 'sources\view\uPrincipal.pas' {fPrincipal},
  routines in 'sources\utils\routines.pas',
  model.service.interfaces in 'sources\model\service\model.service.interfaces.pas',
  model.service.interfaces.impl in 'sources\model\service\impl\model.service.interfaces.impl.pas',
  model.resource.interfaces in 'sources\model\resource\model.resource.interfaces.pas',
  model.resource.impl.configuration in 'sources\model\resource\impl\model.resource.impl.configuration.pas',
  model.resource.impl.connection.firedac in 'sources\model\resource\impl\model.resource.impl.connection.firedac.pas',
  model.resource.impl.factory in 'sources\model\resource\impl\model.resource.impl.factory.pas',
  model.cliente in 'sources\model\entity\model.cliente.pas',
  model.forma_pagto in 'sources\model\entity\model.forma_pagto.pas',
  model.produtos in 'sources\model\entity\model.produtos.pas',
  model.vendas in 'sources\model\entity\model.vendas.pas',
  model.vendas_itens in 'sources\model\entity\model.vendas_itens.pas',
  model.vendedor in 'sources\model\entity\model.vendedor.pas',
  controller.dto.cliente.interfaces in 'sources\controller\dto\controller.dto.cliente.interfaces.pas',
  controller.dto.cliente.interfaces.impl in 'sources\controller\dto\impl\controller.dto.cliente.interfaces.impl.pas',
  controller.dto.forma_pagto.interfaces in 'sources\controller\dto\controller.dto.forma_pagto.interfaces.pas',
  controller.dto.forma_pagto.interfaces.impl in 'sources\controller\dto\impl\controller.dto.forma_pagto.interfaces.impl.pas',
  controller.dto.produto.interfaces in 'sources\controller\dto\controller.dto.produto.interfaces.pas',
  controller.dto.produto.interfaces.impl in 'sources\controller\dto\impl\controller.dto.produto.interfaces.impl.pas',
  controller.dto.venda.interfaces in 'sources\controller\dto\controller.dto.venda.interfaces.pas',
  controller.dto.venda.interfaces.impl in 'sources\controller\dto\impl\controller.dto.venda.interfaces.impl.pas',
  controller.dto.venda_item.interfaces in 'sources\controller\dto\controller.dto.venda_item.interfaces.pas',
  controller.dto.venda_item.interfaces.impl in 'sources\controller\dto\impl\controller.dto.venda_item.interfaces.impl.pas',
  controller.cashbackEuFalo in 'sources\controller\controller.cashbackEuFalo.pas',
  model.tokens in 'sources\model\entity\model.tokens.pas',
  controller.dto.token.interfaces in 'sources\controller\dto\controller.dto.token.interfaces.pas',
  controller.dto.token.interfaces.impl in 'sources\controller\dto\impl\controller.dto.token.interfaces.impl.pas',
  model.loja in 'sources\model\entity\model.loja.pas',
  controller.dto.loja.interfaces in 'sources\controller\dto\controller.dto.loja.interfaces.pas',
  controller.dto.loja.interfaces.impl in 'sources\controller\dto\impl\controller.dto.loja.interfaces.impl.pas',
  controller.dto.vendedor.interfaces in 'sources\controller\dto\controller.dto.vendedor.interfaces.pas',
  controller.dto.vendedor.interfaces.impl in 'sources\controller\dto\impl\controller.dto.vendedor.interfaces.impl.pas',
  model.clienteJuridico in 'sources\model\entity\model.clienteJuridico.pas',
  controller.dto.clienteJuridico.interfaces in 'sources\controller\dto\controller.dto.clienteJuridico.interfaces.pas',
  controller.dto.clienteJuridico.interfaces.impl in 'sources\controller\dto\impl\controller.dto.clienteJuridico.interfaces.impl.pas',
  model.categoria in 'sources\model\entity\model.categoria.pas',
  controller.dto.categoria.interfaces in 'sources\controller\dto\controller.dto.categoria.interfaces.pas',
  controller.dto.categoria.interfaces.impl in 'sources\controller\dto\impl\controller.dto.categoria.interfaces.impl.pas',
  connection.sqlite.interfaces in 'sources\dao\connection.sqlite.interfaces.pas',
  connection.sqlite.interfaces.impl in 'sources\dao\impl\connection.sqlite.interfaces.impl.pas',
  model.service.categoria.interfaces in 'sources\model\service\model.service.categoria.interfaces.pas',
  model.service.categoria.interfaces.impl in 'sources\model\service\impl\model.service.categoria.interfaces.impl.pas',
  model.service.produto.interfaces in 'sources\model\service\model.service.produto.interfaces.pas',
  model.service.produto.interfaces.impl in 'sources\model\service\impl\model.service.produto.interfaces.impl.pas',
  connection.firebird.interfaces in 'sources\dao\connection.firebird.interfaces.pas',
  connection.firebird.interfaces.impl in 'sources\dao\impl\connection.firebird.interfaces.impl.pas',
  model.service.token.interfaces in 'sources\model\service\model.service.token.interfaces.pas',
  model.service.token.interfaces.impl in 'sources\model\service\impl\model.service.token.interfaces.impl.pas',
  model.service.cliente.interfaces in 'sources\model\service\model.service.cliente.interfaces.pas',
  model.service.cliente.interfaces.impl in 'sources\model\service\impl\model.service.cliente.interfaces.impl.pas',
  model.service.vendedor.interfaces in 'sources\model\service\model.service.vendedor.interfaces.pas',
  model.service.vendedor.interfaces.impl in 'sources\model\service\impl\model.service.vendedor.interfaces.impl.pas',
  model.service.vendas.interfaces in 'sources\model\service\model.service.vendas.interfaces.pas',
  model.service.vendas.interfaces.impl in 'sources\model\service\impl\model.service.vendas.interfaces.impl.pas',
  model.service.formaPagto.interfaces in 'sources\model\service\model.service.formaPagto.interfaces.pas',
  model.service.formaPagto.interfaces.impl in 'sources\model\service\impl\model.service.formaPagto.interfaces.impl.pas',
  model.service.cashback.interfaces in 'sources\model\service\model.service.cashback.interfaces.pas',
  model.service.cashback.interfaces.impl in 'sources\model\service\impl\model.service.cashback.interfaces.impl.pas',
  model.service.loja.interfaces in 'sources\model\service\model.service.loja.interfaces.pas',
  model.service.loja.interfaces.impl in 'sources\model\service\impl\model.service.loja.interfaces.impl.pas',
  model.service.fabricante.interfaces in 'sources\model\service\model.service.fabricante.interfaces.pas',
  model.service.fabricante.interfaces.impl in 'sources\model\service\impl\model.service.fabricante.interfaces.impl.pas';

{$R *.res}

begin
  if ParamStr(1) <> '--cashbackeufalo' then
    begin
      Application.MessageBox('Parametros não definidos. Execução interrompida', 'CashBack - EuFalo.com');
      Exit;
    end
  else
    TControllerEuFalo.PostOnEuFalo;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfPrincipal, fPrincipal);
  Application.Run;
end.
