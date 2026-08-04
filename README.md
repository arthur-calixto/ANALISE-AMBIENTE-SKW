# Análise de Ambiente Sankhya

Dashboard web que executa queries de análise (locks, nível de
personalização, parâmetros, jobs com falha, eventos com erro etc.)
contra o banco de clientes, além de um analisador do Monitor de
Consulta/Processos do Sankhya (upload de zip).

## Fluxo

1. As credenciais de cada cliente ficam em um arquivo
   `<SHARED_DIR>/<NOME_CLIENTE>.json` (ex: `SomaForce.json`).
2. A tela inicial (`/`) lista automaticamente os clientes encontrados
   nesse diretório.
3. Usuário clica no cliente, cai no dashboard, clica em "Executar Análise".
4. A aplicação roda as queries em `app/db/queries/` e mostra o resultado.
5. Opcionalmente, baixa um relatório em PDF do resultado.

### Formato do `<NOME_CLIENTE>.json`

```json
{
  "db_type": "oracle",
  "host": "...",
  "port": 1521,
  "service_name": "...",
  "user": "...",
  "password": "..."
}
```

## Rodando local (sem Docker, pra desenvolvimento rápido)

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# editar .env se necessário (SHARED_DIR aponta pra ./data por padrão nesse exemplo)
uvicorn app.main:app --reload
```

Crie `data/exemplo-sessao.json` com as credenciais de um banco de teste
e acesse `http://localhost:8000/` — o cliente deve aparecer listado.

## Rodando com Docker

```bash
cp .env.example .env
docker compose up --build
```

Ajuste o caminho do volume em `docker-compose.yml` (`/repositorio-compartilhado`)
para o diretório real onde ficam os arquivos `<NOME_CLIENTE>.json`.

## Adicionando uma nova query/análise

O dashboard é dirigido pelo registro em `app/checks.py`. Pra adicionar uma
nova análise:

1. Criar o arquivo SQL em `app/db/queries/<id>_<db_type>.sql`
   (um por banco suportado, ex: `<id>_oracle.sql` e `<id>_sqlserver.sql`).
2. Adicionar uma entrada em `CHECKS` (`app/checks.py`) com esse `id`,
   um `titulo` e o tipo de exibição:
   - `Exibicao.TABELA` — qualquer resultado, mostrado como tabela genérica.
   - `Exibicao.CARDS` — query deve retornar colunas `PARAMETRO`, `ESPERADO`,
     `ATUAL`, `STATUS` (`ok`/`alerta`/`indefinido`).
   - `Exibicao.CONTAGEM` — query deve retornar colunas `TITULO`,
     `CONTAGEM`, `DETALHE`, opcionalmente `STATUS`.

Não precisa mexer em rota nem template — o dashboard já itera sobre
`CHECKS` sozinho.

## Pendências conhecidas (próximos passos)

- [ ] Autenticação/controle de acesso na tela inicial e nas rotas de
      análise (hoje qualquer um com acesso à rede vê a lista de
      clientes e pode rodar queries).
- [ ] Coleta de JStack/JFR (fase 2).
