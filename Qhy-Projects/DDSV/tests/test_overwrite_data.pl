#!/usr/bin/perl
use strict;
use warnings;
use lib '../src/';  # Add the path to the core script or modules
require 'ddsv_core.pl';  # Load the core script to access its functions

# Test for overwrite data
sub test_overwrite_data {
    print "\nRunning test: Overwriting Existing Data\n";

    # Create a valid key
    my $key = "test_key";
    my $data = { test => "original_data" };
    store_data($key, $data);

    # Test 1: Overwrite with valid data
    my $new_data = { test => "new_data" };
    store_data($key, $new_data);

    my $retrieved_data = retrieve_data($key);
    if ($retrieved_data->{test} eq "new_data") {
        print "PASSED: Successfully overwrote data with valid content.\n";
    } else {
        print "FAILED: Data overwrite failed.\n";
    }

    # Test 2: Overwrite with invalid data
    eval {
        store_data($key, undef); # Attempt to overwrite with invalid data
    };
    if ($@) {
        print "PASSED: Error correctly thrown for invalid data overwrite.\n";
    } else {
        print "FAILED: No error for invalid data overwrite.\n";
    }
}
