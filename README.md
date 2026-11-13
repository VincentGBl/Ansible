# Ansible
Repositório destinado ao projeto de Implementação do Ansible em um ambiente corporativo real



Estruturação:

Micro-playbooks:
Playbooks de tarefas generalizadas, o objetivo é modularizar o máximo possível cada tarefa em tarefas menores, funcionando como opções a serem escolhidas para os diversos hosts

Macro-playbook:
Playbook que funcionam como orquestradores, esses playbooks 'chamam' outros playbook(micro-playbook) com as tarefas específicas de cada espaço (Sala administrativa, Laboratório, Sala de aula, recepção...)
