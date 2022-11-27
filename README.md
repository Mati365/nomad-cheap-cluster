# infrastructure

Site VPS server configuration

## Local testing

Generate ansible RSA key in `ansible/keys/ansible/` and then:

```bash
./start-dev.sh --create-vm
```

## Useful commands

### Nomad

List server members:

```bash
sudo nomad server members \
  -address=https://localhost:4646 \
  -ca-path=/var/www/nomad/tls/nomad-ca.pem \
  -client-cert=/var/www/nomad/tls/server.pem \
  -client-key=/var/www/nomad/tls/server-key.pem \
  -token=$(sudo jq -r '.SecretID' /var/www/nomad/server/bootstrap.json)
```

List node members:

```bash
sudo nomad node status \
  -address=https://localhost:4646 \
  -ca-path=/var/www/nomad/tls/nomad-ca.pem \
  -client-cert=/var/www/nomad/tls/server.pem \
  -client-key=/var/www/nomad/tls/server-key.pem \
  -token=$(sudo jq -r '.SecretID' /var/www/nomad/server/bootstrap.json)
```

Purge job:

```bash
sudo nomad job stop -purge \
  -address=https://localhost:4646 \
  -ca-path=/var/www/nomad/tls/nomad-ca.pem \
  -client-cert=/var/www/nomad/tls/server.pem \
  -client-key=/var/www/nomad/tls/server-key.pem \
  -token=$(sudo jq -r '.SecretID' /var/www/nomad/server/bootstrap.json) \
  <job name>
```

Take vault snapshot:

```bash
VAULT_TOKEN=<token> vault operator raft snapshot save -tls-skip-verify ./snapshot.snap
```

### Consul

```bash
consul members -token=$(sudo cat /var/www/consul/tokens/bootstrap.key)
```

## License

MIT License

Copyright (c) 2022 Mateusz Bagiński

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
