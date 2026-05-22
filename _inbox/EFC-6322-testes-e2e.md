# Testes E2E — EFC-6322
# Não permitir que a mesma disciplina faça parte de Componentes Formativos de múltiplos ciclos

```gherkin
Feature: Restrição de disciplina por ciclo no Configurador de Itinerário Formativo

  Background:
    Given que o usuário é um configurador do Itinerário Formativo
    And que existe uma combinação de Ano, Rede e Agrupamento configurada
    And que essa combinação possui Componentes Formativos de ciclos distintos

  Scenario: Disciplina já associada a um ciclo fica indisponível em outro ciclo da mesma combinação
    Given que a disciplina "Matemática" já está associada a um Componente Formativo do ciclo Trimestral
    When o configurador consulta as disciplinas disponíveis para um Componente Formativo do ciclo Semestral,
         na mesma combinação de Ano, Rede e Agrupamento
    Then "Matemática" aparece como indisponível para associação
    And uma informação indica que ela já está em uso em um Componente Formativo de outro ciclo

  Scenario: Disciplina do mesmo ciclo permanece disponível para outros CFs desse ciclo
    Given que a disciplina "Física" já está associada a um Componente Formativo do ciclo Semestral
    When o configurador consulta as disciplinas disponíveis para outro Componente Formativo do mesmo ciclo Semestral,
         na mesma combinação de Ano, Rede e Agrupamento
    Then "Física" aparece como disponível para associação

  Scenario: Restrição não se aplica entre combinações de Ano, Rede e Agrupamento distintas
    Given que a disciplina "Química" está associada a um Componente Formativo do ciclo Trimestral
         na combinação Ano A, Rede X e Agrupamento Y
    When o configurador consulta as disciplinas disponíveis para um Componente Formativo do ciclo Semestral
         em uma combinação diferente (Ano distinto, ou Rede distinta, ou Agrupamento distinto)
    Then "Química" aparece como disponível para associação nessa outra combinação

  Scenario: Registro de Componente Formativo com disciplina de ciclo cruzado é recusado
    Given que a disciplina "Biologia" já está associada a um Componente Formativo do ciclo Trimestral,
         na mesma combinação de Ano, Rede e Agrupamento
    When o configurador tenta registrar "Biologia" em um Componente Formativo do ciclo Semestral,
         na mesma combinação
    Then a operação não é concluída
    And o sistema informa que "Biologia" já pertence a um Componente Formativo de outro ciclo nessa combinação
```
