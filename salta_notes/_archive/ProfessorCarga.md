Professor Vago -> 
	Saida Temporaria -> Inativar a carga atual, 


- Data de saida do professor vago nao deve ser informadao, quando um vago sair, ele deve usar a data de entrada do novo professor

- [ ] Ajustar o filtro para considerar professor vago como (1 professor da rede) com todas as cargas que tem vago.
- [ ] Ajustar a listagem para trazer o professor vago com as cargas vagas da rede


- Ao incluir o vago, nao deve ter opcoes que nao facam sentido com o vago em motivoSaida

De PROFESSOR para VAGO : nao preciso informar a data que o vago esta entrando, pq eh a data de saida do professor atual
De um Vago para Professor: nao preciso informar a data de saida do vago, pois eh a mesma data de entrada do novo professor.

os tempos vagos 


```duvidas
mesmo que nao informe o filtro de 'professor vago' caso a rede tenha tempos com vago, esse professor vago deve aparecer na listagem? 
respeitando ordem alfabetica?
deve ser o primeiro professor retornado?
o



```



Preciso incluir um fluxo onde posso informar o professor vago.
Um professor vago eh um Guid.Empty() que vem na lista de cargarParaUpdate da request.

Preciso identificar o tipo de motivo de saida, para saber se crio um vago para a ProfessorCarga ou ProfessroCargaSubstituto, so eh substituto quando o motivoSaida do professor atual EhSaidaTemporaria
se o motivo for SaidaTemporaria.

uma carga Vago eh quase igual as outras cargas, a diferenca eh que ProfessorPerfilVigente fica null e a flag Vago fica true