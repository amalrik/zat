<!-- title: Gerador de corpus de benchmark -->
<!-- labels: area:performance, experiment:zjit, experiment:ractor, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Entradas de benchmark reproduzíveis bit a bit, grandes e com perfis variados.

## Regras

- `bench/corpus/generate.rb --profile P --lines N --seed S` gera um corpus determinístico.
- Perfis:
  - `prose`: parágrafos longos com ênfase, links e code spans;
  - `code-heavy`: cerca de 60% de blocos de código, em várias linguagens;
  - `table-heavy`: tabelas de 3 a 12 colunas e de 5 a 200 linhas, com inline;
  - `mixed`: proporções de um README real;
  - `pathological`: casos difíceis para o algoritmo de delimitadores e para o aninhamento.
- Tamanhos: 1k, 10k e 100k linhas. Para o lab de Ractors, também 64 arquivos `mixed-1k`.
- Os arquivos gerados não são versionados. O `bench/corpus/MANIFEST` registra perfil, linhas, semente e SHA-256 de cada um.
- Corpus real em `bench/corpus/real/`, baixado com hash verificado: `NEWS.md` do Ruby, um Rails Guide e o README do mdcat.
- Os textos incluem uma fração de caracteres não-ASCII.

## Critérios de aceitação

- [ ] A mesma semente produz o mesmo SHA-256
- [ ] `rake bench:corpus` gera os arquivos e valida o MANIFEST
- [ ] Todos os perfis renderizam sem erro em `interp` e `zjit`
- [ ] Estatísticas de cada arquivo registradas
