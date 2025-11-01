#!/usr/bin/perl
use strict;
use warnings;
use File::Spec;
use File::Basename;
use JSON;
use Data::Dumper;
use Cwd;

# DDSV Core Configuration
my $base_dir = getcwd();  # Get the current working directory
my %config = (
    storage_path => "$base_dir/data/",       # Default data storage directory
    log_file     => "$base_dir/logs/ddsv.log",  # Log file location
    extensions   => "$base_dir/extensions/",    # Extensions folder
);

# Initialize DDSV
sub initialize_ddsv {
    print "Initializing Dynamic Data Storage Vault (DDSV)...\n";
    validate_storage_path($config{storage_path});
    validate_storage_path($config{log_file});
    log_message("DDSV initialized successfully.");
}

# Validate the storage path
sub validate_storage_path {
    my $path = shift;
    my $dir = $path;

    # If the path points to a file, extract the directory part
    if ($path =~ /^(.*\/)[^\/]+$/) {
        $dir = $1;  # Get the directory portion of the path
    }

    unless (-d $dir) {
        mkdir $dir or die "Error: Unable to create directory $dir: $!\n";
        print "Created directory: $dir\n";
    }
}

# Log a message to the log file
sub log_message {
    my $message = shift;
    my $log_dir = $config{log_file};
    
    # Extract the directory path from the log file path
    $log_dir =~ s/\/[^\/]+$//;

    unless (-d $log_dir) {
        mkdir $log_dir or die "Error: Unable to create log directory $log_dir: $!\n";
    }

    open my $log_fh, '>>', $config{log_file} or die "Error: Unable to write to log file: $!\n";
    print $log_fh localtime() . " - $message\n";
    close $log_fh;
}

# Store data
sub store_data {
    my ($key, $data) = @_;
    my $file_path = File::Spec->catfile($config{storage_path}, "$key.json");

    open my $data_fh, '>', $file_path or die "Error: Unable to write to $file_path: $!\n";
    print $data_fh encode_json($data);
    close $data_fh;

    log_message("Data stored successfully with key: $key");
    print "Data successfully stored under key: $key\n";
}

# Retrieve data
sub retrieve_data {
    my $key = shift;
    my $file_path = File::Spec->catfile($config{storage_path}, "$key.json");

    unless (-e $file_path) {
        log_message("Error: Data with key '$key' not found.");
        die "Error: No data found for key: $key\n";
    }

    open my $data_fh, '<', $file_path or die "Error: Unable to read $file_path: $!\n";
    my $json = do { local $/; <$data_fh> };
    close $data_fh;

    log_message("Data retrieved successfully with key: $key");
    return decode_json($json);
}

# List all stored data keys
sub list_keys {
    opendir my $dir, $config{storage_path} or die "Error: Unable to read storage directory: $!\n";
    my @files = readdir $dir;
    closedir $dir;

    my @keys = map { basename($_, '.json') } grep { /\.json$/ } @files;
    print "Available keys: ", join(', ', @keys), "\n";
    return @keys;
}

# Load Extensions
sub load_extensions {
    my $extension_dir = $config{extensions};
    unless (-d $extension_dir) {
        print "No extensions directory found. Skipping.\n";
        return;
    }

    opendir my $dir, $extension_dir or die "Error: Unable to read extensions directory: $!\n";
    my @extensions = grep { -d "$extension_dir/$_" && !/^\.{1,2}$/ } readdir($dir);
    closedir $dir;

    print "Loading extensions...\n";
    foreach my $extension (@extensions) {
        my $ext_path = File::Spec->catfile($extension_dir, $extension, 'init.pl');
        if (-e $ext_path) {
            do $ext_path or warn "Error loading extension $extension: $@\n";
            log_message("Loaded extension: $extension");
        }
    }
}

# Main Menu for Testing
sub main_menu {
    print "\n==== DDSV Core Menu ====\n";
    print "1. Store Data\n";
    print "2. Retrieve Data\n";
    print "3. List Keys\n";
    print "4. Load Extensions\n";
    print "5. Exit\n";
    print "Enter your choice: ";

    my $choice = <STDIN>;
    chomp($choice);

    if ($choice == 1) {
        print "Enter key: ";
        my $key = <STDIN>;
        chomp($key);
        print "Enter data (as JSON): ";
        my $data = <STDIN>;
        chomp($data);

        my $decoded_data = eval { decode_json($data) };
        if ($@) {
            print "Error: Invalid JSON data.\n";
            return;
        }
        store_data($key, $decoded_data);
    }
    elsif ($choice == 2) {
        print "Enter key: ";
        my $key = <STDIN>;
        chomp($key);
        my $data = retrieve_data($key);
        print Dumper($data);
    }
    elsif ($choice == 3) {
        list_keys();
    }
    elsif ($choice == 4) {
        load_extensions();
    }
    elsif ($choice == 5) {
        print "Exiting DDSV. Goodbye!\n";
        exit;
    }
    else {
        print "Invalid choice. Please try again.\n";
    }
}

# Entry Point
initialize_ddsv();
while (1) {
    main_menu();
}

