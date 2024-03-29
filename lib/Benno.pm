package Benno;
use Moose;
use namespace::autoclean;
use Data::Dumper;

use Catalyst::Runtime 5.80;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

# StatusMessage: if messages should survive redirects

use Catalyst qw/
    -Debug
    ConfigLoader
    Static::Simple
    Unicode::Encoding
    Session
    Session::Store::File
    Session::State::Cookie
    Authentication
    Authorization::Roles
    +CatalystX::SimpleLogin
/;

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in benno.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Benno',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header

    authentication => {
        default_realm => 'users',
        realms        => {
            users => {
                credential => {
                    class          => 'Password',
                    password_field => 'password',
                    password_type  => 'self_check'
                },
                store => {
                    class         => 'DBIx::Class',
                    user_model    => 'BennoDB::User',
                    role_relation => 'roles',
                    role_field    => 'name',
                }
            }
        },
    },
    'Controller::Login' => {
        #traits => ['-RenderAsTTTemplate'],
        login_form_args => {
               authenticate_username_field_name => 'username',
               authenticate_password_field_name => 'password',
        #       authenticate_args => { active => 'Y' },
        },
        actions => {
            required => {
                Chained => '/label/labels',
                PathPart => '',
                CaptureArgs => 0,
                Does => ['NeedsLogin'],                         
            },
        },
    },
);

# Start the application
__PACKAGE__->setup();


=head1 NAME

Benno - Catalyst based application

=head1 SYNOPSIS

    script/benno_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<Benno::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Atacama Developer,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
