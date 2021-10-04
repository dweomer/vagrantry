#!/usr/bin/env bash
set -ux -o pipefail
if [[ ! -e _output/.timestamp ]]; then
    rm -rvf _output
    mkdir -vp _output
    date --utc +%Y%m%d%H%M%S > _output/.timestamp
fi
for version in ${VERSIONS:="8.4.2105 8.3.2011 8.2.2004 8.1.1911 7.9.2009 7.8.2003 7.7.1908 7.6.1810 7.5.1804 7.4.1708 7.3.1611"}; do
    for provider in ${PROVIDERS:="libvirt virtualbox vmware"}; do
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
        packer build \
            --force \
            --parallel-builds=1 \
            --var iso_version=$version \
            --var iso_edition=$edition \
            --var provider=$provider \
            --var headless=true \
        ./distros/centos/.
    done
done
