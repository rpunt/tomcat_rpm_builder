# To Build on a RHEL-based Linux machine:
#
# sudo yum -y install rpmdevtools && rpmdev-setuptree
# sudo yum install rpm-build -y
# mkdir ~/rpmbuild
# mkdir ~/rpmbuild/BUILD; mkdir ~/rpmbuild/BUILDROOT; mkdir ~/rpmbuild/RPMS; mkdir ~/rpmbuild/SOURCES; mkdir ~/rpmbuild/SPECS; mkdir ~/rpmbuild/SRPMS
#
# copy a tomcat tarball to ~/rpmbuild/SOURCES/
# copy apache-tomcat-initscript to ~/rpmbuild/SOURCES/
# copy this specfile to ~/rpmbuild/SPECS
# rpmbuild -bb ~/rpmbuild/SPECS/tomcat-7.0.63.spec
#
#
# To Build via Docker on your Mac:
#
# execute 'bash ./build.sh -v 9.0.86' (substituting the appropriate Tomcat version)

Name:       apache-tomcat
Version:    ___VERSION___
Release:    1
Summary:    Installs Tomcat %{version}
License:    Apache
URL:        http://tomcat.apache.org
BuildRoot:  %{_tmppath}/%{name}-%{version}
Source:     %{name}-%{version}.tar.gz

%description
Installs Apache Tomcat %{version} to /opt/tomcat

%prep
echo "Building %{name}-%{version}-%{release}"
%setup -q -n %{name}-%{version}
# %{__rm} -rf webapps/ROOT/*
# %{__rm} -rf temp/*

%install
%{__rm} -rf %{buildroot}
%{__mkdir} -p %{buildroot}/opt/tomcat-%{version}
# # TODO: replace initscript with unit file
# %{__mkdir} -p %{buildroot}/etc/init.d
%{__mv} bin conf lib logs temp webapps %{buildroot}/opt/tomcat-%{version}
# %{__rm} -rf %{buildroot}/opt/tomcat-%{version}/webapps/*
# # TODO: replace initscript with unit file
# # %{__cp} %{_sourcedir}/apache-tomcat-initscript %{buildroot}/etc/init.d/tomcat

%clean
%{__rm} -rf %{buildroot}

%pre
getent group tomcat > /dev/null || groupadd -r -g 58859 tomcat
getent passwd tcadmin > /dev/null || useradd -r -u 58859 -g tomcat tomcat

%post
/sbin/chkconfig --add tomcat

%preun
if [ $1 = 0 ]; then
  /sbin/service tomcat stop > /dev/null 2>&1
  # TODO: replace initscript with unit file
  # /sbin/chkconfig --del tomcat
fi

%postun
%{__rm} -rf /opt/tomcat-%{version}
# TODO: replace initscript with unit file
# %{__rm} -rf /etc/init.d/tomcat
groupdel tomcat 1>/dev/null 2>&1
userdel tomcat 1>/dev/null 2>&1

%files
%attr(-,tomcat,tomcat) /opt/tomcat-%{version}

%changelog
