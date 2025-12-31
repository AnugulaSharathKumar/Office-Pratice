output "vm_name" {
  value = google_compute_instance.ubuntu_vm.name
}

output "vm_ip" {
  value = google_compute_instance.ubuntu_vm.network_interface[0].access_config[0].nat_ip
}
