import logging
from typing import Dict
from kafka import KafkaProducer
from datetime import datetime
import json
import uuid


class KafkaDAO(object):

    AIVEN_KAFKA_HOST = "kafka-homework-cornillon-a592.aivencloud.com"
    AIVEN_KAFKA_SSL_PORT = 26618

    def __init__(self):
        print("[Initiating Kafka client]")
        self.producer = KafkaProducer(
            bootstrap_servers=f"{self.AIVEN_KAFKA_HOST}:{self.AIVEN_KAFKA_SSL_PORT}",
            security_protocol="SSL",
            ssl_cafile="ca.pem",
            ssl_certfile="service.cert",
            ssl_keyfile="service.key",
            value_serializer=lambda v: json.dumps(v).encode("utf-8"),
            acks="all",
        )

    def send(self, topic: str, event: Dict):
        print(f"[Publishing one message to topic {topic}...]")
        result = self.producer.send(
            topic=topic,
            value=event,
        )
        print(result.get())


def main():

    order1 = {
        "id": str(uuid.uuid4()),
        "date": datetime.now().isoformat(),
        "items": [
            {
                "id": "ref#314698",
                "name": "Screwdriver",
                "quantity": 1,
                "price_euro": 12,
            },
            {"id": "ref#481516", "name": "Hammer", "quantity": 2, "price_euro": 9},
        ],
    }

    order2 = {
        "id": str(uuid.uuid4()),
        "date": datetime.now().isoformat(),
        "items": [
            {
                "id": "ref#314698",
                "name": "Nails 25mm",
                "quantity": 50,
                "price_euro": 0.06,
            }
        ],
    }

    kafka = KafkaDAO()

    kafka.send("orders-topic", order1)
    kafka.send("orders-topic", order2)


if __name__ == "__main__":
    main()
