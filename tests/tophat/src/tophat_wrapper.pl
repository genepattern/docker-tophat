#!/usr/bin/perl 

use Config;
use File::Basename;
use File::Copy;
use File::Path;
use IPC::Open3;
use IO::Select;
use IO::Handle;
use Getopt::Long;

GetOptions (\%options,  "tophatDir=s",
                        "samtoolsDir=s",
                        "bowtieDir=s",
                        "libdir=s",
                        "pair1:s",      #A set of unpaired or first pair of paired-end reads
                        "pair2:s",      #A set of the second pair of paired-end reads
                        "index:s",   #the prebuilt bowtie index name
                        "gtf:s",        #A set of gene model annotations and/or known transcripts
                        "mateDist:s",   #the mate innner distance
                        "mateStd:s",    #the mate standard deviation
                        "readEditDist:s",   #the read edit distance
                        "readGapLength:s",   #the read gap length
					    "juncs:s",      #the name of the transcriptome index to create
					    "transcriptomeOnly:s", #Only align the reads to the transcriptome and report only those mappings as
					                           #genomic mappings requires GTF file or tname option be set
					    "transcriptomeIndex:s", #a directory containing an existing transcriptome index
					    "minALen:s",    #the minimum anchor length
					    "maxSpliceM:s", #the maximum number of mismatches that may appear in the "anchor" region of a spliced alignment
					    "minILen:s",    #the minimum intron length
					    "maxILen:s",    #the maximum intron length
					    "maxInsLen:s",  #the maximum insertion length
					    "maxDelLen:s",  #the maximum deletion length
		                "maxMHit:s",    #the maximum number of multihits
					    "readMis:s",    #the maximum number of read mismatches allowed
					    "maxTHit:s",    #the maximum number of mappings allowed for a read, when aligned to the transcriptome
					    "fusion:s",  # A "supporting" read must map to both sides of a fusion by at least these many bases
					    "fAnchorLen:s",  # A "supporting" read must map to both sides of a fusion by at least these many bases
					    "fReadMis:s",   # Reads support fusions if they map across fusion with at most these many mismatches
					    "oprefix:s",    #the prefix for the output files
					  );

require $options{libdir}."common.pl";

$tmpDir = "tempDir";
$default_input_dir1 = $tmpDir."/input1";
$default_input_dir2 = $tmpDir."/input2";

$transcriptome_index_dir = "transcriptome_index";

#Add SAMTools and Bowtie to the path
$ENV{"PATH"} = $options{samtoolsDir}.":".$options{bowtieDir}.":".$ENV{"PATH"};

@cmdline = ();

#add Bowtie command
push(@cmd, catfile($options{tophatDir},"tophat2"));


if(isNonEmptyString($options{gtf}) && isNonEmptyString($options{transcriptomeIndex}))
{
    wr_die("Either a GTF file or transcriptome index should be provided but not both.")
}

if(isNonEmptyString($options{transcriptomeIndex}))
{
    #auto detect the name prefix for the transcriptome index
    opendir(DIR, $options{transcriptomeIndex});
    @files = readdir(DIR);

    #Figure out the name of the index by looking at one of the transcriptome Bowtie2 index files
    $size = @files;
    $index = 0;
    print("T index is $options{transcriptomeIndex}");

    while(!defined($transcriptome_index_name) && $index < $size)
    {
        print("$files[$index]");

        if($files[$index] !~ m/^\./ && $files[$index] =~ m/\.bt2$/)
        {
            $transcriptome_index_name = $files[$index];
            $transcriptome_index_name =~ s/\.rev\.[\d]\.bt2$//g;
            $transcriptome_index_name =~ s/\.[\d]\.bt2$//g;
        }

        $index = $index +1;
    }

    closedir(DIR);
    #check if index name was found
    if(!defined($transcriptome_index_name))
    {
        die "Unable to detect the name of the transcriptome index.";
    }


    push(@cmd, "--transcriptome-index $options{transcriptomeIndex}/$transcriptome_index_name");
}

if(isNonEmptyString($options{gtf}))
{
    #provide directory to output the transcriptome
    #right now this will be always be the current directory

    mkdir $transcriptome_index_dir;
    push(@cmd, "--transcriptome-index $transcriptome_index_dir");

    push(@cmd, "--GTF", "\"".$options{gtf}."\"");
}

if(isNonEmptyString($options{pair1}))
{
    if($options{transcriptomeOnly} eq "yes")
    {
        if(!isNonEmptyString($options{gtf}) && !isNonEmptyString($options{transcriptomeIndex}))
        {
            wr_die("\nA GTF file or transcriptome index must be specified");
        }
        else
        {
            push(@cmd, "--transcriptome-only");
        }
    }

    if(isNonEmptyString($options{juncs}))
    {
        push(@cmd, "--raw-juncs", "\"".$options{juncs}."\"");
    }

    if(isNonEmptyString($options{minALen}))
    {
        isInteger($options{minALen}) ? push(@cmd, "-a", $options{minALen}) : wr_die("\nMinimum anchor length must be an integer");
    }

    if(isNonEmptyString($options{maxSpliceM}))
    {
        isInteger($options{maxSpliceM}) ? push(@cmd, "-m", $options{maxSpliceM}) : wr_die("\nMaximum splice mismatches must be an integer");
    }

    if(isNonEmptyString($options{minILen}))
    {
        isInteger($options{minILen}) ? push(@cmd, "-i", $options{minILen}) : wr_die("\nMinimum intron length must be an integer");
    }

    if(isNonEmptyString($options{maxILen}))
    {
        isInteger($options{maxILen}) ? push(@cmd, "-I", $options{maxILen}) : wr_die("\nMaximum intron length must be an integer");
    }

    if(isNonEmptyString($options{maxInsLen}))
    {
        isInteger($options{maxInsLen}) ? push(@cmd, "--max-insertion-length", $options{maxInsLen}) : wr_die("\nMaximum insert length must be an integer");
    }

    if(isNonEmptyString($options{maxDelLen}))
    {
        isInteger($options{maxDelLen}) ? push(@cmd, "--max-deletion-length", $options{maxDelLen}) : wr_die("\nMaximum insert length must be an integer");
    }

    if(isNonEmptyString($options{maxMHit}))
    {
        isInteger($options{maxMHit}) ? push(@cmd, "--max-multihits", $options{maxMHit}) : wr_die("\nMaximum multihits must be an integer");
    }

    if(isNonEmptyString($options{readMis}))
    {
        isInteger($options{readMis}) ? push(@cmd, "--read-mismatches", $options{readMis}) : wr_die("\nMaximum read mismatches must be an integer");
    }

    if(isNonEmptyString($options{mateDist}))
    {
        isInteger($options{mateDist}) ? push(@cmd, "--mate-inner-dist", $options{mateDist}) : wr_die("\Mate inner distance must be an integer");
    }
    
    if(isNonEmptyString($options{mateStd}))
    {
        isInteger($options{mateStd}) ? push(@cmd, "--mate-std-dev", $options{mateStd}) : wr_die("\Mate standard deviation must be an integer");
    }

    if(isNonEmptyString($options{readEditDist}))
    {
        isInteger($options{readEditDist}) ? push(@cmd, "--read-edit-dist", $options{readEditDist}) : wr_die("\Read edit distance must be an integer");
    }

    if(isNonEmptyString($options{readGapLength}))
    {
        isInteger($options{readGapLength}) ? push(@cmd, "--read-gap-length", $options{readGapLength}) : wr_die("\Read gap length must be an integer");
    }

    if(isNonEmptyString($options{maxTHits}))
    {
        isInteger($options{tMaxHits}) ? push(@cmd, "--transcriptome-max-hits", $options{tMaxHits}) : wr_die("\nMaximum transcriptome hits must be an integer");
    }

    if(isNonEmptyString($options{fusion}))
    {
        push(@cmd, "--fusion-search");
        if(isNonEmptyString($options{fAnchorLen}))
        {
            isInteger($options{fAnchorLen}) ? push(@cmd, "--fusion-anchor-length", $options{fAnchorLen}) : wr_die("\nMinimum fusion anchor length must be an integer");
        }

        if(isNonEmptyString($options{fReadMis}))
        {
            isInteger($options{fReadMis}) ? push(@cmd, "--fusion-read-mismatches", $options{fReadMis}) : wr_die("\nMaximum fusion read mismatches must be an integer");
        }
    }

    if (@ARGV) {
        # Tokenize the ARGV strings and add these items to @cmd.  This must be split because otherwise the
        # arguments are clumped together with the switches in a single string (e.g. '--foobar 12'
        # instead of '--foobar' '12') and are thus unrecognized.
        foreach my $arg (@ARGV)
        {
           my @opts = split ' ', $arg;
           push(@cmd, @opts);
        }
    }
}

print "\nSetting up Bowtie indexes\n";

if(isNonEmptyString($options{index}))
{
    #if the bowtie index is zipped then extract it to the current directory
    if (rindex($options{index}, '.zip') != -1)
    {
        $bowtie_index = $tmpDir."/bowtie_index/";
        unzip_func($options{index}, $bowtie_index);
    }
    else
    {
        #in the case a directory containing the index was specified
        $bowtie_index = $options{index}."/";
    }

    opendir(DIR, $bowtie_index);
    @files = readdir(DIR);

    #Figure out the name of the index by looking at one of the bowtie2 index files
    $size = @files;
    $index =0;
    while(!defined($index_name) && $index < $size)
    {
        if($files[$index] !~ m/^\./ && $files[$index] =~ m/\.bt2$/)
        {
            $index_name = $files[$index];
            $index_name =~ s/\.rev\.[\d]\.bt2$//g;
            $index_name =~ s/\.[\d]\.bt2$//g;
        }

        $index = $index +1;
    }

    closedir(DIR);
    #check if index name was found
    if(!defined($index_name))
    {
        die "Unable to detect the name of the bowtie index.";
    }
}
else
{
    #if we get here then a Bowtie2 index was specified
    wr_die("\nEither a Bowtie2 index must be specified");
}

push(@cmd, $bowtie_index.$index_name);

if(-e $options{pair1})
{
    open(READSFILE, "<", $options{pair1}) or die("Could not open file: $options{pair1}");

    foreach my $file (<READSFILE>)
    {
        chomp $file;
        if(-e $file)
        {
            push(@reads_setA, $file);
        }
        else
        {
            wr_die("File does not exist: $file");
        }
    }

    close(READSFILE) or warn "close failed $!";

    #add reads files if any were found
    my $reads_setA_Size = @reads_setA;

    if($reads_setA_Size != 0)
    {
        #add quotes around file names to handle spaces
        push(@cmd, "\"".join("\",\"", @reads_setA)."\"");
    }
    else
    {
        wr_die("An error occurred while parsing: $options{pair1}. No read files found.")
    }
}

#check if this is a set of paired-end reads
if(isNonEmptyString($options{pair2}))
{
    if(-e $options{pair2})
    {
        open(READSFILE2, "<", $options{pair2}) or die("Could not open file: $options{pair2}");

        foreach my $file (<READSFILE2>)
        {
            chomp $file;

            if(-e $file)
            {
                push(@reads_setB, $file);
            }
            else
            {
                wr_die("File does not exist: $file");
            }
        }

        close(READSFILE2) or warn "close failed $!";
    }
    else
    {
        wr_die("File does not exist: $options{pair2}");
    }

    #check that reads files were found
    my $reads_setB_Size = @reads_setB;

    if($reads_setB_Size == 0)
    {
        wr_die("An error occurred while parsing: $options{pair2}. No read files found.")
    }

    #this is a set of paired-end reads so do a check that the file name ends with _2
    #which is recommended but not required

    checkPairMatching(\@reads_setA, \@reads_setB);

    push(@cmd, "\"".join("\",\"", @reads_setB)."\"");
}

#output command line to a separate file
open (CMDLINEFILE, '> cmdline.log');
print CMDLINEFILE "Command: @cmd\n";

print "\nLaunching TopHat command\n";

runCmd(join(" ", @cmd));
renameOutputFiles();

sub renameOutputFiles
{
    print "\nRenaming output files...";

    #prepend the output prefix to the output file names
    opendir(DIR, "tophat_out");
    @files = readdir(DIR);
    closedir(DIR);

    foreach $file (@files)
    {
        #prepend the output prefix to the name of the bed file
        rename("tophat_out/".$file, $options{oprefix}.".".$file);
    }
}

sub runCmd
{
    $cmd = shift;
    $Pin  = new IO::Handle;       $Pin->fdopen(10, "w");
    $Pout = new IO::Handle;       $Pout->fdopen(11, "r");
    $Perr = new IO::Handle;       $Perr->fdopen(12, "r");
    $Proc = open3($Pin, $Pout, $Perr, $cmd);

    my $sel = IO::Select->new();
    $sel->add($Perr, $Pout);

    while (my @ready = $sel->can_read)
    {
        foreach my $handle (@ready)
        {
            if (fileno($handle) == fileno($Perr))
            {
                # process has printed something on standard error
                my ($count, $data);
                $count = sysread($handle, $data, 1024);
                if ($count == 0)
                {
                    $sel->remove($handle);
                    next;
                }
                if($data =~ m/Traceback/i)
                {
                    $traceback = "true";
                }

                if ($data =~ m/error/i || $data =~ m/not recognized/i || $traceback eq "true")  #if stderr output looks like an error message, write to stderr
                {
                    print STDERR $data;
                }
                else
                {
                    print STDOUT $data;
                }
            }
            else
            {
                # process has printed something on standard out
                my ($count, $data);
                $count = sysread($handle, $data, 1024);
                if ($count == 0)
                {
                    $sel->remove($handle);
                    next;
                }
                print STDOUT $data;
            }
        }
    }

    close($Perr);
    close($Pout);

    waitpid($pid, 0);
    cleanup();
}


END
{
    cleanup();
}

sub cleanup
{
    print "\nCleaning up files\n";
    #try to remove temp directories and ignore any failures

    if (-d $tmpDir)
    {
        {
            local $SIG{'__WARN__'} = sub {
                print "\n";
                print $_[0];
            };
            eval { rmtree($tmpDir) };
        }
    }

    if(-d "tophat_out")
    {
        #remove log files from tophat output
        rmtree("tophat_out/logs");

        #remove tophat_out if directory is empty
        opendir(my $t_out, "tophat_out") || die;
        $itemsFound = 0;
        while(readdir $t_out) {
            $itemsFound = 1;
        }

        if(!$itemsFound)
        {
            rmtree("tophat_out");
        }

        closedir $t_out;
    }
}
