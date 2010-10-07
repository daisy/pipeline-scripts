#!/usr/bin/perl -- # -*- Perl -*-

# See http://norman.walsh.name/2010/06/09/epubxpl
# Version 1.1

use URI;
use strict;
use English;
use LWP::UserAgent;

my $ua = new LWP::UserAgent;
my $global_data = "";

my %uris = ();
my $xml = "<manifest>\n";

my $base = shift @ARGV || ".";
chop $base if $base =~ /\/$/;

my @filelist = ();
while (<>) {
    chop;
    push (@filelist, $_);
}

while (@filelist) {
    my $url = shift @filelist;

    next if exists($uris{$url});
    $uris{$url} = 1;

    print STDERR "\t$url\n";

    my $req = new HTTP::Request GET => $url;

    $global_data = "";
    my $res = $ua->request($req, \&callback, 4096);

    my $code = $res->code();

    my $type = $res->header("Content-Type");
    $type =~ s/\;.*$//;

    if ($code == 404) {
        $type = 'text/css' if $url =~ /\.css$/;
    }

    my $fn = $url;
    $fn =~ s/^https?:\/\///;

    my $datafn = "$base/$fn";

    if ($datafn =~ /^(.*)\/(.+?)$/) {
        system("mkdir -p $1") unless -d $1;
    }

    if ($type eq 'text/css') {
        if ($code != 200) {
            $global_data = "/* Original file was 404. */";
        }
        $global_data = patchCSS($global_data, $url);
    }

    open (DATA, ">$datafn");
    binmode DATA;
    print DATA $global_data;
    close (DATA);

    $xml .= "  <file type='$type' uri='$url' fn='$fn'/>\n";
}
close (F);

$xml .= "</manifest>\n";

print $xml;

# ============================================================

sub callback {
    my($data, $response, $protocol) = @_;
    my $clength = $response->content_length();
    $global_data .= $data;
}

# ============================================================

sub patchCSS {
    my $css = shift;
    my $baseurl = shift;
    my $newCSS = "";

    #print STDERR "Patching $baseurl...\n";

    my $baseURI = new URI($baseurl);

    my $part = $baseurl;
    $part =~ s/^https?:\/\///;
    my @parts = split(/\//, $part);
    pop @parts; # get rid of one level

    my $prefix = "";
    foreach my $part (@parts) {
        $prefix .= "../";
    }

    while ($css =~ /(^.*?[:\s]url\s*\(\s*[\'\"]?)(.*?)([\'\"]?\s*\))/si) {
        $newCSS .= $1;
        my $url = $2;
        my $after = $3;
        $css = $POSTMATCH;

        $url = new URI($url)->abs($baseURI);

        push(@filelist, $url);

        $url =~ s/^https?:\/\///;

        $newCSS .= $prefix . $url;
        $newCSS .= $after;

        print STDERR "\t\t$prefix$url\n";
    }

    return $newCSS . $css;
}

