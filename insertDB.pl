
#!usr/bin/perl
use strict;
use Spreadsheet::ParseExcel::SaveParser;
use DBI;

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
	my $name = $worksheet->get_name();
	if($name eq 'users')
	{
		$colEnd = 3;
		$query = "insert into users (user_id,user_name,password,role) values (?,?,?,?)";
		&insertdb($worksheet,$query,$colEnd);
	}
}


sub insertdb
{
	my $Refworksheet = shift;
	my $Refquery = shift;
	my $Refcolend = shift;
	my $i = 1;

	# DB Connectivity #
	my $dbuser = 'root';
	my $dbpwd = '';
	my $db = 'organism_database';

	# Establishing DB Connectivity #
	my $conn = DBI->connect("dbi:mysql:$db",$dbuser,$dbpwd) or die "Can't establish DB connectivity\n";

	my $sth = '';
	$sth = $conn->prepare($Refquery);

	# Variable Declaration and insertion #
	while(defined($Refworksheet->get_cell($i,0)) && (!$Refworksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
	{
		my @temp = ();
		for(my $k=0;$k<=$Refcolend;$k++)
		{
			my $temp = $Refworksheet->get_cell($i,$k)->{Val};
			push(@temp,$temp);
		}
		my $rec = join(",",@temp);
		$sth->execute($temp[0],$temp[0],$temp[0],$temp[0]);
		$i++;
	}
	$sth->finish();

	$conn->disconnect();
}