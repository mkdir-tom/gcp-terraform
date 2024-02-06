# Bucket to store my web
resource "google_storage_bucket" "my_web" {
  name     = "ex-my-web-store-bk"
  location = "ASIA"
}

# Make new Object Public
resource "google_storage_bucket_access_control" "public_role" {
  object = google_storage_bucket_object.static_site_src.name
  bucket = google_storage_bucket.my_web.name
  role   = "READER"
  entity = "allUsers"
}

# Upload the html file to the bucket
resource "google_storage_bucket_object" "static_site_src" {
  name   = "index.html"
  source = ",,/my-web/index.html"
  bucket = google_storage_bucket.my_web.name
}

# Reserve a static external IP address
resource "google_compute_global_address" "my_web_ip" {
  name = "my-web-lb-ip"
}

data "google_dns_managed_zone" "dns_zone" {
  name = "xxx" # create dns on network
}

# Add the IP to the DNS
resource "google_dns_record_set" "my_web" {
  managed_zone = data.google_dns_managed_zone.dns_zone.name
  name         = "my-web.${data.google_dns_managed_zone.dns_zone.dns_name}"
  rrdatas      = [google_compute_global_address.my_web_ip.address]
  ttl          = 300
  type         = "A"
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "my_web_backend" {
  bucket_name = google_storage_bucket.my_web.name
  name        = "my-web-backend"
  enable_cdn  = true
}

# GCP URL map
resource "google_compute_url_map" "my_web" {
  name            = "my-web-url-map"
  default_service = google_compute_backend_bucket.my_web_backend.self_link
  host_rule {
    hosts        = ["*"]
    path_matcher = "allpaths"
  }
  path_matcher {
    name            = "allpaths"
    default_service = google_compute_backend_bucket.my_web_backend.self_link
  }
}

# GCP HTTP proxy
resource "google_compute_target_http_proxy" "my_web" {
  name    = "my-web-http-proxy"
  url_map = google_compute_url_map.my_web.self_link
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "my_web_forwarding_rule" {
  name   = "my-web-forwarding-role"
  target = google_compute_target_http_proxy.my_web.self_link
  load_balancing_scheme = "EXTERNAL"
  ip_address = google_compute_global_address.my_web_ip.address
  ip_protocol = "TCP"
  port_range = "80"
}

