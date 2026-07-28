# Análise de Ambiente Sankhya

MVP: dashboard web que executa queries de análise (locks + nível de
personalização) contra o banco do cliente, a partir de uma sessão
preparada pelo `server-tool.sh` num diretório compartilhado.

## Fluxo

1. `server-tool.sh` gera um `session_id` (UUID) e grava
   `<SHARED_DIR>/<session_id>/credentials.json` com os dados de conexão.
2. `server-tool.sh` retorna a URL: `<PUBLIC_BASE_URL>/analise/<session_id>`
3. Usuário abre a URL, vê o dashboard, clica em "Executar Análise".
4. A aplicação roda as queries em `app/db/queries/` e mostra o resultado.

## Rodando local (sem Docker, pra desenvolvimento rápido)

```bash
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
# editar .env se necessário (SHARED_DIR aponta pra ./data por padrão nesse exemplo)
uvicorn app.main:app --reload
```

Acesse: `http://localhost:8000/analise/exemplo-sessao`
(usa o `credentials.json` de exemplo em `data/exemplo-sessao/`)

## Rodando com Docker

```bash
cp .env.example .env
docker compose up --build
```

Ajuste o caminho do volume em `docker-compose.yml` (`/repositorio-compartilhado`)
para o diretório real onde o `server-tool.sh` escreve as sessões.

## Adicionando uma nova query/análise

O dashboard é dirigido pelo registro em `app/checks.py`. Pra adicionar uma
nova análise:

1. Criar o arquivo SQL em `app/db/queries/<id>_<db_type>.sql`
   (um por banco suportado, ex: `<id>_oracle.sql` e `<id>_sqlserver.sql`).
2. Adicionar uma entrada em `CHECKS` (`app/checks.py`) com esse `id`,
   um `titulo` e o tipo de exibição:
   - `Exibicao.TABELA` — qualquer resultado, mostrado como tabela genérica.
   - `Exibicao.CARDS` — query deve retornar colunas `PARAMETRO`, `ESPERADO`,
     `ATUAL`; cada linha vira um card verde (bate) ou vermelho (diverge).

Não precisa mexer em rota nem template — o dashboard já itera sobre
`CHECKS` sozinho.

## Pendências conhecidas (próximos passos)

- [ ] Colar as queries reais de `NIVEL_PERSONALIZACAO` e `parametros`
      (hoje são placeholders) em `app/db/queries/`.
- [ ] Definir se o `credentials.json` deve ser removido/expirado após uso,
      e se o volume deve ser montado `ro` ou `rw` para permitir isso.
- [ ] Autenticação da URL da sessão (hoje qualquer um com o link acessa —
      avaliar token de uso único ou expiração por tempo).
- [ ] Coleta de JStack/JFR (fase 2 — feita pelo `server-tool.sh` no
      momento da geração da sessão, conforme decidido).
