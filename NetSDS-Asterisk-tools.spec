%define origname NetSDS-Asterisk-tools
%define version 1.0

Name: %origname
Summary: Asterisk tools: callback, voicefile-rotate
Version: %version
Release: alt15
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
BuildRequires: perl-IO-Prompt 
BuildRequires: Nibelite-core
BuildRequires: perl-File-Tail 

Requires: perl-NetSDS-Asterisk
Requires: perl-NetSDS
Requires: perl-Data-UUID
Requires: pwgen
Requires: service
Requires: perl-Getopt-Mixed
Requires: perl-IO-Prompt 
Requires: Nibelite-core
Requires: perl-File-Tail 
Requires: monit-base

# apt-get install asterisk1.4.42-chan_sip asterisk1.4.42 perl-asterisk-perl asterisk-base-configs asterisk-images asterisk-initscript asterisk-sounds-base asterisk-sounds-ru-base asterisk-user asterisk-base asterisk-keys  asterisk-files-all  asterisk1.4.42 asterisk1.4.42-codec_gsm asterisk1.4.42-ael asterisk1.4.42-docs asterisk-core-sounds-ru-ulaw asterisk-firmware asterisk1.4.42-res_crypto asterisk1.4.42-pgsql 

# А где конфиги ? /etc/asterisk ? 

# Где tftpprovidor.sh:

%description
Some useful tools: 
- callback
- voicefile rotate
- uuid (agi)

%prep
%setup -n %origname-%version

%build

%install
mkdir -p %buildroot/usr/share/doc/%origname/etc/
mkdir -p %buildroot/usr/bin
mkdir -p %buildroot/usr/sbin
mkdir -p %buildroot/usr/lib/asterisk/agi-bin
mkdir -p %buildroot/etc/cron.daily
mkdir -p %buildroot/etc/asterisk
mkdir -p %buildroot/etc/NetSDS
mkdir -p %buildroot%_initdir
mkdir -p %buildroot%_sysconfdir/monit.d/
install -m750 etc/NetSDS-hangupd.init %buildroot%_initdir/NetSDS-hangupd
install -m750 etc/NetSDS-parsequeuelogd.init %buildroot%_initdir/NetSDS-parsequeuelogd
install -m755 callback.sh %buildroot/usr/bin/
install -m755 bin/peermod.pl %buildroot/usr/bin/
install -m755 bin/astconf2sql.pl %buildroot/usr/bin/
install -m755 voicefiles.rotate.sh %buildroot/etc/cron.daily/
install -m755 uuid.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 navconnect.sh %buildroot/usr/lib/asterisk/agi-bin/
install -m755 confirm_call.sh %buildroot/usr/lib/asterisk/agi-bin/
install -m755 officepark.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 agi-bin/NetSDS-route.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 agi-bin/NetSDS-AGI-integration.pl %buildroot/usr/lib/asterisk/agi-bin/
install -m755 make_sip_conf.pl %buildroot/usr/bin/
install -m644 NetSDS.ael %buildroot/usr/share/doc/%origname
install -m644 sql/asterisk2.sql %buildroot/usr/share/doc/%origname
install -m644 dialout_examples.ael %buildroot/etc/asterisk
install -m755 sbin/NetSDS-hangupd.pl %buildroot/usr/sbin/
install -m755 sbin/NetSDS-recd.pl %buildroot/usr/sbin/
install -m755 sbin/NetSDS-parsequeuelogd.pl %buildroot/usr/sbin/
install -m644 etc/NetSDS/asterisk-router.conf %buildroot/etc/NetSDS
install -m750 tftpprovisor.sh %buildroot/usr/bin/
install -m750 grandstream-config.pl %buildroot/usr/bin/
install -m 640 etc/NetSDS-hangupd.monit %buildroot/etc/monit.d/NetSDS-hangupd
install -m 640 etc/NetSDS-parsequeuelogd.monit %buildroot/etc/monit.d/NetSDS-parsequeuelogd
cp -ar dialplan %buildroot/usr/share/doc/%origname/
cp -ar sql %buildroot/usr/share/doc/%origname
cp -ar etc/asterisk %buildroot/usr/share/doc/%origname/etc/

%post
%post_service NetSDS-hangupd
%post_service NetSDS-parsequeuelogd

%preun
%preun_service NetSDS-hangupd
%preun_service NetSDS-parsequeuelogd

%files
/usr/bin/callback.sh
/usr/bin/astconf2sql.pl
/usr/bin/peermod.pl
/etc/cron.daily/voicefiles.rotate.sh 
/usr/lib/asterisk/agi-bin/uuid.pl 
/usr/lib/asterisk/agi-bin/navconnect.sh
/usr/lib/asterisk/agi-bin/confirm_call.sh
/usr/lib/asterisk/agi-bin/officepark.pl
/usr/lib/asterisk/agi-bin/NetSDS-route.pl 
/usr/lib/asterisk/agi-bin/NetSDS-AGI-integration.pl 
/usr/bin/make_sip_conf.pl 
/usr/bin/grandstream-config.pl
/usr/bin/tftpprovisor.sh
/usr/sbin/NetSDS-hangupd.pl 
/usr/sbin/NetSDS-recd.pl
/usr/sbin/NetSDS-parsequeuelogd.pl 
/usr/share/doc/NetSDS-Asterisk-tools/*
/usr/share/doc/NetSDS-Asterisk-tools/NetSDS.ael 
/etc/asterisk/dialout_examples.ael
%_initdir/NetSDS-hangupd
%_initdir/NetSDS-parsequeuelogd
%config(noreplace) %_sysconfdir/NetSDS/asterisk-router.conf
%config(noreplace) %_sysconfdir/monit.d/NetSDS-hangupd
%config(noreplace) %_sysconfdir/monit.d/NetSDS-parsequeuelogd.monit

%changelog
* Tue Jan 17 2012 Dmitriy Kruglikov <drk@altlinux.ru> 1.0-alt15
- Added monit rules

* Mon Jan 16 2012 Alex Radetsky <rad@rad.kiev.ua> 1.0-alt14 
- Updated spec 
- Add new files 

* Mon Jan 09 2012 Dmitriy Kruglikov <drk@altlinux.ru> 1.0-alt13
- Rebuild with new files

* Sun Jan 08 2012 Dmitriy Kruglikov <drk@altlinux.ru> 1.0-alt12
- Updated spec

* Fri Jan 06 2012 Dmitriy Kruglikov <drk@altlinux.ru> 1.0-alt11
- Added tftpprovisor for configuring autoprovisioning

* Thu Jan 05 2012 Dmitriy Kruglikov <drk@altlinux.ru> 1.0-alt10
- Added astconf2sql.pl and peermod.pl

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




