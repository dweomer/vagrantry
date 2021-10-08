#!/usr/bin/env bash
set -eux -o pipefail

if [[ ! -e _output/.timestamp ]]; then
    rm -rvf _output
    mkdir -vp _output
    date --utc +%Y%m%d%H%M%S > _output/.timestamp
fi

for version in ${VERSIONS:="8.4.2105 8.3.2011 8.2.2004 8.1.1911 7.9.2009 7.8.2003 7.7.1908 7.6.1810 7.5.1804 7.4.1708 7.3.1611"}; do
    case $version in
        8.2.*|8.3.*)
            edition=minimal
            ;;
        8.*)
            edition=dvd1
            ;;
        7.*)
            edition=Minimal
            ;;
    esac

    # build the vms
    if [[ -n ${VAGRANTRY_PUBLISH_BUILD:=} ]]; then
        for provider in ${PROVIDERS:="libvirt virtualbox vmware"}; do
            packer build \
                --parallel-builds=1 \
                --var iso_version="$version" \
                --var iso_edition="$edition" \
                --var provider="$provider" \
                --var headless=true \
            ./distros/centos/.
        done
    fi

    # compress the tarballs
    if [[ -n ${VAGRANTRY_PUBLISH_COMPRESS:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish=compress://${VAGRANTRY_PUBLISH_COMPRESS} \
        ./distros/centos/.
    fi

    # checksum all `*.box` and `*.tar*` files
    if [[ -n ${VAGRANTRY_PUBLISH_CHECKSUM:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish=checksum://${VAGRANTRY_PUBLISH_CHECKSUM} \
        ./distros/centos/.
    fi

    # conditionally publish via rsync
    if [[ -n ${VAGRANTRY_PUBLISH_RSYNC:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish="rsync://${VAGRANTRY_PUBLISH_RSYNC}" \
        ./distros/centos/.
    fi

    # conditionally publish via s3
    if [[ -n ${VAGRANTRY_PUBLISH_S3:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish="s3://${VAGRANTRY_PUBLISH_S3}" \
        ./distros/centos/.
    fi

    # conditionally publish to vagrant-cloud
    if [[ -n ${VAGRANTRY_PUBLISH_CLOUD:=} ]]; then
        packer build \
            --parallel-builds=1 \
            --var iso_version="$version" \
            --var iso_edition="$edition" \
            --var publish="vagrant-cloud://${VAGRANTRY_PUBLISH_CLOUD}" \
        ./distros/centos/.  # dweomer,,https://virt.dweomer.io/vagrant/boxes
    fi
done
