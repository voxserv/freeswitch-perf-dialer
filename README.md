FreeSWITCH call generator for performance tests
===============================================

This is a simple dialer that connects to FreeSWITCH via event socket and
originates calls at a given interval.

The script subsututes the question mark signs (?) with random digits in
caller ID and the destination number.

There are two ways to specify the call destination:

1. Loopback endpoint
--------------------

If used with `--content` and `--dest` options, the dialer originates the
calls into the specified context via loopback endpoint. For example, the
following contexts will forward all calls to some remote servers:

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
  --ncalls=100 --cps=9 --duration=600 --context=dialer01 \
  --dest='01234?????'
```

2. Endpoint string
------------------

You can specify explicitly the endpoint string. In case of SIP
endpoints, that will instruct FreeSWITCH to use a specified SIP profile
and gateway for example:

```
perl /opt/freeswitch-perf-dialer/dialer.pl --cid='+3333???????' \
 --endpoint='sofia/external/+777???????@10.250.250.23' --cps=5 --forever
 

perl /opt/freeswitch-perf-dialer/dialer.pl --cid='+3333???????' \
 --endpoint='sofia/gateway/voxbeam/+777???????' --cps=5 --forever
```

Transferring instead of playback
--------------------------------

The `--exec` option allows you to send the call to a dialplan context
instead of playing back the media. The following example sends the call
after originating to default dialplan context, with destination number
12345678 and caller ID 87654321:

```
perl /opt/freeswitch-perf-dialer/dialer.pl --cid='12345678' \
 --endpoint='sofia/gateway/voxbeam/87654321' --cps=5 --forever \
 --exec='12345678 XML default 87654321 87654321'
```

The general syntax of the exec string is as follows:

```
<destnumber> XML <context> <caller_id_name> <caller_id_number>
```


Installing on Debian 8
----------------------

```
apt-get install -y curl git

cat >/etc/apt/sources.list.d/freeswitch.list <<EOT
deb http://files.freeswitch.org/repo/deb/freeswitch-1.6/ jessie main
EOT

curl http://files.freeswitch.org/repo/deb/debian/freeswitch_archive_g0.pub |\
apt-key add -

git clone https://github.com/voxserv/freeswitch_conf_minimal.git /etc/freeswitch

apt-get update && apt-get install -y freeswitch-meta-all libesl-perl

systemctl enable freeswitch
systemctl start freeswitch

git clone https://github.com/voxserv/freeswitch-perf-dialer.git /opt/freeswitch-perf-dialer
```




Usage
-----

```
# perl /opt/freeswitch-perf-dialer/dialer.pl --help
Usage: /opt/freeswitch-perf-dialer/dialer.pl [options...]
Options:
  --fs_host=HOST    [127.0.0.1] FreeSWITCH host
  --fs_port=PORT    [8021] FreeSWITCH ESL port
  --fs_password=PW  [ClueCon] FreeSWITCH ESL password
  --cid=NUMBER      [12126647665] caller ID
  --dest=NUMBER     [13115552368] destination number
  --context=NAME    [public] FreeSWITCH context name
  --endpoint=STRING destination endpoint
  --duration=N      [60] call duration in seconds
  --ncalls=N        [10] total number of calls
  --cps=N           [10] rate in calls per second
  --play=STRING     [local_stream://moh] playback argument
  --help            this help message

If endpoint is specified, --dest and --context are ignored.
Otherwise, the call is sent to the loopback endpoint with the specified
context and destination number
```

Author and License
------------------
Copyright (c) 2015-2016 Stanislav Sinyagin <ssinyagin@k-open.com>

This software is distributed under the MIT license.