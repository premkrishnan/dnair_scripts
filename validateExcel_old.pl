#===========================================================================================
# Description
#-------------------------------------------------------------------------------------------
# Filter Program to validate excel file at the end of Format 1 phase
# Note: Please make sure that the input excel file is in '.xls' format
# Authors: Bipin & Premkrishnan B. V.
# Date: August 5th 2011
# Version: 1.0
#===========================================================================================
# Modification block
#-------------------------------------------------------------------------------------------
# 29-05-2012 -> Added new sheet for Functional Information (Functional_info)
# 
#===========================================================================================

#!usr/bin/perl
use strict;
use Spreadsheet::ParseExcel;
use Spreadsheet::ParseExcel::SaveParser;
use DBI;
use File::Copy;
=comm
# DB Connectivity #
my $dbuser = 'root';
my $dbpwd = '';
my $db = 'GeneLibrary';
my $Table1 = 'Gene';
my $Table2 = 'geneTranscript';

# Establishing DB Connectivity #
my $conn = DBI->connect("dbi:mysql:$db",$dbuser,$dbpwd) or die "Can't establish DB connectivity\n";

# Input & O/P Files #
#my $InputFolder = '88888_SGMF_1';
my $InputFolder = '15737014_SGMF_1';
my $PubMedID = $1 if($InputFolder=~/^\s*(\d+)\_+.*/);
my $OutputFolder = "$InputFolder\/AfterFiltering";

# Variable Declaration and initialization #
my $CommentFile = '';
my $ErrorFile = '';
my %Error = ();
my %Stat = ();

if(-d $OutputFolder) # If O/P Folder alreday present, emptying the folder #
{
	opendir(DIRDATA,$OutputFolder) or die "can't open Input Folder : $OutputFolder for reading\n";
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
opendir(DIR,$InputFolder) or die "can't open Input Folder : $InputFolder for reading\n";
while(my $files = readdir(DIR))
{
	next if($files=~/^\s*\.+\s*$/);
	my $InputFile = "$InputFolder\/$files";
	my $OutputFile = "$OutputFolder\/$files";
	if($files=~/\.+xls/)
	{
		&MutationFormat1Filter($InputFile,$OutputFile,$files,\%Error,\%Stat,\$conn);
	}
	elsif($files=~/\.+txt/)
	{
		if($files=~/Error/i)
		{
			#system("cp $InputFile $OutputFolder"); # for LINUX
			copy($InputFile,$OutputFolder);		# for Windows
			$ErrorFile = $OutputFile;
		}
		elsif($files=~/Comment/i)
		{
			#system("cp $InputFile $OutputFolder");	# for LINUX
			copy($InputFile,$OutputFolder);		# for Windows
			$CommentFile = $OutputFile;
		}
	}
}
closedir DIR; # Closing Directory handler #
$conn->disconnect(); # Closing DB Connectivity #

if($ErrorFile eq '')
{
	$ErrorFile = "$OutputFolder\/$InputFolder".'_error_log.txt';
}
if($CommentFile eq '')
{
	$CommentFile = "$OutputFolder\/$InputFolder".'_comments.txt';
}

# Writing/Appending to the Error Log File #
if(scalar(keys %Error) >0)
{
	open ERROR,">>$ErrorFile" or die "Can't open Error Log File : $ErrorFile for writing\n";
	print ERROR "\n\nERROR FOUND IN FILTER PROGRAM\n----------------------------------------------\n";
	foreach my $EachFiles(keys %Error)
	{
		print ERROR "File Name : $EachFiles\n--------------\n";
		foreach my $Errors(keys %{$Error{$EachFiles}})
		{
			print ERROR $Error{$EachFiles}{$Errors}."\n";
		}
	}
	close ERROR;
}

# Writing/Appending to the Comments File #
open COMMENTS,">>$CommentFile" or die "Can't open Comment File : $CommentFile for writing\n";
print COMMENTS "\n\nFILTER PROGRAM STATISTICS\n----------------------------------------------\n";
foreach my $EachFiles(keys %Stat)
{
	print COMMENTS "File Name : $EachFiles\n--------------\n";
	my($totalRec,$totalValidRec,$totalInvalidRec,$Cnt_mRNAIdentifiers,$Cnt_GeneID_GeneSymbol,$Cnt_Tumor_Base,$Cnt_NonCodingIdentifiers,$Cnt_Mandatory_Fields,$Cnt_mRNA_CDS_Cord,$Cnt_Intergenic) = split"\t",$Stat{$EachFiles};
	print COMMENTS "Total Number of Records : $totalRec\n";
	print COMMENTS "Total Number of Valid Records : $totalValidRec\n";
	print COMMENTS "Total Number of Invalid Records : $totalInvalidRec\n\n";
	print COMMENTS "Total Number of Records which contain any Intergenic/Promoter mutation : $Cnt_Intergenic\n\n" if($Cnt_Intergenic>0);
	
	print COMMENTS "Total Number of Records which doesn't contain any mRNA Identifiers (IN ERROR LOG): $Cnt_mRNAIdentifiers\n" if($Cnt_mRNAIdentifiers>0);
	print COMMENTS "Total Number of Records which doesn't contain GeneID/GeneSymbol (IN ERROR LOG): $Cnt_GeneID_GeneSymbol\n" if($Cnt_GeneID_GeneSymbol>0);
	print COMMENTS "Total Number of Records which doesn't contain any mRNA/CDS tumor bases and no AA change (IN ERROR LOG): $Cnt_Tumor_Base\n" if($Cnt_Tumor_Base>0);
	print COMMENTS "Total Number of Records which contain any other IDs (IN ERROR LOG): $Cnt_NonCodingIdentifiers\n" if($Cnt_NonCodingIdentifiers>0);
	print COMMENTS "Total Number of Records having empty fields(mandatory) (IN ERROR LOG): $Cnt_Mandatory_Fields\n" if($Cnt_Mandatory_Fields>0);
	print COMMENTS "Total Number of Records which doesn't contain any mRNA/CDS Start&End Position (IN ERROR LOG): $Cnt_mRNA_CDS_Cord\n" if($Cnt_mRNA_CDS_Cord>0);
}
close COMMENTS;

exit;


sub MutationFormat1Filter
{
	my $inputFile = shift;
	my $outputFile = shift;
	my $inFile = shift;
	my $RefError = shift;
	my $RefStat = shift;
	my $Refconn = shift;

	# Open an existing file with SaveParser
	my $parser   = Spreadsheet::ParseExcel::SaveParser->new();
	my $template = $parser->Parse($inputFile);
	
	# Get the worksheet.
	my $worksheet = $template->worksheet(3);
	my ($rowStart, $rowEnd) = $worksheet->row_range();
	
	my $colStart = 0;
	my $colEnd = 36;
	my @StudyInfoHeader    = ('PMID','Article','Authors','Journal','Year','Page Number','DOI','Study Type','Study Category','Data Source');
	my @GeneInfoHeader     = ('Gene ID','Gene Symbol');
	my @SampleInfoHeader   = ('SGM_Sample ID','Study_Sample ID','Study_Sample Name','SG_Tissue Type','Cancer Type','Cancer Subtype','Sample Type','Sample Subtype','Age ','Gender','Sample_Tissue','Sample_SubTissue','Histology_1','Histology_2','Histology_3','Metastasis','Tumor Karyotype','Sample_Source','Percentage Tumor nuclei','Race/Ethnicity','Patient Survival after initial diagnosis','Secondary cancer','Recurrent');
	my @MutationInfoHeader = ('SGM_Sample ID','Study_Sample Name','Refseq_Transcript ID','Ensembl_Transcript ID','CCDS_ID','Transcript ref base','Tumor Transcript base','Transcript position Start','Transcript position End','CDS ref base','Tumor CDS base','CDS position Start','CDS position End','Chromosome','Genomic Build','Chromosome_Start','Chromosome _ End','Strand','Genomic Reference base','Genomic Tumor base','Amino acid Change','Calculated Amino acid Change','Amino acid Change Validation','Mutation Type','Mutation Subtype','Mutation zygosity','Mutation in the normal control','Somatic Validation','Discovery Technology','Functional Validation','Gene ID','Gene Symbol','Mutation Class','Other IDs','Chromosome_Start(hg19)','Chromosome_End(hg19)','Associated gene ID');
	my @FunctionalInfoHeader = ('Gene ID','Gene Symbol','Mutation','Functional Effect','Description','Mechanism of Action','MoA Validation','Comments');
	
	# Declaration and Initialization of variables #
#	my %ValidAAChange = map{uc($_)} ('Unknown','a','sp','b','Splice','c','utr','d','fs','e','indel','f','IVS','g','NR','h','NA','i');
	my $ValidAAChange = 'Unknown|sp|Splice|utr|fs|indel|IVS|NR|NA|intronic|flanking_region';
	my $i = 1;
	my $j = 1;
	my $ErrorFlag = 0;
	my $TotalRec = 0;
	my $NO_mRNAIdentifiers = 0;
	my $NO_GeneID_GeneSymbol = 0;
	my $NO_Tumor_Base = 0;
	my $NonCodingIdentifiers = 0;
	my $NO_Mandatory_Fields = 0;
	my $NO_mRNA_CDS_Cord = 0;
	my $TotalValidRec = 0;
	my $TotalInValidRec = 0;
	my $TotalIntergenicCnt = 0;

	my @BaseColumnPos = (5,6,9,10,18,19,20);
	my @MandatoryColumns = (0,25,26,27,28,29);
	my @PositionColumns = (7,8,11,12);

	while(defined($worksheet->get_cell($i,0)) && (!$worksheet->get_cell($i,0)->{Val}=~/^\s*$/) )
	{
		$TotalRec++;

		my $IntergenicFlag = 0;
		my $ErrorFlag = 0;
		my $NRFlag = 0;

		# If any data present in Other IDs column ( Example : miRNA iD), the record should be moved to the Error Log.
		if(defined($worksheet->get_cell($i,33)) && (!$worksheet->get_cell($i,33)->{Val}=~/^\s*$/))
		{
			$ErrorFlag = 1;
			$NonCodingIdentifiers++;
			foreach my $indx(2..4)
			{
				if( (defined($worksheet->get_cell($i,$indx))) && ((($worksheet->get_cell($i,$indx)->{Val}=~/\S+/g))))
				{
					$ErrorFlag = 0;
					$NonCodingIdentifiers--;
					last;
				}
			}
		}
		elsif( (defined($worksheet->get_cell($i,2))) && ((($worksheet->get_cell($i,2)->{Val}=~/^\s*NR+\_+.*/))))
		{
			if( (defined($worksheet->get_cell($i,24))) && ((($worksheet->get_cell($i,24)->{Val} eq 'Promoter')))) # IF Promoter
			{
				$NRFlag = 1;
			}
			else
			{
				$ErrorFlag = 1;
			}
			
		}
		
		if($ErrorFlag == 0)
		{
			# Variable Declaration and insertion #
			my $Query = '';
			my $GeneID = '';
			my $GeneSymbol = '';

			if( (defined($worksheet->get_cell($i,2))) && (!(($worksheet->get_cell($i,2)->{Val}=~/^\s*$/)))) # IF NCBI Transcript ID is present
			{
				my ($TrID,$ver) = split'\.',$worksheet->get_cell($i,2)->{Val};
				$Query = "select geneID,geneSymbol from $Table1 where geneID=(select distinct(geneID) from $Table2 where NMID =\"$TrID\")";
				
				# For NR_ IDS ( Non-Coding RNA) # 
				$NRFlag = 1 if($TrID=~/^\s*NR+\_+.*/);
				#print "Hai - $TrID - $NRFlag\n$Query\n";
			}
			elsif( (defined($worksheet->get_cell($i,3))) && (!(($worksheet->get_cell($i,3)->{Val}=~/^\s*$/)))) # IF Ensembl Transcript ID is present
			{
				my $EnsemblID = $worksheet->get_cell($i,3)->{Val};
				$Query = "select geneID,geneSymbol from $Table1 where geneID=(select distinct(geneID) from $Table2 where ensemblTranscriptID =\"$EnsemblID\")";
			}
			elsif( (defined($worksheet->get_cell($i,4))) && (!(($worksheet->get_cell($i,4)->{Val}=~/^\s*$/)))) # IF CCDS ID is present
			{
				my ($ccdsid,$ver) = split'\.',$worksheet->get_cell($i,4)->{Val};
				$Query = "select geneID,geneSymbol from $Table1 where geneID=(select distinct(geneID) from $Table2 where ccdsID like \"$ccdsid\.%\")";
			}
			else
			{
				# Handling Intergenic and Promoter #
				if( (defined($worksheet->get_cell($i,24))) && ((($worksheet->get_cell($i,24)->{Val} eq 'Promoter')||($worksheet->get_cell($i,24)->{Val} eq 'Intergenic')))) # IF Intergenic
				{
					$IntergenicFlag = 1;
					$TotalIntergenicCnt++;
				}
				else
				{
					$ErrorFlag = 1;
					$NO_mRNAIdentifiers++;
				}
			}

			if($Query ne '')
			{
				my $sth = $$Refconn->prepare($Query);
				$sth->execute();
				if($sth->rows>0)
				{
					# Binding and fetching values from DB #
					$sth->bind_columns(undef,\$GeneID,\$GeneSymbol);
					$sth->fetch();
					$worksheet->AddCell( $i,30,$GeneID);
					$worksheet->AddCell( $i,31,$GeneSymbol);
				}
				else
				{
					$ErrorFlag = 1;
					#print "Row :$i\n";
					$NO_GeneID_GeneSymbol++;
				}
			}

			if($ErrorFlag == 0)
			{
				my $TumorBase = '';
				foreach my $ColumnPos(sort{$a<=>$b;} @BaseColumnPos)
				{
					my $CheckFlag = 0;

					# If the Column is defined and contain space #
					if( (defined($worksheet->get_cell($i,$ColumnPos))) && ($worksheet->get_cell($i,$ColumnPos)->{Val}=~/^\s*$/) )
					{
						$CheckFlag = 1;
					}
					elsif(! defined($worksheet->get_cell($i,$ColumnPos))) # If the Column is not defined # 
					{
						$CheckFlag = 1;
					}
					elsif(grep /^$ColumnPos$/,(5,6,9,10))
					{
						if($worksheet->get_cell($i,$ColumnPos)->{Val} eq 'ND')
						{
							$worksheet->AddCell($i,$ColumnPos,'NR');
						}
					}

					if($CheckFlag == 1)
					{
						if($IntergenicFlag==1) # IF intergenic #
						{
							if(grep /^$ColumnPos$/,(18,19)) # In the Chr Reference, Tumor base & AA Change columns #
							{
								$worksheet->AddCell($i,$ColumnPos,'NR');
							}
							else
							{
								$worksheet->AddCell($i,$ColumnPos,'NA');
							}
						}
						else # For other records #
						{
							$worksheet->AddCell($i,$ColumnPos,'NR');
						}
					}

					# Fetching Tumor Base #
					if(grep /^$ColumnPos$/,(6,10,19))
					{
						$TumorBase = $worksheet->get_cell($i,$ColumnPos)->{Val};
					}
				}

				my $mRNAPosCheck = 0;
				my $CDSPosCheck = 0;
				foreach my $PosCord(@PositionColumns)
				{
					if( (defined($worksheet->get_cell($i,$PosCord))) && ($worksheet->get_cell($i,$PosCord)->{Val}!~/^\s*$/) )
					{
						if( ($worksheet->get_cell($i,$PosCord)->{Val} ne 'NR') || ($worksheet->get_cell($i,$PosCord)->{Val} ne 'NA') || ($worksheet->get_cell($i,$PosCord)->{Val}!~/^\s*$/))
						{
							if(grep /^$PosCord$/,(7,8))
							{
								$mRNAPosCheck++;
							}
							else
							{
								$CDSPosCheck++;
							}
						}
						if($worksheet->get_cell($i,$PosCord)->{Val} eq 'ND')
						{
							$worksheet->AddCell($i,$PosCord,'NR');
						}
					}
				}

				if($mRNAPosCheck==2)
				{
					foreach my $pos(9..12)
					{
						if($NRFlag = 1)
						{
							$worksheet->AddCell($i,$pos,'NA');
						}
						else
						{
							$worksheet->AddCell($i,$pos,'');
						}
					}
				}
				elsif($CDSPosCheck==2)
				{
					foreach my $pos(5..8)
					{
						$worksheet->AddCell($i,$pos,'');
					}
				}
				elsif($IntergenicFlag==1)
				{
					foreach my $pos(5..12)
					{
						$worksheet->AddCell($i,$pos,'NA');
					}
				}
				else
				{

					$ErrorFlag = 1;
					$NO_mRNA_CDS_Cord++;
				}

				# If the Tumor Base is NR and the Protein change is NR/NA, the record should go to Error Log #
				if( ($TumorBase eq 'NR') && ( ($worksheet->get_cell($i,20)->{Val} eq 'NA') || ($worksheet->get_cell($i,20)->{Val} eq 'NR') ) )
				{
					$ErrorFlag = 1;
					$NO_Tumor_Base++;
				}
				elsif( ($worksheet->get_cell($i,20)->{Val}=~/^\s*[^p\.]+/) && ($worksheet->get_cell($i,20)->{Val}!~/$ValidAAChange/i))
				{
					$worksheet->AddCell($i,20,'p.'.$worksheet->get_cell($i,20)->{Val});
				}
			}

			if($ErrorFlag == 0 )
			{
				# Checking whether the mandatory columns are filled #
				foreach my $MandatoryCols(sort{$a<=>$b;} @MandatoryColumns)
				{
					if( (defined($worksheet->get_cell($i,$MandatoryCols))) && ($worksheet->get_cell($i,$MandatoryCols)->{Val}=~/^\s*$/) )
					{
						$ErrorFlag = 1;
						$NO_Mandatory_Fields++;
					}
					elsif(! defined($worksheet->get_cell($i,$MandatoryCols))) # If the Column is not defined # 
					{
						$ErrorFlag = 1;
						$NO_Mandatory_Fields++;
					}
				}
			}
		}

		for(my $k=$colStart;$k<=$colEnd;$k++)
		{
			my $val = "";
			if(defined($worksheet->get_cell($i,$k)))
			{
				$val = $worksheet->get_cell($i,$k)->{Val};
			}
			# Putting Error Row in to the Error Hash #
			if($ErrorFlag == 1)
			{
				if(defined($$RefError{$inFile}{$i}))
				{
					$$RefError{$inFile}{$i} .= "\t".$val;
				}
				else
				{
					my $rwNo = $i+1;
					$$RefError{$inFile}{$i} = $rwNo."\t".$val;
				}
			}
			else # Writing Validated Rows in to the Excel Sheet #
			{
				$worksheet->AddCell($j,$k,$val);
			}
		}

		if($ErrorFlag==0)
		{
			$TotalValidRec++;		
			$j++;
		}
		else
		{
			$TotalInValidRec++;
		}
		$i++;
	}
	
	# Storing Statistics in to the Stat Hash #
	$$RefStat{$inFile} = "$TotalRec\t$TotalValidRec\t$TotalInValidRec\t$NO_mRNAIdentifiers\t$NO_GeneID_GeneSymbol\t$NO_Tumor_Base\t$NonCodingIdentifiers\t$NO_Mandatory_Fields\t$NO_mRNA_CDS_Cord\t$TotalIntergenicCnt";

	if($i!=$j)
	{
		foreach my $EachRows($j..($i-1))
		{
			for(my $k=$colStart;$k<=$colEnd;$k++)
			{
				$worksheet->AddCell($EachRows,$k,'');
			}
		}
	}
	
	# Changing Column headers #
	
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

	my $StudyColEnd = 9;
	my $GeneColEnd = 1;
	my $SampleColEnd = 22;
	my $MutationColEnd = 36;
	my $FunctionalColEnd = 7;
	
	for(my $i=0;$i<=4;$i++)
	{
		# Use Spreadsheet::WriteExcel methods
		my $worksheet = $workbook->sheets($i);
		my $SheetName = $worksheet->get_name();
	
		#  Add and define a format
		my $StudyInfoHeaderStyle = $workbook->add_format(color=>0, bg_color=>31, align=>'center', bold=>1, text_wrap=> 1, border=>3);
		$StudyInfoHeaderStyle->set_align('vcenter');
		
		my $GeneInfoHeaderStyle = $workbook->add_format(color=>0, bg_color=>44, align=>'center', bold=>1, text_wrap=> 1, border=>3);
		$GeneInfoHeaderStyle->set_align('vcenter');
		
		my $SampleInfoHeaderStyle = $workbook->add_format(color=>0, bg_color=>45, align=>'center', bold=>1, text_wrap=> 1, border=>3);
		$SampleInfoHeaderStyle->set_align('vcenter');
		
		my $MutationInfoHeaderStyle = $workbook->add_format(color=>0, bg_color=>47, align=>'center', bold=>1, text_wrap=> 1, border=>3);
		$MutationInfoHeaderStyle->set_align('vcenter');
		
		my $FunctionalInfoHeaderStyle = $workbook->add_format(color=>0, bg_color=>50, align=>'center', bold=>1, text_wrap=> 1, border=>3);
		$FunctionalInfoHeaderStyle->set_align('vcenter');
		
		if($SheetName eq 'Study_info')
		{
			$worksheet->set_tab_color(31);
			for(my $k=0;$k<=$StudyColEnd;$k++)
			{
				$worksheet->write(0, $k, $StudyInfoHeader[$k], $StudyInfoHeaderStyle);
			}
		}
		elsif($SheetName eq 'Gene_info')
		{
			$worksheet->set_tab_color(44);
			for(my $k=0;$k<=$GeneColEnd;$k++)
			{
				$worksheet->write(0, $k, $GeneInfoHeader[$k], $GeneInfoHeaderStyle);
			}		
		}
		elsif($SheetName eq 'Sample_info')
		{
			$worksheet->set_tab_color(45);
			for(my $k=0;$k<=$SampleColEnd;$k++)
			{
				$worksheet->write(0, $k, $SampleInfoHeader[$k], $SampleInfoHeaderStyle);
			}		
		}
		elsif($SheetName eq 'Mutation_info')
		{
			$worksheet->set_tab_color(47);
			for(my $k=0;$k<=$MutationColEnd;$k++)
			{
				$worksheet->write(0, $k, $MutationInfoHeader[$k], $MutationInfoHeaderStyle);
			}		
		}
		elsif($SheetName eq 'Functional_info')
		{
			$worksheet->set_tab_color(50);
			for(my $k=0;$k<=$FunctionalColEnd;$k++)
			{
				$worksheet->write(0, $k, $FunctionalInfoHeader[$k], $FunctionalInfoHeaderStyle);
			}		
		}		
	}	
	$workbook->close();
}
=cut