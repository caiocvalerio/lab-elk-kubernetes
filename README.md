# Lab: Elastic Stack com Kubernetes para Observabilidade

![Kubernetes](https://img.shields.io/badge/kubernetes-%23326ce5.svg?style=for-the-badge&logo=kubernetes&logoColor=white)
![ElasticSearch](https://img.shields.io/badge/-ElasticSearch-005571?style=for-the-badge&logo=elasticsearch)
![Logstash](https://img.shields.io/badge/-Logstash-005571?style=for-the-badge&logo=logstash)
![Kibana](https://img.shields.io/badge/-Kibana-005571?style=for-the-badge&logo=kibana)
![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)

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

### Provisionar a infraestrutura
Cria um cluster Kubernetes leve (K3d) simulando 3 nós físicos.

```
k3d cluster create --config infra/k3d-config.yaml
```

### Instalar Elasticsearch, Logstash e Kibana
Utilizando Helm com valores customizados para laboratório.

Primeiro adiciona-se o repositório oficial
```
helm repo add elastic [https://helm.elastic.co](https://helm.elastic.co) && helm repo update
```

Segue para instalar Elasticsearch 
 ```
helm install elasticsearch elastic/elasticsearch \
  --version 7.17.3 \
  --values helm-values/elastic-values.yaml
```

Para instalar o Logstash, primeiro criar-se o configMap
```
kubectl create configmap logstash-pipeline-config --from-file=pipelines/uptime.conf
```

 Após, efetua a instalação
```
helm install logstash elastic/logstash \
  --version 7.17.3 \
  --values helm-values/logstash-values.yaml
```

Por fim, instala-se o Kibana
```
helm install kibana elastic/kibana \
  --version 7.17.3 \
  --values helm-values/kibana-values.yaml
```

### Iniciar os geradores de carga

Cria-se primeiro o config map com o script python
```
kubectl create configmap python-script --from-file=src/main.py
```

Realiza o deploy
```
kubectl apply -f k8s/log-generator.yaml
```

Aguarde os containers rodarem, podendo ser verificado com o comando
```
kubectl get pods
```

### Abrir o túnel
```
kubectl port-forward svc/kibana-kibana 5601:5601
```

A aplicação fica disponível em: http://localhost:5601
