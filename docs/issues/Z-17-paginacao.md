<!-- title: Paginação via $PAGER -->
<!-- labels: milestone:advanced, area:cli, type:feature -->
<!-- milestone: M2 · Experiência avançada -->
## Objetivo

Equivalente ao `mdless`: abrir a saída num pager.

## Regras

- `-p/--paginate` força o pager; `-P/--no-pager` desliga.
- Usa `$PAGER` se estiver definido; senão, `less -R`. Garante que `R` esteja em `$LESS`.
- Só pagina quando a saída é um TTY. Se o pager não existir, avisa no stderr e escreve direto.

## Critérios de aceitação

- [ ] `zat -p README.md` abre no less com cores
- [ ] Sair cedo do pager não gera stack trace
- [ ] `PAGER=cat` funciona
- [ ] Teste com um pager falso
