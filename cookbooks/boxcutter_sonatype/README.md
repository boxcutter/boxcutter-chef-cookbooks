boxcutter_sonatype
==================

Usage
-----

To use this automation, you need to define a password for the `admin` account.
The `admin` account is used to authorize all the API calls that drive this
automation.

Since this is a secret, it is recommended this key be stored in
`node.run_state` so that it is not stored on the Chef server after the Chef run.

The automation will look for credentials in the following preference order:
1. `node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password']`
4. `node['boxcutter_sonatype']['nexus_repository']['admin_password']`

Provide the `admin` password in `node.run_state`, like so. The automation will
automatically

The automation will automatically allocate a new one-time preauthorization key using
the OAuth Client on each Chef run, when something needs to be changed on your tailnet.
Conflicts with `auth_key`, if provided.

```
# Initialize the parent hash if it doesn't exist
node.run_state['boxcutter_tailscale'] ||= {}
node.run_state['boxcutter_sonatype'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository'] ||= {}
node.run_state['boxcutter_sonatype']['nexus_repository']['admin_password'] = 'Superseekret63'
```

NOTE: Instructions for recovery if Chef ever gets out of sync with the current
admin password are located as this [link](https://support.sonatype.com/hc/en-us/articles/213467158-How-to-reset-a-forgotten-admin-password-in-Sonatype-Nexus-Repository-3).

Raw Repository
--------------

```bash
# Create file - Direct Upload using HTTP PUT
cat >hello.txt <<EOF
Hello Sonatype Nexus!
EOF

NEXUS_USERNAME=test
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=https://example-nexus.boxcutter.dev
curl --verbose --user ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
  --request PUT --upload-file hello.txt \
  "${NEXUS_SERVER}/repository/testy-hosted/sandbox/hello.txt"

# Create file - Direct Upload using HTTP POST
NEXUS_USERNAME=test
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=https://hq0-nexus01.sandbox.polymathrobotics.dev
curl --verbose --user ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
  --request POST "${NEXUS_SERVER}/service/rest/v1/components?repository=testy-hosted" \
  --header "accept: application/json" \
  --header "Content-Type: multipart/form-data" \
  --form "raw.directory=/sandbox" \
  --form "raw.asset1=@hello.txt" \
  --form "raw.asset1.filename=hello.txt"

# List files
NEXUS_USERNAME=test
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=https://example-nexus.boxcutter.dev
curl --user ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
  "${NEXUS_SERVER}/service/rest/v1/components?repository=testy-hosted"

# Delete file
NEXUS_USERNAME=test
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=https://example-nexus.boxcutter.dev
curl --verbose --user ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
   --request DELETE \
  "${NEXUS_SERVER}/repository/testy-hosted/sandbox/hello.txt"

NEXUS_USERNAME=test
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=https://hq0-nexus01.sandbox.polymathrobotics.dev
COMPONENT_ID=cG9seW1hdGgtaW1hZ2VzOjE3MTU2MGEy
curl --verbose --user ci-sandbox:${CI_PASSWORD} \
   --request DELETE "${NEXUS_SERVER}/service/rest/v1/components/${COMPONENT_ID}" 
# Downlaod
NEXUS_SERVER=https://example-nexus.boxcutter.dev
curl --verbose -LOJ \
  "${NEXUS_SERVER}/repository/ubuntu-releases-proxy/24.04.2/ubuntu-24.04.2-live-server-amd64.iso"

NEXUS_USERNAME=test
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=http://example-nexus.boxcutter.dev
curl --verbose --user ${NEXUS_USERNAME}:${NEXUS_PASSWORD} \
  --output hello.txt \
  "${NEXUS_SERVER}/repository/polymath-images/sandbox/tmp/hello.txt"   
```

Apt Repositories
----------------

https://help.sonatype.com/en/apt-repositories.html

```bash
# Depoy package with HTTP POST (equivalent of Upload in the UI)
NEXUS_USER=admin
NEXUS_PASSWORD=superseekret
NEXUS_SERVER=https://hq0-nexus01.sandbox.polymathrobotics.dev
curl --verbose --user "${NEXUS_USER}:${NEXUS_PASSWORD}" \
    -H "Content-Type: multipart/form-data" \
    --data-binary "@./test.deb" \
    "${NEXUS_SERVER}/repository/apt-hosted/"
```

Docker Repositories
-------------------

```bash
docker login docker.hq0-nexus01.sandbox.polymathrobotics.dev
docker pull docker.hq0-nexus01.sandbox.polymathrobotics.dev/ubuntu:22.04
docker run -it --rm docker.hq0-nexus01.sandbox.polymathrobotics.dev/ubuntu:22.04
docker logout docker.hq0-nexus01.sandbox.polymathrobotics.dev

cat >Containerfile <<EOF
FROM docker.hq0-nexus01.sandbox.polymathrobotics.dev/ubuntu:22.04

RUN apt-get update
RUN apt-get install -y figlet
EOF

cat >docker-bake.hcl <<EOF
target "default" {
  tags = ["docker.hq0-nexus01.sandbox.polymathrobotics.dev/testy"]
  dockerfile = "Containerfile"
  platforms = ["linux/amd64", "linux/arm64/v8"]
}
EOF

docker login docker.hq0-nexus01.sandbox.polymathrobotics.dev
docker buildx create --use --name testy-buildkit --driver docker-container
docker buildx bake --metadata-file metadata.json --push
docker buildx rm testy-buildkit
docker logout
```

Pypi Repositories
-----------------

```bash
# Per-install (one-time use)
NEXUS_SERVER=https://example-nexus.boxcutter.dev
pip install --index-url "${NEXUS_SERVER}/repository/python-proxy/simple/" pulumi


# Global (in pip.conf or pip.ini)
NEXUS_SERVER=https://example-nexus.boxcutter.dev
mkdir -p ~/.config/pip
cat >~/.config/pip/pip.conf <<EOF
[global]
# pip search --index (XML-RPC search) 
# https://pip.pypa.io/en/stable/cli/pip_search/
index = https://example-nexus.boxcutter.dev/repository/python-proxy/pypi

# pip install --index-url 
# https://pip.pypa.io/en/stable/cli/pip_install/
index-url = https://example-nexus.boxcutter.dev/repository/python-proxy/simple
EOF

pip config list -v
pip install pulumi
```

```bash
# Per-install (one-time use)
docker run -it --rm \
  --entrypoint /bin/bash \
  docker.io/boxcutter/python:3.10-noble
  
NEXUS_SERVER=http://host.docker.internal:2404
pip install \
  --trusted-host host.docker.internal \
  --index-url "${NEXUS_SERVER}/repository/python-proxy/simple/" pulumi

# Global (in pip.conf or pip.ini)
docker run -it --rm \
  --entrypoint /bin/bash \
  docker.io/boxcutter/python:3.10-noble

mkdir -p ~/.config/pip
cat >~/.config/pip/pip.conf <<EOF
[global]
# pip search --index (XML-RPC search) 
# https://pip.pypa.io/en/stable/cli/pip_search/
index = http://host.docker.internal:2404/repository/python-proxy/pypi

# pip install --index-url 
# https://pip.pypa.io/en/stable/cli/pip_install/
index-url = http://host.docker.internal:2404/repository/python-proxy/simple
trusted-host = host.docker.internal
EOF

# Check config
pip config list -v
pip install pulumi
```

```bash
cat >~/.netrc <<EOF
machine example-nexus.boxcutter.dev
  login admin
  password superseekret
EOF

chmod 600 ~/.netrc

mkdir -p mypackage/src/mypackage
cat >mypackage/src/mypackage/__init__.py <<EOF
def hello():
    return "Hello from mypackage"
EOF

cat >mypackage/pyproject.toml <<EOF
# pyproject.toml
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "mypackage"
version = "0.1.0"
description = "A simple example package"
authors = [{name="Your Name", email="you@example.com"}]
readme = "README.md"
license = {text = "MIT"}
requires-python = ">=3.6"

[tool.setuptools.packages.find]
where = ["src"]
EOF

cat >mypackage/README.md <<EOF
# My Package
EOF

cd mypackage
pip install --upgrade build
python -m build

# (Optional) .pypirc for upload config
cat >~/.pypirc <<EOF
# ~/.pypirc
[distutils]
index-servers =
    nexus

[nexus]
repository: https://nexus.example.com/repository/python-hosted/
username: admin
password: superseekret
EOF

pip install --upgrade twine
twine upload -r nexus dist/*

twine upload --repository-url https://nexus.example.com/repository/python-hosted/ dist/*
```
