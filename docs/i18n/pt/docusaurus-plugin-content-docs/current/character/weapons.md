---
title: Armas
---

Há vários tipos diferentes de armas disponíveis para usar no servidor, mais
do que o jogo original. As armas são divididas em categorias: Armas corpo a corpo e
Armas de fogo.

As armas também podem ser classificadas pelas suas áreas de spawn mais comuns,
armas corpo a corpo e armas de fogo podem ser encontradas em áreas civis, mas de grau militar ou raras
e armas únicas são mais difíceis de encontrar, geralmente estão em locais de difícil acesso, tais como
bases militares ou pilhagens de sobrevivência em telhados.

Esta página enumera toda a informação, das armas brancas personalizadas e armas de fogo.

## Armas de Fogo

As armas de fogo são o método mais comum e viável de derrubar jogadores hostis
nas terras do servidor. Há um total de 16 armas de fogo utilizáveis no jogo no
momento que vai desde as pistolas de mão até às espingardas de longo alcance.

Cada arma tem um calibre que corresponde a um tipo de munição (ver abaixo).

Aqui está uma lista de todas as armas de fogo e os seus respectivos tipos de munições.


| Item | Calibre da Munição | Velocidade de Disparo | Slots do Carregador | Máximo de Carregadores |
| -------------- | ------------- | --------------- | ------------- | ----------------- |
| M9 | calibre_9mm | 330.0 | 10 | 1 |
| M9 SD | calibre_9mm | 295.0 | 10 | 1 | 1
| Desert Eagle | calibre_357 | 420.0 | 7 | 2 | Desert Eagle | calibre_357
| Shotgun | calibre_12g | 475.0 | 6 | 1 | 1
| Sawnoff | calibre_12g | 265.0 | 2 | 6 |
| Spas 12 | calibre_12g | 480.0 | 6 | 1 | 1
| Mac 10 | calibre_9mm | 376.0 | 32 | 1 | 1
| MP5 | calibre_9mm | 400.0 | 30 | 1 | 1
| WASR-3 | calibre_556 | 943.0 | 30 | 1 |
| M16 | calibre_556 | 948.0 | 30 | 1 |
| Tec 9 | calibre_9mm | 360.0 | 36 | 1 | 1
| Rifle | calibre_357 | 829.0 | 5 | 1 |
| Sniper | calibre_357 | 864.0 | 5 | 1 | 1
| RPG | calibre_rpg | 0.0 | 1 | 0 |
| calibrre_rpg | 0.0 | 1 | 0 | 0 |
| Flamer | Liquid_Petrol | 0.0 | 100 | 10 | 10 |
| Minigun | calibre_556 | 853.0 | 100 | 1 |
| Câmara | calibre_filme | 1337.0 | 24 | 4 |
| VEHICLE_WEAPON | calibre_556 | 750.0 | 0 | 1 | 1 |
| AK-47 | calibre_762 | 715.0 | 30 | 1 | 1
| M77-RM | calibre_357 | 823.0 | 1 | 9 |
| calibre_50bmg | 888.8 | 1 | 9 | 9 | Dog's Breath | calibre_50bmg | 888.8 | 1 | 9
| Modelo 70 | calibre_308 | 860.6 | 1 | 9 | 9
| The Len-Knocks | calibre_50bmg | 938.5 | 1 | 4 |

### Como funcionam os Danos

Antes de ler isto, certifique-se de que se familiarizou com a forma como a Saúde funciona
em Scavenge and Survive.

Uma arma tem duas partes: a arma e as munições. Cada parte tem factores que
afetão a forma como a arma irá atingir o alvo.

A munição tem uma taxa de sangramento de base que é onde o resultado da taxa de sangramento é derivado.
 Leia mais sobre hemorragias na página da Saúde.

As armas de fogo têm uma velocidade de disparo que determina a rapidez com que a força da bala
cai ao longo da distância.

#### Ao disparar

A bala que é disparada contém agora esta informação: a velocidade do disparo
(velocidade inicial) e a taxa de sangramento de base desse calibre. Esta estátistica
a informação sobre os artigos será utilizada quando a bala atingir em conjunto
com dados circunstanciados baseados no evento individual.

#### Após o Impacto

(por favor note que o jogo usa hitscan em vez de balística, não há
intervalo real entre o fogo e o impacto.)_

Quando a bala atinge o alvo, a distância é registada, sendo depois utilizada para
calcular a velocidade real da bala no momento do impacto. A velocidade de tiro
da arma determina o quanto a velocidade final é afetada pela
distância. Por exemplo, uma bala disparada de uma arma de velocidade muito alta
provavelmente não irá perder muito essa velocidade acima dos 100m mas uma baixa velocidade de disparo da
arma perderá muito da velocidade (e portanto da força) ao longo da distância de
100m.

Agora que a velocidade da bala no impacto é calculada, este valor é utilizado para
afetar a taxa de hemorragia de base do calibre, resultando numa taxa de hemorragia mais baixa, dependendo
sobre a distância até ao alvo.

#### Ferida e Inconsciência

(pode ler mais sobre isto na página da Saúde).

Quando uma bala atinge um alvo, uma ferida será infligida e estas começarão a
sangrar. É então efetuado um cálculo para determinar se o jogador
devem ficar inconscientes. Isto é baseado no número de feridas que tinham e na sua
taxa de sangramento antes do impacto. Valores mais elevados resultam numa maior probabilidade de obter um desmaio.

#### Conclusão

As armas de fogo enfraquecerão o seu adversário, no entanto, atualmente, uma bala raramente matará
um jogador, uma vez que as balas não removem imediatamente grandes pedaços de sangue. Existe um
limite da ferida de 64 de dano, quando um jogador atinge esse valor, morre instantaneamente.

Isto significa que as armas são fundamentais para levar o seu inimigo a um estado insalubre, a partir de
uma distância segura. Uma vez enfraquecidos, pode usar armas de combate corpo a corpo ou ultilizar de meios
criativos para acabar com eles.

Esta grande mudança na mecânica de combate e saúde foi feita numa atualização que veio
com o objetivo de prolongar o combate a partir de nocaute,uma bala final pode matar rapidamente, para combater
os cenários torna-se mais interessantes, tácticas tensas. Aprender a utilizar
as suas ferramentas disponiveis para seu pleno benefício e não desperdiçar munições é a chave para a sobrevivência. Cada
 bala conta, faça os tiros valerem a pena rsrs

### Munições

A desvantagem óbvia das armas de fogo são as munições, muitas vezes vistas como mais raras do que as
armas propriamente ditas. As munições podem ser encontradas nos mesmos tipos de locais que as armas
sob a forma de caixas/pacotes de munição, as munições de grau inferior encontram-se em áreas civil,
ja o bom material só está disponível em áreas militares e esconderijos de sobreviventes e 
telhados.

As munições vêm em diferentes tipos, que correspondem a diferentes armas, alguns
 tipos de munições funcionam em múltiplas armas(9mm por exemplo serve em 4 tipos de armas) e podem ser trocadas entre elas com a
Opção "Transferir munição" em armas dropadas.

A maioria das armas de fogo padrão cabem um carregador na arma e uma reserva.


| Item           | Nome de Munição      | Calibre       | Taxa de Sangramento | Multiplicador K/O | Penetração | Tamanho |
| -------------- | -------------- | ------------- | ---------- | -------------- | ----------- | ---- |
| 9mm Rounds     | Ponta Oca   | calibre_9mm   | 1.0        | 1.0            | 0.2         | 20   |
| .50 Rounds     | Action Express | calibre_50cae | 1.0        | 1.5            | 0.9         | 28   |
| Shotgun Shells | No. 1          | calibre_12g   | 1.1        | 1.8            | 0.5         | 24   |
| 5.56 Rounds    | FMJ            | calibre_556   | 1.1        | 1.2            | 0.8         | 30   |
| .357 Rounds    | FMJ            | calibre_357   | 1.2        | 1.1            | 0.9         | 10   |
| Rockets        | RPG            | calibre_rpg   | 1.0        | 1.0            | 1.0         | 1    |
| Petrol Can     | Gasolina         | calibre_fuel  | 0.0        | 0.0            | 0.0         | 20   |
| 9mm Rounds     | FMJ            | calibre_9mm   | 1.2        | 0.5            | 0.8         | 20   |
| Shotgun Shells | Flechette      | calibre_12g   | 1.6        | 0.6            | 0.2         | 8    |
| Shotgun Shells | Improvisada     | calibre_12g   | 1.6        | 0.4            | 0.3         | 14   |
| 5.56 Rounds    | Traçante         | calibre_556   | 0.9        | 1.1            | 0.5         | 30   |
| 5.56 Rounds    | Ponta Oca   | calibre_556   | 1.3        | 1.6            | 0.4         | 30   |
| .357 Rounds    | Traçante         | calibre_357   | 1.2        | 1.1            | 0.6         | 10   |
| 7.62 Rounds    | FMJ            | calibre_762   | 1.3        | 1.1            | 0.9         | 30   |
| .50 Rounds     | BMG            | calibre_50bmg | 1.8        | 1.8            | 1.0         | 16   |
| .308 Rounds    | FMJ            | calibre_308   | 1.2        | 1.1            | 0.8         | 10   |

### Eficácia

Geralmente, as balas de ponta oca são melhores contra alvos não blindados e 
As balas de FMJ penetrarão as armaduras. Já as balas traçantes não têm
outros beneficios além da iluminação da sua trajetória de percurso e possivelmente a inflamação de
materiais explosivos.

### Tipos de Munições

- Ponta Oca - mais desmaio, hemorragia moderada, menos eficaz contra
  veículos/ocupantes
- Ponta Mole - menos desmaios do que acima, taxa de hemorragia mais rápida, menos eficaz
  contra veículos/ocupantes
- FMJ - perfurante de blindagem, perfurante de escudo, mais eficaz contra
  veículos/ocupantes
- Traçante - bala acesa, possibilidade de acender tanques de combustível
- Explosivo/incendiário - acende tanques de combustível, possibilidade extra de nocaute e queimadura
  danos

### Transferência de munições

Transferência de munições entre armas e armazenamento de munições é uma parte vital
de comércio, gestão de armas e trabalho de equipe. Pode transferir munições para qualquer
arma que dispara o mesmo tipo de munição.

Para transferir munições do item 1 para o item 2, deve ter o item 1 no seu inventário.
ou um drop no chão de algum tipo de munição, depois segure o item 2, abra as opções do item e
clique na opção "Transferir Munição", um diálogo irá mostrar onde pode digitar a
quantidade de munições a transferir.

Por exemplo, tem uma caixa de munição 5.56, algumas munições e uma AK47 nas suas mãos, coloque a
caixa na sua bolsa, segure a AK47, abra a bolsa > Opções de Caixa > "Transferir munição
para a Arma". Isto também funciona ao contrário, bem como com a transferência de munições
de uma caixa para outra, ou de uma arma para outra (as armas não têm de ser
o mesmo tipo de arma, só precisam de usar o mesmo tipo de munição)

Esta característica torna-se inestimável quando se trabalha para caça, através de melhores armas,
pode apanhar uma M9 logo após a trocar para outra, que utiliza munições de 9mm. E depois, em 
poucos dias encontra um Tec9 que também usa munições de 9mm, porquê desperdiçar aquela preciosa
munição? só porque se atualizou para uma arma melhor? Transfira-a!

## Armas de Corpo

As armas de corpo estão entre as mais simples, de uma multiplicidade de formas de abate que podem ser feitas em
jogadores nas brigas que ocorrem em San Andreas.

Cada arma tem uma taxa de sangramento infligida e uma hipótese de desmaio. Leia mais sobre
como funciona a saúde [aqui](health).

### Contusas

A maioria das armas de combate corpo-a-corpo como o taco de basebol ou o taco de bilhar são menos eficazes em
fazer a vítima sangrar, mas têm uma maior probabilidade de os desmaiar. Estes são
o mais comum a encontrar e são os melhores para deitar o seu inimigo ao chão,
mas pode não ser a melhor escolha se estiver tentando fazer o trabalho rapidamente.
Apesar desta desvantagem, a maior possibilidade de nocautear pode tornar mais fácil
imobilizar os inimigos.

### Afiadas

Armas de combate corpo a corpo afiadas como a faca ou a espada têm uma menor probabilidade de nocautear
mas causará uma hemorragia muito rápida. As armas afiadas são destinadas a enfraquecer um
jogador e infligindo danos a longo prazo. As armas afiadas são geralmente encontradas em
áreas civis e industriais, dependendo do tipo.

### Choque

A arma de choque é uma arma paralisante eléctrica de contato a curta distância. Não inflige
feridas no seu alvo, mas sim um zumbido muito poderoso que as deixará
desmaiado por um minuto.

| Item | Taxa de Sangramento | Probabilidade de Desmaio |
| -------------- | ---------- | -------------------- |
| Soco Inglês (Knuckle Duster) | 0.05 | 20 | 20 |
| Taco de Golfe | 0.07 | 35 | 35 |
| Baton | 0.03 | 24 | 24 |
| Faca de Combate | 0.35 | 14 | Faca de combate
| Taco de Basebol | 0.09 | 35 | 35
| Spade | 0.21 | 40 | 40 |
| Taco de Bilhar | 0.08 | 37 | 37
| Espada | 0.44 | 15 | 15
| Moto-serra | 0.93 | 100 | 100 | Chainsaw
| Dildo | 0.01 | 0 | 0
| Dildo | 0.01 | 0 | 0
| Dildo | 0.01 | 0 | 0
| Dildo | 0.01 | 0 | 0
| Flores | 0.01 | 0 | 0 |
| Cane | 0.06 | 24 | 24 | Cane
| Granada | 0.0 | 0 | 0
| Teargas | 0.0 | 0 | 0 |
| Molotov | 0.0 | 0 | 0
| M9 | 330.0 | 10 |
| M9 SD | 295.0 | 10 | 10 |
| Desert Eagle | 420.0 | 7 | Desert Eagle
| Shotgun | 475.0 | 6 | Shotgun
| Sawnoff | 265.0 | 2 | 2
| Spas 12 | 480.0 | 6 | 6 |
| Mac 10 | 376.0 | 32 | 32 |
| MP5 | 400.0 | 30 | 30 |
| WASR-3 | 943.0 | 30 | 30 |
| M16 | 948.0 | 30 |
| Tec 9 | 360.0 | 36 | 36 |
| Espingarda | 829.0 | 5 |
| Sniper | 864.0 | 5 | Sniper |
| RPG | 0.0 | 1 | 1 |
| Heatseeker     | 0.0        | 1                    |
| Flamer | 0.0 | 100 | 100 |
| Minigun | 853.0 | 100 | 100
| Bomba Remota | 0.0 | 1 | 1 |
| Detonador | 0.0 | 1 | Detonador | 0.0 | 1 | Detonador
| Spray Paint | 0.0 | 100 | 100
| Extintor | 0.0 | 100 | 100 |
| Câmara | 1337.0 | 24 | 24 |
| VEHICLE_WEAPON ? | 750.0      | 0                    |
| AK-47 | 715.0 | 30 | 30 |
| M77-RM | 823.0 | 1 |
| Dog's Breath | 888.8 | 1 |
| Modelo 70 | 860.6 | 1 | 1
| The Len-Knocks | 938.5 | 1 |

## Armas de Corpo Adicionais

| Item | Taxa de Sangramento | Probabilidade de Nocaute | Tipo de Ataque
| ------------- | ---------- | -------------------- | ----------- |
| Chave de Rodas | 0.01 | 1.20 | Contusão |
| Pé-de-Cabra | 0.03 | 1.25 | Cortante |
| Martelo | 0.02 | 1.30 | Cortante |
| Rake | 0.18 | 1.30 | Pesado |
| Cane | Cane | 0.08 | 1.25 | Contusão |
| Stun Gun | 0.0 | 0 | Facada |
| Chave de Fendas | 0.24 | 0 | Facada |
| Caixa de Correio | 0.0 | 1.40 | Pesado |
| Sledgehammer | 0.03 | 2.9 | Pesado |
| Big Ass Sword | 0.39 | 0.15 | Pesado |
| Spatula | 0.001 | 0 | Contusão |
| Pan | 0.01 | 1.05 | Contusão |
| Faca de Cozinha | 0.29 | 0 | Faca |
| Frigideira | 0.01 | 1.06 | Contusão |
| Garfo | 0.17 | 0 | Facada |
| Vassoura | 0.11 | 1.1 | Pesada |