# Critérios de Aceite — EFC-6322

- CA-01: Disciplina bloqueada aparece desabilitada na combo — Ao abrir o seletor de disciplinas de um Componente Formativo, disciplinas que já estão associadas a um CF de ciclo diferente (mesmo Ano, Rede e Agrupamento) devem aparecer na lista, porém desabilitadas e com tooltip: "Disciplina já selecionada para um Componente Formativo de outro Ciclo".
- CA-02: Disciplina do mesmo ciclo permanece disponível — Uma disciplina já usada em um CF do mesmo ciclo pode ser selecionada novamente em outro CF desse mesmo ciclo. O bloqueio se aplica apenas a ciclos distintos.
- CA-03: Restrição não aplica entre combinações diferentes — Dois Componentes Formativos de Ano, Rede ou Agrupamento distintos não estão sujeitos à restrição entre si. O bloqueio é sempre dentro da mesma combinação Ano + Rede + Agrupamento.
- CA-04: Tentativa de salvar com disciplina de ciclo cruzado é rejeitada — Se o usuário contornar o bloqueio visual e tentar salvar um CF com uma disciplina que viola a regra, o sistema deve rejeitar a operação e exibir mensagem de erro indicando o conflito.
