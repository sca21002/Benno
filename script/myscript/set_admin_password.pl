#!/usr/bin/env perl
 
use strict;
use warnings;
use lib 'lib';
 
#BEGIN { $ENV{CATALYST_DEBUG} = 0 }
 
use Benno;
use DateTime;
 
my $admin = Benno->model('BennoDB::User')->search({ username => 'admin' })->single;
 
$admin->update({ password => '***REMOVED***', password_expires => DateTime->now });
