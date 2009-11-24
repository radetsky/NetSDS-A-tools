%define origname NetSDS-Asterisk-tools
%define version 0.2

Name: %origname
Summary: Asterisk tools: callback, voicefile-rotate
Version: %version
Release: alt1
License: GPL
Group: Development/Perl
BuildArch: noarch

Packager: Alex Radetsky <rad@rad.kiev.ua>

Source: %origname-%version.tar.gz

Requires: perl-Data-UUID pwgen  

%description
Some useful tools: 
- callback
- voicefile rotate
- uuid (agi)

%prep
%setup -n %origname-%version

%build
%install
mkdir -p %buildroot/usr/share/doc/%origname
mkdir -p %buildroot/usr/bin
mkdir -p %buildroot/usr/lib/asterisk/agi-bin
mkdir -p %buildroot/etc/cron.daily
install -m755 callback.sh %buildroot/usr/bin/
install -m755 voicefiles.rotate.sh %buildroot/etc/cron.daily/
install -m755 uuid.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 make_sip_conf.pl %buildroot/usr/bin/


%files
/usr/bin/callback.sh
/etc/cron.daily/voicefiles.rotate.sh 
/usr/lib/asterisk/agi-bin/uuid.pl 
/usr/bin/make_sip_conf.pl 



%changelog
* Tue Nov 24 2009 Alex Radetsky <rad@rad.kiev.ua> 0.2-alt1
- added make_sip_conf.pl 

* Tue Nov 10 2009 Alex Radetsky <rad@rad.kiev.ua> 0.1-alt1
- create package.
- added uuid.pl (simple AGI script) 




