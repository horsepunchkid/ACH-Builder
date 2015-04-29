use strict;
use warnings;

use Test::More;
use ACH::Builder;

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

$ach = ACH::Builder->new($sample_config);
$ach->make_file_header_record;
$ach->set_entry_class_code('WEB');
$ach->make_batch([$ach->sample_detail_records]);
$ach->make_file_control_record;
$ach->make_filler_records;

# test combining lines
is(join('', map "$_\n", @{$sample_lines}), $ach->to_string, 'default terminator');
is(join('', map "${_}X", @{$sample_lines}), $ach->to_string('X'), 'alternate terminator');
is(join('', @{$sample_lines}), $ach->to_string(''), 'no terminator');

done_testing(3);
