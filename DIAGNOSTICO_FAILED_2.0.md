# Diagnóstico de falha ao aplicar patch

Esta cópia foi alterada para não esconder erros de aplicação atrás de apenas `Failed`.

Alterações:
- `PatchTransaction.atomicWrite` informa etapa, caminho e `errno` em falhas de `createFile` e `rename`.
- Erros de `FileHandle`/`synchronize` preservam domínio, código e descrição original.
- O `apply()` preserva o erro original mesmo depois de tentar rollback.
- O alerta da interface pode exibir uma mensagem literal detalhada.

Ao testar um patch, copie a mensagem completa exibida no alerta. Ela deve indicar a causa real, como `Permission denied`, `Operation not permitted`, caminho inexistente etc.
