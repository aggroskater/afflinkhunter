#!/usr/bin/perl
use strict;
use warnings;

use WWW::Mechanize;
use JSON -support_by_pp;
use Data::Printer;
use DateTime;

# grab the front page
my $url = "http://www.reddit.com/hot.json";
my $browser = WWW::Mechanize->new();

eval {

  #grab the json
  $browser->get($url);
  
  my $content = $browser->content();
  my $json = new JSON;

  my $json_text = $json->allow_nonref->utf8->relaxed->escape_slash->loose->allow_singlequote->allow_barekey->decode($content);

#  p $json_text; 

  print "**********************************" . "\n";
 
  foreach my $entry(@{$json_text->{data}->{children}}) {
    
    my $user = $entry->{data}->{author};

    sleep(5);

    print "User: " . $user . "\n";

    $browser->get("http://www.reddit.com/user/$user/about.json");
    my $user_page = $browser->content();
    my $user_info = $json->decode($user_page);

    my $creation_date = $user_info->{data}->{created_utc};
    $creation_date = DateTime->from_epoch( epoch => $creation_date );

    print "Comment Karma: " . $user_info->{data}->{comment_karma} . "\n";
    print "Link Karma: " . $user_info->{data}->{link_karma} . "\n";
    print "Account Creation Date: " . $creation_date . "\n";

    print "**********************************" . "\n";
  }

}; #end of main eval

if($@) {

  print "[[JSON ERROR]] JSON parser barfed. $@\n";

}

