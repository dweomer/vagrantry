#!/usr/bin/env bash
set -eux -o pipefail

if [[ ! -e _output/.timestamp ]]; then
    rm -rvf _output
    mkdir -vp _output
    date --utc +%Y%m%d%H%M%S > _output/.timestamp
fi

for version in ${VERSIONS:="Snapshot20211117"}; do
    build_version="16.2021.1117"
    # build the vms
    if [[ -n ${VAGRANTRY_BUILD:=} ]]; then
        for provider in ${PROVIDERS:="libvirt virtualbox vmware"}; do
            packer build \
                --parallel-builds=1 \
                --var iso_version="$version" \
                --var build_version="$build_version" \
                --var provider="$provider" \
                --var headless="${VAGRANTRY_BUILD_HEADLESS:=true}" \
            ./distros/microos/.
        done
    fi

    # compress the tarballs
    if [[ -n ${VAGRANTRY_PUBLISH_COMPRESS:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var build_version="$build_version" \
            --var publish=compress://${VAGRANTRY_PUBLISH_COMPRESS} \
        ./distros/microos/.
    fi

    # checksum all `*.box` and `*.tar*` files
    if [[ -n ${VAGRANTRY_PUBLISH_CHECKSUM:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var build_version="$build_version" \
            --var publish=checksum://${VAGRANTRY_PUBLISH_CHECKSUM} \
        ./distros/microos/.
    fi

    # conditionally publish via rsync
    if [[ -n ${VAGRANTRY_PUBLISH_RSYNC:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var build_version="$build_version" \
            --var publish="rsync://${VAGRANTRY_PUBLISH_RSYNC}" \
        ./distros/microos/.
    fi

    # conditionally publish via s3
    if [[ -n ${VAGRANTRY_PUBLISH_S3:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var build_version="$build_version" \
            --var publish="s3://${VAGRANTRY_PUBLISH_S3}" \
        ./distros/microos/.
    fi

    # conditionally publish to vagrant-cloud
    if [[ -n ${VAGRANTRY_PUBLISH_CLOUD:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var build_version="$build_version" \
            --var cloud_org="${VAGRANTRY_CLOUD_ORG:=dweomer}" \
            --var cloud_tag="${VAGRANTRY_CLOUD_TAG:=microos-amd64}" \
            --var cloud_url="${VAGRANTRY_CLOUD_URL:=https://virt.dweomer.io/vagrant/boxes}" \
            --var publish="vagrant-cloud" \
        ./distros/microos/.
    fi
done
