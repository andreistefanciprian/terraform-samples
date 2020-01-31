
# DNS zone for domain name
resource "google_dns_managed_zone" "app" {
  name        = "${var.name}-dns-zone"
  dns_name    = "${var.domain_name}."
  description = "App DNS zone"

}

# DNS zone records
resource "google_dns_record_set" "www" {
  name = "www.${google_dns_managed_zone.app.dns_name}"
  type = "CNAME"
  ttl  = 60

  managed_zone = google_dns_managed_zone.app.name

  rrdatas = [ google_dns_managed_zone.app.dns_name ]
}

resource "google_dns_record_set" "main" {
  name = google_dns_managed_zone.app.dns_name
  type = "A"
  ttl  = 60

  managed_zone = google_dns_managed_zone.app.name

  rrdatas = [ google_compute_global_address.default.address ]
}

