<!-- title: Realce de sintaxe: Prism + realçador próprio -->
<!-- labels: milestone:advanced, area:syntax, zjit:hot-path, experiment:zjit, ractor-safety, type:feature -->
<!-- milestone: M2 · Experiência avançada -->
## Objetivo

Realce de sintaxe colorido nos blocos de código, sem o Rouge (que falha em Ractor) e sem dependências de runtime.

## Regras

- **Ruby:** usa `Prism.lex` (já vem com o Ruby e funciona em Ractor). Cada tipo de token é mapeado para uma categoria (`keyword`, `string`, `comment`, `constant`, `number`, `ivar`…).
- **Outras linguagens:** `Zat::Highlight::Lexer`, um lexer genérico dirigido por tabela. Cada linguagem é um `Data` congelado com:
  - palavras-chave;
  - delimitadores de string;
  - comentários de linha e de bloco;
  - padrão de números.
- **Linguagens na v1:** ruby, shell, json, yaml, javascript, python, rust, c, diff e markdown.
- Linguagem desconhecida, ou bloco sem info string: texto puro, sem tentar adivinhar.
- **Painel:**
  - margem `│` e o nome da linguagem na primeira linha;
  - linhas longas truncadas com `…` (a opção `--wrap-code` quebra em vez de truncar);
  - tabs viram 4 espaços.
- O realce é uma fase separada no harness (Z-23).

## Critérios de aceitação

- [ ] Fixtures por linguagem, nas profundidades `:truecolor`, `:ansi256`, `:ansi16` e `:none`
- [ ] Ruby com heredoc, interpolação e `%w[]` realçado corretamente pelo Prism
- [ ] Bloco de 5.000 linhas com tempo linear
- [ ] Funciona dentro de um Ractor
