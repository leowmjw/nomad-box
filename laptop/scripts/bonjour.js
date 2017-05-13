var bonjour = require('bonjour')()
 
// advertise an HTTP server on port 3000 
bonjour.publish({ name: 'My Web Server', host: 'myapp.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'Quote Service', host: 'quote.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'NodeRed Service', host: 'nodered.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'WhoAmI Service', host: 'whoami.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'Fluentd Service', host: 'fluentd.local', type: 'http', port: 3000 })

bonjour.publish({ name: 'Traefik Service', host: 'traefik.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'Consul Service', host: 'consul.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'Nomad Service', host: 'nomad.local', type: 'http', port: 3000 })
bonjour.publish({ name: 'Hashi-UI Service', host: 'dashboard.local', type: 'http', port: 3000 })


