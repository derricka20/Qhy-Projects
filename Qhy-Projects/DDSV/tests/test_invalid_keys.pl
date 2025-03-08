#!/usr/bin/perl
use strict;
use warnings;
use lib '../src/';  # Add the path to the core script or modules
require 'ddsv_core.pl';  # Load the core script to access its functions

# Test for invalid keys
sub test_invalid_keys {
    print "\nRunning test: Invalid Keys\n";

    # Test 1: Non-existent key
    my $invalid_key = "non_existent_key";
    eval {
        retrieve_data($invalid_key);
    };
    if ($@) {
        print "PASSED: Error correctly thrown for non-existent key.\n";
    } else {
        print "FAILED: No error for non-existent key.\n";
    }

    # Test 2: Key with invalid characters
    $invalid_key = "/invalid/key!";
    eval {
        retrieve_data($invalid_key);
    };
    if ($@) {
        print "PASSED: Error correctly thrown for key with invalid characters.\n";
    } else {
        print "FAILED: No error for key with invalid characters.\n";
    }

    # Test 3: Empty key
    $invalid_key = "";
    eval {
        retrieve_data($invalid_key);
    };
    if ($@) {
        print "PASSED: Error correctly thrown for empty key.\n";
    } else {
        print "FAILED: No error for empty key.\n";
    }
}
