%define origname NetSDS-Asterisk-tools
%define version 0.1

Name: %origname
Summary: Asterisk tools: callback, voicefile-rotate
Version: %version
Release: alt1
License: GPL
Group: Development/Perl
BuildArch: noarch

Packager: Alex Radetsky <rad@rad.kiev.ua>

Source: %origname-%version.tar.gz

%description
Some useful tools: 
- callback
- voicefile rotate 

%prep
%setup -n %origname-%version

%build
%install
mkdir -p %buildroot/usr/share/doc/%origname
install -m755 callback.sh %buildroot/usr/share/doc/%origname
install -m755 voicefiles.rotate.sh %buildroot/usr/share/doc/%origname


%files
%doc /usr/share/doc/%origname/callback.sh
%doc /usr/share/doc/%origname/voicefiles.rotate.sh 

%changelog
* Tue Nov 10 2009 Alex Radetsky <rad@rad.kiev.ua> 0.1-alt1
- create package.



