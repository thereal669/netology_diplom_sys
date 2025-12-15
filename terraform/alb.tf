# Target group: IP web-серверов
resource "yandex_alb_target_group" "web_tg" {
  name = "tg-web"

  target {
    subnet_id  = yandex_vpc_subnet.private_a.id
    ip_address = yandex_compute_instance.web1.network_interface[0].ip_address
  }

  target {
    subnet_id  = yandex_vpc_subnet.private_b.id
    ip_address = yandex_compute_instance.web2.network_interface[0].ip_address
  }
}

# Backend group
resource "yandex_alb_backend_group" "web_bg" {
  name = "bg-web"

  http_backend {
    name             = "web-backend"
    target_group_ids = [yandex_alb_target_group.web_tg.id]
    port             = 80
    weight           = 1

    healthcheck {
      timeout  = "1s"
      interval = "5s"

      http_healthcheck {
        path = "/"
      }
    }
  }
}

# HTTP router
resource "yandex_alb_http_router" "web_router" {
  name = "router-web"
}

resource "yandex_alb_virtual_host" "web_host" {
  name           = "vh-web"
  http_router_id = yandex_alb_http_router.web_router.id

  route {
    name = "route-root"

    http_route {
      http_route_action {
        backend_group_id = yandex_alb_backend_group.web_bg.id
      }
    }
  }
}

# ALB
resource "yandex_alb_load_balancer" "web_alb" {
  name       = "alb-web"
  network_id = yandex_vpc_network.main.id
   
  allocation_policy {
    location {
      zone_id   = "ru-central1-a"
      subnet_id = yandex_vpc_subnet.public.id
    }
  }

  listener {
    name = "listener-http"

    endpoint {
      address {
        external_ipv4_address {}
      }
      ports = [80]
    }

    http {
      handler {
        http_router_id = yandex_alb_http_router.web_router.id
      }
    }
  }
}
