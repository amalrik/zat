<!-- title: Relatório e template de feedback upstream -->
<!-- labels: area:performance, experiment:zjit, experiment:ractor, type:chore -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Transformar os resultados em relatos reproduzíveis e úteis para os mantenedores do Ruby (ZJIT e Ractors).

## Regras

- `docs/zjit-findings.md` é o registro cumulativo de achados, em ordem cronológica.
- Template em `.github/ISSUE_TEMPLATE/finding.md`:

  ```markdown
  ### Resumo
  <uma frase: o que acontece, em qual configuração (ZJIT / Ractor)>

  ### Ambiente
  - ruby -v / commit:
  - CPU / governor / kernel:
  - commit do Zat:

  ### Reprodução
  1. corpus (seed, SHA-256):
  2. comando exato:

  ### Resultado
  | config | mediana | p95 | ganho vs interp |
  |---|---|---|---|

  ### Stats
  <trecho de --zjit-stats ou GC.stat por Ractor>

  ### Hipótese
  <separada dos fatos acima>

  ### Reprodução mínima
  <script independente do Zat>
  ```

- Um achado só vai para o upstream quando:
  1. reproduz em duas execuções, em dias diferentes ou em máquinas diferentes;
  2. existe uma reprodução mínima fora do Zat;
  3. não há issue equivalente aberta no tracker do Ruby.
- Classificação de cada achado: `crash/miscompile` > `regressão` > `desempenho abaixo do YJIT` > `observação`.

## Critérios de aceitação

- [ ] Template criado
- [ ] Primeiro relatório de linha de base (M1 completo × matriz) publicado em `docs/zjit-findings.md`
- [ ] Processo descrito em `bench/README.md`
