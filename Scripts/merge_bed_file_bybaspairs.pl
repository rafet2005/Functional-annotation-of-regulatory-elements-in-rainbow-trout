#!/usr/bin/perl

use warnings;
use strict;

if(scalar (@ARGV) != 4)
{
	print "use for: merge bed files by basepair\n";
	print "need three arguments\n";
	print "first bed file one\n";
	print "Second file\n";
	print "third output file\n";
	print "fourth cut off value\n";
	exit(-1)
}

my @parts;
my @name;
my @name2;
my $line;
my %list;
my %length;
my %tmp;
my %orig;
my %new;
my %Nelimit;
my %ExonStart;
my %ExonEnd;
my $count =1;
my $flag = 0;
my $NeExon = "";
my $tmp;
my $start;
my $dist;
my $end;
my $countP = 0;
#open(INPUT, "gunzip -c $ARGV[0] |") || die "can not open pipe to $ARGV[0] $!\n";
open List , "<$ARGV[0]" or die " could not open $ARGV[0] $!\n";
open INPUT , "<$ARGV[1]" or die " could not open $ARGV[1] $!\n";
open OUTPUT, ">$ARGV[2].csv" or die " could not open $ARGV[2] $!\n";
#open OUTPUT2, ">$ARGV[2]_gene_snp_info" or die " could not open $ARGV[2] $!\n";
#open LOG , ">$ARGV[1]/chr_$ARGV[2].log" or die "could not open $ARGV[1] $!\n";

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
		$orig{$parts[0]}{$parts[1]}{$parts[2]} = $line;
        $tmp{$parts[0]}{$parts[1]}{$parts[2]} = $line;
	}
}
# this is a special print statment for the header and should be adjusted base on input file

print OUTPUT "Chr,EnhStart,EnhEnd,Enhstrand, , , , , , , ,Gene,Body,Promoter1K,2K,3K,5K,10K,GeneStart,GeneEnd,GeneStrand,FirstExon,disTSS\n";
while(<INPUT>)
{
	chomp;
	$line = $_;
	# keep the header
	@parts = split(/[\s,]+/, $line);
#	if (($parts[3]+$parts[4]+$parts[7]+$parts[8]+$parts[9]+$parts[10]+$parts[11]+$parts[12]+$parts[13]+$parts[14]+$parts[15]+$parts[16])>= 10 )
#	if (($parts[3]+$parts[4]+$parts[7]+$parts[8]+$parts[9]+$parts[10]+$parts[11]+$parts[12]+$parts[13]+$parts[14]+$parts[5]+$parts[6])>= 10 )
#{
	if ($line !~ /^#/)
	{
		$tmp = $line;
		foreach my $key(keys %{$list{$parts[0]}})
		{
            $end = $list{$parts[0]}{$key} ;
				if (($key  <= $parts[1] and ($parts[1] <= $end) and $parts[2] <= $end) )
                {
                    #  print OUTPUT "Megede$line\t$orig{$parts[0]}{$key}{$end}\n";
                        $new{$parts[0]}{$key}{$end} = $tmp{$parts[0]}{$key}{$end};
                        delete  $tmp{$parts[0]}{$key}{$end};
                        last;
                } 
                elsif(($key  >= $parts[1] and ($key <= $parts[2]) and $parts[2] >= $end))
                {
                    # print OUTPUT "Merged$line\t$orig{$parts[0]}{$key}{$end}\n";
                        $new{$parts[0]}{$parts[1]}{$parts[2]} = $line;
                         delete  $tmp{$parts[0]}{$key}{$end};
                      #last;

                }
                elsif(($key  >= $parts[1] and ($key <= $parts[2]) and $parts[2] <= $end))
                {
                    if(($key + $ARGV[3]) <= $parts[2])
                            {
                                #   print OUTPUT "Merged$parts[0]\t$parts[1]\t$end\tORIG$line\tORGI$orig{$parts[0]}{$key}{$end}\n";
                                $new{$parts[0]}{$parts[1]}{$end} = $parts[0] ."\t".$parts[1]."\t".$end;
                                   delete  $tmp{$parts[0]}{$key}{$end};
                    #        delete $tmp{$parts[0]}{$parts[1]}{$parts[2]} ;
                                #last;

                            }

                }
                elsif(($key  <= $parts[1] and ( $parts[1]  <= $end) and $parts[2] >= $end))
                {
                    if(($parts[1] + $ARGV[3]) <= $end)
                            {
                                #   print OUTPUT "Merged$parts[0]\t$key\t$parts[2]\tORIG$line\tORGI$orig{$parts[0]}{$key}{$end}\n";
                                    $new{$parts[0]}{$key}{$parts[2]} = $parts[0] ."\t".$key."\t".$parts[2];
                                       delete  $tmp{$parts[0]}{$key}{$end};
                                    #last;

                            }

                }
                else
                {
                    #print OUTPUT "$line\n";
                    $new{$parts[0]}{$parts[1]}{$parts[2]} = $line;
                    # last;
                }


        }
    }
}

foreach my $chr(keys %tmp)
{
    foreach my $start(keys %{$tmp{$chr}})
    {
        foreach my $end(keys %{$tmp{$chr}{$start}})
        {
            print OUTPUT "$tmp{$chr}{$start}{$end}\tONE\n";
        }
    }
}

foreach my $chr(keys %new)
{
    foreach my $start(keys %{$new{$chr}})
    {
        foreach my $end(keys %{$new{$chr}{$start}})
        {
            print OUTPUT "$new{$chr}{$start}{$end}\tTWO\n";
        }
    }
}
close INPUT;
close OUTPUT;
close List;
