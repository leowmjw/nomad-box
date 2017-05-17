job "forum" {

  datacenters = ["dc1"]
  type = "service"

  constraint {
    attribute = "${attr.kernel.name}"
    value = "linux"
  }

  update {
    stagger = "2s"
    max_parallel = 1
  }

/*
  group "current" {

    constraint {
      attribute = "${attr.unique.hostname}"
      value = "acme-nomad-dev-experiment-node-1"
    }

    count = 5
    restart {
      attempts = 10
      interval = "1m"
      delay = "5s"
      mode = "delay"
    }

    ephemeral_disk {
      size = 500
    }

    task "caddy" {
      driver = "docker"
      config {
        image = "leowmjw/caddy:v0.1"
        port_map {
          http = 80
        }
        command = "/usr/bin/caddy"
        args = [
          "-conf", "/local/Caddyfile"
        ]
      }

      resources {
        cpu = 100
        memory = 100
        network {
          port "http" {}
        }
      }

      service {
        tags = [
          "traefik.tags=current,lolcats",
          "traefik.frontend.rule=Host:whoami.local",
          "traefik.frontend.entryPoints=http"
        ]
        port = "http"
      }

      template {
        data = <<EOF
# Docs: https://caddyserver.com/docs/caddyfile
0.0.0.0:80
root /var/www/public
fastcgi / {{ env "NOMAD_ADDR_php_fpm_phpfpm" }} php {
    index index.php
}

# To handle .html extensions with laravel change ext to
# ext / .html

rewrite {
    r .*
    ext /
    to /index.php?{query}
}
gzip
browse
log /var/log/caddy/access.log
errors /var/log/caddy/error.log

        EOF
        destination = "local/Caddyfile"
      }

    }

    task "php-fpm" {
      driver = "docker"
      config {
        image = "leowmjw/forum:v0.1"
        port_map {
          phpfpm = "9000"
        }
        dns_servers = ["${attr.unique.network.ip-address}"]
      }

      resources {
        cpu = 500
        memory = 300
        network {
          port "phpfpm" {}
        }
      }

      service {
        tags = ["forum"]
        port = "phpfpm"
      }

      template {
        data = <<EOF
APP_ENV=local
APP_KEY=base64:5ImsTupEy0ciUhsMasslYk4erjzeCV76r1Q2xZ2Hbu4=
APP_DEBUG=true
APP_LOG_LEVEL=debug
APP_URL=http://acme-nomad-dev-worker-node-1

DB_CONNECTION=mysql
DB_HOST=data-mysql.service.consul
DB_PORT=3308
DB_DATABASE=laravel
DB_USERNAME=laravel
DB_PASSWORD=passw0rd

BROADCAST_DRIVER=log
CACHE_DRIVER=file
SESSION_DRIVER=file
QUEUE_DRIVER=sync

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_DRIVER=smtp
MAIL_HOST=mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
        EOF
        destination = "local/env"
      }

    }

  }

*/

  group "blue" {

    constraint {
      attribute = "${attr.unique.hostname}"
      value = "acme-nomad-dev-experiment-node-1"
    }

    count = 1
    restart {
      attempts = 10
      interval = "1m"
      delay = "5s"
      mode = "delay"
    }

    ephemeral_disk {
      size = 500
    }

    task "caddy" {
      driver = "docker"
      config {
        image = "leowmjw/caddy:v0.5"
        port_map {
          http = 80
        }
        command = "/usr/bin/caddy"
        args = [
          "-conf", "/local/Caddyfile"
        ]
      }

      resources {
        cpu = 100
        memory = 100
        network {
          port "http" {}
        }
      }

      service {
        tags = [
          "traefik.tags=blue,lolcats",
          "traefik.frontend.rule=Host:quote.local;Headers:Secret,Bob",
          "traefik.frontend.entryPoints=http"
        ]
        port = "http"
      }

      template {
        data = <<EOF
# Docs: https://caddyserver.com/docs/caddyfile
0.0.0.0:80
root /var/www/public
fastcgi / {{ env "NOMAD_ADDR_php_fpm_phpfpm" }} php {
    index index.php
}

# To handle .html extensions with laravel change ext to
# ext / .html

rewrite {
    r .*
    ext /
    to /index.php?{query}
}
gzip
browse
log /var/log/caddy/access.log
errors /var/log/caddy/error.log

        EOF
        destination = "local/Caddyfile"
      }

    }

    task "php-fpm" {
      driver = "docker"
      config {
        image = "leowmjw/forum:v0.5"
        port_map {
          phpfpm = "9000"
        }
        dns_servers = ["${attr.unique.network.ip-address}"]
        command = "php-fpm"
        args = [
          "-y", "/local/php-fpm.conf"
        ]
      }

      resources {
        cpu = 500
        memory = 300
        network {
          port "phpfpm" {}
        }
      }

      service {
        tags = ["forum"]
        port = "phpfpm"
      }

      template {
        data = <<EOF
; Template
; test

[global]

; What is missing?
; needed?
[global]
error_log = /proc/self/fd/2

[www]
; if we send this to /proc/self/fd/1, it never appears
access.log = /proc/self/fd/2

clear_env = no

; Ensure worker stdout and stderr are sent to the main error log.
catch_workers_output = yes

user = www-data
group = www-data

listen = 0.0.0.0:9000

pm = dynamic

pm.max_children = 20

pm.start_servers = 2

pm.min_spare_servers = 1

pm.max_spare_servers = 3

;---------------------
; Make specific Docker environment variables available to PHP
env[APP_ENV] = "local"
env[APP_KEY] = "base64:5ImsTupEy0ciUhsMasslYk4erjzeCV76r1Q2xZ2Hbu4="
env[APP_DEBUG] = true
env[APP_LOG_LEVEL] = "debug"
env[APP_URL] = "http://quote.local"

env[DB_CONNECTION] = "mysql"
env[DB_HOST] = "data-mysql.service.consul"
env[DB_PORT] = "{{ key "blue/config/DBPORT" }} "
env[DB_DATABASE] = "laravel"
env[DB_USERNAME] = "laravel"
env[DB_PASSWORD] = "passw0rd"

env[BROADCAST_DRIVER] = "log"
env[CACHE_DRIVER] = {{ key "blue/config/CACHEDRIVER" }}
env[SESSION_DRIVER] = "file"
env[QUEUE_DRIVER] = "sync"

catch_workers_output = yes

[www]

user = www-data
group = www-data
listen = 127.0.0.1:9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
[global]
daemonize = no

[www]
listen = [::]:9000

; no more... 
        EOF
        destination = "local/php-fpm.conf"
      }

    }

  }

  group "data" {

    constraint {
      attribute = "${attr.unique.hostname}"
      value = "acme-nomad-dev-worker-node-1"
    }

    count = 1
    restart {
      attempts = 10
      interval = "5m"
      delay = "25s"
      mode = "delay"
    }

    ephemeral_disk {
      migrate = "true"
      size = 1500
      sticky = "true"
    }

    task "mysql" {
      driver = "docker"
      config {
        image = "mysql"
        port_map {
          mysql = "3306"
        }
      }

      env {
        MYSQL_DATABASE = "laravel"
        MYSQL_USER = "laravel"
        MYSQL_PASSWORD = "passw0rd"
        MYSQL_PORT = "3306"
        MYSQL_ROOT_PASSWORD = "root"
      }

      resources {
        memory = 1500
        network {
          port "mysql" {
            static = "3308"
          }
        }
      }

      service {
        name = "data-mysql"
        tags = ["master"]
        port = "mysql"
      }
    }

  }

}
