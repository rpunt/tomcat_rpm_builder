FROM centos:7

LABEL maintainer Ryan Punt "ryan@mirum.org"

# OS stuff -
RUN yum install -y gcc make rpm-build perl sudo tar perl-ExtUtils-MakeMaker zlib-devel wget which; yum clean all
RUN adduser --comment "RPM Builder" --home /home/builder --create-home builder ; mkdir -p /home/builder/rpmbuild/{BUILD,SPECS,SOURCES,RPMS,SRPMS} ; chown -R builder /home/builder
RUN echo "builder ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

USER builder
WORKDIR /home/builder
CMD /bin/bash
