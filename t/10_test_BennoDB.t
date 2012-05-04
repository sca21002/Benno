#!/usr/bin/env perl
use warnings;
use strict;
use Test::More;
use Benno;

#BEGIN { use_ok 'Benno::Model::BennoDB' }

my $admin = Benno->model('BennoDB::User')->search({username => 'admin'})->single;

is($admin->username,'admin','User admin found');

diag $admin->username;

my @users_roles = $admin->users_roles;

foreach my $user_role (@users_roles) {
diag 'user_role: ' . $user_role->role_id;
}

my $admin_roles_rs = $admin->roles;
while (my $role = $admin_roles_rs->next) {
    diag $role->id;  
}

done_testing();

