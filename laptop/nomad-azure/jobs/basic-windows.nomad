job "win-db" {

  datacenters = ["dc1"]
  type = "service"

  constraint {
     attribute = "${attr.kernel.name}"
     value     = "windows"
  }

  update {
    stagger = "10s"
    max_parallel = 1
  }

  group "store" {
    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }
    ephemeral_disk {
      size = 3000
    }

    task "aspnet" {
      driver = "docker"
      config {
        image = "leowmjw/musicstore"
        port_map {
          web = 5000
        }
      }

      env {
        "Data:DefaultConnection:ConnectionString" = "Server=10.0.2.5,1455;Database=MusicStore;User Id=sa;Password=Passw0rd;MultipleActiveResultSets=True"
      }

      resources {
        cpu    = 800 # 500 MHz
        memory = 500 # 256MB
        network {
          mbits = 3
          port "web" {}
        }
      }

      service {
        name = "aspnet-music-app"
        tags = [
                 "monitor", 
                 "traefik.tags=lolcats",
		 "traefik.frontend.rule=Host:store.10.0.3.4.xip.io"
                ]
        port = "web"
      }

    }

    task "sqlserver" {
      # The "driver" parameter specifies the task driver that should be used to
      # run the task.
      driver = "docker"
      config {
        image = "microsoft/mssql-server-2016-express-windows"
        port_map {
          db = 1433 
        }
      }

      env {
	"sa_password" = "Passw0rd"
      }
      resources {
        cpu    = 2500 # 500 MHz
        memory = 1024 # 256MB
        network {
          mbits = 10
          port "db" {
	    static = "1455"
	  }
        }
      }

      service {
        name = "mssql-db"
        tags = [
                 "monitor", 
                 "database"
                ]
        port = "db"
      }
    }
  }
}
