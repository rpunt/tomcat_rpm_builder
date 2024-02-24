#!/bin/bash

usage() {
  echo -e "\nUsage:   $0 -v Tomcat_Version"
  echo -e "\nExample: $0 -v 9.0.86\n"
  exit 1
}

while getopts hv: OPTION; do
  case $OPTION in
    h)  usage
        exit 2;;
    v)  VERSION=$OPTARG;;
    ?)  usage
        exit;;
  esac
done
MAJOR=$(echo "$VERSION" | cut -f1 -d'.')

if [ "$#" -lt 2 ]; then
  usage
  exit 1
fi

# black=$(tput setaf 0)
red=$(tput setaf 1)
# green=$(tput setaf 2)
# yellow=$(tput setaf 3)
# blue=$(tput setaf 4)
# magenta=$(tput setaf 5)
# cyan=$(tput setaf 6)
# white=$(tput setaf 7)
reset=$(tput sgr0)

command -v docker >/dev/null 2>&1 || { echo >&2 "${red}I require docker but it's not installed.${reset}"; exit 1; }

docker build -t "rpmbuild-tomcat" -f "./tomcat.Dockerfile" .

BUILD="$(pwd)/BUILD"
mkdir -p "${BUILD}/RPMS"
mkdir -p "${BUILD}/SCRATCH"
mkdir -p "${BUILD}/SOURCES"

# TODO: replace initscript with unit file
# cp apache-tomcat-initscript "${BUILD}/SOURCES"

test -f "${BUILD}/SOURCES/apache-tomcat-${VERSION}.tar.gz" || wget "http://archive.apache.org/dist/tomcat/tomcat-${MAJOR}/v${VERSION}/bin/apache-tomcat-${VERSION}.tar.gz" -O "${BUILD}/SOURCES/apache-tomcat-${VERSION}.tar.gz"
if [ ! -f "${BUILD}/SOURCES/apache-tomcat-${VERSION}.tar.gz" ]; then
  echo -e "\n${red}Could not download Tomcat sources; please place the tarball from http://archive.apache.org/dist/tomcat/tomcat-${MAJOR}/v${VERSION} into ${BUILD}/SOURCES/apache-tomcat-${VERSION}.tar.gz${reset}\n"
  exit 1
fi

sed -e "s/___VERSION___/${VERSION}/g" "${BUILD}/../apache-tomcat-template.spec" >"${BUILD}/SCRATCH/apache-tomcat-${VERSION}.spec"

docker run --rm -it \
  --hostname rpmbuild \
  --volume "${BUILD}/RPMS:/home/builder/rpmbuild/RPMS" \
  --volume "${BUILD}/SOURCES:/home/builder/rpmbuild/SOURCES" \
  --volume "${BUILD}/SCRATCH:/home/builder/rpmbuild/SPECS/" \
  "rpmbuild-tomcat" \
  bash -c "sudo yum-builddep rpmbuild/SPECS/apache-tomcat-${VERSION}.spec; rpmbuild -bb rpmbuild/SPECS/apache-tomcat-${VERSION}.spec"

# # or run interactively for debugging:
# MAJOR=9
# BUILD="$(pwd)/BUILD"
# # discard the container after build:
# docker run --rm -it \
#   --entrypoint bash \
#   --volume "${BUILD}/RPMS:/home/builder/rpmbuild/RPMS" \
#   --volume "${BUILD}/SOURCES:/home/builder/rpmbuild/SOURCES" \
#   --volume "${BUILD}/SCRATCH:/home/builder/rpmbuild/SPECS/" \
#   "rpmbuild-tomcat${MAJOR}"
# # keep the container after build:
# docker exec -it \
#   --entrypoint bash \
#   --volume "${BUILD}/RPMS:/home/builder/rpmbuild/RPMS" \
#   --volume "${BUILD}/SOURCES:/home/builder/rpmbuild/SOURCES" \
#   --volume "${BUILD}/SCRATCH:/home/builder/rpmbuild/SPECS/" \
#   "rpmbuild-tomcat${MAJOR}"

RC=$?

if [ $RC != 0 ]; then
  echo -e "\n$(tput setaf 1)Build process RC: ${RC}\nAn error occurred while building your RPM. Please investigate.$(tput sgr0)\n"
else
  echo -e "\n$(tput setaf 2)Your RPM has been created within ${BUILD}/RPMS/$(tput sgr0)\n"
fi
