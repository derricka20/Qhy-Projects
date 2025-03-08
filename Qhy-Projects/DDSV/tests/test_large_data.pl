sub test_large_data {
    print "\nRunning test: Large Data Handling\n";

    # Generate large data
    my $key = "large_data_key";
    my $large_data = { content => "a" x (1024 * 1024) }; # 1MB data

    eval {
        store_data($key, $large_data);
        my $retrieved_data = retrieve_data($key);
        if ($retrieved_data->{content} eq $large_data->{content}) {
            print "PASSED: Successfully handled large data.\n";
        } else {
            print "FAILED: Data mismatch for large data.\n";
        }
    };
    if ($@) {
        print "FAILED: Error occurred while handling large data: $@\n";
    }
}
