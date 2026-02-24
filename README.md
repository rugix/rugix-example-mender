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
./run-bakery bake image rpi-raspios-pi4
```

To build an image for Raspberry Pi 5 or 4, without the firmware update:

```bash
./run-bakery bake image rpi-raspios
```

To create an update bundle and a Mender artifact from the produced `rpi-raspios` system:

```bash
./run-bakery bake bundle --disable-compression rpi-raspios

VERSION=$(date +'%Y%m%d.%H%M')
mender-artifact write module-image \
    -n "Image ${VERSION}" \
    -t raspberrypi4 \
    -T rugix-bundle \
    -f build/rpi-raspios/system.rugixb \
    -o build/${VERSION}.mender \
    --software-name "Rugix Image" \
    --software-version "${VERSION}"
```

To build an image for an AMD64 EFI-compatible system:

```bash
./run-bakery bake image efi-debian-amd64
```

To build an image that is directly usable with a VM (e.g., QEMU):

```bash
./run-bakery bake image efi-debian-amd64-vm
```

## Remarks

### GitHub Actions

This repository contains a workflow for GitHub Actions which builds all images (except the VM images) and a Mender artifact for each image.
To inject the Mender tenant token, you need to create a GitHub Actions secret named `ENV` and put the contents of the `.env` file there.
Note that the build artifacts contain the token and are thus not uploaded by default.
If you want to extract the artifacts, uncomment the respective section in the workflow.
**Make sure your repository is private in order to not leak the token.**

### Simple SBOM

As part of the image building process, a simple *software bill of materials* (SBOM) is generated.
The SBOM is stored in `build/*.sbom.txt` and is also included in the build artifacts of the GitHub Actions workflow.
