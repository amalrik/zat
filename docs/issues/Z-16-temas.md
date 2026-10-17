<!-- title: Temas claro e escuro -->
<!-- labels: milestone:advanced, area:terminal, type:feature -->
<!-- milestone: M2 · Experiência avançada -->
## Objetivo

Temas legíveis em fundo escuro e em fundo claro, cobrindo texto e código.

## Regras

- Seleção com `--theme dark|light` ou `ZAT_THEME`; o padrão é `dark`. Se `COLORFGBG` existir, o tema é detectado por ele.
- Cada `Theme` é um `Data` congelado que define a paleta do texto e as categorias de token da Z-15.
- Temas são dados, não subclasses.

## Critérios de aceitação

- [ ] Um teste falha se algum tema não tiver uma chave usada pelo renderer ou pelo realce
- [ ] Contraste ≥ 4.5 do texto normal contra o fundo assumido
- [ ] Goldens para os dois temas
