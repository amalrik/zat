# Zat — Plano de Engenharia

> Clone em Ruby puro do `mdcat`, com parser de Markdown próprio, e laboratório de medição do **ZJIT** e de **Ractors** no Ruby 4.1.
> Revisado em 2026-10-17. As issues prontas para colar estão em [`docs/issues/`](issues/).

---

## 0. Decisões e evidências

### 0.1 Decisões

| Decisão | Motivo |
|---|---|
| **ZJIT é o alvo; o YJIT é só uma coluna de referência** | O ZJIT é o sucessor do YJIT, e é nele que o feedback tem valor. O YJIT aparece só para responder "o ZJIT já alcançou o YJIT neste código?" |
| **Ruby 4.1** (hoje `4.1.0-preview1` no mise; RC quando sair, costuma ser em dezembro) | Versão alvo do ZJIT. Todo resultado registra o commit exato do Ruby |
| **Parser de Markdown próprio** (`Zat::Markdown`), escrito para poder virar uma gem separada | Nenhuma gem de Markdown em Ruby puro funciona em Ractor (ver 0.2), e o parser vira código Ruby que o próprio projeto controla e o ZJIT pode otimizar |
| **kramdown só em desenvolvimento**, como referência nos testes diferenciais e como ponto de comparação | Ganhamos uma referência de correção sem depender dele no runtime |
| **Sem dependências de runtime** | Rouge e `unicode-display_width` também quebram em Ractor. O realce de Ruby usa o Prism (já vem com o Ruby e funciona em Ractor); o de outras linguagens, um realçador próprio; a largura de exibição, uma tabela própria |
| **Ractors são parte do produto** (modo em lote, `--jobs N`) | Dá uso real tanto para o warm-up do JIT quanto para o paralelismo |

### 0.2 Medições que embasaram as decisões (Ruby 4.0.7, YJIT como substituto do ZJIT, ~9.800 linhas)

| Fase | Interpretador | YJIT | Ganho |
|---|---|---|---|
| Parse do kramdown (GFM) | 0,86–0,95 s | 0,68–0,72 s | ~1,25x (gasto em regex/C) |
| Lexing do Rouge | 1,12 s | 0,60 s | ~1,9x |
| Percorrer a AST (render simulado) | 0,43 s | 0,27 s | ~1,55x |

| Executado dentro de um Ractor (fora do principal) | Resultado |
|---|---|
| `Kramdown::Document.new` | ❌ `Ractor::IsolationError` (`@options` em `Kramdown::Options`) |
| `Rouge::Lexers::Ruby.new`, `Rouge::Lexer.find` | ❌ `Ractor::IsolationError` (`@registry`, `eager_load!`) |
| `Unicode::DisplayWidth.of` | ❌ `Ractor::IsolationError` (`EmojiSupport.recommended`) |
| `Prism.lex` | ✅ |
| `Array#pack("m0")` (base64) | ✅ |
| Construção de strings ANSI em Ruby puro | ✅, mas 4 Ractors ficaram só **~1,9x** mais rápidos que o sequencial numa máquina de 16 núcleos. Primeiro candidato a achado (contenção de alocação/GC) |

Ressalvas: o YJIT não é o ZJIT, e foram poucas execuções. Os números indicam direção, não resultado. O laboratório existe para refazê-los direito.

### 0.3 Ambiente atual

- Ruby instalado: `4.0.7`, compilado **sem ZJIT** (falta `rustc` no build). Resolvido na Z-01.
- `gh` instalado. `hyperfine` ausente, por isso o runner precisa funcionar sem ele.

---

## 1. Escopo: mdcat vs Zat

| Recurso do mdcat | Zat | Milestone |
|---|---|---|
| CommonMark + GFM | **Subconjunto documentado** (ver 1.2), testado contra a spec e contra o kramdown | M1 / M2 |
| Cabeçalhos, ênfase, listas, citações, regra, código inline | Sim | M1 |
| Arquivo(s) e stdin | Sim | M1 |
| Links OSC 8 | Sim, com fallback numerado | M1 |
| Detecção de TTY / sem cor | Sim, incluindo `NO_COLOR` | M1 |
| Realce de sintaxe | Ruby via Prism; outras linguagens via realçador próprio | M2 |
| Tabelas GFM | Sim, com bordas Unicode e alinhamento | M2 |
| Paginação | Sim, via `$PAGER` | M2 |
| Imagens inline (Kitty, iTerm2) | Kitty com PNG; iTerm2 com qualquer formato | M3 |
| Imagens remotas | Fora de escopo | — |
| **Modo em lote com Ractors** (`zat docs/**/*.md --jobs N`) | Novo, não existe no mdcat | Lab · Ractors |

### 1.1 Milestones

- **M0 · Fundação**: toolchain 4.1 com ZJIT, esqueleto, ADR do parser, testes golden e testes diferenciais.
- **M1 · MVP**: parser de blocos e inline, terminal, renderer, listas, wrap e links.
- **M2 · Experiência avançada**: tabelas, realce de sintaxe, temas e paginação.
- **M3 · Protocolos modernos**: imagens Kitty e iTerm2, com fallback e regras de segurança.
- **Lab · ZJIT**: começa assim que existirem parser e renderer básico (Z-07, Z-08 e Z-10).
- **Lab · Ractors**: começa junto com o Lab ZJIT. A garantia de Ractor-safety (Z-31) entra no CI **já no M1**, para nada "pegar" estado global sem ninguém notar.

### 1.2 Subconjunto do Markdown suportado

**Dentro, na v1:**

- Blocos: ATX e setext headings, parágrafos, quebras de linha (dois espaços e `\`), thematic breaks, block quotes (aninhados), listas ordenadas e não ordenadas (tight/loose, aninhadas), fenced code (` ``` ` e `~~~`, com info string), indented code.
- Inline: escapes com backslash, entidades HTML, code spans, ênfase e negrito (pelo algoritmo de *delimiter run* da spec), links e imagens inline, autolinks.
- GFM: tabelas, strikethrough, task lists e autolinks estendidos (`www.`, `https://`).

**Fora, ou adiado** (registrado em `docs/known-differences.md`):

- reference links e definições (candidato para a v1.1);
- blocos HTML (viram texto esmaecido, nunca são interpretados);
- footnotes e lazy continuation em casos raros.

### 1.3 Arquitetura

```
exe/zat                         Zat::CLI.start(ARGV)
lib/zat.rb
lib/zat/markdown.rb             ┐ Zat::Markdown: o futuro gem.
lib/zat/markdown/node.rb        │  NÃO depende de nada em Zat::*.
lib/zat/markdown/block_parser.rb│  Data.define para nós, constantes
lib/zat/markdown/inline_parser.rb│ congeladas, nenhum estado de classe.
lib/zat/markdown/entities.rb    ┘  API: Zat::Markdown.parse(str) → Node
lib/zat/cli.rb                  Zat::CLI       opções, entradas, pager, --jobs
lib/zat/batch.rb                Zat::Batch     distribui arquivos entre Ractors
lib/zat/terminal.rb             Zat::Terminal  tty, colunas, cor, imagens
lib/zat/style.rb / theme.rb     Zat::Style / Zat::Theme (Data, shareable)
lib/zat/width.rb                Zat::Width     tabela de largura própria
lib/zat/text.rb                 Zat::Text      wrap ciente de ANSI
lib/zat/renderer.rb             Zat::Renderer  AST → buffer
lib/zat/table.rb                Zat::Table     layout de tabelas
lib/zat/highlight.rb            Zat::Highlight Prism (Ruby) + realçador próprio
lib/zat/image.rb                Zat::Image     Kitty / iTerm2
```

**Regras de Ractor-safety** (verificadas pela Z-31):

- toda constante é `Ractor.make_shareable` ou literal congelado;
- nenhuma variável de instância de classe ou módulo é escrita depois do boot;
- nenhum cache preguiçoso global; cache só por instância;
- `Terminal` e `Theme` são resolvidos no Ractor principal e passados prontos (shareable) aos workers.

**Regras de estilo para o JIT, sem distorcer o código:**

- código **idiomático primeiro**; variantes "pensadas para o JIT" vivem só nos microbenchmarks (Z-27);
- um buffer de saída por documento (`String.new(capacity:)` com `<<`);
- despacho com `case node.type`;
- o parser decide conscientemente onde usar `StringScanner`/regex e onde varrer bytes, e os dois estilos são comparados (Z-27).

**Extração futura da gem:** `Zat::Markdown` tem testes próprios em `test/markdown/` e não conhece o terminal. Extrair significa mover `lib/zat/markdown*` e `test/markdown/` e renomear o namespace.

---

## 2. Laboratório ZJIT

### 2.1 Matriz de execução

| ID | Comando | Papel |
|---|---|---|
| `interp` | `ruby exe/zat` | Linha de base |
| `zjit` | `ruby --zjit exe/zat` | **Alvo** |
| `zjit-t1` | `ruby --zjit --zjit-call-threshold=1` | Isola o custo de compilação |
| `zjit-stats` | `ruby --zjit --zjit-stats` | Só para estatísticas, nunca para medir tempo |
| `yjit` | `ruby --yjit exe/zat` | Referência ("o ZJIT já alcançou?") |

Os nomes exatos das flags `--zjit-*` são confirmados na Z-01 e ficam só em `bench/config.rb`.

### 2.2 Cenários

**A · Warm-up e overhead de compilação**

- *Frio:* um processo por execução, N=30, por arquivo e tamanho. É o uso real do CLI.
- *Quente:* o mesmo documento renderizado K=200 vezes no mesmo processo, com o tempo de cada iteração.
- *Em lote:* `zat corpus/*.md`, o uso real que justifica o modo quente.
- Métricas:
  - iteração de estabilização (coeficiente de variação < 3% numa janela de 10);
  - tempo até estabilizar;
  - custo do warm-up;
  - **break-even** contra o `interp` (iteração e número de arquivos no modo em lote).
- `--zjit-stats` cruzado com a curva: tempo de compilação, ISEQs compiladas e side exits.

**B · Strings e travessia da AST**

- Corpus sintético determinístico em quatro perfis (`prose`, `code-heavy`, `table-heavy`, `mixed`) e três tamanhos (1k, 10k e 100k linhas), mais um corpus real fixado por hash.
- Medição por fase:
  - **block parse**;
  - **inline parse**;
  - **highlight**;
  - **render**;
  - **write**.
- Métricas de memória por fase:
  - tempo;
  - objetos alocados;
  - `malloc_increase_bytes`;
  - quantidade de GC minor e major;
  - `GC.stat(:time)`;
  - RSS de pico.
- Normalizações: objetos por linha de entrada; bytes de saída por milissegundo.

**C · Comparativos automatizados**

- `rake bench` roda a matriz × corpus × modo e grava `bench/results/<data>-<commit-ruby>/` com `raw.jsonl`, `summary.csv`, `REPORT.md` e `env.json`.
- Cada célula: mediana, p95, desvio e ganho sobre o `interp` com IC 95% por bootstrap.
- **Parser próprio × kramdown**, com o mesmo corpus e a mesma matriz: "parser idiomático escrito para 4.1" contra "parser de gem popular".

**D · Correção do ZJIT** (barato e o feedback mais valioso)

- A suíte do Zat roda no CI com `--zjit` e `--zjit-call-threshold=1`.
- As suítes do kramdown e do Rouge rodam com `--zjit`. Uma falha que não acontece no interpretador é candidata a bug de compilação.

### 2.3 Microbenchmarks (Z-27)

| Nome | Pergunta |
|---|---|
| `scan_style` | Parser de blocos com `StringScanner`+regex × varredura com `getbyte`/`byteindex` |
| `delimiters` | Algoritmo de delimitadores de ênfase: arrays de structs × `Data` × hashes |
| `width` | Tabela própria com `bsearch` × `case` com ranges |
| `wrap` | `each_char` × índice + `getbyte` |
| `buffer` | `<<` × interpolação × `Array#join` × `StringIO` |
| `dispatch` | `case/when` × `send` × Hash de lambdas × uma classe por nó |
| `sgr` | Montagem na hora × cache congelado |
| `kramdown_parse` | Controle negativo: ganho baixo esperado (regex) |

---

## 3. Laboratório Ractors

| Cenário | Medição |
|---|---|
| **Escala** | `zat --jobs N` para N ∈ {1, 2, 4, 8, 16} sobre 64 arquivos `mixed-1k`, com `interp` e `zjit`: tempo total, ganho, eficiência (ganho/N) |
| **Contenção** | Mesmos cenários com `GC.stat` por Ractor e global; perfis com mais e menos alocação para separar CPU de alocação |
| **ZJIT × Ractors** | O ganho do ZJIT se mantém com N Ractors? O código compilado é compartilhado ou o warm-up se repete por Ractor? |
| **Custo de comunicação** | Passar o caminho do arquivo e ler no worker × passar o conteúdo; devolver a string renderizada (cópia × `move: true`) |

A hipótese inicial, vinda da medição de 0.2, é que alocar strings não escala de forma linear entre Ractors. Se a hipótese se confirmar no 4.1, o achado é reportado com uma reprodução mínima fora do Zat.

---

## 4. GitHub: labels, milestones e Projects

### 4.1 Milestones

| Milestone | Issues |
|---|---|
| `M0 · Fundação` | Z-01 – Z-05 |
| `M1 · MVP` | Z-06 – Z-13 |
| `M2 · Experiência avançada` | Z-14 – Z-17 |
| `M3 · Protocolos modernos` | Z-18 – Z-21 |
| `Lab · ZJIT` | Z-22 – Z-29 |
| `Lab · Ractors` | Z-30 – Z-32 |

### 4.2 Labels

| Label | Cor | Uso |
|---|---|---|
| `milestone:setup` `milestone:mvp` `milestone:advanced` `milestone:protocols` | `#0E8A16` | Espelham os milestones |
| `area:cli` `area:parser` `area:renderer` `area:terminal` `area:text` `area:tables` `area:syntax` `area:images` | `#1D76DB` | Componente |
| `area:infra` `area:tests` `area:performance` | `#5319E7` | Transversal |
| `experiment:zjit` | `#D93F0B` | Gera ou consome dados do ZJIT |
| `experiment:ractor` | `#E99695` | Gera ou consome dados de Ractor |
| `zjit:hot-path` | `#FBCA04` | Código que aparece no perfil; mudanças pedem `rake bench:quick` |
| `ractor-safety` | `#F9D0C4` | Toca em constantes ou estado compartilhado |
| `gem:markdown` | `#BFDADC` | Código do futuro gem `Zat::Markdown` |
| `type:feature` `type:chore` `type:research` | `#C5DEF5` | Natureza da issue |
| `blocked` | `#B60205` | Dependência externa |

### 4.3 GitHub Projects

Um Project (v2) **"Zat"** com estes campos:

| Campo | Tipo | Valores |
|---|---|---|
| Status | Single select | `Backlog` · `Ready` · `In progress` · `In review` · `Done` |
| Trilha | Single select | `Produto` · `Parser` · `Lab ZJIT` · `Lab Ractors` |
| Tamanho | Single select | `S` (≤½ dia) · `M` (1–2 dias) · `L` (3+ dias) |
| Impacto JIT | Single select | `Hot path` · `Neutro` · `N/A` |
| Iteração | Iteration | 2 semanas |
| Depende de | Text | `Z-xx` |

Views:

1. **Kanban:** board por `Status`, com swimlanes por `Trilha`.
2. **Por milestone:** tabela agrupada por milestone, ordenada por ID.
3. **Linha do tempo:** roadmap por `Iteração`. Os labs correm em paralelo a partir do fim do M1.
4. **Achados:** tabela filtrada por `experiment:zjit` ou `experiment:ractor`, com o campo "Último resultado" (link para `bench/results/...`).

Automações: item novo → `Backlog`; PR vinculado → `In review`; issue fechada → `Done`.

### 4.4 Caminho crítico

```
Z-01 ─┬─ Z-02 ─┬─ Z-03 ─ Z-07 ─ Z-08 ─┬─ Z-10 ─┬─ Z-11 ─ … M1
      │        ├─ Z-04 ────────────────┤        └─ Z-12 ─ Z-14 (tabelas)
      │        ├─ Z-05 (diferencial) ──┘
      │        └─ Z-06, Z-09
      │                      Z-31 (Ractor-safety no CI desde o M1)
      ├─ Z-28 (suítes de gems sob --zjit: pode começar já)
      └────────────── Z-22 ─ Z-23 ─┬─ Z-24, Z-25 ─ Z-26 ─ Z-29
                                   └─ Z-30 ─ Z-32
```

A Z-28 não depende de nada do Zat além do toolchain. Ela pode render o primeiro feedback para o ZJIT antes mesmo de o parser existir.

---

## 5. Lista de issues

Cada arquivo em `docs/issues/` traz o corpo da issue. As linhas de metadados em comentário HTML ficam invisíveis no GitHub e são lidas por `script/bootstrap_github.rb`.

| ID | Título | Milestone |
|---|---|---|
| Z-01 | Toolchain: Ruby 4.1 com ZJIT | M0 |
| Z-02 | Esqueleto do projeto, Gemfile e CI | M0 |
| Z-03 | ADR: parser próprio e regras de Ractor-safety | M0 |
| Z-04 | Testes golden de saída ANSI | M0 |
| Z-05 | Testes de conformidade e diferenciais do parser | M0 |
| Z-06 | CLI: entrada por arquivo e stdin | M1 |
| Z-07 | Parser de blocos | M1 |
| Z-08 | Parser inline | M1 |
| Z-09 | Terminal, Style e Theme | M1 |
| Z-10 | Renderer: blocos e inline básicos | M1 |
| Z-11 | Listas e task lists | M1 |
| Z-12 | Largura de exibição e quebra de linha | M1 |
| Z-13 | Links com OSC 8 e fallback | M1 |
| Z-14 | Tabelas GFM com bordas Unicode | M2 |
| Z-15 | Realce de sintaxe: Prism + realçador próprio | M2 |
| Z-16 | Temas claro e escuro | M2 |
| Z-17 | Paginação via $PAGER | M2 |
| Z-18 | Detecção de protocolo de imagem | M3 |
| Z-19 | Imagens via Kitty graphics protocol | M3 |
| Z-20 | Imagens via iTerm2 inline images | M3 |
| Z-21 | Imagens: fallback e segurança | M3 |
| Z-22 | Gerador de corpus de benchmark | Lab ZJIT |
| Z-23 | Harness de warm-up in-process | Lab ZJIT |
| Z-24 | Métricas de memória e alocação por fase | Lab ZJIT |
| Z-25 | Coleta de estatísticas do ZJIT | Lab ZJIT |
| Z-26 | Runner comparativo | Lab ZJIT |
| Z-27 | Microbenchmarks de hot paths | Lab ZJIT |
| Z-28 | Suítes de teste sob --zjit | Lab ZJIT |
| Z-29 | Relatório e template de feedback upstream | Lab ZJIT |
| Z-30 | Modo em lote com Ractors (--jobs) | Lab Ractors |
| Z-31 | Ractor-safety garantida no CI | Lab Ractors |
| Z-32 | Benchmark de escala e contenção de Ractors | Lab Ractors |

Como criar: `ruby script/bootstrap_github.rb` mostra o que seria feito (dry-run); `--apply` executa.
