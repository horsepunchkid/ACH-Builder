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

my $ach;

# test alternate blocking factor
$ach = ACH::Builder->new($sample_config);
$ach->{__BLOCKING_FACTOR__} = 3;
$ach->make_file_header_record;
$ach->make_filler_records;
is(scalar @{$ach->ach_data}, 3, 'record count with blocking factor 3');

done_testing(1);
