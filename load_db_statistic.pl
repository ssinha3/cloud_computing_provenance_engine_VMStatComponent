#!/usr/bin/perl
use DBI;
print "####### LOAD DB IN PROGRESS #######\n";
$dbh = DBI->connect('dbi:mysql:provenance','root','') or die "Error: $DBI::errstr\n";
$dbh_vcl = DBI->connect('dbi:mysql:vcl','root','') or die "Error: $DBI::errstr\n";
open(MYFILE,$ARGV[0]) || die "Cannot open file \"$ARGV[0]\"";
while($line = <MYFILE>)
{
    chomp($line);
    my @arr = split(/ /, $line);
        $arr[0]=~ s/\-(.*)//g;
	$lastupdt = $arr[0];
	if ( $lastupdt =~ /^([0-9]{4})([0-9]{2})([0-9]{2})/)
	{
        $lastupdt = "$1-$2-$3";
	}
	#print "$lastupdt\n";
        $vname = $arr[3];
        $arr[5] =~ s/%//g;
        $arr[7] =~ s/%//g;
        $cpu = $arr[5];
        $mem = $arr[7];
        $sql_vcl = "select stateid, IPaddress  from computer where hostname='$vname'";
        $sth_vcl = $dbh_vcl->prepare($sql_vcl);
        $sth_vcl->execute or die "SQL Error: $DBI::errstr\n";
        while (@row = $sth_vcl->fetchrow_array)
        {
        $myquery = "INSERT INTO vmusage (`id`, `stateid`, `hostname`, `lastupdated`, `Pub_IPaddress`,`CPU(%)`, `Mem(%)`) VALUES (DEFAULT,'$row[0]','$vname','$lastupdt','$row[1]','$cpu','$mem')";
        $st_vcl = $dbh->prepare($myquery);
        $st_vcl->execute or die "SQL Error: $DBI::errstr\n";
        #print "$row[1]\n";
        }
}
close(MYFILE);
