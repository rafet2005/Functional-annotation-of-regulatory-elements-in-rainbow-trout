#!/usr/bin/perl

use warnings;
use strict;

if(scalar (@ARGV) != 4)
{
	print "use for: outpue fro merge all bed files by add_source.pl to find stat and source \n";
	print "need three arguments\n";
	print "first bed file hass comination with three colomun chr start end\n";
	print "Second file hs the location of other  files\n";
	print "third output file\n";
    print "fourth Length .5\n";
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
		$list{$parts[0]}{$parts[1]}{$parts[2]} = $line;
		$orig1{$parts[0]}{$parts[1]}{$parts[2]} = 0;
        $tmp{$parts[0]}{$parts[1]}{$parts[2]} =  " ";
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
            foreach my $end1(keys %{$list{$chr}{$start1}})
            {
                #$end1 = $list{$chr}{$start1} ;
            $length1 = $end1 - $start1 ;
                # for full overlap we delete the samll one
                #	if (($start1  <= $start2)  and ($end2 <= $end1) )
				if (($start1  <= $start2) and ($start2 <= $end1) and ($end2 <= $end1) )
                {
                    if ($tmp{$chr}{$start1}{$end1}  !~ /$name/)
                        {
                            $tmp{$chr}{$start1}{$end1} .= $name;
		                        $orig1{$chr}{$start1}{$end1} += 1;
                        }
                    $flag = 1;
                } 
                elsif(($start2 <= $start1) and ($start1 <= $end2) and ($end1 <= $end2))
                {
                    if ($tmp{$chr}{$start1}{$end1}  !~ /$name/)
                        {
                            $tmp{$chr}{$start1}{$end1} .= $name;
		                        $orig1{$chr}{$start1}{$end1} += 1;
                        }
                    $flag = 1;
                }
                # pick the start and end for partiall over lap over 0.5
                    #elsif(($start1 <=  $start2) and ($start2 <= $end1) )
                elsif(($start1 <=  $start2) and ($start2 <= $end1) and ($end1  <= $end2))
                {
                    $over = $end1 - $start2 + .0001; # I add .0001 to prevent divide by zero
                    if((($over /$length1) >=$ARGV[3] ) or (($over / $length2) >= $ARGV[3]))
                    {
                    if ($tmp{$chr}{$start1}{$end1}  !~ /$name/)
                        {
                              $tmp{$chr}{$start1}{$end1} .= $name;
		                        $orig1{$chr}{$start1}{$end1} += 1;
                        }
                            $flag = 1;
                        }

                }
                # pick the start and end for partiall over lap over 0.5
                #elsif(($start2 <=  $start1) and ($start1 <= $end2) )
                elsif(($start2 <=  $start1) and ($start1 <= $end2) and ($end2  <= $end1))
                {
                    $over = $end2 - $start1 + .0001; # I add .0001 to prevent divide by zero
                    if((($over /$length1) >= $ARGV[3]) or (($over / $length2) >= $ARGV[3]))
                {
                    if ($tmp{$chr}{$start1}{$end1}  !~ /$name/)
                        {
                               $tmp{$chr}{$start1}{$end1} .= $name;
		                        $orig1{$chr}{$start1}{$end1} += 1;
                           }
                                $flag = 1;
                }
                }
            }
        }
    }
    if ($flag == 0)
    {
              $tmp{$orChr}{$start2}{$end2} =  0;
		      $orig1{$orChr}{$start2}{$end2} = 0;


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
                print OUTPUT  "$chr,$start,$end,$tmp{$chr}{$start}{$end},$orig1{$chr}{$start}{$end}\n";
                #       print OUTPUT "$chr\t$start\t$end\t$ARGV[3]\n";
        }
    }
}


close INPUT;
close OUTPUT;
close List;
=cut



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

				if (($key - $ARGV[3]) < $parts[1] and ($key + $limit{$parts[0]}{$key}    > $parts[1] ))  
				{
					#	print "Positive,$parts[1],$parts[0],$key,$ExonStart{$parts[0]}{$key},$ExonEnd{$parts[0]}{$key}\n";
					$line.=",". $list{$parts[0]}{$key}; #  add gene name;
					if (($key ) <= $parts[1] and ($end{$parts[0]}{$key}  >=  $parts[1] ))  
					{
						$line.=",". "Body,NA,NA,NA,NA,NA"; #  add body;
					}
					else
					{
						$line.=",". "NA"; # ;
						if (($key - 1000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."1K,2K,3k,5k,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							$countP++;
						}
						elsif (($key - 2000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,2K,3k,5k,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 3000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,NA,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - 5000) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($key - $ARGV[3]) <= $parts[1] and ($key  > $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,NA,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						else
						{
							$line.=",". "NA,NA,NA,NA,NA,NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
					}
					$line.=",".$key.",". $end{$parts[0]}{$key}.",".$signe{$parts[0]}{$key}; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					if($parts[1] > $ExonStart{$parts[0]}{$key}  and $parts[1] < $ExonEnd{$parts[0]}{$key} )
					{
						$line.= "," ."FirstExon"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					}
                    else
                    {
						$line.= ",NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";

                    }
                    $dist =  $key -  $parts[1]   ;
					print 	OUTPUT "$line,$dist\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					$line = $tmp;
				#	last;
				}
			}
			else
			{
				if (  ($end{$parts[0]}{$key} - $Nelimit{$parts[0]}{$key})  <= $parts[1] and (($end{$parts[0]}{$key} + $ARGV[3] )  >= $parts[1] ))  
				{
					#	print "Negative,$parts[1],$parts[0],$key,$ExonStart{$parts[0]}{$key},$ExonEnd{$parts[0]}{$key}\n";
					$line.=",". $list{$parts[0]}{$key}; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					if (($key ) <= $parts[1] and ($end{$parts[0]}{$key}  >=  $parts[1] ))  
					{
						$line.=",". "Body,NA,NA,NA,NA,NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					}
					else
					{
						$line.=",". "NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						if (($end{$parts[0]}{$key} + 2000 >= $parts[1]) and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."1K,2K,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
							$countP++;
						}
						elsif (($end{$parts[0]}{$key} + 2000 >= $parts[1]) and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,2K,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($end{$parts[0]}{$key} + 3000) >= $parts[1] and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,NA,3K,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($end{$parts[0]}{$key} + 5000) >= $parts[1] and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,5K,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						elsif (($end{$parts[0]}{$key} + $ARGV[3]) >= $parts[1] and ($end{$parts[0]}{$key}  <= $parts[1] ))  
						{
							$line.= "," ."NA,NA,NA,NA,10K"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
						else
						{
							$line.=",". "NA,NA,NA,NA,NA,NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
						}
					}
					$line.=",".$key.",". $end{$parts[0]}{$key}.",".$signe{$parts[0]}{$key}; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					if($parts[1] > $ExonStart{$parts[0]}{$key}  and $parts[1] < $ExonEnd{$parts[0]}{$key} )
					{
						$line.= "," ."FirstExon"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					}
                    else
                    {
						$line.= ",NA"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";

                    }
                    $dist =  $end{$parts[0]}{$key} -  $parts[1] ; 
					print 	OUTPUT "$line,$dist\n"; # $parts[1],$parts[2],$parts[3],$parts[4]\n";
					$line = $tmp;
					#last;
				}
			}
		}

	}
#}
}
print "there are $countP within 1K\n";
close INPUT;
close OUTPUT;
close List;
foreach my $key(keys %gene)
{
	if($gene_count{$key} > 1)
	{
		print OUTPUT "$key $gene{$key}\n";
	}
	else
	{
		print OUTPUT2 "$key $gene{$key}\n";
	}
}
#=cut
		#if (length($parts[3]) == 1 and length( $parts[4]) == 1 and $parts[6] eq 'PASS' and $parts[0] == $ARGV[2])
		# keep pass
		if ( $parts[6] eq 'PASS')
		{
			$Pcount++;
			if($parts[0] eq $ARGV[2])
			{
				# classify based on number of allele 	
				if ( length($parts[3]) == 1 and length( $parts[4]) == 1)
				{	
					$Scount++;		
					print OUTPUT "$line\n";
				}
			}
		}
	} 

}
#record stat to log file
print LOG "The following was observed:\n";
print LOG "\n\nTotla number of variants is           : $Tcount\n";
print LOG "Totla number of Passing variants is   : $Pcount\n";
print LOG "Totla number of Passing Biallelic variants for $ARGV[2] : $Scount\n";
close INPUT;
close OUTPUT;
close LOG;
