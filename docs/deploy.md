# Deploy por botão

O workflow **Deploy de produção** gera a imagem no GitHub, publica no GHCR e atualiza a aplicação em um runner instalado **no próprio servidor de produção**. Não depende de SSH acessível pela internet. Não executa deploy em push ou PR.

## Preparação única

1. Integre este PR à `main`. O botão só aparece quando o workflow estiver na branch padrão.
2. No Oracle Linux, confirme `uname -m` (esperado: `x86_64`), `docker info` e `docker compose version`. O plugin Compose precisa suportar `up --wait --wait-timeout` e `bind.create_host_path`.
3. Em **Settings → Actions → Runners → New self-hosted runner**, selecione Linux x64. Execute os comandos e a verificação de checksum apresentados pelo GitHub usando um usuário dedicado, sem executar o runner como root. Adicione a label `analise-producao`. No diretório do runner, instale o serviço conforme as instruções do GitHub: `sudo ./svc.sh install USUARIO` e `sudo ./svc.sh start`.
4. O usuário do runner precisa acessar Docker e ler o `.env` existente. Acesso ao Docker equivale a acesso administrativo ao host: restrinja quem pode modificar e executar workflows. Não execute jobs de PR nesse runner. Em repositório público, prefira executor isolado e revise as restrições antes de conectá-lo à produção.
5. Crie o environment **production**, restrinja a branch de deploy a `main` e cadastre estas **variables**:

| Variável | Valor |
| --- | --- |
| `PROD_ENV_FILE` | Caminho absoluto do `.env` já usado em produção |
| `PROD_DATA_DIR` | Caminho absoluto dos dados já montados em `/app/data` |
| `COMPOSE_PROJECT_NAME` | Nome do projeto Compose que controla o container atual |

Consulte o projeto real (não deduza pelo nome do container):

```bash
docker inspect --format '{{index .Config.Labels "com.docker.compose.project"}}' analise-ambiente
```

Consulte os volumes com `docker inspect analise-ambiente --format '{{json .Mounts}}'`. Localize o `.env` no diretório do Compose atualmente usado. Não envie segredos ao GitHub. Preserve as permissões e os rótulos SELinux que já permitem ao container ler os dados; não desative o SELinux.

O `401` no endpoint do GHCR comprova acesso ao endpoint, mas não download de camadas. Libere os destinos de GitHub Actions e armazenamento de imagens conforme a documentação oficial. O workflow baixa a imagem antes de alterar o container. A autenticação usa `GITHUB_TOKEN`; caso o pacote já exista, conceda ao repositório acesso em **Package settings → Manage Actions access**.

## Publicar e instalar

Depois de integrar e testar a implementação na `main`, crie uma tag nova:

```bash
git switch main
git pull --ff-only
git tag v1.0.0
git push origin v1.0.0
```

No GitHub: **Actions → Deploy de produção → Run workflow**. Selecione **main** e informe `v1.0.0`. Só são aceitas tags `vX.Y.Z` cujo commit pertença ao histórico da `main`.

Cada execução publica uma imagem identificada por versão e execução. O deploy usa seu digest exato, registrado no resumo do workflow. Mantém a porta 8590 e os dados e `.env` no host. Existe uma breve interrupção durante a recriação do container.

O teste `/health` valida que a aplicação responde, não a conectividade com todos os bancos de clientes. Valide o dashboard após o primeiro deploy.

## Falhas e retorno

Falhas de build ou download não alteram o container atual. Se a atualização ou saúde falhar, o script tenta restaurar o ID local da imagem anterior e retorna erro no workflow. Não remove imagens antigas. O retorno usa a configuração Compose nova e não desfaz mudanças de dados. Cancelamento forçado, falha do host ou falha no rollback exigem intervenção manual.

Para restaurar exatamente uma imagem publicada, use seu digest do resumo, em um checkout confiável desta configuração no servidor (requer login no GHCR para imagens privadas):

```bash
export APP_IMAGE='ghcr.io/arthur-calixto/analise-ambiente-skw@sha256:DIGEST_DO_RESUMO'
export PROD_ENV_FILE='/caminho/real/.env'
export PROD_DATA_DIR='/caminho/real/data'
export COMPOSE_PROJECT_NAME='nome-real-do-projeto'
bash scripts/deploy.sh
```

Executar o botão com uma tag antiga faz um novo build; dependências externas podem ter mudado. Use o digest para retorno exato.

O Compose de desenvolvimento permanece separado. O `analise.tar` existente permanece no histórico, mas não é usado neste fluxo nem enviado no contexto de build.

## Referências

- [Instalar runner](https://docs.github.com/en/actions/how-tos/manage-runners/self-hosted-runners/add-runners)
- [Sistemas e rede necessários](https://docs.github.com/en/actions/reference/runners/self-hosted-runners)
- [Registro e permissões](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)
- [Compose e verificação de saúde](https://docs.docker.com/reference/cli/docker/compose/up/)
