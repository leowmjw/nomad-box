job "whoami" {
  datacenters = ["dc1"]
  type = "service"
  update {
    stagger = "10s"
    max_parallel = 1
  }
  group "identity" {
    count = 2
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      size = 300
    }

    task "whoami" {
      driver = "docker"
      config {
        image = "emilevauge/whoami"
        port_map {
          http = 80
        }
      }

      resources {
        cpu    = 100 # 500 MHz
        memory = 64 # 256MB
        network {
          mbits = 1
          port "http" {}
        }
      }

      service {
	name = "global-whoami"
        tags = [
		"traefik.tags=blue,lolcats",
		"urlprefix-whoami.10.0.51.4.xip.io/whoami",
		"traefik.frontend.rule=Host:whoami.10.1.51.181.xip.io", 
		"traefik.frontend.entryPoints=http"
	]
        port = "http"
      }
    }
  }
}
