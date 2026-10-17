<!-- title: Toolchain: Ruby 4.1 com ZJIT -->
<!-- labels: milestone:setup, area:infra, experiment:zjit, type:chore -->
<!-- milestone: M0 · Fundação -->
## Objetivo

Ter o Ruby 4.1 **compilado com ZJIT**, reproduzível por qualquer pessoa que clonar o repositório.

## Contexto

- O Ruby atual da máquina (`4.0.7`) foi compilado sem ZJIT (`ruby: warning: Ruby was built without ZJIT support. You may need to install rustc`). O ZJIT é escrito em Rust e só entra no build se o `rustc` estiver presente no `configure`.
- Hoje o mise oferece `4.1.0-preview1` e `4.1-dev`. O RC deve sair perto de dezembro; quando sair, trocamos para ele.

## Regras

- Versão fixada em `mise.toml`, com o commit exato do Ruby registrado em `docs/toolchain.md`.
- O build também precisa ter YJIT, que é a coluna de referência.
- Sem flags de compilação exóticas.
- Toda troca de versão do Ruby gera uma nova linha de base de benchmark (Z-26).

## Critérios de aceitação

- [ ] `rustc` instalado na versão mínima exigida pelo Ruby alvo, documentada
- [ ] Ruby 4.1 instalado via mise com ZJIT; passo a passo em `docs/toolchain.md`
- [ ] `ruby --zjit -e 'p RubyVM::ZJIT.enabled?'` imprime `true`
- [ ] `ruby --yjit -e 'p RubyVM::YJIT.enabled?'` imprime `true`
- [ ] Flags reais copiadas de `ruby --help` (`--zjit-*`) para `docs/toolchain.md`
- [ ] API documentada: `RubyVM::ZJIT.methods(false)` e o formato das stats
- [ ] Ractors: confirmar a API do 4.1 (`Ractor#value`, `Ractor::Port`, `Ractor.make_shareable`) e registrar se o aviso "experimental" ainda aparece
