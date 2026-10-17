<!-- title: ADR: parser próprio e regras de Ractor-safety -->
<!-- labels: milestone:setup, area:parser, gem:markdown, ractor-safety, type:research -->
<!-- milestone: M0 · Fundação -->
## Objetivo

Registrar em `docs/adr/0001-parser-proprio.md` por que o Zat tem um parser de Markdown próprio e as regras que ele segue.

## Contexto (medido em 2026-10-17, Ruby 4.0.7)

- Em Ractor: kramdown, Rouge e unicode-display_width falham com `Ractor::IsolationError` por manterem estado mutável na classe. O Prism e `pack("m0")` funcionam.
- Com YJIT, o parse do kramdown ganhou só ~1,25x, porque o tempo é dominado por regex no Onigmo.
- Gems nativas (`commonmarker`, `redcarpet`) estão descartadas porque o projeto é Ruby puro.

## Decisões a registrar

1. `Zat::Markdown` é um parser próprio em duas fases (blocos, depois inline), no modelo da spec do CommonMark.
2. Subconjunto suportado e diferenças conhecidas (ver PLANEJAMENTO §1.2), mantidos em `docs/known-differences.md`.
3. **AST:** nós `Data.define` (`type`, `children`, atributos), imutáveis após o parse e shareable.
4. **Ractor-safety:**
   - constantes congeladas ou `make_shareable`;
   - nenhuma variável de instância de classe escrita após o load;
   - nenhum cache global.
5. **Independência:** `Zat::Markdown` não referencia nada de `Zat::` fora do próprio namespace, o que prepara a extração para gem.
6. **Escaneamento:** idiomático por padrão (`StringScanner` onde clarifica); variantes por bytes ficam nos microbenchmarks até os números justificarem a troca.
7. **kramdown** é dependência de desenvolvimento, usada como referência e ponto de comparação.

## Critérios de aceitação

- [ ] ADR escrito com contexto, decisão, alternativas e consequências
- [ ] Tipos de nó e seus atributos listados
- [ ] `script/dump_ast.rb arquivo.md` imprime a AST do Zat (e a do kramdown com `--kramdown`)
