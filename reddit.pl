#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize;
use JSON -support_by_pp;

################################################################################
#
# This will serve as the beginning of my serious adventures into Perl. This
# started because I wanted to programmatically hunt down Affiliate Link
# spammers on reddit. I had a simple enough algorithm for finding them, but
# automating it quickly became desirable. The languages I'm immediately
# familiar with though (HC12 Assembler, C++) and even others I hadn't used
# recently (C and Java) didn't seem like the right tools for job.
#
# I haven't done full-on web development since the late 90s/early 2000s. And
# holy shit have things changed. Tons of different js frameworks, ruby, python,
# HTML5, CSS3, XML, JSON -- so really, this project is also exposing me to the
# languages and tech that have become popular for these sorts of things. JSON
# and HTML5/CSS3 in particular should come in handy for this project.
#
# But why are you using Perl?! Perl is teh suxxorz! Use python or ruby! Well, 
# I've done system administration before, and could conceivably end up doing 
# that gig again. Perl is popular in that sphere. And given Perl's ubiquity and
# applications in a number of other fields I'm interested in --software
# testing, hardware synthesis validation-- this experience builder with Perl
# could come in handy in other paths of my life as well. I know python is the
# new hip hacker language. I know that everyone seems to have a hardon for
# ruby. But I tend to trust the older tools, and past experience during my
# sys-admin days dealing with python and ruby has left a distinctly bad taste
# in my mouth. Not to mention, I have high hopes for Perl 6 once the eternal
# design-by-committee process is complete.
#
# I'll need an event handler/scheduler to queue API requests. Looking at 
# libev/EV module to handle this (The Event module, however, has excellent
# documentation about event loops in general in a nice PDF; should read up on
# this in any case). I will need to run stats on the various users and
# subreddits. Thankfully, this and the API calls are not inter-dependent, so I
# don't need to deal with any locking mechanisms. The handler will just dump
# relevant data into a queue at whatever rate the Reddit API accepts (one
# request every two seconds), and the statistics code will chew through it.
# Basically, I've got a spider that will crawl for interesting data, and then
# dump it off to a separate bit of code to run stats on it.
#
# I might end up coding a simple CGI to expose this data to the web on a 
# VPS somewhere or an EC2 instance. As well, I'm looking at Test::More, 
# Test::Simple, and Test::Tutorial as well to get a handle on how Perl 
# does testing and module packing.
#
# The code below has been my attempt to parse reddit thread JSON data. I think 
# I've got a shaky handle on it now, especially after reading up on Perl 
# syntax and the difference between immediate variables and references to them. 
# Seeing how JSON arrays/hashes correspond to Perl list structures is as good 
# an introduction as any in my eyes to both JSON and Perl, and has the added 
# benefit of being immediately relevant to me :)
#
################################################################################

my $url = "http://www.reddit.com/comments/1iep4e.json";
my $browser = WWW::Mechanize->new();

eval {

  #grab the json
  $browser->get($url);
  
  my $content = $browser->content();
  my $json = new JSON;

  my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);

  print $json_text."\n";

#  foreach my $f(@{$json_text}) {
#    print $f->{data}->{children}[0]->{data}{author}."\n";
#  }

  my @internal_links;

  #FINALLY SOMETHING THAT WORKS
  foreach my $f(@$json_text[1]->{data}{children}) {
    #print $f->{data}{author}."\n";
    print $f."\n";
    foreach my $g(@$f) {
      print $g."\n";
      print $g->{data}{author}."\n";
      my $temp;
      $temp = $g->{data}{body};
      while ($temp =~ m/\/r\/.*\ /g) {
        print "Found match.\n";
        #print $temp."\n";
        #push(@internal_links,$temp); 
      }
      #store all subreddit links in @internal_links
      @internal_links = ($temp =~ /\/r\/([a-z0-9A-Z]*)\ /g); 
    }
  }

  foreach my $i(@internal_links) {
    $i = "/r/".$i;
    print $i."\n";
  }

#  for (my $i = 0; $i < 10 ; $i++) {
#    print @$json_text[1]->{data}->{children}[$i]->{data}{author}."\n";
#  }

#  print @$json_text[1]->{data}->{children}[0]->{data}{author}."\n";

  print "Ok. Parsing JSON will take some practice.\n";

# BAD CODE. DON'T USE.
#  foreach my $f(@json_text) {
#    foreach my $comment(@{$f->{data}->{children}}) {
#
#      my %comment_info = ();
#      $comment_info{author} = "uname: $comment->{data}{author}";
#      $comment_info{body} = "message: $comment->{data}{author}";
#
#      while (my($k, $v) = each (%comment_info)) {
#        print "$k => $v\n";
#      }
#
#      print "\n";
#
#    }
#  }

#  foreach my $comment(@{@json_text->{data}->{children}}) {

#    my %comment_info = ();
#    $comment_info{author} = "uname: $comment->{data}{author}";
#    $comment_info{body} = "message: $comment->{data}{body}";

#    while (my($k, $v) = each (%comment_info)) {
#      print "$k => $v\n";
#    }

#    print "\n";

#  }

};

if($@) {

  print "[[JSON ERROR]] JSON parser barfed. $@\n";

}

