# E-commerce SOLID — Projeto 3

Evolução do [Projeto 2](https://github.com/r4mongui/projeto2_ecommerce-solid) com PostgreSQL, Docker Compose e consulta de pedidos por ID.

## Como rodar

Na pasta do repositório, com Docker e Docker Compose v2 instalados:

```bash
cp .env.example .env
docker compose up --build
```

No PowerShell, use `Copy-Item .env.example .env` no primeiro passo. A API fica em `http://localhost:3000`. O Compose espera o PostgreSQL estar pronto antes de iniciar a API, que cria as tabelas e cadastra os dois produtos iniciais.

O modo `dev` usa o PostgreSQL. O banco fica acessível na rede interna do Compose e guarda os pedidos no volume `dados_postgres`, inclusive após `docker compose down` seguido de `docker compose up`. Por padrão, o Compose escreve os e-mails de confirmação no log da API. Para usar Ethereal, defina `MAIL_PROVIDER=ethereal` no `.env` e disponibilize acesso à internet e ao SMTP.

## Testar a API

No PowerShell:

```powershell
$body = @{
  customer = 'teste@example.com'
  items = @(@{ productId = 1; quantity = 1 })
  paymentMethod = 'pix'
} | ConvertTo-Json -Depth 4
$pedido = Invoke-RestMethod -Method Post -Uri http://localhost:3000/orders -ContentType 'application/json' -Body $body
Invoke-RestMethod -Uri "http://localhost:3000/orders/$($pedido.orderId)"
curl.exe -i http://localhost:3000/orders/0
```

Em Bash:

```bash
curl -fsS http://localhost:3000/orders -H 'Content-Type: application/json' -d '{"customer":"teste@example.com","items":[{"productId":1,"quantity":1}],"paymentMethod":"pix"}'
curl -i http://localhost:3000/orders/1  # Use o orderId devolvido pelo POST
curl -i http://localhost:3000/orders/0
```

`GET /orders/:id` retorna 200 com `id`, `customer`, `items`, `total`, `status` e `createdAt`. Um ID inexistente ou inválido retorna 404. O produto 1 custa R$ 100 mais R$ 10 de frete por linha do pedido. O produto 2 custa R$ 50 e dispensa frete. Os pagamentos são simulados, e o endpoint anterior `POST /pedidos` segue disponível.

## Verificações

Com o Compose em execução, rode os testes no PostgreSQL e em memória:

```bash
docker compose exec -T api npm test
docker compose exec -T -e APP_ENV=test api npm test
```

Para experimentar a API com dados em memória, altere `APP_ENV=test` no `.env` e execute `docker compose up --build` novamente. Os pedidos desse modo são descartados ao reiniciar a API. Para rodar o modo em memória sem Docker, use Node.js 22 e execute `npm ci`, `npm run prisma:generate` e `npm run dev` com `APP_ENV=test`.

A consulta passa por `OrderController → ServicoPedido → IRepositorioPedido`. O Inversify seleciona o repositório Prisma em `dev` e o repositório em memória em `test`.
