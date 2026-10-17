<!-- title: Coleta de estatísticas do ZJIT -->
<!-- labels: area:performance, experiment:zjit, type:feature -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Registrar o que o ZJIT fez: o que compilou, quanto tempo levou e onde saiu do código compilado.

## Regras

- Execução dedicada com `--zjit-stats`, sempre separada das execuções que medem tempo.
- Ao fim, grava o snapshot de `RubyVM::ZJIT.stats` em JSON. Se essa API não existir no build, captura a saída que o Ruby imprime ao sair.
- Interessam principalmente:
  - o tempo total de compilação;
  - o número de ISEQs compiladas;
  - os side exits por motivo;
  - o tamanho do código gerado;
  - as instruções não suportadas.
- Variações de `--zjit-call-threshold`: 1, padrão e alto.
- `--yjit-stats` só na tabela de referência, com as métricas equivalentes.

## Critérios de aceitação

- [ ] `rake bench:stats[corpus]` gera `stats-zjit.json`
- [ ] Os 10 principais motivos de side exit no `mixed-10k`, cada um mapeado ao método Ruby do Zat que o causa
- [ ] Para cada um desses 10: é limitação conhecida do ZJIT, padrão de código nosso que vale mudar ou candidato a reporte?
