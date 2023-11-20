output "master_ip" {
  value = yandex_compute_instance.kubenode[0].network_interface.0.nat_ip_address
}
output "worker_ip" {
  value = yandex_compute_instance.kubenode[1].network_interface.0.nat_ip_address
}
