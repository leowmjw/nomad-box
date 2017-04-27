job "whoami" {
  datacenters = ["dc1"]
  type = "service"
  constraint {
    attribute = "${attr.kernel.name}"
    value     = "linux"
  }
  update {
    stagger = "10s"
    max_parallel = 1
  }
  group "identity" {
    count = 1
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
		"traefik.frontend.rule=Host:whoami.local", 
		"traefik.frontend.entryPoints=http"
	]
        port = "http"
      }
    }
  }
}
