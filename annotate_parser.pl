#!/usr/bin/perl
use warnings;
use strict;
use Getopt::Long qw(GetOptions);
use Pod::Usage;

# VERSION
=head1 SYNOPSIS

annotate_parser.pl -i kobas_output.txt -o kobas_tabular_output.txt

=head1 DESCRIPTION

Perl file to convert KOBAS annotate output to tabular format

=head1 OPTIONS
 
=over 8

=item I<-i>

Input file (original KOBAS annotate file)

=item I<-o>
	
Output file to store converted KOBAS file. If no output path is provided, results will be printed on the console.

=back 

=cut


my $help = 0;
my ($in, $out);
my $state = 0;
my ($Path_state, $GO_state, $GO_slim_state) = (0)x3;
my ($Query, $Gene_id, $Gene_name, $Entrez_id) = ("NA")x4;
my (@All_pathway_ids, @All_GO_ids, @All_GO_slim_ids);

# handle command line options
#GetOptions('i=s' => \$in,
#           'o=s' => \$out) or die "Usage: $0 -i input_path -o output_path\n";

GetOptions('i=s' => \$in,
           'o=s' => \$out,
					 q(help) => \$help) or pod2usage(q(-verbose) => 1);

pod2usage(q(-verbose) => 1) if $help;


# check command line options
check_arguments($in, $out);

# input files can be provided comma separated -> all files will be parsed into single output file
my @samples = (split(/,/,$in));
foreach(@samples) {
	parse($_);
}

sub parse {
	# open file and parse content using flip flop principle
	open(my $filehandle,'<',$_[0]) || die "Can´t open $in: $!";
	while(my $line = <$filehandle>) {
	  chomp($line);
	  if($line =~ m!^/{4}! and $state == 0) {
		$state = 1;
	  }
	  elsif($line =~ m!^/{4}! and $state == 1) {
		# concate final information of arrays
		my $Pathway = @All_pathway_ids ? join(";", @All_pathway_ids) : "NA";
		my $GO = @All_GO_ids ? join(";", @All_GO_ids) : "NA";
		my $GO_slim = @All_GO_slim_ids ? join(";", @All_GO_slim_ids) : "NA";

		# output information
		# if output path is set, write to file
		# otherwise print in console
		if(defined $out) {
		  write_file($out, join("\t", $Query, $Gene_id, $Gene_name, $Entrez_id, $Pathway, $GO, $GO_slim));
		}
		else {
		  print(join("\t", $Query, $Gene_id, $Gene_name, $Entrez_id, $Pathway, $GO, $GO_slim) . "\n");
		}

		# reset variables for next annotation
		($Query, $Gene_id, $Gene_name, $Entrez_id) = ("NA")x4;
		@All_pathway_ids = ();
		@All_GO_ids = ();
		@All_GO_slim_ids = ();

		# set state
		$state = 1;
	  }
	  elsif($state) {
		# get query id
		if($line =~ /^Query:/) {
		  $Query = (split(/\t/,$line))[1] // "NA";
		}

		# get gene id
		if($line =~ /^Gene:/) {
		  $Gene_id = (split(/\t/,$line))[1] // "NA";
		  $Gene_name = (split(/\t/,$line))[2] // "NA";
		}

		# get entrez gene id
		if($line =~ /^Entrez/) {
		  $Entrez_id = (split(/\t/,$line))[1] // "NA";
		}

		# get pathway ids
		if($line =~ /^Pathway:/ and $Path_state == 0) {
		  push(@All_pathway_ids, (split(/\t/,$line))[-1] // "NA");
		  $Path_state = 1
		}
		elsif($line !~ /^\s/ and $Path_state == 1) {
		  $Path_state = 0;
		}
		elsif($Path_state) {
		  push(@All_pathway_ids, (split(/\t/,$line))[-1] // "NA");
		}

		# get GO ids
		if($line =~ /^GO:/ and $GO_state == 0) {
		  push(@All_GO_ids, (split(/\t/,$line))[-1] // "NA");
		  $GO_state = 1
		}
		elsif($line !~ /^\s/ and $GO_state == 1) {
		  $GO_state = 0;
		}
		elsif($GO_state) {
		  push(@All_GO_ids, (split(/\t/,$line))[-1] // "NA");
		}

		# get GO Slim ids
		if($line =~ /^GOslim:/ and $GO_slim_state == 0) {
		  push(@All_GO_slim_ids, (split(/\t/,$line))[-1] // "NA");
		  $GO_slim_state = 1
		}
		elsif($line !~ /^\s/ and $GO_slim_state == 1) {
		  $GO_slim_state = 0;
		}
		elsif($GO_slim_state) {
		  push(@All_GO_slim_ids, (split(/\t/,$line))[-1] // "NA");
		}
		}
	}
	close $filehandle;
}

sub check_arguments {
  # check if input file is provided, otherwise exit the program
  if(!$_[0]) {
    print("No input file provided. Use '-i' tag.\n");
    exit;
  }
  # check if '-o' parameter is provided
  if(defined $_[1]) {
      # check if output file already exists
      if(-e $_[1]) {
	  	print("Output file already exists, please provide an other output path.\n");
		exit;
      }
  }
}

sub write_file {
  # append parsed data to file
  open(FH, ">>", $_[0]) || die $!;
  print(FH $_[1] . "\n");
  close(FH);
}
