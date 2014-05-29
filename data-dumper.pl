#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize;
use JSON -support_by_pp;
use Data::Printer;

my $url = "http://www.reddit.com/comments/1iep4e.json";
my $browser = WWW::Mechanize->new();

#grab the json
$browser->get($url);
  
my $content = $browser->content();
my $json = new JSON;

my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);

p $json_text;
