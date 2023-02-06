---
title: Veículos
---

Veículos podem ser encontrados por todo o mapa, algumas vezes nas localizações mais estranhas.
Cada restart, em volta de 100 veículos são spawnados randomicamente em um dos 2000 pontos
no mapa. Isto inclui carros, motos, barcos, aviões e helicópteros. Alguns veículos
são mais raros que outros, por exemplo, o BF Injection tem 100% de chance de spawnar enquanto o helicóptero de ataque Hunter tem 1% de chance para spawnar.

Alguns veículos apenas spawnam em certos pontos, por exemplo, heliportos apenas spawnam
helicópteros e veículos militares são apenas encontrados em áreas militares como na Area 69 e na Easter Basin Naval Dock.

## Porta-Malas

A maioria dos veículos tem um porta-malas que podem ter itens guardados dentro. Não há limite de tamanho 
de itens para os porta-malas dos veículos e a quantidade de slots de itens variam por veículo. Por exemplo,
um carro pequeno terá um porta-malas de 12 slots, enquanto um caminhão grande
teria um porta-malas com o tamanho de 16 ou mais, o maior tamanho de porta-malas é de 24 (que pode
ser atualizado para 64 para veículos muito grandes).

![/docs/trunk.webp](/docs/trunk.webp)

## Reparando

Para reparar um veículo, você deve utilizar 3 ferramentas em uma sequência específica, a sequência
é:

> Chave de Roda > Chave de Fenda > Martelo > Chave de Roda (novamente)

Cada ferramente funciona em um pedaço específico de saúde, a tabela abaixo mostra a você quando
é para usar cada ferramenta:

|                   | Chave de Roda | Chave de Fenda | Martelo | Chave de Roda |
| ----------------- | ------------- | -------------  | ------- | ------------- |
| Faixa de dano:    |    250-450    |    450-650     | 650-800 |    800-Max    |
| Indicador de cor: |   Vermelho    |    Laranja     | Amarelo |     Verde     |

Enquanto a saúde de um veículo está abaixo de 450 (na faixa Chave de Roda ou Vermelho) o motor irá falhar
e ligar aleatóriamente, por fim desacelerando o veículo.

Se a saúde de um veículo cai abaixo de 300, o motor irá falhar completamente e
nunca voltará a funcionar até que o veículo seja reparado.

### Reparando Pneus

Este item pode ser usado em um veículo para consertar uma roda quebrada / pneu
estourado. Para fazer isto, simplesmente segure o item e fique em frente de uma roda do
veículo com 1 ou mais rodas faltando e pressione a Tecla de Interação (Padrão F/Enter),
você irá ver uma lista de rodas para consertar onde as quebradas serão exibidas em
vermelho.

Rodas são mais comuns em áreas industriais, mas também podem ser encontradas dentro da maioria
dos porta-malas de veículos.

![/docs/wheel.webp](/docs/wheel.webp)

## Chavearia

Chaveiro de Veículo requer um Kit de Chaveiro e é executado ficando
do lado esquerdo (motorista) de um veículo e segurar a Tecla de Interação (Padrão
F/Enter); uma barra de progresso cinza irá aparecer na tela e será preenchida.

Uma vez terminada a chavearia, o Kit de Chaveiro em suas mãos será
substituído por uma chave. Esta chave está vinculada ao veículo para sempre e pode ser usada para
trancar/destrancar o veículo pelo exterior.

Um veículo trancado permanecerá trancado durante os restarts do servidor e atualmente
não há nenhuma outra maneira de acessar um veículo trancado. Isso provavelmente mudará no futuro.