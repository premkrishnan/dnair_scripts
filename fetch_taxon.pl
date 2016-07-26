#!usr/bin/perl -w
use strict;
use warnings;
use LWP;
use XML::LibXML::Reader;
use DBI;

/*Grabs all existing species_strain taxa id from dnair and goes to ebi and grabs the taxonomic lineage. 
Then it finds if the organism is bacteria, eukaryota, or archea and updates the species_straint table.
Output an error file if bacteria,eukaryota, or archea were not found as a super kingdom -cassie
*/ 

open(ERR, ">taxon_fetch_error.txt") or die ("Cannot open error file for writing");

# DB Connectivity #
my $dbuser = 'dnair_user';
my $dbpwd = 'ffaq9hhvPFAC8XsM';
my $db = 'organism_database';

### The database handle
my %attr = (RaiseError=> 1,  # error handling enabled 
	AutoCommit=>0); # transaction enabled for changes to db
my $dbh = DBI->connect("dbi:mysql:$db",$dbuser,$dbpwd, \%attr) or die ("Can't establish DB connectivity\n");


my $sql_stmnt = "SELECT species_strain_taxa_id FROM species_strain";                
my $species_taxa_list = $dbh->selectall_hashref($sql_stmnt, 'species_strain_taxa_id');

my $query = "UPDATE species_strain SET super_kingdom= ? WHERE  species_strain_taxa_id = ?";
my $sth = $dbh->prepare($query);

my $counter = 0;
my $counter2 = 0;
foreach my $e (keys %$species_taxa_list) {
	$counter2++;
	print "$e\n";
	#my $taxa_id = '553';
	my $taxa_id = $e;
	my $url = "http://www.ebi.ac.uk/ena/data/view/Taxon:".$taxa_id."&display=xml";

	
	# Issue request, with an HTTP header
	my $browser = LWP::UserAgent->new;
	my $response = $browser->get($url,
	  'User-Agent' => 'Mozilla/4.0 (compatible; MSIE 7.0)',
	);
	die 'Error getting $url' unless $response->is_success;
	#print 'Content type is ', $response->content_type;
	#print 'Content is:';
	#print $response->content;
	my $xml_string = $response->content;

	my $reader = XML::LibXML::Reader->new( string => $xml_string);


	while ( $reader->nextElement('taxon' )){
		 my $rank = $reader->getAttribute('rank');
		 if($rank){
			 if($rank eq 'superkingdom'){
				my $taxon = $reader->getAttribute('scientificName');
				print "$e\t$taxon\n";
				
				my $taxon_id; 
				if($taxon eq 'Bacteria'){
					$taxon_id = 2;
				}elsif($taxon eq 'Eukaryota'){
					$taxon_id = 3;
				}elsif($taxon eq 'Archaea'){
					$taxon_id = 4;
				}else{
					$taxon_id = 1;
					print ERR "$e\t$taxon\t$taxon_id\n";
				}
				
				
				eval{
						$sth->execute($taxon_id,$e) or die $DBI::errstr;
				};
								
				if( $@ ) {
					warn "Database error: $DBI::errstr\n";
					$dbh->rollback(); 
					die;
				}	
				
				$sth->finish();
				
				$counter++;
			 }
		 }
	}
}
print "$counter out of $counter2";
$dbh->commit();
$dbh->disconnect();
close ERR;
