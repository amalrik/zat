<!-- title: Ractor-safety garantida no CI -->
<!-- labels: area:tests, ractor-safety, experiment:ractor, type:chore -->
<!-- milestone: Lab · Ractors -->
## Objetivo

Impedir que algum código passe a depender de estado global sem ninguém perceber. Esta guarda entra **no M1**, não depois.

## Regras

- Teste `test/ractor_safety_test.rb` que:
  1. roda o pipeline completo (parse, render, realce e tabela) dentro de um `Ractor.new` sobre todas as fixtures golden;
  2. compara com a saída do Ractor principal;
  3. verifica `Ractor.shareable?` em todas as constantes de `Zat::` (percorrendo `constants` recursivamente).
- Lint simples (`rake check:ractor`) que procura escritas em variáveis de instância de classe (`@x ||=` em `self.`/`class << self`) dentro de `lib/`.
- Roda no CI com e sem `--zjit`.

## Critérios de aceitação

- [ ] O teste passa e falha de propósito quando alguém introduz um cache em variável de instância de classe (teste do próprio teste)
- [ ] O lint está integrado ao `rake test`
- [ ] Documentado em `CONTRIBUTING.md`
