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
# execute 'bash ./build.sh -v 8.0.53' (substituting the appropriate Tomcat version)

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

%install
%{__mkdir} -p %{buildroot}/opt/tomcat
%{__mv} bin conf lib logs temp webapps %{buildroot}/opt/tomcat
%{__rm} -rf %{buildroot}/opt/tomcat/webapps/*
%{__rm} -rf %{buildroot}/opt/tomcat/temp/*

%clean
%{__rm} -rf %{buildroot}

%files
%attr(-,tomcat,tomcat) /opt/tomcat

%changelog
