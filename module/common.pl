#!/usr/bin/perl

use File::Basename;
use File::Path;
use File::Spec::Functions qw(catfile);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use IO::Compress::Zip qw(zip $ZipError) ;
use Archive::Extract;

sub unzip_func
{
    $file = shift;
    $dest = shift;

    # build an Archive::Extract object
    my $ae = Archive::Extract->new( archive => $file );

    # extract to destination directory
    my $ok = $ae->extract( to => $dest ) or die $ae->error;

    ### files from the archive ###
    #my $files   = $ae->files;
}

sub isZipFile
{
    my $file = shift;

    if ($file =~ /\.zip$/)
    {
        return 1;
    }

    return 0;
}

sub isGzipFile
{
    my $file = shift;

    if ($file =~ /\.gz$/)
    {
        return 1;
    }

    return 0;
}

sub gunzip
{
    my $file = shift;
    my $output = shift;

    #if an output file name is not specified then create one
    #by removing the .gz from the name of the input file
    $output = defined($output) ? $output : basename($file);
    $output =~ s/\.gz$//;

    my $uncompressed_file = new IO::Uncompress::Gunzip($file) or die $!;

    open (OUTFILE, '>>'.$output);

    while (defined (my $line = $uncompressed_file->getline()))
    {
       print OUTFILE $line;
    }

    $uncompressed_file->close();
    close(OUTFILE);

    $output;
}

sub createZip
{
    my ($args) = @_;

    #the input can be a list of file paths or a pattern of files
    #to look for on the file system
    if( defined $args->{pattern})
    {
        #create an "input file glob string"
        $file_pattern_or_list = "<".$args->{pattern}.">";
    }
    elsif(defined $args->{filelist})
    {
        $file_pattern_or_list = $args->{filelist};
    }
    else
    {
        wr_die("Error: No file pattern or list of files was provided");
    }

    $output_file = $args->{output};
    if( not defined $output_file)
    {
        wr_die("Error: No output file was provided");
    }

    my $status = zip $file_pattern_or_list => $output_file
            or wr_die("Error: Failed to create zip file $output_file: $ZipError\n");
}

#gets a list of file names from a zip file or directory
sub getFileList
{
    my $input = shift;
    my $tempDir = shift;

    my @file_set = ();

    if(!isNonEmptyString($input))
    {
        wr_die ( "\nInvalid file or directory: $input" );
    }

    #unzip if this is a zip file
    if ($input =~ /.zip$/)
    {
        unzip_func($input1, $temp_dir);
        $input1 = $temp_dir;
    }

    if(-d $input)
    {
         opendir(DIR, $input);
         @FILES = readdir(DIR);
         closedir(DIR);

         foreach $file (@FILES)
         {
            if($file !~ m/^\./)
            {
                push(@file_set, catfile($input, $file));
            }
        }
    }
    else
    {
        #input is a file so add it directly
        push(@file_set, $input);
    }

    $file_set_size = @file_set;
    wr_die("No files found in:  $input") if $file_set_size <= 0;


    return @file_set;
}

sub isNonEmptyString
{
    $value = shift;
    if($value !~ /^\s*$/)
    {
        return 1;
    }

    return 0;
}

sub isInteger
{
    $value = shift;
    if($value =~ /^\d+$/)
    {
        return 1;
    }

    return 0;
}

# does a complimentary check that the paired reads have the expected _1 and _2 file name patterns
# to insure that all the pairs will be correctly matched up
sub checkPairMatching
{
    my($pairA, $pairB) = @_ ;

    $pair1_size = @{$pairA};
    $pair2_size = @{$pairB};

    if($pair1_size != $pair2_size)
    {
        wr_die("Number of files for pair 1 ($pair1_size) and pair 2 ($pair2_size) are different.");
    }

    for my $i (0 .. $#$pairA)
    {
        my $start_index = rindex(basename(@{$pairA}[$i]), "_1");
	    if($start_index != -1)
        {
	        my $expected_pairB =basename(@{$pairA}[$i]);
	        substr($expected_pairB, $start_index+1, 1, "2");
	        if(basename(@{$pairB}[$i]) ne $expected_pairB)
	        {
                # The pair 2 file does not have the expected _2 right before the extension i.e. mypair1sample_2.fq
                # but the pair 1 fail does  i.e. mypair1sample_1.fq
		        print STDOUT "\nWARNING: Possible unmatched pairs found @{$pairA}[$i] and @{$pairB}[$i]";
	        }
	    }
	    else
        {
            #The pair 1 file does not have the expected _1 right before the extension i.e. mypair1sample_1.fq
	        print STDOUT "\nWARNING: Unexpected input file name @{$pairA}[$i]";
        }
    }
}

sub wr_die
{
    print STDERR @_, "\n\n";
    exit(1);
}

1;