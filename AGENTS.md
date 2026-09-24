# Fluxo padrão de versionamento

Estas instruções orientam o agente nas implementações deste projeto.

- Manter `main` como versão estável. Realizar implementações em branches curtas, uma por funcionalidade ou correção; mudanças do mesmo objetivo podem compartilhar a branch.
- Antes de iniciar, verificar a branch atual e as alterações locais. Preservar o trabalho existente, sem descartar arquivos ou sobrescrever ajustes do usuário.
- Para uma nova implementação, com a árvore de trabalho limpa, atualizar `main` com `git pull --ff-only` e criar a branch. Se houver trabalho pendente ou divergência, preservar e avaliar o estado antes de prosseguir.
- Usar nomes descritivos: `feat/<funcionalidade>`, `fix/<correcao>` ou `docs/<assunto>`. Não criar uma branch `develop` sem necessidade acordada.
- O agente deve executar esse fluxo como parte do trabalho solicitado, sem pedir novamente ao usuário que escolha entre branch e `main`.
- Criar commits pequenos e coerentes por objetivo, com mensagens claras. Revisar os arquivos incluídos; não adicionar credenciais ou arquivos alheios à implementação.
- Executar as verificações adequadas à mudança antes de concluir.
- Enviar a branch com `git push -u origin <branch>` e abrir um Pull Request quando houver acesso e autenticação disponíveis. Se houver bloqueio, informar o que foi concluído e o que falta.
- Revisar e testar antes do merge para `main`. Fazer merge e publicação em produção quando solicitados pelo usuário.
- Identificar versões de produção com tags como `v1.0.0` e `v1.1.0`, quando uma versão for publicada.
