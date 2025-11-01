#!/usr/bin/perl
use strict;
use warnings;
# Add the absolute path to the src directory to @INC
use lib '/workspaces/Qhy-Projects/Qhy-Projects/DDSV/src';  # Add the path to the core script or modules
require 'ddsv_core.pl';  # Load the core script to access its functions

# Test for corrupted files
sub test_corrupted_files {
    print "\nRunning test: Corrupted Data Files\n";

    # Test 1: Missing data file
    my $missing_key = "missing_key";
    eval {
        retrieve_data($missing_key);
    };
    if ($@) {
        print "PASSED: Error correctly thrown for missing file.\n";
    } else {
        print "FAILED: No error for missing file.\n";
    }

    # Test 2: Invalid JSON file
    my $invalid_file_path = "$config{storage_path}/invalid_json_key.json";
    open my $fh, '>', $invalid_file_path or die "Error creating test file: $!\n";
    print $fh "{ invalid_json: true"; # Deliberately malformed JSON
    close $fh;

    eval {
        retrieve_data("invalid_json_key");
    };
    if ($@) {
        print "PASSED: Error correctly thrown for invalid JSON file.\n";
    } else {
        print "FAILED: No error for invalid JSON file.\n";
    }

    # Clean up test file
    unlink $invalid_file_path;
}
