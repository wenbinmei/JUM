#!/usr/bin/perl
use strict;
use warnings;
use Statistics::Descriptive;
#data_file_1=temp_long_intron_retention_junction_coordinate_with_read_num.txt; date_file_2=long_intron_retention_with_linear_fitting.txt; 

my $len=scalar(@ARGV);
if ($len < 1) {
    die "Usage:determining_rightful_total_cassette_exon_event.pl <data_file_1> <data_file_2>\n";

}

my ($data_file_1, $data_file_2)  = @ARGV;

my %junction; #$junction{junction_id}=[#_coor1][#_coor2]....;

open(IN1, "<$data_file_1") or die "can't open input1 file: $!";
open(OUT, ">$data_file_2") or die "can't open input2 file: $!";

while(<IN1>) {
      chomp;
      my @array=split(/\s+/,$_);
       if(exists $junction{$array[4]}) {
          $junction{$array[4]}[0]=$junction{$array[4]}[0]+1;
          $junction{$array[4]}[$junction{$array[4]}[0]]=$array[5];
       }
       else {
          $junction{$array[4]}[0]=1;
          $junction{$array[4]}[1]=$array[5];
       }
}

close IN1;

my @y;
my $j;

foreach my $i (sort keys %junction) {
       my $outlier_indicator=0;
       my @y = @{ $junction{$i} }[1 .. $junction{$i}[0]];
       my $stat = Statistics::Descriptive::Full->new();
       $stat->add_data(\@y);
       my $q1 = $stat->quantile(1);
       my $q3 = $stat->quantile(3);
       my $q0 = $stat->quantile(0);
       my $q4 = $stat->quantile(4);
       my $median = $stat->median();
       if (($q0 < $median/4) || ($q1 < $q3/3) || ($q4 > $median*4)) {
             $outlier_indicator=1;
       }              
       print OUT $i; print OUT "\t"; print OUT $outlier_indicator; print OUT "\t"; # print OUT $q0; print OUT "\t"; print OUT $median; print OUT "\t"; print OUT $q1; print OUT "\t"; print OUT $q3; print OUT "\t";
          if ( grep( /^0$/, @{ $junction{$i} } ) ) {       #this is to determine if there is any zero readout for read mapped to the intron. If yes, not valid intron retention and will be marked as 1, otherwise 0
            print OUT "1"; print OUT "\n";
          }
          else { print OUT "0"; print OUT "\n";
          }
}
                  
       
