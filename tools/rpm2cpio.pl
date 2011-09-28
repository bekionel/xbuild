#!/usr/bin/perl

# Add a path if desired
$gzip = "gzip";

sub printhelp {
    print "\n";
    print "rpm2cpio, perl version by orabidoo <odar\@pobox.com>\n";
    print "\n";
    print "use: rpm2cpio [file.rpm]\n";
    print "dumps the contents to stdout as a GNU cpio archive\n";
    print "\n";
    exit 0;
}

if ($#ARGV == -1) {
    printhelp if -t STDIN;
    $f = "STDIN";
} elsif ($#ARGV == 0) {
    open(F, "< $ARGV[0]") or die "Can't read file $ARGV[0]\n";
    $f = 'F';
} else {
    printhelp;
}

printhelp if -t STDOUT;

# gobble the file up
undef $/;
$|=1;
$rpm = <$f>;
close ($f);

($magic, $major, $minor, $crap) = unpack("NCC C90", $rpm);

die "Not an RPM\n" if $magic != 0xedabeedb;
die "Not a version 3 or 4 RPM\n" if $major != 3 and $major != 4;

$rpm = substr($rpm, 96);

while ($rpm ne '') {
    $rpm =~ s/^\c@*//s;
    ($magic, $crap, $sections, $bytes) = unpack("N4", $rpm);
    $smagic = unpack("n", $rpm);
    last if $smagic eq 0x1f8b;
    die "Error: header not recognized\n" if $magic != 0x8eade801;
    $rpm = substr($rpm, 16*(1+$sections) + $bytes);
}

die "bogus RPM\n" if $rpm eq '';

open(ZCAT, "|gzip -cd") || die "can't pipe to gzip\n";
print ZCAT $rpm;
close ZCAT;
