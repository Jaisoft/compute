/*terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "3.5.0"
    }
  }
}*/


provider "google" {
   credentials = file("gce-terraform-poc-160efee8db4d.json")
   project = "gce-terraform-poc"
   region = "europe-southwest1"
   zone = "europe-southwest1-a"
}


resource "google_compute_instance" "my_server"{
 name            = "gce-terraform-poc"
 machine_type    = "e2-micro"
 zone            = "europe-southwest1-a"
      boot_disk {
   
        initialize_params {
	    image = "ubuntu-minimal-2004-lts"
		}
	}
      network_interface {
   
         network = "default" // Private IP
         access_config {}  // Public IP

	}
 }



