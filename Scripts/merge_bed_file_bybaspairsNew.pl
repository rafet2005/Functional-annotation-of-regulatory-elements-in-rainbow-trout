#!/usr/bin/perl

use warnings;
use strict;

if(scalar (@ARGV) != 6)
{
	print "use for: merge bed files by basepair\n";
	print "need three arguments\n";
	print "first bed file one\n";
	print "Second file\n";
	print "third output file\n";
	print "first tissue Name\n";
	print "second tissue Name\n";
	print "percentage of overlap such as 0.5\n";
	exit(-1)
}

my @parts;
my @name;
my @name2;
my $line;
my %list;
my %list2;
my %length;
my %tmp;
my %tmp2;
my %orig1;
my %orig2;
my %new;
my %Nelimit;
my %ExonStart;
my %ExonEnd;
my $count =1;
my $flag = 0;
my $NeExon = "";
my $tmp;
my $starti1;
my $end1;
my $dist1;
my $start2;
my $end2;
my $dist2;
my $length1;
my $length2;
my $over;
my $countP = 0;
#open(INPUT, "gunzip -c $ARGV[0] |") || die "can not open pipe to $ARGV[0] $!\n";
open List , "<$ARGV[0]" or die " could not open $ARGV[0] $!\n";
open INPUT , "<$ARGV[1]" or die " could not open $ARGV[1] $!\n";
open OUTPUT, ">$ARGV[2].csv" or die " could not open $ARGV[2] $!\n";

#create a hash to hold the genes and use the chr and start point as key and gene Id as value
while(<List>)
{
	chomp;
	$line = $_;
	if ($line !~ /##/)
	{
	@parts = split(/[\s]+/, $line);
#		@parts = split(/[\s]+/, $line);
#		@name = split('GeneID:' , $parts[8]);
#		@name2 = split(',', $name[1]);
		$list{$parts[0]}{$parts[1]} = $parts[2];
		$orig1{$parts[0]}{$parts[1]}{$parts[2]} = $line;
        $tmp{$parts[0]}{$parts[1]}{$parts[2]} = $line;
	}
}
while(<INPUT>)
{
	chomp;
	$line = $_;
	if ($line !~ /##/)
	{
	@parts = split(/[\s]+/, $line);
		$list2{$parts[0]}{$parts[1]} = $parts[2];
		$orig2{$parts[0]}{$parts[1]}{$parts[2]} = $line;
        $tmp2{$parts[0]}{$parts[1]}{$parts[2]} = $line;
	}
}
foreach my $chr(keys %list)
{
    foreach my $start1(keys %{$list{$chr}})
    {
        $end1 = $list{$chr}{$start1} ;
        $length1 = $end1 - $start1 ;
        foreach my $start2(keys %{$list2{$chr}})
        {
             $end2 = $list2{$chr}{$start2} ;
               $length2 = $end2 - $start2 ;
                # for full overlap we delete the samll one
				if (($start1  <= $start2) and ($start2 <= $end1) and ($end2 <= $end1) )
                {
                    #  print OUTPUT "Megede$line\t$orig{$parts[0]}{$key}{$end}\n";
                    #         $orig1{$chr}{$start1}{$end1} .= "\t" . $ARGV[4];
                        delete  $orig2{$chr}{$start2}{$end2};
                } 
                elsif(($start2 <= $start1) and ($start1 <= $end2) and ($end1 <= $end2))
                {
                    # print OUTPUT "Merged$line\t$orig{$parts[0]}{$key}{$end}\n";
                    #  $orig2{$chr}{$start2}{$end2} .= "\t". $ARGV[3];
                         delete  $orig1{$chr}{$start1}{$end1};
                }
                # pick the start and end for partiall over lap over 0.5
                elsif(($start1 <=  $start2) and ($start2 <= $end1) and ($end1  <= $end2))
                {
                    $over = $end1 - $start2 + .0001; # I add .0001 to prevent divide by zero
                    if((($over /$length1) >=$ARGV[5] ) or (($over / $length2) >= $ARGV[5]))
                    {
                        # update the longer and delete the smaller
                                $orig1{$chr}{$start1}{$end2} = $orig1{$chr}{$start1}{$end1} ; # . "\t".$ARGV[3].$ARGV[4] ;#. "\t". $orig2{$chr}{$start2}{$end2} ;
                                delete  $orig1{$chr}{$start1}{$end1};
                                delete  $orig2{$chr}{$start2}{$end2};
                   }

                }
                # pick the start and end for partiall over lap over 0.5
                elsif(($start2 <=  $start1) and ($start1 <= $end2) and ($end2  <= $end1))
                {
                    $over = $end2 - $start1 + .0001; # I add .0001 to prevent divide by zero
                    if((($over /$length1) >= $ARGV[5]) or (($over / $length2) >= $ARGV[5]))
                    {
                        # update the longer and delete the smaller
                                $orig1{$chr}{$start2}{$end1} = $orig1{$chr}{$start1}{$end1} ;# ."\t" .$ARGV[3].$ARGV[4] ;#. "\t". $orig2{$chr}{$start2}{$end2} ;
                                delete  $orig1{$chr}{$start1}{$end1};
                                delete  $orig2{$chr}{$start2}{$end2};
                    }

                }
            
        }
    }
}


foreach my $chr(keys %orig1)
{
    foreach my $start(keys %{$orig1{$chr}})
    {
        foreach my $end(keys %{$orig1{$chr}{$start}})
        {
              print OUTPUT "$orig1{$chr}{$start}{$end}\t$ARGV[3]\n";
        }
    }
}
foreach my $chr(keys %orig2)
{
    foreach my $start(keys %{$orig2{$chr}})
    {
        foreach my $end(keys %{$orig2{$chr}{$start}})
        {
                print OUTPUT "$orig2{$chr}{$start}{$end}\t$ARGV[4]\n";
        }
    }
}


close INPUT;
close OUTPUT;
close List;
