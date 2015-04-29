# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl ACH-Builder.t'

#########################

use strict;
use warnings;

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More;
BEGIN { use_ok('ACH::Builder') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

isa_ok(ACH::Builder->new, 'ACH::Builder', 'empty constructor');

my $sample_config = {
  company_id        => '11-111111',
  company_name      => 'MY COMPANY',
  entry_description => 'TV-TELCOM',
  destination       => '123123123',
  destination_name  => 'COMMERCE BANK',
  origination       => '12312311',
  origination_name  => 'MYCOMPANY',
  company_note      => 'BILL',
  effective_date    => '130903',
  creation_date     => '130903',
  creation_time     => '1234',
};

my $sample_lines = [
  '101 123123123  123123111309031234A094101COMMERCE BANK          MYCOMPANY                      ',
  '5200MY COMPANY      BILL                11-111111 WEBTV-TELCOM 130903130903   1123123110000001',
  '627010010101103030030        00000025011234-0123456   JOHN SMITH              0123123110000002',
  '632010010401440030030        0000002501verylongaccountALICE VERYLONGNAMEGETS  0123123110000003',
  '8200000002000200205000000000250100000000250111-111111                          123123110000001',
  '9000001000001000000020002002050000000002501000000002501                                       ',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
];

my $ach;

# create builder
$ach = ACH::Builder->new($sample_config);
is(scalar @{$ach->ach_data}, 0, 'new builder');

# add file header record
$ach->make_file_header_record;
is(scalar @{$ach->ach_data}, 1, 'record count after file header');
is($ach->ach_data->[0], $sample_lines->[0], 'file header record format');

# add batch for sample records
$ach->set_entry_class_code('WEB');
$ach->make_batch([$ach->sample_detail_records]);
is(scalar @{$ach->ach_data}, 5, 'record count after batch');
is($ach->ach_data->[1], $sample_lines->[1], 'batch header record format');
is($ach->ach_data->[2], $sample_lines->[2], 'entry detail record format');
is($ach->ach_data->[3], $sample_lines->[3], 'entry detail record format');
is($ach->ach_data->[4], $sample_lines->[4], 'batch control record format');

# add file control record
$ach->make_file_control_record;
is(scalar @{$ach->ach_data}, 6, 'record count after file control');
is($ach->ach_data->[5], $sample_lines->[5], 'file control record format');

# add 9's filler records
$ach->make_filler_records;
is(scalar @{$ach->ach_data}, 10, 'record count after filler');
is($ach->ach_data->[$_], $sample_lines->[$_], 'filler record format') for 6..9;

$ach->make_filler_records;
is(scalar @{$ach->ach_data}, 10, 'record count after redundant filler');

# test combining lines
is(join('', map "$_\n", @{$sample_lines}), $ach->to_string, 'default terminator');
is(join('', map "${_}X", @{$sample_lines}), $ach->to_string('X'), 'alternate terminator');
is(join('', @{$sample_lines}), $ach->to_string(''), 'no terminator');

done_testing(21);
