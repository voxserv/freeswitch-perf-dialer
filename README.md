FreeSWITCH dialer for performance tests
=======================================

This is a simple dialer that connects to FreeSWITCH via event socket and
originates calls at a given interval.

Installing on Debian 7
----------------------

```
apt-get install -y curl emacs git wireshark sysstat

cat >/etc/apt/sources.list.d/freeswitch.list <<EOT
deb http://files.freeswitch.org/repo/deb/debian/ wheezy main
EOT

curl http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub |\
apt-key add -

apt-get update && apt-get install -y freeswitch-all 

cd /etc
git clone https://github.com/voxserv/freeswitch_conf_minimal.git freeswitch

service freeswitch start

# Install the ESL module for Perl. It's not available in a package, so
# we get the whole source and build only the Perl module

apt-get install -y autoconf automake devscripts gawk g++ git-core \
 libjpeg-dev libncurses5-dev libtool make python-dev gawk pkg-config \
 libtiff5-dev libperl-dev libgdbm-dev libdb-dev gettext libssl-dev \
 libcurl4-openssl-dev libpcre3-dev libspeex-dev libspeexdsp-dev \
 libsqlite3-dev libedit-dev libldns-dev libpq-dev \
 libxml2-dev libpcre3-dev libcurl4-openssl-dev libgmp3-dev libaspell-dev\
 python-dev php5-dev libonig-dev libqdbm-dev libedit-dev


cd /usr/src
git clone -b v1.4 https://freeswitch.org/stash/scm/fs/freeswitch.git
cd /usr/src/freeswitch
./bootstrap.sh -j
./configure 
cd /usr/src/freeswitch/libs/esl
make
make perlmod-install

cd /opt
git clone https://github.com/voxserv/freeswitch-perf-dialer.git

```

You need to edit the FreeSWITCH dialplan, so that it routes the call somewhere.



Usage
-----

```

perl /opt/freeswitch-perf-dialer/dialer.pl --help

Usage: /opt/freeswitch-perf-dialer/dialer.pl [options...]
Options:
  --fs_host=HOST    [127.0.0.1] FreeSWITCH host
  --fs_port=PORT    [8021] FreeSWITCH ESL port
  --fs_password=PW  [ClueCon] FreeSWITCH ESL password
  --cid=NUMBER      [12126647665] caller ID
  --dest=NUMBER     [13115552368] destination number
  --context=NAME    [public] FreeSWITCH context name
  --duration=N      [60] call duration in seconds
  --ncalls=N        [10] total number of calls
  --cps=N           [10] rate in calls per second
  --help            this help message

```
 