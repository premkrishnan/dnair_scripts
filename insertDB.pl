#===========================================================================================
# Description
#-------------------------------------------------------------------------------------------
# Filter Program to validate excel file
# Note: Please make sure that the input excel file is in '.xls' format
# Authors: Premkrishnan B. V.
# Date: June 8th 2016
# Version: 1.0
#===========================================================================================
# Modification block
#-------------------------------------------------------------------------------------------
#
#===========================================================================================

#!usr/bin/perl
use strict;
use warnings;
use Spreadsheet::ParseExcel::SaveParser;
use DBI;

# DB Connectivity #
my $dbuser = 'root';
my $dbpwd = '1234';
my $db = 'organism_database';
my $table1 = 'samplers';
my $table2 = 'users';
my $table3 = 'locations';
my $table4 = 'projects';
my $table5 = 'media_types';
my $table6 = 'sequencer';
my %samplers = ();
my %users = ();
my %locations = ();
my %projects = ();
my %media_types = ();
my %sequencer = ();
my $dataQuery = '';

# Establishing DB Connectivity #
my $conn = DBI->connect("dbi:mysql:$db",$dbuser,$dbpwd) or die "Can't establish DB connectivity\n";

# Reading Input Folder #
my $inputFile = 'excel_to_upload.xls';
=put
# Get sampler ids
$dataQuery = "select * from $table1";
&fetchdb($dataQuery,\%samplers);

# Get user ids
$dataQuery = "select * from $table2";
&fetchdb($dataQuery,\%users);

# Get location ids
$dataQuery = "select * from $table3";
&fetchdb($dataQuery,\%locations);

# Get project ids
$dataQuery = "select * from $table4";
&fetchdb($dataQuery,\%projects);

# Get media type ids
$dataQuery = "select * from $table5";
&fetchdb($dataQuery,\%media_types);

# Get sequencer ids
$dataQuery = "select * from $table6";
&fetchdb($dataQuery,\%sequencer);
foreach my $x(keys %locations)
{
	print "$x\t$locations{$x}\n";
}
=cut

# ----------------#
# Database upload #
# ----------------#
# Open an existing file with SaveParser
my $parser   = Spreadsheet::ParseExcel::SaveParser->new();
my $template = $parser->Parse($inputFile);

# Get the worksheet
foreach my $worksheet( $template->worksheets())
{
	my $colStart = 0;
	my $colEnd = 0;	
	my $query = '';
	my $sth = '';
	my $i = 1;
	my $name = $worksheet->get_name();
	
	## tables update
	if($name eq 'samples')
	{
		$colEnd = 14;
		$query = "insert into samples (sample_id,sample_name,sampler_id,location_id,remarks,project_id,sample_type,sampling_height,sampling_start_date,sampling_time,storage_method,media_type_id,collection_temperature,pacbio_seq,sequencer_id) values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
		$sth = $conn->prepare($query) or die "$!";

			my $sample_id = 0;
			my $sample_name = '-';
			my $sampler_id = 0;
			my $location_id = 0;
			my $remarks = '-';
			my $project_id = 0;
			my $sample_type = 0;
			my $sampling_height = 0;
			my $sampling_start_date = '00/00/0000';
			my $sampling_time = '00:00:00';
			my $storage_method = '-';
			my $media_type_id = 0;
			my $collection_temperature = 0;
			my $pacbio_seq = '-';
			my $sequencer_id = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			$sample_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			$sample_name = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			$sampler_id = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$location_id = $worksheet->get_cell($i,3)->{Val} if(defined($worksheet->get_cell($i,3)->{Val}) && ($worksheet->get_cell($i,3)->{Val} ne ''));
			$remarks = $worksheet->get_cell($i,4)->{Val} if(defined($worksheet->get_cell($i,4)->{Val}) && ($worksheet->get_cell($i,4)->{Val} ne ''));
			$project_id = $worksheet->get_cell($i,5)->{Val} if(defined($worksheet->get_cell($i,5)->{Val}) && ($worksheet->get_cell($i,5)->{Val} ne ''));
			$sample_type = $worksheet->get_cell($i,6)->{Val} if(defined($worksheet->get_cell($i,6)->{Val}) && ($worksheet->get_cell($i,6)->{Val} ne ''));
			$sampling_height = $worksheet->get_cell($i,7)->{Val} if(defined($worksheet->get_cell($i,7)->{Val}) && ($worksheet->get_cell($i,7)->{Val} ne ''));
			$sampling_start_date = $worksheet->get_cell($i,8)->value if(defined($worksheet->get_cell($i,8)->{Val}) && ($worksheet->get_cell($i,8)->{Val} ne ''));
			$sampling_time = $worksheet->get_cell($i,9)->value if(defined($worksheet->get_cell($i,9)->{Val}) && ($worksheet->get_cell($i,9)->{Val} ne ''));
			$storage_method = $worksheet->get_cell($i,10)->{Val} if(defined($worksheet->get_cell($i,10)->{Val}) && ($worksheet->get_cell($i,10)->{Val} ne ''));
			$media_type_id = $worksheet->get_cell($i,11)->{Val} if(defined($worksheet->get_cell($i,11)->{Val}) && ($worksheet->get_cell($i,11)->{Val} ne ''));
			$collection_temperature = $worksheet->get_cell($i,12)->{Val} if(defined($worksheet->get_cell($i,12)->{Val}) && ($worksheet->get_cell($i,12)->{Val} ne ''));
			$pacbio_seq = $worksheet->get_cell($i,13)->{Val} if(defined($worksheet->get_cell($i,13)->{Val}) && ($worksheet->get_cell($i,13)->{Val} ne ''));
			$sequencer_id = $worksheet->get_cell($i,14)->{Val} if(defined($worksheet->get_cell($i,14)->{Val}) && ($worksheet->get_cell($i,14)->{Val} ne ''));
			$sth->execute($sample_id,$sample_name,$sampler_id,$location_id,$remarks,$project_id,$sample_type,$sampling_height,$sampling_start_date,$sampling_time,$storage_method,$media_type_id,$collection_temperature,$pacbio_seq,$sequencer_id);
			#print "$sample_id,$sample_name,$sampler_id,$location_id,$remarks,$project_id,$sample_type,$sampling_height,$sampling_start_date,$sampling_time,$storage_method,$media_type_id,$collection_temperature,$pacbio_seq,$sequencer_id\n";

			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'samples_users')
	{
		$colEnd = 2;
		$query = "insert into samples_users (sample_user_id,sample_id,user_id) values (?,?,?)";
		$sth = $conn->prepare($query);
		
		my $id1 = 0;
		my $id2 = 0;
		my $id3 = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id1 = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $id2 = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $id3 = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$sth->execute($id1,$id2,$id3);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'species_strain')
	{
		$colEnd = 9;
		$query = "insert into species_strain (species_strain_taxa_id,species_strain_name,genus_taxa_id,genome_availability,genome_size,genome_size_units,description,carbon_fixation_method,reducing_agents,energy_source) values (?,?,?,?,?,?,?,?,?,?)";
		$sth = $conn->prepare($query);

		my $species_strain_taxa_id = 0;
		my $species_strain_name = '-';
		my $genus_taxa_id = 0;
		my $genome_availability = '-';
		my $genome_size = 0;
		my $genome_size_units = '-';
		my $description = '-';
		my $carbon_fixation_method = '-';
		my $reducing_agents = '-';
		my $energy_source = '-';

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			$species_strain_taxa_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			$species_strain_name = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			$genus_taxa_id = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$genome_availability = $worksheet->get_cell($i,3)->{Val} if(defined($worksheet->get_cell($i,3)->{Val}) && ($worksheet->get_cell($i,3)->{Val} ne ''));
			$genome_size = $worksheet->get_cell($i,4)->{Val} if(defined($worksheet->get_cell($i,4)->{Val}) && ($worksheet->get_cell($i,4)->{Val} ne ''));
			$genome_size_units = $worksheet->get_cell($i,5)->{Val} if(defined($worksheet->get_cell($i,5)->{Val}) && ($worksheet->get_cell($i,5)->{Val} ne ''));
			$description = $worksheet->get_cell($i,6)->{Val} if(defined($worksheet->get_cell($i,6)->{Val}) && ($worksheet->get_cell($i,6)->{Val} ne ''));
			$carbon_fixation_method = $worksheet->get_cell($i,7)->{Val} if(defined($worksheet->get_cell($i,7)->{Val}) && ($worksheet->get_cell($i,7)->{Val} ne ''));
			$reducing_agents = $worksheet->get_cell($i,8)->{Val} if(defined($worksheet->get_cell($i,8)->{Val}) && ($worksheet->get_cell($i,8)->{Val} ne ''));
			$energy_source = $worksheet->get_cell($i,9)->{Val} if(defined($worksheet->get_cell($i,9)->{Val}) && ($worksheet->get_cell($i,9)->{Val} ne ''));
			$sth->execute($species_strain_taxa_id,$species_strain_name,$genus_taxa_id,$genome_availability,$genome_size,$genome_size_units,$description,$carbon_fixation_method,$reducing_agents,$energy_source);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'species_ecology')
	{
		$colEnd = 2;
		$query = "insert into species_ecology (species_ecology_id,species_id,ecology_id) values (?,?,?)";
		$sth = $conn->prepare($query);
		
		my $se_id = 0;
		my $s_id = 0;
		my $e_id = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $se_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $s_id = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $e_id = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$sth->execute($se_id,$s_id,$e_id);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'assembly')
	{
		$colEnd = 6;
		$query = "insert into assembly (assembly_id,species_id,n50_val,tot_num_contigs,max_contig_length,sum_read_len,16s_identity) values (?,?,?,?,?,?,?)";
		$sth = $conn->prepare($query);
		
		my $assembly_id = 0;
		my $species_id = 0;
		my $n50_val = 0;
		my $tot_num_contigs = 0;
		my $max_contig_length = 0;
		my $sum_read_len = 0;
		my $s16_identity = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $assembly_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $species_id = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $n50_val = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			my $tot_num_contigs = $worksheet->get_cell($i,3)->{Val} if(defined($worksheet->get_cell($i,3)->{Val}) && ($worksheet->get_cell($i,3)->{Val} ne ''));
			my $max_contig_length = $worksheet->get_cell($i,4)->{Val} if(defined($worksheet->get_cell($i,4)->{Val}) && ($worksheet->get_cell($i,4)->{Val} ne ''));
			my $sum_read_len = $worksheet->get_cell($i,5)->{Val} if(defined($worksheet->get_cell($i,5)->{Val}) && ($worksheet->get_cell($i,5)->{Val} ne ''));
			my $s16_identity = $worksheet->get_cell($i,6)->{Val} if(defined($worksheet->get_cell($i,6)->{Val}) && ($worksheet->get_cell($i,6)->{Val} ne ''));
			$sth->execute($assembly_id,$species_id,$n50_val,$tot_num_contigs,$max_contig_length,$sum_read_len,$s16_identity);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'species_citations')
	{
		$colEnd = 2;
		$query = "insert into species_citations (species_citation_id,species_id,citation_id) values (?,?,?)";
		$sth = $conn->prepare($query);
		
		my $species_citation_id = 0;
		my $s_id = 0;
		my $c_id = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $species_citation_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $s_id = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $c_id = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$sth->execute($species_citation_id,$s_id,$c_id);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'links')
	{
		$colEnd = 2;
		$query = "insert into links (link_id,link,species_id) values (?,?,?)";
		$sth = $conn->prepare($query);
		
		my $link_id = 0;
		my $link = '-';
		my $s_id = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $s_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $link_id = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $link = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$sth->execute($link_id,$link,$s_id);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'species_samples')
	{
		$colEnd = 2;
		$query = "insert into species_samples (species_sample_id,species_id,sample_id) values (?,?,?)";
		$sth = $conn->prepare($query);
		
		my $species_sample_id = 0;
		my $species_id = 0;
		my $sample_id = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $species_sample_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $species_id = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $sample_id = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$sth->execute($species_sample_id,$species_id,$sample_id);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'sequences')
	{
		$colEnd = 2;
		$query = "insert into sequences (sequences_id,species_id,sequence) values (?,?,?)";
		$sth = $conn->prepare($query);
		
		my $sequences_id = 0;
		my $species_id = 0;
		my $sequence = 0;

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $sequences_id = $worksheet->get_cell($i,0)->{Val} if(defined($worksheet->get_cell($i,0)->{Val}) && ($worksheet->get_cell($i,0)->{Val} ne ''));
			my $species_id = $worksheet->get_cell($i,1)->{Val} if(defined($worksheet->get_cell($i,1)->{Val}) && ($worksheet->get_cell($i,1)->{Val} ne ''));
			my $sequence = $worksheet->get_cell($i,2)->{Val} if(defined($worksheet->get_cell($i,2)->{Val}) && ($worksheet->get_cell($i,2)->{Val} ne ''));
			$sth->execute($sequences_id,$species_id,$sequence);
			$i++;
		}
		$sth->finish();
	}
}

$conn->disconnect();

sub fetchdb
{
	my $refquery = shift;
	my $refhash = shift;
	my $dbsth = '';
	$dbsth = $conn->prepare($refquery);
	$dbsth->execute();
	while (my @row = $dbsth->fetchrow_array()) 
	{
	   $$refhash{$row[0]} = $row[1];
	}
	$dbsth->finish();
}