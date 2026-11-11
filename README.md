# Rugix: Quick Start Template for Mender

This template showcases how to build a [Rugix](https://rugix.org) image with [Mender](https://mender.io) integration.

For general information about Rugix and how to use it, check out [Rugix's documentation](https://rugix.org/docs/getting-started).

This template allows you to build images for:

- Raspberry Pi 4 and 5 (ARM64).
- Any EFI-compatible system (ARM64 and AMD64).

For Raspberry Pi, images can be built based on Raspberry Pi OS or Debian.
Note that Rugix also supports older models of Raspberry Pi, however, we do not showcase images for them here.

The images are ready-to-use and devices running them should connect to Mender's device management platform automatically.
To this end, you must configure the tenant/organization token (details bellow).
Note that while fully compatible with Mender's cloud offering and update client, **the actual update is handled by Rugix**.
In this setup, Mender only serves as a frontend for Rugix's OTA update mechanism.

## Configuration

To configure Mender, you need your Mender tenant/organization token.
Note that this token, as any secret, should not be committed to Git.
For this reason, we use a `.env` file for secrets.
To configure the token, copy the `env.template` file to `.env` and replace the placeholder with your actual token.
In addition, you may need to change the server URL in the [`mender.conf`](recipes/mender/files/mender.conf) configuration file.
If you want to be able to connect via SSH, put your public SSH key in the respective layer configuration file in [`layers`](layers).

## Building Images

Install Docker or Podman. After configuring `.env`, you can build an image
directly with the included Bakery launcher:

```sh
./run-bakery bake image rpi-raspios
```

Install [mise](https://mise.jdx.dev/) to use the equivalent convenience tasks
below. These image and bundle builds use your installed container runtime.

To build an image for Raspberry Pi 4, including the necessary firmware update:

```bash
mise run build rpi-raspios-pi4
```

To build an image for Raspberry Pi 5 or 4, without the firmware update:

```bash
mise run build rpi-raspios
```

To create an update bundle and a Mender artifact from the produced `rpi-raspios` system,
install `mender-artifact` as described under [Development Tasks](#development-tasks):

```bash
mise run build:bundle -- --disable-compression rpi-raspios

# If Docker created root-owned build files:
sudo chown -R "$(id -u):$(id -g)" build

VERSION=$(date +'%Y%m%d.%H%M')
export VERSION
MENDER_ARTIFACT_DEVICE_TYPE=raspberrypi4 \
MENDER_ARTIFACT_OUTPUT="build/$VERSION.mender" \
    mise run build:artifact rpi-raspios
```

To build an image for an AMD64 EFI-compatible system:

```bash
mise run build efi-debian-amd64
```

To build an image that is directly usable with a VM (e.g., QEMU):

```bash
mise run build efi-debian-amd64-vm
```

## Remarks

### GitHub Actions

This repository contains a workflow for GitHub Actions which builds all images (except the VM images) and a Mender artifact for each image.
Each image builds on a runner matching its CPU architecture, without QEMU emulation.
The artifact step uses the shared mise task with the Nix-pinned Mender Artifact CLI.
To inject the Mender tenant token, you need to create a GitHub Actions secret named `ENV` and put the contents of the `.env` file there.
Note that the build artifacts contain the token and are thus not uploaded by default.
If you want to extract the artifacts, uncomment the respective section in the workflow.
**Make sure your repository is private in order to not leak the token.**

### Simple SBOM

As part of the image building process, a simple *software bill of materials* (SBOM) is generated.
The SBOM is stored in `build/*.sbom.txt` and is also included in the build artifacts of the GitHub Actions workflow.

## Development Tasks

The tasks use installed host tools. Image and bundle builds require Docker
or Podman; artifact creation requires `mender-artifact` (tested with 4.4.2).
Integration tests use rootless Podman so their build files remain accessible
to the host artifact CLI; they also require `ssh-keygen`. Docker can leave
build files owned by root; restore ownership before running the host artifact
CLI, as shown below.

~~~sh
mise run build efi-debian-arm64
mise run build:bundle efi-debian-arm64
# If Docker created root-owned build files:
sudo chown -R "$(id -u):$(id -g)" build
mise run build:artifact efi-debian-arm64
DOCKER=podman mise run test
~~~

`build:artifact` wraps an existing bundle as a Mender module artifact. Local
tests and CI share `scripts/build-mender-artifact.sh` and use `mender-artifact`
from `PATH`.
Set `MENDER_ARTIFACT_DEVICE_TYPE`, `NAME`, `VERSION`, or
`MENDER_ARTIFACT_OUTPUT` to override its metadata and output path.

If you use Nix with flakes enabled, an optional shell supplies Podman, SSH
tools, and Mender Artifact on x86-64 and AArch64 Linux. For example:

```sh
nix develop --command mise run build:artifact efi-debian-arm64
```


## Support

This repository is covered by
[Tier 3: Example Integration](https://rugix.org/support-commitment/#tier-example-integration)
of the Rugix Support Commitment.
