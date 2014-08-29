#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize;
use JSON -support_by_pp;
use Data::Printer;
#use HTML::FromANSI;

my $url = "http://www.reddit.com/comments/1iep4e.json";
my $browser = WWW::Mechanize->new();

my $url_user = "http://www.reddit.com/user/aspensmonster/about.json";
my $url_fp = "http://www.reddit.com/hot.json";

#grab the json
$browser->get($url_fp);
  
my $content = $browser->content();
my $json = new JSON;

my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);

p $json_text;

#print ansi2html( p($json_text, colored => 1) );
