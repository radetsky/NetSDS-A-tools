%define origname NetSDS-Asterisk-tools
%define version 1.0

Name: %origname
Summary: Asterisk tools: callback, voicefile-rotate
Version: %version
Release: alt1
License: GPL
Group: Development/Perl
BuildArch: noarch

Packager: Dmitriy Kruglikov <dkr@altlinux.ru>

Source: %origname-%version.tar.gz

Requires: perl-Data-UUID
Requires: pwgen
Requires: perl-Getopt-Mixed

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
mkdir -p %buildroot/etc/asterisk
install -m755 callback.sh %buildroot/usr/bin/
install -m755 voicefiles.rotate.sh %buildroot/etc/cron.daily/
install -m755 uuid.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 navconnect.sh %buildroot/usr/lib/asterisk/agi-bin/
install -m755 confirm_call.sh %buildroot/usr/lib/asterisk/agi-bin/
install -m755 officepark.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 make_sip_conf.pl %buildroot/usr/bin/
install -m644 NetSDS.ael %buildroot/usr/share/doc/%origname
install -m644 dialout_examples.ael %buildroot/etc/asterisk


%files
/usr/bin/callback.sh
/etc/cron.daily/voicefiles.rotate.sh 
/usr/lib/asterisk/agi-bin/uuid.pl 
/usr/lib/asterisk/agi-bin/navconnect.sh
/usr/lib/asterisk/agi-bin/confirm_call.sh
/usr/lib/asterisk/agi-bin/officepark.pl
/usr/bin/make_sip_conf.pl 
/usr/share/doc/NetSDS-Asterisk-tools/NetSDS.ael 
/etc/asterisk/dialout_examples.ael

%changelog
* Thu Oct 04 2011 Dmitriy Kruglikov <dkr@altlinux.ru>
- Version up.

* Thu Dec 03 2009 Alex Radetsky <rad@rad.kiev.ua> 0.7-alt1
- Jump to same version with other tools 
- added officepark.pl that uses perlapps/fcgi to find and park the call 
- added new functionality to NetSDS.ael 


* Tue Nov 24 2009 Alex Radetsky <rad@rad.kiev.ua> 0.2-alt1
- added make_sip_conf.pl 
- added NetSDS.ael 
- added dialout_examples.ael 
- added navconnect.sh 
- added confirm_call.sh 

* Tue Nov 10 2009 Alex Radetsky <rad@rad.kiev.ua> 0.1-alt1
- create package.
- added uuid.pl (simple AGI script) 




