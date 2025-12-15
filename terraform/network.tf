resource "yandex_vpc_network" "main" {
  name = "prod-network"
}

resource "yandex_vpc_subnet" "public" {
  name           = "public-subnet-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.public_subnet_cidr]
}

resource "yandex_vpc_subnet" "private_a" {
  name           = "private-subnet-a"
  zone           = var.zone_a
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_a_cidr]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_subnet" "private_b" {
  name           = "private-subnet-b"
  zone           = var.zone_b
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = [var.private_subnet_b_cidr]
  route_table_id = yandex_vpc_route_table.private_rt.id
}

resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "private_rt" {
  name       = "private-rt"
  network_id = yandex_vpc_network.main.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}
