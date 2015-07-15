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
  allow_unbalanced_file => 1,
};

my $sample_entries = [
  {
    customer_name       => 'JOHN SMITH',
    customer_acct       => '1234-0123456',
    amount              => '2501',
    routing_number      => '010010101',
    bank_account        => '103030030',
    transaction_code    => '27',
    addenda             => [
      {
        addendum_code => '05',
        addendum_info => 'Addendum Info 1',
      },
    ],
  },
];

my $sample_lines = [
  '101 123123123  123123111309031234A094101COMMERCE BANK          MYCOMPANY                      ',
  '5200MY COMPANY      BILL                11-111111 WEBTV-TELCOM 130903130903   1123123110000001',
  '627010010101103030030        00000025011234-0123456   JOHN SMITH              1123123110000002',
  '705Addendum Info 1                                                                 00010000002',
  '8200000002000100101000000000250100000000000011-111111                          123123110000001',
  '9000001000001000000020001001010000000002501000000000000                                       ',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
  '9999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999999',
];

my $ach;

$ach = ACH::Builder->new($sample_config);
$ach->make_file_header_record;
$ach->set_entry_class_code('WEB');
$ach->make_batch($sample_entries);
$ach->make_file_control_record;
$ach->make_filler_records;
is(scalar @{$ach->ach_data}, 10, 'record count after filler');
is($ach->ach_data->[$_], $sample_lines->[$_], 'filler record format') for 0..9;

done_testing(11);
