%define origname NetSDS-Asterisk-tools
%define version 1.0

Name: %origname
Summary: Asterisk tools: callback, voicefile-rotate
Version: %version
Release: alt9
License: GPL
Group: Development/Perl
BuildArch: noarch

Packager: Dmitriy Kruglikov <dkr@altlinux.ru>

Source: %origname-%version.tar.gz

BuildRequires: perl-Data-UUID
BuildRequires: pwgen
BuildRequires: perl-Getopt-Mixed
BuildRequires: perl-NetSDS
BuildRequires: perl-NetSDS-Asterisk

Requires: perl-NetSDS-Asterisk
Requires: perl-NetSDS
Requires: perl-Data-UUID
Requires: pwgen
Requires: service
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
mkdir -p %buildroot/usr/sbin
mkdir -p %buildroot/usr/lib/asterisk/agi-bin
mkdir -p %buildroot/etc/cron.daily
mkdir -p %buildroot/etc/asterisk
mkdir -p %buildroot/etc/NetSDS
mkdir -p %buildroot%_initdir
install -m750 etc/NetSDS-hangupd.init %buildroot%_initdir/NetSDS-hangupd
install -m755 callback.sh %buildroot/usr/bin/
install -m755 voicefiles.rotate.sh %buildroot/etc/cron.daily/
install -m755 uuid.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 navconnect.sh %buildroot/usr/lib/asterisk/agi-bin/
install -m755 confirm_call.sh %buildroot/usr/lib/asterisk/agi-bin/
install -m755 officepark.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 make_sip_conf.pl %buildroot/usr/bin/
install -m644 NetSDS.ael %buildroot/usr/share/doc/%origname
install -m644 dialout_examples.ael %buildroot/etc/asterisk
install -m755 sbin/NetSDS-hangupd.pl %buildroot/usr/sbin/
install -m755 sbin/NetSDS-recd.pl %buildroot/usr/sbin/
install -m644 etc/NetSDS/asterisk-router.conf %buildroot/etc/NetSDS
cp -ar dialplan %buildroot/usr/share/doc/%origname/
cp -ar sql %buildroot/usr/share/doc/%origname

%post
%post_service NetSDS-hangupd

%preun
%preun_service NetSDS-hangupd

%files
/usr/bin/callback.sh
/etc/cron.daily/voicefiles.rotate.sh 
/usr/lib/asterisk/agi-bin/uuid.pl 
/usr/lib/asterisk/agi-bin/navconnect.sh
/usr/lib/asterisk/agi-bin/confirm_call.sh
/usr/lib/asterisk/agi-bin/officepark.pl
/usr/bin/make_sip_conf.pl 
/usr/sbin/NetSDS-hangupd.pl 
/usr/sbin/NetSDS-recd.pl
/usr/share/doc/NetSDS-Asterisk-tools/*
/usr/share/doc/NetSDS-Asterisk-tools/NetSDS.ael 
/etc/asterisk/dialout_examples.ael
%_initdir/NetSDS-hangupd
%config(noreplace) %_sysconfdir/NetSDS/asterisk-router.conf

%changelog
* Thu Jan 05 2012 Dmitriy Kruglikov <drk@altlinux.ru> 1.0-alt9
- Added NetSDS-recd.pl

* Thu Dec 22 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt8
- Fixed spec

* Thu Dec 22 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt7
- Added service start-stop requirements

* Thu Dec 22 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt6
- Added perl-NetSDS-Asterisk into Requirements

* Thu Dec 22 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt5
- Added perl-NetSDS into Requirements

* Thu Dec 22 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt4
- Added NetSDS-hangupd service and init script

* Tue Dec 13 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt3
- New dialplan and sql files

* Wed Nov 30 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt2
- New dialplan and sql files

* Thu Oct 04 2011 Dmitriy Kruglikov <dkr@altlinux.ru> 1.0-alt1
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




