package Sledge::Plugin::Email::Japanese;
use strict;
use warnings;
our $VERSION = '0.03';
use MIME::Lite::TT::Japanese;
use File::Slurp;

sub import {
    my $pkg = caller;

    no strict 'refs';
    *{"$pkg\::send_mail"} = sub {
        my ($self, $tmpl, $args, $sendmail_opt) = @_;

        my $file = $self->guess_filename($tmpl);
        my $body = File::Slurp::read_file($file);
        if (!$args->{Subject} and $body =~ /\A([^\n]+)\n\n(.*)\Z/ms) {
            $args->{Subject} = $1;
            $body = $2;
        }

        my $conf = $self->create_config->email;
        my $option = {
            LineWidth => 0,
            Template => \$body,
            %$conf,
            %$args,
        };
        $option->{TmplParams}->{r} ||= $self->r;
        $option->{TmplParams}->{session} ||= $self->session;

        my $msg = MIME::Lite::TT::Japanese->new(%$option);
        if ($self->debug_level) {
            $msg->print(\*STDERR);
            $self->session->param('last_mail' => $msg->as_string);
        }
        $msg->send(@{$sendmail_opt || $conf->{send}});
    };
}

1;
__END__

=head1 NAME

Sledge::Plugin::Email::Japanese - easy to send the mail

=head1 SYNOPSIS

    package Your::Pages;
    use Sledge::Plugin::Email::Japanese;

    sub dispatch_foo {
        my $self = shift;
        $self->send_mail(
            'foo.eml' => {
                Subject => 'Hi!',
                To      => $self->r->param('email'),
                TmplParams => {
                    name => $self->r->param('name'),
                },
            },
        );
    }

    package Your::Config::_common;
    $C{EMAIL} = {
        From => 'info@example.com',
        send => ['sendmail', 'FromSender' => 'foo@example.com']
    };

=head1 DESCRIPTION

Send emails with Sledge and MIME::Lite::TT::Japanese.

=head1 AUTHOR

MATSUNO Tokuhiro E<lt>tokuhiro at mobilefactory.jpE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 THANKS TO

    id:precuredaisuki

=head1 SEE ALSO

L<Catalyst::Plugin::Email::Japanese>, L<MIME::Lite::TT::Japanese>

=cut

