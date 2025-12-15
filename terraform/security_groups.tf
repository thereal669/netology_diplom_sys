resource "yandex_vpc_security_group" "bastion" {
  name       = "sg-bastion"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from my IP"
    port           = 22
    v4_cidr_blocks = ["109.126.14.134/32"] # здесь будет твой_IP/32
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "alb" {
  name       = "sg-alb"
  network_id = yandex_vpc_network.main.id

  # HTTP трафик от пользователей из интернета
  ingress {
    protocol       = "TCP"
    description    = "HTTP from internet"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  # Трафик от служебных IP Yandex Cloud для health-check'ов ALB
  ingress {
    protocol          = "TCP"
    description       = "Health checks"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "web" {
  name       = "sg-web"
  network_id = yandex_vpc_network.main.id

  # HTTP-трафик от ALB и других хостов внутри VPC
  ingress {
    description    = "HTTP from ALB and internal VPC"
    protocol       = "TCP"
    port           = 80
    v4_cidr_blocks = ["10.10.0.0/16"]
  }

  # Health-check'и от служебных IP ALB
  ingress {
    description       = "Health checks from ALB"
    protocol          = "TCP"
    port              = 80
    predefined_target = "loadbalancer_healthchecks"
  }

  # SSH с bastion на web-сервера
  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  # Zabbix agent 10050 от Zabbix-сервера
  ingress {
    description       = "Zabbix agent from Zabbix server"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.zabbix.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "zabbix" {
  name       = "sg-zabbix"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "Zabbix frontend"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"] # при желании можешь ограничить своим IP
  }

  ingress {
    protocol       = "TCP"
    description    = "Zabbix server from agents"
    port           = 10051
    v4_cidr_blocks = ["10.10.0.0/16"]
  }

  # SSH с bastion на zabbix
  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "kibana" {
  name       = "sg-kibana"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "Kibana UI"
    port           = 5601
    v4_cidr_blocks = ["0.0.0.0/0"] # можешь ограничить
  }

  # SSH с bastion на kibana
  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  # Zabbix agent 10050 от Zabbix-сервера
  ingress {
    description       = "Zabbix agent from Zabbix server"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.zabbix.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "elastic" {
  name       = "sg-elastic"
  network_id = yandex_vpc_network.main.id

  ingress {
    protocol       = "TCP"
    description    = "Elastic HTTP API"
    port           = 9200
    v4_cidr_blocks = ["10.10.0.0/16"]
  }

  # SSH с bastion на elastic
  ingress {
    description       = "SSH from bastion"
    protocol          = "TCP"
    port              = 22
    security_group_id = yandex_vpc_security_group.bastion.id
  }

  # Zabbix agent 10050 от Zabbix-сервера
  ingress {
    description       = "Zabbix agent from Zabbix server"
    protocol          = "TCP"
    port              = 10050
    security_group_id = yandex_vpc_security_group.zabbix.id
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
