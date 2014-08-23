requires 'perl', '5.008005';

requires 'Exporter', '5.57';

on test => sub {
    requires 'Test::More', '0.96';
    requires 'Test::Is', '20140823';
    requires 'Test::Synopsis', '0.10';
};
