<!-- title: Suítes de teste sob --zjit -->
<!-- labels: area:tests, experiment:zjit, type:research -->
<!-- milestone: Lab · ZJIT -->
## Objetivo

Usar suítes de teste existentes como um detector de bugs de compilação do ZJIT. É o tipo de feedback mais valioso para um JIT novo e quase não custa nada.

## Regras

- `script/zjit_suites.sh` clona versões fixadas do kramdown, do Rouge e do `unicode-display_width` e roda os testes de cada um com:
  1. o interpretador;
  2. `--zjit`;
  3. `--zjit --zjit-call-threshold=1` (compila tudo, o que maximiza a cobertura do JIT).
- Uma falha que só aparece com ZJIT é investigada até virar uma reprodução mínima.
- A suíte do próprio Zat já roda sob `--zjit` no CI (Z-02); esta issue cobre as gems de terceiros.
- Bônus: anotar as falhas de Ractor encontradas nessas gems (`Ractor::IsolationError`) e, quando fizer sentido, abrir issue no repositório de cada gem, citando o Ruby 4.1.

## Critérios de aceitação

- [ ] O script roda as três suítes nos três modos e salva o resumo em `bench/results/suites-<data>.md`
- [ ] Cada falha exclusiva do ZJIT registrada como achado (Z-29)
- [ ] Rodar de novo a cada nova versão do Ruby 4.1 (preview, RC, final)
