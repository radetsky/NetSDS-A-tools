#!/bin/sh


#set -x

prefix="/var/lib/tftpboot"
PSN=
MAC=
EXT=
PASS=
SIP=


getoptarg="hc:m:s:e:p:M:"

legend()
{
    cat <<EOF
Usage: $(basename $0) [options]
  -h            print this screen
  -m model      Phone model (Example: 502G)
  -s SIP        SIP server IP address (Example: 192.168.1.82)
  -e extension  SIP extension number (Example: 201)
  -p password   SIP user password
  -M Phone MAC  Phone MAC address (Example: e0:b9:a5:6a:ba:a1)

Example: $(basename $0) -m 502G -s 192.168.1.92 -e 201 -p "SuperSecret" -M "f4:6d:04:0b:ee:0a"

EOF
}

while getopts $getoptarg opt
do
    case $opt in
        h) legend; exit 0;;
        m) PSN="$OPTARG";;
        s) SIP="$OPTARG";;
        e) EXT="$OPTARG";;
        p) PASS="$OPTARG";;
        M) MAC=$(echo "$OPTARG" | tr "[A-Z]" "[a-z]" | tr -d ":");;
    esac
done

if [ -z "${PSN}" -o -z "${MAC}" -o -z "${EXT}" -o -z "${PASS}" -o -z "${SIP}" ]; then
    legend
    echo "Error: Missing one from required parameters."
    exit 1
fi

mkdir -p ${prefix}/SPA${PSN}

cat > ${prefix}/SPA${PSN}/${MAC}.xml <<EOF
<flat-profile>
  <User_ID_1_ group="Ext_1/Subscriber_Information">${EXT}</User_ID_1_>
  <Password_1_ group="Ext_1/Subscriber_Information">${PASS}</Password_1_>
  <Use_Auth_ID_1_ group="Ext_1/Subscriber_Information">No</Use_Auth_ID_1_>
  <Auth_ID_1_ group="Ext_1/Subscriber_Information"></Auth_ID_1_>
  <Display_Name_1_ group="Ext_1/Subscriber_Information">Im Phone</Display_Name_1_>
  <Proxy_1_ group="Ext_1/Proxy_and_Registration">${SIP}</Proxy_1_>
  <Station_Name group="Phone/General">Ext_${EXT}</Station_Name>
  <Station_Display_Name group="Phone/General">Ext ${EXT}</Station_Display_Name>
  <Voice_Mail_Number ua="rw"></Voice_Mail_Number>
  <Text_Logo group="Phone/General">Taxi Express</Text_Logo>
  <BMP_Picture_Download_URL group="Phone/General"></BMP_Picture_Download_URL>
  <Select_Logo group="Phone/General">Text Logo</Select_Logo>
  <Select_Background_Picture group="Phone/General">None</Select_Background_Picture>
  <Time_Format group="User/Supplementary_Services">24hr</Time_Format>
  <DND_Serv group="Phone/Supplementary_Services">No</DND_Serv>
</flat-profile>
EOF

chmod 777 ${prefix}/SPA${PSN}/${MAC}.xml

exit 0
