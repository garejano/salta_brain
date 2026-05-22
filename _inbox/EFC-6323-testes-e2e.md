Feature: Seleção de Componentes Formativos com permissão própria

  Background:
    Given que a funcionalidade de seleção de Componentes Formativos existe no sistema como uma permissão independente da configuração

  Scenario: Usuário com permissão de seleção realiza associação de aluno a componente formativo
    Given que o usuário possui permissão de seleção de Componentes Formativos para a escola "Escola Alpha"
    When o usuário acessa a tela de seleção de Componentes Formativos
    And filtra por ano letivo, escola, turma e período
    And associa um componente formativo a um aluno da turma
    Then a associação é registrada com sucesso
    And o componente formativo aparece vinculado ao aluno na listagem

  Scenario: Filtro de escolas exibe apenas as escolas com permissão de seleção
    Given que o usuário possui permissão de seleção para a escola "Escola Alpha"
    And o usuário possui permissão de configuração para a escola "Escola Beta"
    When o usuário acessa a tela de seleção de Componentes Formativos
    And consulta as escolas disponíveis no filtro
    Then apenas "Escola Alpha" é exibida entre as opções
    And "Escola Beta" não aparece no filtro de escolas

  Scenario: Usuário com ambas as permissões acessa configuração e seleção de Componentes Formativos
    Given que o usuário possui permissão de configuração de Componentes Formativos
    And o usuário possui permissão de seleção de Componentes Formativos
    When o usuário acessa a tela de configuração de Componentes Formativos
    Then o acesso é concedido e a tela é exibida normalmente
    When o usuário acessa a tela de seleção de Componentes Formativos
    Then o acesso também é concedido e a tela é exibida normalmente
