<!-- title: Esqueleto do projeto, Gemfile e CI -->
<!-- labels: milestone:setup, area:infra, type:chore -->
<!-- milestone: M0 · Fundação -->
## Objetivo

Montar a estrutura mínima do projeto: executável, biblioteca, testes, Rake e CI.

## Estrutura

```
exe/zat
lib/zat.rb  lib/zat/version.rb  lib/zat/markdown.rb
test/test_helper.rb  test/markdown/  test/zat/
Gemfile  zat.gemspec  Rakefile  mise.toml
.github/workflows/ci.yml
```

## Regras

- **Zero dependências de runtime.** Tudo vem da biblioteca padrão e das default gems (Prism incluído).
- Dependências de desenvolvimento: `minitest`, `rake` e `kramdown` + `kramdown-parser-gfm` (só para os testes diferenciais e comparações).
- `# frozen_string_literal: true` em todos os arquivos.
- `test/markdown/` só testa `Zat::Markdown`, sem carregar o resto do Zat. Isso prepara a extração para uma gem.

## Critérios de aceitação

- [ ] `exe/zat --version` funciona
- [ ] `rake test` passa
- [ ] `rake test:markdown` roda isolado (`require "zat/markdown"` sem carregar `zat`)
- [ ] CI com matriz Ruby 4.1 × `RUBYOPT` ∈ {vazio, `--zjit`, `--zjit --zjit-call-threshold=1`}
- [ ] O gemspec declara `add_dependency` vazio e um teste garante isso
- [ ] README mínimo
