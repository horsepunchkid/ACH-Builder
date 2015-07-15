use strict;
use warnings;

use Test::More;
use ACH::Builder;

my $sample_config = {
  company_id        => '11-111111',
  company_name      => 'MY COMPANY',
  destination       => '123123123',
  destination_name  => 'COMMERCE BANK',
  origination       => '12312311',
  origination_name  => "Se\x{00f1}or Frog",
  company_note      => 'BILL',
  creation_date     => '130903',
  creation_time     => '1234',
};

my $ach = ACH::Builder->new($sample_config);

$ach->make_file_header_record;
is('101 123123123  123123111309031234A094101COMMERCE BANK          Se?or Frog                     ' , $ach->ach_data->[0], 'replace non-ascii chars');

done_testing(1);
