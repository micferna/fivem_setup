#/bin/bash
noir='\e[0;30m'
gris='\e[1;30m'
rougefonce='\e[0;31m'
rose='\e[1;31m'
vertfonce='\e[0;32m'
vert='\e[1;32m'
jaune='\e[1;33m'
bleufonce='\e[0;34m'
bleuclair='\e[1;34m'
violetfonce='\e[0;35m'
violetclair='\e[1;35m'
cyanfonce='\e[0;36m'
cyanclair='\e[1;36m'
grisclair='\e[0;37m'
blanc='\e[1;37m'

neutre='\e[0;m'


function show_main_title {
  # Set a foreground colour using ANSI escape
  tput setaf 125

  clear

cat <<EOF
███╗   ███╗███████╗███╗   ██╗██╗   ██╗
████╗ ████║██╔════╝████╗  ██║██║   ██║
██╔████╔██║█████╗  ██╔██╗ ██║██║   ██║
██║╚██╔╝██║██╔══╝  ██║╚██╗██║██║   ██║
██║ ╚═╝ ██║███████╗██║ ╚████║╚██████╔╝
╚═╝     ╚═╝╚══════╝╚═╝  ╚═══╝ ╚═════╝    COUCOU                  
EOF
  tput sgr0
echo "
TWiTCH:   OCB_TV
WEB:      micferna.eu
"
}

show_menu() {
  show_main_title
    printf "%s\n" "-------------------------------"
    printf "%s\n" "  MENU D'UTILISATION           " 
    printf "%s\n" "-------------------------------"
    printf "%s\n" "  A FAIRE SUR UN SERVEUR VIERGE"
    printf "%s\n" "-------------------------------"
    printf "%s\n" "  1. Installer un serveur web   ?    | (Nginx) " 
    printf "%s\n" "  2. Installer un serveur mysql ?    | (MariaDB-Server)"
    printf "%s\n" "  3. Installer un serveur FiveM ?    | (install auto avec une template basique)"
    printf "%s\n" "  4. Installer un certificat Let's Encrypt SSL ? "
    printf "%s\n" "-------------------------------"
    printf "%s\n" "  8. Crées un compte user aléatoirement pour mariadb ? "
    printf "%s\n" "  0. Exit" 
    printf "%s\n" ""
}

read_input(){
  # get user input via keyboard and make a decision using case...esac 

  local c
  read -p "Faite votre choix [ 1-4 ]:  " c
  case $c in
    1) install_nginx ;;
    2) install_mariadb ;;
    3) install_fivem ;; 
    4) install_letsencrypt ;;
    8) compte_user_mariadb ;;
    0) printf "%s\n" "Ciao!"; exit 0 ;;
    *)
       printf "%s\n" "Choisir une option entre (1 to 4):  "

       pause
esac 
}

pause() {
  printf "%s\n" ""
  local message="$@"
  [ -z $message ] && message="Appuyez sur [Enter] Pour continuer:  "
  read -p "$message" readEnterKey            
}

function install_nginx {

if which nginx >/dev/null; then
  printf "%s\n" "
                Nginx est déjà installé. ! ⚠️
                "
else

  apt install curl gnupg2 ca-certificates lsb-release debian-archive-keyring

  curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
      |  tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

  echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
  http://nginx.org/packages/mainline/debian `lsb_release -cs` nginx" \
      |  tee /etc/apt/sources.list.d/nginx.list

  apt update
  apt install nginx   
  mkdir /var/www
  wget https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1-mysql.php
  mv adminer-4.8.1-mysql.php /var/www/adminer.php
fi
  pause
}

function install_mariadb {
if which mysql >/dev/null; then

  printf "%s\n" "
                Mysql est déjà installé. ! ⚠️
                "
else
  apt install mariadb-server php-mysql

fi
  pause
}

function install_fivem {

if [[  -d "/mnt/gta" ]]
then
  printf "%s\n" "
                Une base est déjà configurée. ! ⚠️
                Regarder le chemin /mnt/gta pour voir vos fichiers configurés avec le script.
                "
else


echo "Installe de quelle que dépendances."
apt install -y tar xz-utils curl git file jq screen
mkdir /mnt/gta



RELEASE_PAGE=$(curl -sSL https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/?$RANDOM)
  # Grab download link from FIVEM_VERSION
  if [ "${FIVEM_VERSION}" == "latest" ] || [ -z ${FIVEM_VERSION} ] ; then
    # Grab latest optional artifact if version requested is latest or null
    LATEST_ARTIFACT=$(echo -e "${RELEASE_PAGE}" | grep "LATEST OPTIONAL" -B1 | grep -Eo 'href=".*/*.tar.xz"' | grep -Eo '".*"' | sed 's/\"//g' | sed 's/\.\///1')
    DOWNLOAD_LINK=$(echo https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${LATEST_ARTIFACT})
  else
    # Grab specific artifact if it exists
    VERSION_LINK=$(echo -e "${RELEASE_PAGE}" | grep -Eo 'href=".*/*.tar.xz"' | grep -Eo '".*"' | sed 's/\"//g' | sed 's/\.\///1' | grep ${FIVEM_VERSION})
    if [ "${VERSION_LINK}" == "" ]; then
      echo -e "Defaulting to directly downloading artifact as the version requested was not found on page."
    else
      DOWNLOAD_LINK=$(echo https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/${FIVEM_VERSION}/fx.tar.xz)
    fi
  fi

  # Download artifact and get filetype
  echo -e "Running curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}..."
  curl -sSL ${DOWNLOAD_LINK} -o ${DOWNLOAD_LINK##*/}
  echo "Extracting FiveM artifact files..."
  FILETYPE=$(file -F ',' ${DOWNLOAD_LINK##*/} | cut -d',' -f2 | cut -d' ' -f2)

  # Unpack artifact depending on filetype
  if [ "$FILETYPE" == "gzip" ]; then
    tar xzvf ${DOWNLOAD_LINK##*/}
  elif [ "$FILETYPE" == "Zip" ]; then
    unzip ${DOWNLOAD_LINK##*/}
  elif [ "$FILETYPE" == "XZ" ]; then
    tar xvf ${DOWNLOAD_LINK##*/}
  else
    echo -e "Downloaded artifact of unknown filetype. Exiting."
    exit 2
  fi

mv alpine /mnt/gta 
mv run.sh /mnt/gta
rm -rf fx.tar.xz
git clone https://github.com/citizenfx/cfx-server-data.git /mnt/gta/server-data
chown 755 /mnt/gta



cat <<EOF > /mnt/gta/server-data/server.cfg
# Only change the IP if you're using a server with multiple network interfaces, otherwise change the port only.
endpoint_add_tcp "0.0.0.0:30120"
endpoint_add_udp "0.0.0.0:30120"

# These resources will start by default.
ensure mapmanager
ensure chat
ensure spawnmanager
ensure sessionmanager
ensure basic-gamemode
ensure hardcap
ensure rconlog

# This allows players to use scripthook-based plugins such as the legacy Lambda Menu.
# Set this to 1 to allow scripthook. Do note that this does _not_ guarantee players won't be able to use external plugins.
sv_scriptHookAllowed 0

# Uncomment this and set a password to enable RCON. Make sure to change the password - it should look like rcon_password "YOURPASSWORD"
#rcon_password ""

# A comma-separated list of tags for your server.
# For example:
# - sets tags "drifting, cars, racing"
# Or:
# - sets tags "roleplay, military, tanks"
sets tags "default"

# A valid locale identifier for your server's primary language.
# For example "en-US", "fr-CA", "nl-NL", "de-DE", "en-GB", "pt-BR"
sets locale "fr-FR"
# please DO replace root-AQ on the line ABOVE with a real language! :)

# Set an optional server info and connecting banner image url.
# Size doesn't matter, any banner sized image will be fine.
#sets banner_detail "https://url.to/image.png"
#sets banner_connecting "https://url.to/image.png"

# Set your server's hostname
sv_hostname "NOMSRV"

# Set your server's Project Name
sets sv_projectName "My FXServer Project"

# Set your server's Project Description
sets sv_projectDesc "Default FXServer requiring configuration"

# Nested configs!
#exec server_internal.cfg

# Loading a server icon (96x96 PNG file)
#load_server_icon myLogo.png

# convars which can be used in scripts
set temp_convar "hey world!"

# Remove the `#` from the below line if you do not want your server to be listed in the server browser.
# Do not edit it if you *do* want your server listed.
#sv_master1 ""

# Add system admins
add_ace group.admin command allow # allow all commands
add_ace group.admin command.quit deny # but don't allow quit
add_principal identifier.fivem:1 group.admin # add the admin to the group

# enable OneSync (required for server-side state awareness)
set onesync on

# Server player slot limit (see https://fivem.net/server-hosting for limits)
sv_maxclients 48

# Steam Web API key, if you want to use Steam authentication (https://steamcommunity.com/dev/apikey)
# -> replace "" with the key
set steam_webApiKey APIKEY

# License key for your server (https://keymaster.fivem.net)
sv_licenseKey LICENSEKEY

EOF

cp src/manage.sh /mnt/gta


fi

pause

}

function install_letsencrypt {

if [[ -d "/etc/letsencrypt"]]; then

  printf "%s\n" "
                Let's Encrypt est déjà installé. ! ⚠️
                "
else
apt install python3-certbot-nginx

echo "Rentrez votre nom de domaine pour avoir le certificat SSL"
echo "Par exemple: google.fr ou si vous avez configuré un CNAME images.google.fr"
read ndd_ssl

echo "Renseignez une adresse mail valide pour recevoir une notif quand le certificat ssl sera au bout de ça validité"
echo email_ssl
certbot certonly --nginx --agree-tos --no-eff-email --email "$email_ssl" -d "$ndd_ssl"

rm -rf /etc/nginx/nginx.conf
cat <<EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll; # gestionnaire d'évènements epoll (kernel 2.6+)
}

http {
    include /etc/nginx/mime.types;
    default_type  application/octet-stream;

    access_log /var/log/nginx/access.log combined;
    error_log /var/log/nginx/error.log error;

    sendfile on;
    keepalive_timeout 15;
    keepalive_disable msie6;
    keepalive_requests 100;
    tcp_nopush on;
    tcp_nodelay off;
    server_tokens off;

    gzip on;
    gzip_comp_level 5;
    gzip_min_length 512;
    gzip_buffers 4 8k;
    gzip_proxied any;
    gzip_vary on;
    gzip_disable "msie6";
    gzip_types
        text/css
        text/javascript
        text/xml
        text/plain
        text/x-component
        application/javascript
        application/x-javascript
        application/json
        application/xml
        application/rss+xml
        application/vnd.ms-fontobject
        font/truetype
        font/opentype
        image/svg+xml;

    include /etc/nginx/sites-enabled/*.conf;
}

EOF

rm -rf /etc/nginx/conf.d/default
mkdir /etc/nginx/sites-enabled
cat <<EOF > /etc/nginx/sites-enabled/default.conf
server {
    listen 80;
    listen [::]:80;
    server_name ${ndd_ssl};
    return 301 https://${ndd_ssl}$request_uri;
}

server {
    listen 443 http2 ssl;
    listen [::]:443 http2 ssl;
    server_name ${ndd_ssl};

    charset utf-8;
    index index.html index.php;
    client_max_body_size 10M;

    ssl_certificate /etc/letsencrypt/live/${ndd_ssl}/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/${ndd_ssl}/privkey.pem;

    access_log /var/log/nginx/access.log combined;
    error_log /var/log/nginx/error.log error;

    error_page 500 502 503 504 /50x.html;

    root /var/www/;

    location = /50x.html {
        root /usr/share/nginx/html;
    }

    location = /favicon.ico {
        access_log off;
        log_not_found off;
    }

    #location / {
    #allow Rensignez votre ip publique de votre BOX INTERNET pour whitelist votre IP sur la page du serveur /!\ ATTENTION cette page est définie sur votre page PUBLIC du serveur /!\;
    #deny all;
    #}

    location ~ \.php$ {
        fastcgi_index index.php;
        include /etc/nginx/fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_pass unix:/run/php/php7.4-fpm.sock;
    }

    location ~* \.(jpg|jpeg|gif|css|png|js|map|woff|woff2|ttf|svg|eot)$ {
        expires 30d;
        access_log off;
    }

}
EOF



fi
  pause  
}

function compte_user_mariadb {
apt install pwgen

PASS=`pwgen -s 70 1`
user=`pwgen 12 1`

mysql -uroot <<MYSQL_SCRIPT
CREATE DATABASE $user character set utf8mb4 collate utf8mb4_unicode_ci;
CREATE USER '$user'@'%' IDENTIFIED BY '$PASS';
GRANT ALL PRIVILEGES ON $user.* TO '$user'@'%';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo -e ${bleu}"Utilisateur MySQL crées.\n"${neutre}
echo -e "${rouge}Username:${neutre}   $user"
echo -e "${rouge}Password:${neutre}   $PASS"

pause

}


# Quel bordel p'tin !
