sub test_unexpected_file_modifications {
    print "\nRunning test: Unexpected File Modifications\n";

    # Test 1: Manual modification of a file
    my $key = "manual_mod_key";
    my $data = { test => "original" };
    store_data($key, $data);

    # Modify the file directly
    my $file_path = File::Spec->catfile($config{storage_path}, "$key.json");
    open my $fh, '>', $file_path or die "Error opening file: $!\n";
    print $fh "{ \"test\": \"tampered\" }";
    close $fh;

    eval {
        my $retrieved_data = retrieve_data($key);
        if ($retrieved_data->{test} eq "tampered") {
            print "PASSED: Successfully detected manual modification.\n";
        } else {
            print "FAILED: Manual modification not detected.\n";
        }
    };

    # Test 2: Missing file
    unlink $file_path;
    eval {
        retrieve_data($key);
    };
    if ($@) {
        print "PASSED: Error correctly thrown for missing file.\n";
    } else {
        print "FAILED: No error for missing file.\n";
    }
}
