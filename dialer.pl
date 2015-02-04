# Copyright (c) 2015 Stanislav Sinyagin <ssinyagin@k-open.com>

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    
use strict;
use warnings;
use Getopt::Long;
use Time::HiRes;
use ESL;

$| = 1;

my $fs_host = '127.0.0.1';
my $fs_port = 8021;
my $fs_password = 'ClueCon';

my $callerid = '12126647665';
my $dest = '13115552368';
my $context = 'public';

my $duration = 60;
my $ncalls = 10;
my $cps = 10;

my $help_needed;

my $ok = GetOptions
    (
     'fs_host=s'     => \$fs_host,
     'fs_port=s'     => \$fs_port,
     'fs_password=s' => \$fs_password,
     'cid=s'         => \$callerid,
     'dest=s'        => \$dest,
     'context=s'     => \$context,
     'duration=i'    => \$duration,
     'ncalls=i'      => \$ncalls,
     'cps=i'         => \$cps,
     'help'          => \$help_needed,
    );


if( not $ok or $help_needed or scalar(@ARGV) > 0 )
{
    print STDERR "Usage: $0 [options...]\n",
    "Options:\n",
    "  --fs_host=HOST    \[$fs_host\] FreeSWITCH host\n",
    "  --fs_port=PORT    \[$fs_port\] FreeSWITCH ESL port\n",
    "  --fs_password=PW  \[$fs_password\] FreeSWITCH ESL password\n",
    "  --cid=NUMBER      \[$callerid\] caller ID\n",
    "  --dest=NUMBER     \[$dest\] destination number\n",
    "  --context=NAME    \[$context\] FreeSWITCH context name\n",
    "  --duration=N      \[$duration\] call duration in seconds\n",
    "  --ncalls=N        \[$ncalls\] total number of calls\n",
    "  --cps=N           \[$cps\] rate in calls per second\n",
    "  --help            this help message\n";
    exit 1;
}

my $originate_string =
    'originate ' .
    '{ignore_early_media=true,' .
    'origination_uuid=%s,' . 
    'originate_timeout=60,' .
    'origination_caller_id_number=' . $callerid . ',' .
    'origination_caller_id_name=' . $callerid . '}' .
    'loopback/%s/' . $context .
    ' ' .
    '&playback(local_stream://moh)';
    

my $esl = new ESL::ESLconnection($fs_host,
                                 sprintf('%d', $fs_port),
                                 $fs_password);

$esl->connected() or die("Cannot connect to FreeSWITCH");

my $interval = 1.0/$cps;
my $nc = 0;
my $start = Time::HiRes::time();

while( $nc < $ncalls )
{
    $nc++;

    my $next_time = $start + $nc * $interval;
    my $now = Time::HiRes::time();
    if( $next_time > $now )
    {
        Time::HiRes::sleep($next_time - $now);
    }

    my $uuid = $esl->api('create_uuid')->getBody();
    $esl->bgapi(sprintf($originate_string, $uuid, $dest));
    $esl->bgapi(sprintf('sched_hangup +%d %s', $duration, $uuid));
    
    print $nc, "\n";    
}
