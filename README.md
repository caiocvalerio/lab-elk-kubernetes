# Lab: Elastic Stack com Kubernetes para Observabilidade

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![ElasticSearch](https://img.shields.io/badge/-ElasticSearch-005571?style=for-the-badge&logo=elasticsearch)
![Logstash](https://img.shields.io/badge/-Logstash-005571?style=for-the-badge&logo=logstash)
![Kibana](https://img.shields.io/badge/-Kibana-005571?style=for-the-badge&logo=kibana)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

Este projeto foi desenvolvido como um laboratório prático destinado ao estudo introdutório e familiarização com a Elastic Stack (ELK) e orquestração de containers via Kubernetes.

A iniciativa partiu da necessidade de compreender, através da implementação ativa, como os componentes da stack de observabilidade se integram arquiteturalmente.
O foco do estudo foi estabelecer um fluxo de dados funcional, identificando os desafios de configuração, conexão entre serviços e gerenciamento de recursos em um ambiente containerizado.


![Dashboard Kibana](/doc/elk.png)


## Arquitetura da Solução

O fluxo de dados é apresentado da seguinte forma:

1.  **Source (Python Robots):** Aplicação rodando no K8s gerando transações em tempo real.
2.  **Middle Layer (Logstash):** Recebe os dados via HTTP, remove headers e classifica clientes como `VIP` ou `PADRAO` baseado no valor da compra.
3.  **Storage (Elasticsearch):** Cluster configurado com 3 nós ( 1 master e 2 workers ).
4.  **Visualization (Kibana):** Dashboards de negócio monitorando Latência (p95), Taxa de Erros e Revenue Share por categoria de cliente.

## Métricas
O dashboard foi construído com base em três pilares de observabilidade: 
  - Performance: Acompanhamento da latência em p95. Diferente da média simples, essa métrica revela a lentidão experimentada pelos 5% de requisições mais pesadas.
  - Visão de Negócio: Cruzamento de dados técnicos com regras de negócio, visualizando a proporção de transações entre clientes VIP e PADRÃO.
  - Confiabilidade: Monitoramento de disponibilidade através da tipificação de erros (FALHA_CARTAO, etc.), permitindo distinguir erros de infraestrutura de recusas de negócio.

## Como executar

### Pré-requisitos

Certifique-se de ter as seguintes ferramentas instaladas:
 - Docker
 - K3d
 - Terraform
 - Kubectl

### Inicializar o Cluster
Crie o cluster local simulando 3 nós físicos utilizando a configuração definida:

```
k3d cluster create --config infra/k3d-config.yaml
```

### Provisionamento Automatizado
Utilizamos o Terraform para orquestrar a instalação dos Charts Helm (Elasticsearch, Logstash, Kibana) e aplicar os manifestos Kubernetes da aplicação Python.

```
cd terraform && terraform init
```

```
terraform plan -out plan
```

```
terraform apply plan
```

### Validação
Verifique se todos os pods estão com o status `Running`. O Elasticsearch pode demorar um pouco para atingir o estado de prontidão.
```
kubectl get pods
```

### Acessar o Kibana
Para acessar a interface do Kibana localmente, utilize o port-forward:
```
kubectl port-forward svc/kibana-kibana 5601:5601
```
A aplicação fica disponível em: http://localhost:5601
