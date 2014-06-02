#!/usr/bin/env perl

#OK: THIS LINK, WITH COMMENTS BY USER "Browser UK", SHOULD BE REGARDED AS THE
#AUTHORITATIVE SOURCE ON THE VARIOUS CONCEPTS OF THREADS, ITHREADS, "REAL"
#THREADS, "GREEN" THREADS, FAKE THREADS, FIBERS, PROCESSES, EVENT LOOPS,
#COOPERATIVE SCHEDULING, SCHEDULING, ETC ETC ETC AD NASEUM.
#
# http://www.perlmonks.org/?node_id=866074
#
#tl;dr: the man (or woman) knows his (or her) shit. S/he was able to
#coalesce everything I learned desparately while in school into a single,
#intuitive, stream of thoughts on the matter that addresses all sorts of
#misconceptions and sources of confusion.
#
#tl;dr: If I *really* want *true* multithreading, I'll have to learn
#perl ithreads. Coro/AnyEvent and company all implement scheduling that
#treats lots of events *like* threads for the purposes of scheduling, but
#it is not *actual* threading, in the sense that all SMP threads are
#utilized. This gels with my observations of this code as it ran, by
#examining its process tree with `pstree`. Now, UNLIKE typical multithreading
#programming paradigms, where "true" multithreading utilizes shared memory
#to communicate amongst different threads, perl's ithreads are actually the
#exact opposite. Nothing is shared unless explicitly told to share. In this
#sense, threading and eventing utilize the same method of communicating
#with eachother: messages. While eventing, in particular, the notion of a
#call-back plays very heavily. While ithreading, not necessary.

use LWP::Protocol::AnyEvent::http;
use WWW::Mechanize;
use EV;
use AnyEvent::HTTP::LWP::UserAgent;
use AnyEvent;

# get the url
my $url = "http://aspensmonster.com";
my $mech = WWW::Mechanize->new;
$mech->get($url);

# set up evented user-agent to fetch the list of links
my $ua = AnyEvent::HTTP::LWP::UserAgent->new;

# set up a condvar for events to comm with
my $cv = AnyEvent->condvar ( cb => sub { warn "done"; } );

# set up a watcher to catch SIGINT
my $w = AnyEvent->signal (signal => "INT", cb => sub {
  print "Caught SIGINT. Shutting down.\n";
  exit 1;
});

# begin loop; honestly, it looks like condvars just mimic the
# producer/consumer dichotomy.

$cv->begin;

foreach my $link ($mech->links) {

  $cv->begin;
  $ua->get_async($link->url)->cb( sub {
  print "Got " . $link->url . "\n";
  $cv->end;
  });

}

$cv->end;
#$cv->recv;
EV::loop;
