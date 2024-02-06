output "url" {
  description = "Website URL"
  value       = google_compute_url_map.my_web.self_link
}