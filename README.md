FreeSWITCH call generator for performance tests
===============================================

This is a simple dialer that connects to FreeSWITCH via event socket and
originates calls at a given interval. Each call is sent to a specified
destination number via loopback endpoint, in specified context. For
example, the following contexts will forward all calls to some remote
servers:

```
<!-- File: /etc/freeswitch/dialplan/dialer.xml -->
<include>
  <context name="dialer01">
    <extension name="to_sbc">
      <condition>
        <action application="set" data="sip_h_X-Asterisk-AccountNo=X839546"/>
        <action application="bridge"
                data="sofia/external/${destination_number}@203.0.113.55"/>
      </condition>
    </extension>
  </context>
  <context name="dialer02">
    <extension name="to_lab">
      <condition>
        <action application="bridge"
                data="sofia/external/moh@lab77.voxserv.net"/>
      </condition>
    </extension>
  </context>
</include>
```

Keep in mind that the default limit of sessions per second in FreeSWITCH
is 30 (`sessions-per-second` parameter in
`autoload_configs/switch.conf.xml`). Because of the loopback endpoint,
each call occupies 3 channels, and this results in 10 calls per second
maximum.

For example, the following command would start 100 calls, and each call
would last 10 minutes:

```
perl /opt/freeswitch-perf-dialer/dialer.pl \
  --ncalls=100 --cps=9 --duration=600 --context=dialer02
```


Installing on Debian 7
----------------------

```
apt-get install -y curl git

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

Author and License
------------------
Copyright (c) 2015 Stanislav Sinyagin <ssinyagin@k-open.com>

This software is distributed under the MIT license.