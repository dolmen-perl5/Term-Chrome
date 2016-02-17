# vim:set ft=perl:

requires 'perl', '5.008005';

requires 'Exporter', '5.57';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Is', '20140823';
    requires 'Test::Requires' => '0.05';
    suggests 'Test::Synopsis' => '0.14';
};

on develop => sub {
    requires 'Test::Requires' => '0.07'; # Features RELEASE_TESTING
    requires 'Test::Synopsis' => '0.14';
}
