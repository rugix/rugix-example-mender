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

To build an image for Raspberry Pi 4, including the necessary firmware update:

```bash
mise run build rpi-raspios-pi4
```

To build an image for Raspberry Pi 5 or 4, without the firmware update:

```bash
mise run build rpi-raspios
```

To create an update bundle and a Mender artifact from the produced `rpi-raspios` system:

```bash
mise run build:bundle -- --disable-compression rpi-raspios

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
The artifact step uses the same mise task and pinned Nix CLI as local builds.
To inject the Mender tenant token, you need to create a GitHub Actions secret named `ENV` and put the contents of the `.env` file there.
Note that the build artifacts contain the token and are thus not uploaded by default.
If you want to extract the artifacts, uncomment the respective section in the workflow.
**Make sure your repository is private in order to not leak the token.**

### Simple SBOM

As part of the image building process, a simple *software bill of materials* (SBOM) is generated.
The SBOM is stored in `build/*.sbom.txt` and is also included in the build artifacts of the GitHub Actions workflow.

## Development Tasks

Install Nix with flakes enabled and mise. On x86-64 and AArch64 Linux, mise
tasks select Nix for Podman, SSH tools, and `mender-artifact`.

~~~sh
mise run build efi-debian-arm64
mise run build:bundle efi-debian-arm64
mise run build:artifact efi-debian-arm64
mise run test
~~~

`build:artifact` wraps an existing bundle as a Mender module artifact. Local
tests and CI share `scripts/build-mender-artifact.sh`; the command uses the
pinned native CLI without installing packages inside a temporary container.
Set `MENDER_ARTIFACT_DEVICE_TYPE`, `NAME`, `VERSION`, or
`MENDER_ARTIFACT_OUTPUT` to override its metadata and output path.


## Support

This repository is covered by
[Tier 3: Example Integration](https://rugix.org/support-commitment/#tier-example-integration)
of the Rugix Support Commitment.
