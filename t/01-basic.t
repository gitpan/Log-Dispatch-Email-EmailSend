#!/usr/bin/perl -w

use strict;

use Test::More;

plan tests => 6;

use_ok('Log::Dispatch::Email::EmailSend');

SKIP:
{
    eval { require Email::Send::Test };
    skip( 'These tests need Email::Send::Test', 5 )
        if $@;

    my $dispatch = Log::Dispatch->new;

    $dispatch->add
        ( Log::Dispatch::Email::EmailSend->new( name      => 'email-send',
                                                min_level => 'info',
                                                to        => 'foo@example.com',
                                                from      => 'bar@example.com',
                                                subject   => 'email send log',
                                                mailer    => 'Test',
                                                buffered  => 0,
                                              )
        );

    $dispatch->log( level   => 'error',
                    message => 'An error occurred',
                  );

    my @email = Email::Send::Test->emails;

    is( @email, 1, 'only one email was sent' );

    is( $email[0]->header('To'), 'foo@example.com',
        'check To header' );
    is( $email[0]->header('From'), 'bar@example.com',
        'check From header' );
    is( $email[0]->header('Subject'), 'email send log',
        'check Subject header' );
    like( $email[0]->body, qr/An error occurred/,
        'check body' );
}
