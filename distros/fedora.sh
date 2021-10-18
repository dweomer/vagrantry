#!/usr/bin/env bash
set -eux -o pipefail

if [[ ! -e _output/.timestamp ]]; then
    rm -rvf _output
    mkdir -vp _output
    date --utc +%Y%m%d%H%M%S > _output/.timestamp
fi

for version in ${VERSIONS:="34-1.2 33-1.2 32-1.6"}; do
    edition=dvd
    # build the vms
    if [[ -n ${VAGRANTRY_BUILD:=} ]]; then
        for provider in ${PROVIDERS:="libvirt virtualbox vmware"}; do
            packer build \
                --parallel-builds=1 \
                --var iso_version="$version" \
                --var iso_edition="$edition" \
                --var provider="$provider" \
                --var headless="${VAGRANTRY_BUILD_HEADLESS:=true}" \
            ./distros/fedora/.
        done
    fi

    # compress the tarballs
    if [[ -n ${VAGRANTRY_PUBLISH_COMPRESS:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish=compress://${VAGRANTRY_PUBLISH_COMPRESS} \
        ./distros/fedora/.
    fi

    # checksum all `*.box` and `*.tar*` files
    if [[ -n ${VAGRANTRY_PUBLISH_CHECKSUM:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish=checksum://${VAGRANTRY_PUBLISH_CHECKSUM} \
        ./distros/fedora/.
    fi

    # conditionally publish via rsync
    if [[ -n ${VAGRANTRY_PUBLISH_RSYNC:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish="rsync://${VAGRANTRY_PUBLISH_RSYNC}" \
        ./distros/fedora/.
    fi

    # conditionally publish via s3
    if [[ -n ${VAGRANTRY_PUBLISH_S3:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish="s3://${VAGRANTRY_PUBLISH_S3}" \
        ./distros/fedora/.
    fi

    # conditionally publish to vagrant-cloud
    if [[ -n ${VAGRANTRY_PUBLISH_CLOUD:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish="vagrant-cloud://${VAGRANTRY_PUBLISH_CLOUD}" \
        ./distros/fedora/.  # dweomer,,https://virt.dweomer.io/vagrant/boxes
    fi
done
