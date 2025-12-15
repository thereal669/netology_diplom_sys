locals {
  all_disk_ids = [
    yandex_compute_instance.bastion.boot_disk[0].disk_id,
    yandex_compute_instance.zabbix.boot_disk[0].disk_id,
    yandex_compute_instance.kibana.boot_disk[0].disk_id,
    yandex_compute_instance.elastic.boot_disk[0].disk_id,
    yandex_compute_instance.web1.boot_disk[0].disk_id,
    yandex_compute_instance.web2.boot_disk[0].disk_id,
  ]
}

resource "yandex_compute_snapshot_schedule" "daily_snapshots" {
  name = "daily-snapshots"

  schedule_policy {
    expression = "0 3 * * *" # каждый день в 03:00 по расписанию cron
  }

  snapshot_count = 7 # храним максимум 7 снапшотов (≈ 7 дней)

  snapshot_spec {
    description = "Daily snapshot"
    labels = {
      environment = var.environment
      backup      = "daily"
    }
  }

  disk_ids = local.all_disk_ids
}
