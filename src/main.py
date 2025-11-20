from datetime import datetime
import json
import random
import time
import urllib.request

ES_HOST = "http://elasticsearch-master:9200"
INDEX_NAME = "vendas-app"

produtos = ["Notebook", "Mouse", "Teclado", "Monitor", "Cadeira Gamer"]
status_opts = ["SUCESSO", "PENDENTE", "FALHA_CARTAO", "FALHA_ESTOQUE"]
paises = ["BR", "US", "DE", "JP"]

print(f"Iniciando gerador de logs para {ES_HOST}")

while True:
    data = {
        "timestamp": datetime.now().isoformat(),
        "produto": random.choice(produtos),
        "valor": round(random.uniform(50.0, 5000.0), 2),
        "status": random.choice(status_opts),
        "pais": random.choice(paises),
        "response_time_ms": random.randint(10, 1500)
    }

    try:
        url = f"{ES_HOST}/{INDEX_NAME}/_doc"
        req = urllib.request.Request(
            url=url,
            data=json.dumps(data).encode('utf-8'),
            headers={'Content-Type':'application/json'}
            )

        with urllib.request.urlopen(req) as response:
            print(f"Log enviado: {data['status']} - {data['produto']}")

    
    except Exception as e:
        print(f"Error ao enviar log: {e}")
    
    time.sleep(random.uniform(0.1, 1.0))