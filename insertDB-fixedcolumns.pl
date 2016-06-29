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
use Spreadsheet::ParseExcel::SaveParser;
use DBI;

# DB Connectivity #
my $dbuser = 'root';
my $dbpwd = '1234';
my $db = 'organism_database';

# Establishing DB Connectivity #
my $conn = DBI->connect("dbi:mysql:$db",$dbuser,$dbpwd) or die "Can't establish DB connectivity\n";

# Reading Input Folder #
my $inputFile = 'excel_to_upload.xls';
	
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
	
	## table
	if($name eq 'genus')
	{
		$colEnd = 1;
		$query = "insert into genus (genus_taxa_id,genus_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'ecology')
	{
		$colEnd = 1;
		$query = "insert into ecology (ecology_id,ecology) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'users')
	{
		$colEnd = 3;
		$query = "insert into users (user_id,user_name,password,role) values (?,?,?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			my $pass = $worksheet->get_cell($i,2)->{Val};
			my $role = $worksheet->get_cell($i,3)->{Val};
			$sth->execute($id,$name,$pass,$role);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'citations')
	{
		$colEnd = 1;
		$query = "insert into citations (citation_id,citation_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = $worksheet->get_cell($i,1)->{Val};
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'samplers')
	{
		$colEnd = 1;
		$query = "insert into samplers (sampler_id,sampler_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'location_type')
	{
		$colEnd = 1;
		$query = "insert into location_type (type_id,type_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'locations')
	{
		$colEnd = 2;
		$query = "insert into locations (location_id,location_name,location_type_id) values (?,?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			my $type = $worksheet->get_cell($i,2)->{Val};
			$sth->execute($id,$name,$type);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'projects')
	{
		$colEnd = 1;
		$query = "insert into projects (project_id,project_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'media_types')
	{
		$colEnd = 1;
		$query = "insert into media_types (media_type_id,media_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
	elsif($name eq 'sequencer')
	{
		$colEnd = 1;
		$query = "insert into sequencer (sequencer_id,sequencer_name) values (?,?)";
		$sth = $conn->prepare($query);

		# Variable Declaration and insertion #
		while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
		{
			my $id = $worksheet->get_cell($i,0)->{Val};
			my $name = ucfirst($worksheet->get_cell($i,1)->{Val});
			$sth->execute($id,$name);
			$i++;
		}
		$sth->finish();
	}
}

$conn->disconnect();
