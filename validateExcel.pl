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
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;
use DBI;

# DB Connectivity #
my $dbuser = 'root';
my $dbpwd = '';
my $db = 'GeneLibrary';
my $Table1 = 'species';
my $Table2 = 'geneTranscript';

# Establishing DB Connectivity #
#my $conn = DBI->connect("dbi:mysql:$db",$dbuser,$dbpwd) or die "Can't establish DB connectivity\n";

# Input & O/P Files #
my $OutputFolder = "Validated";

# Variable Declaration and initialization #
my $CommentFile = '';
my $ErrorFile = '';

if(-d $OutputFolder) # If O/P Folder alreday present, emptying the folder #
{
	opendir(DIRDATA,$OutputFolder) or die "can't open $OutputFolder for reading\n";
	while(my $files = readdir(DIRDATA))
	{
		next if($files=~/^\s*\.+\s*$/);
		my $FileName = "$OutputFolder\/$files";
		unlink($FileName);
	}
	closedir DIRDATA; # Closing Directory handler #
}
else
{
	mkdir($OutputFolder);
}


# Reading Input Folder #
my $InputFile = 'excel_to_upload.xls';
my $filename = $1 if($InputFile=~/^\s*(\S+)\.+xls$/);
my $OutputFile = "$OutputFolder\/$InputFile";

# Error log file
if($ErrorFile eq '')
{
	$ErrorFile = "$OutputFolder\/$filename".'_error_log.txt';
}

if($InputFile=~/\.+xls/)
{
	#&validateExcel($InputFile,$OutputFile,$ErrorFile,\$conn);
	&validateExcel($InputFile,$OutputFile,$ErrorFile);
}

#$conn->disconnect(); # Closing DB Connectivity #

exit;

sub validateExcel
{
	my $inputFile = shift;
	my $outputFile = shift;
	my $ErrFile = shift;
	#my $Refconn = shift;
	my $colStart = 0;
	my $colEnd =0 ;
	
	# Open an existing file with SaveParser
	my $parser   = Spreadsheet::ParseExcel::SaveParser->new();
	my $template = $parser->Parse($inputFile);

	open ERR,">>$ErrFile" or die "Can't open Error Log File : $ErrFile for writing\n";
	print ERR "\nERROR FOUND IN FILTER PROGRAM\n----------------------------------------------\n";
	
	# Get the worksheet
	foreach my $worksheet( $template->worksheets())
	{
		my $i = 0;
		my $Query = '';		
		my $name = $worksheet->get_name();
		if($name eq 'species')
		{
			$colStart = 0;
			$colEnd = 0 ;
			# Variable Declaration and insertion #
			my $id = '';
			my $name = '';			
			while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
			{
				my $spec_id = $worksheet->get_cell($i,0)->{Val};
				$Query = "select species_strain_taxa_id,species_strain_name from $Table1 where species_strain_taxa_id=\"$spec_id\")";
				#print "$spec_id\n";
				
				$i++;
			}
		}
	}
	
	### Writing to a new excel file
	### ----------------------------
	# The SaveParser SaveAs() method returns a reference to a
	# Spreadsheet::WriteExcel object. If you wish you can then
	# use this to access any of the methods that aren't
	# available from the SaveParser object. If you don't need
	# to do this just use SaveAs().
	#
	my $workbook;
	{
		# SaveAs generates a lot of harmless warnings about unset
		# Worksheet properties. You can ignore them if you wish.
		local $^W = 0;
		
		# Saving the filtered rows in to O/P Excel file #
		$workbook = $template->SaveAs($outputFile);		
	}

	
}

=comm
				if($Query ne '')
				{
					my $sth = $$Refconn->prepare($Query);
					$sth->execute();
					if($sth->rows>0)
					{
						# Binding and fetching values from DB #
						$sth->bind_columns(undef,\$id,\$name);
						$sth->fetch();
						$worksheet->AddCell( $i,0,$id);
						$worksheet->AddCell( $i,1,$name);
					}
					else
					{
						$ErrorFlag = 1;
						print ERR "Species id ($spec_id) missing in database : Row :$i\n";
					}
				}

=cut