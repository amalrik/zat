<!-- title: Testes de conformidade e diferenciais do parser -->
<!-- labels: milestone:setup, area:parser, area:tests, gem:markdown, type:feature -->
<!-- milestone: M0 · Fundação -->
## Objetivo

Garantir que o parser próprio está correto, usando a spec do CommonMark/GFM e o kramdown como referências.

## Regras

- **Conformidade:** os exemplos da spec do CommonMark e da extensão GFM (JSON oficial, versionado com hash) são carregados como testes. Cada exemplo é marcado `:pass`, `:known_difference` (com justificativa) ou `:out_of_scope`. A comparação é estrutural, por AST normalizada, e não pelo HTML gerado.
- **Diferencial:** o mesmo documento passa pelo `Zat::Markdown` e pelo kramdown-GFM; as duas ASTs são normalizadas para uma forma comum (tipos e texto) e comparadas. Roda sobre o corpus (Z-22) e sobre documentos aleatórios com semente.
- Toda divergência é um bug do Zat, uma diferença conhecida ou uma diferença do kramdown em relação à spec. Esta última é documentada e não é bug nosso.
- `rake spec:report` mostra a porcentagem de exemplos da spec que passam, por seção.

## Critérios de aceitação

- [ ] Loader dos exemplos da spec com status por exemplo
- [ ] Normalizador de AST para o Zat e para o kramdown
- [ ] Teste diferencial com corpus e geração aleatória com semente
- [ ] Relatório de conformidade por seção da spec
- [ ] Meta da v1: 100% em `:pass` nas seções do subconjunto suportado
