
Projeto disponível em: https://feloti.github.io/Trabalho-1-LFA/

Para executar localmente:
* Mudar para o diretório /docs
* Iniciar servidor local
`python -m http.server 8000`
*e acessar
http://127.0.0.1:8000/

Dentro de /scripts/search_algorithms cotém os algortimos implementados e as heuristicas, os outros arquivos interagem com funcionalidades da Godot.

Em example.png
No terrreno:
* Marrom: Plano
* Amarelo: Arenoso
* Cinza: Rochoso
* Verde: Pantanoso

Os botões em ordem: 
* 'Play' inicia a simulação
* Escolha do algoritmo (Para o greedy e A*, abre um novo input para um fator de quão importante é pegar recompensas. Fator = 0, funciona somente com a heurística de distância base Manhattan)
* 'Voltar' limpa o mapa atual, para executar outro algoritmo no mesmo mapa
* 'Mapa', gera um novo mapa 
    * Abre um janela de input pedindo o tamanho do grid, distribuição do terreno(medido pela proporcionalidades dos numeros passados), nº de recompensas e se o grid deve conter espaços vazios(paredes)
* 'Lixeira' Apaga métricas do lado direito

Nas cores do mapa depois da execução Pisos:
* Vermelhos = Visitados
* Azul = Expandidos / Fronteira
* Roxo = Caminho gerado

Os cálices são as recompensas extras e o baú, o objetivo final.
