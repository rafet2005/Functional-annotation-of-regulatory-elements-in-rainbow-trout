#!/usr/bin/perl

use warnings;
use strict;

if(scalar (@ARGV) != 5)
{
	print "use for: to addd source of the merge bed files by percentof overlap \n";
	print "need three arguments\n";
	print "first bed file one\n";
	print "Second file has the location of other be files\n";
	print "third output file\n";
    print "fourth is the tissue name for the main file\n";
	print "fifth percentage of overlap such as 0.5\n";
	exit(-1)
}

my @parts;
my @parts2;
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
my $flag;
my $file;
my $orChr;
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
		$orig1{$parts[0]}{$parts[1]}{$parts[2]} = $line;
        $tmp{$parts[0]}{$parts[1]}{$parts[2]} =  $ARGV[3];
	}
}
# input files that has locations of other files
while(<INPUT>)
{

	chomp;
	$file = $_;
    print "$file\n";
    @parts=split(/[_]+/,$file);
    $parts[2] =~ s/\s+//g;
    my $name = $parts[2];
    open INPUT3 ,"<$file" or die "couldn't open input file $file $!\n";
    while(<INPUT3>)
   {
         chomp;
          $line=$_;
          chop($line) if ($line=~ m/\r$/);# remove carige return ^m from end of line
          @parts2=split(/[\s]+/,$line);
          $orChr = $parts2[0];
          $start2 = $parts2[1];
          $end2 = $parts2[2];
          $length2 = $end2 - $start2 ;
          $flag = 0;


    foreach my $chr(keys %list)
    {
        foreach my $start1(keys %{$list{$chr}})
        {
            $end1 = $list{$chr}{$start1} ;
            $length1 = $end1 - $start1 ;
                # for full overlap we delete the samll one
				if (($start1  <= $start2) and ($start2 <= $end1) and ($end2 <= $end1) )
                {
                    #  print OUTPUT "Megede$line\t$orig{$parts[0]}{$key}{$end}\n";
                    $tmp{$chr}{$start1}{$end1} .= "\t" . $name;
                    $flag = 1;
                    #delete  $orig2{$chr}{$start2}{$end2};
                } 
                elsif(($start2 <= $start1) and ($start1 <= $end2) and ($end1 <= $end2))
                {
                    # print OUTPUT "Merged$line\t$orig{$parts[0]}{$key}{$end}\n";
                      $orig1{$chr}{$start2}{$end2} = $line;
                      $tmp{$chr}{$start2}{$end2} = $tmp{$chr}{$start1}{$end1};
                     $tmp{$chr}{$start2}{$end2} .=  "\t" . $name;
                      delete $tmp{$chr}{$start1}{$end1};
                      delete  $orig1{$chr}{$start1}{$end1};
                    $flag = 1;
                }
                # pick the start and end for partiall over lap over 0.5
                elsif(($start1 <=  $start2) and ($start2 <= $end1) and ($end1  <= $end2))
                {
                    $over = $end1 - $start2 + .0001; # I add .0001 to prevent divide by zero
                    if((($over /$length1) >=$ARGV[4] ) or (($over / $length2) >= $ARGV[4]))
                    {
                        # update the longer and delete the smaller
                                $orig1{$chr}{$start1}{$end2} = $orig1{$chr}{$start1}{$end1} ; # . "\t".$ARGV[3].$ARGV[4] ;#. "\t". $orig2{$chr}{$start2}{$end2} ;
                                $tmp{$chr}{$start1}{$end2}= $tmp{$chr}{$start1}{$end1};
                               $tmp{$chr}{$start1}{$end2} .= "\t" . $name;
                                delete $tmp{$chr}{$start1}{$end1};
                                delete  $orig1{$chr}{$start1}{$end1};
                            $flag = 1;
                   }

                }
                # pick the start and end for partiall over lap over 0.5
                elsif(($start2 <=  $start1) and ($start1 <= $end2) and ($end2  <= $end1))
                {
                    $over = $end2 - $start1 + .0001; # I add .0001 to prevent divide by zero
                    if((($over /$length1) >= $ARGV[4]) or (($over / $length2) >= $ARGV[4]))
                    {
                        # update the longer and delete the smaller
                                $orig1{$chr}{$start2}{$end1} = $orig1{$chr}{$start1}{$end1} ;# ."\t" .$ARGV[3].$ARGV[4] ;#. "\t". $orig2{$chr}{$start2}{$end2} ;
                                $tmp{$chr}{$start2}{$end1}= $tmp{$chr}{$start1}{$end1};
                               $tmp{$chr}{$start2}{$end1} .= "\t" . $name;
                                delete $tmp{$chr}{$start1}{$end1};
                                delete  $orig1{$chr}{$start1}{$end1};
                                $flag = 1;
                    }

                }
            
        }
    }
    if ($flag == 0)
    {
              $tmp{$orChr}{$start2}{$end2} =  $name;
              $orig1{$orChr}{$start2}{$end2} = $line;

    } 
}
}

#foreach my $chr(keys %orig1)
#{
#    foreach my $start(keys %{$orig1{$chr}})
#    {
#        foreach my $end(keys %{$orig1{$chr}{$start}})
#        {
#            # if ($orig1{$chr}{$start}{$end} !~ /$ARGV[3]/)
#              print OUTPUT "$orig1{$chr}{$start}{$end}\n";
#              #        print OUTPUT "$chr\t$start\t$end\t$ARGV[3]\n";
#        }
#    }
#}
foreach my $chr(keys %tmp)
{
    foreach my $start(keys %{$tmp{$chr}})
    {
        foreach my $end(keys %{$tmp{$chr}{$start}})
        {
                print OUTPUT  "$chr\t$start\t$end\t$tmp{$chr}{$start}{$end}\n";
                #       print OUTPUT "$chr\t$start\t$end\t$ARGV[3]\n";
        }
    }
}


close INPUT;
close OUTPUT;
close List;
