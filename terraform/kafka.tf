###################################################
# Aiven provider configuration                    #
###################################################

terraform {
  required_providers {
    aiven = {
      source  = "aiven/aiven"
      version = "3.7.0"
    }
  }
}

provider "aiven" {
  api_token = var.aiven_token
}

###################################################
# Grafana and InfluxDB services                   #
###################################################

resource "aiven_grafana" "grafana-python-demo" {
  project                 = var.aiven_project
  cloud_name              = "google-europe-west1"
  plan                    = "startup-1"
  service_name            = "grafana-homework"

  grafana_user_config {
    public_access {
      grafana = true
    }
  }
}

resource "aiven_influxdb" "influx-python-demo" {
  project                 = var.aiven_project
  cloud_name              = "google-europe-west1"
  plan                    = "startup-4"
  service_name            = "influx-homework"

  influxdb_user_config {
    public_access {
      influxdb = true
    }
  }
}

###################################################
# Kafka cluster and topic                         #
###################################################

resource "aiven_kafka" "kafka-python-demo" {
  project                 = var.aiven_project
  cloud_name              = "google-europe-west1"
  plan                    = "startup-2"
  service_name            = "kafka-homework"

  kafka_user_config {
    kafka_rest      = true
    kafka_version   = "3.2"

    public_access {
      kafka_rest    = true
    }
  }
}

resource "aiven_kafka_topic" "orders-topic" {
  project                = var.aiven_project
  service_name           = aiven_kafka.kafka-python-demo.service_name
  topic_name             = "orders-topic"
  partitions             = 3
  replication            = 3
}

###################################################
# Integrations for observability                  #
###################################################

resource "aiven_service_integration" "grafana-to-influx-observability" {
  project                  = var.aiven_project
  integration_type         = "dashboard"
  source_service_name      = aiven_grafana.grafana-python-demo.service_name
  destination_service_name = aiven_influxdb.influx-python-demo.service_name
}

resource "aiven_service_integration" "kafka-to-influx-observability" {
  project                  = var.aiven_project
  integration_type         = "metrics"
  source_service_name      = aiven_kafka.kafka-python-demo.service_name
  destination_service_name = aiven_influxdb.influx-python-demo.service_name
}
