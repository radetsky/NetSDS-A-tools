#!/bin/sh

ext=
pass=
name=
model=
MAC=

TFTPDIR="/var/lib/tftpboot"
NTPSERVER="192.168.1.98"
SIPSERVER="192.168.1.98"
PHONEBOOK="192.168.1.111"

clear_vars(){
    ext=
    pass=
    name=
    model=
    MAC=
}

generate_SPA502G_config() {
cat > ${TFTPDIR}/SPA502G/${MAC}.xml <<EOF
<flat-profile>
  <User_ID_1_ group="Ext_1/Subscriber_Information">${ext}</User_ID_1_>
  <Password_1_ group="Ext_1/Subscriber_Information">${pass}</Password_1_>
  <Use_Auth_ID_1_ group="Ext_1/Subscriber_Information">No</Use_Auth_ID_1_>
  <Auth_ID_1_ group="Ext_1/Subscriber_Information"></Auth_ID_1_>
  <Display_Name_1_ group="Ext_1/Subscriber_Information">${name}</Display_Name_1_>
  <Proxy_1_ group="Ext_1/Proxy_and_Registration">${SIPSERVER}</Proxy_1_>
  <Station_Name group="Phone/General">${ext}</Station_Name>
  <Station_Display_Name group="Phone/General">${name}</Station_Display_Name>
  <Voice_Mail_Number ua="rw"></Voice_Mail_Number>
  <Text_Logo group="Phone/General">Taxi Express</Text_Logo>
  <BMP_Picture_Download_URL group="Phone/General"></BMP_Picture_Download_URL>
  <Select_Logo group="Phone/General">Text Logo</Select_Logo>
  <Select_Background_Picture group="Phone/General">None</Select_Background_Picture>
  <Time_Format group="User/Supplementary_Services">24hr</Time_Format>
  <DND_Serv group="Phone/Supplementary_Services">No</DND_Serv>
</flat-profile>
EOF

chmod 777 ${TFTPDIR}/SPA502G/${MAC}.xml 
clear_vars

}

generate_GXP1200_config(){
cat > ${TFTPDIR}/cfg${MAC}.txt <<EOF
#--------------------------------------------------------------------------------------
# Primary Account (Account 1) Settings
#--------------------------------------------------------------------------------------
P91 = 1
# Account Active (In Use). 0 - no, 1 - yes
P271 = 1
# Account Name
P270 = ${name}
# SIP Server
P47 = ${SIPSERVER}
# Outbound Proxy
P48 = ${SIPSERVER}
# SIP User ID
P35 = ${ext}
# SIP Password
P34 = ${pass}
# Authenticate ID
P36 = ${ext}
# Display Name (John Doe)
P3 = ${name}
#--------------------------------------------------------------------------------------
# End User Time settings
#--------------------------------------------------------------------------------------
# Time Zone. Offset in minutes to GMT 
# ( Offset from GMT in minutes + 720, IE: MST (GMT - 7 hours) = -420 + 720 = 300 )
P64=840
# Time Display Format. 0 - 12 Hour, 1 - 24 Hour
P122 = 1
# NTP Server
P30 = ${ntpserver}
# Enable Downloadable Phonebook (P330): NO/YES-HTTP/YES-TFTP
# (default NO). Possible values 0 (NO)/1 (HTTP)/2 (TFTP), other values
# ignored.
P330 = 2
# Phonebook XML Path (P331): This is a string of up to 128 characters that
# should contain a path to the XML file. It MUST be in the host/path format.
# Name must be gs_phonebook.xml
# For example: directory.grandstream.com/engineering
# TFTP dont understand path. So onle host/ format is working
P331 = ${PHONEBOOK}
# Phonebook Download Interval (P332): This is an integer variable in MINUTES.
# Valid value range is 0-720 (default 0), and greater values will default to 720.
P332 = 60
EOF

compile_GXP1200_config ${MAC}

}

compile_GXP1200_config(){
    /usr/local/bin/grandstream-config.pl ${MAC} ${TFTPDIR}/cfg${MAC}.txt ${TFTPDIR}/cfg${MAC}
    #rm -rf ${TFTPDIR}/cfg${MAC}.txt
    chmod 777 ${TFTPDIR}/cfg${MAC}
    clear_vars
}

[ -d ${TFTPDIR} ] || mkdir -p ${TFTPDIR}
[ -d ${TFTPDIR}/SPA502G ] || mkdir -p ${TFTPDIR}/SPA502G

psql -U asterisk -A -t -c 'select a.name,a.secret,a.callerid,b.teletype,b.mac_addr_tel from public.sip_peers a, integration.workplaces b where a.id=b.sip_id' | \
while read str; do
    echo $str | tr "|" ":" |\
    while IFS=":" read Extn Upass Dname Model Mac; do
	ext=$Extn
	pass=$Upass
	name=$(echo $Dname | awk '{print $1,$2}')
	model=$Model
	MAC=$Mac
	case 1 in 
	    $(echo $model | grep -ic GXP1200 ) )
		#generate_GXP1200_config ${ext} ${pass} ${MAC} ${model} ${name}
		generate_GXP1200_config
		;;
	    $(echo $model | grep -ic SPA502G ) )
		generate_SPA502G_config
		;;
	esac
    done
done
