use strict;
use warnings;

my $msg;

package Test::Config;
use base 'Class::Accessor';
sub email {
    return {
        From => 'info@example.com',
        send => ['sub', sub { $msg = shift->as_string }]
    };
}

package Test::Pages;
use Sledge::Plugin::Email::Japanese;
use Data::Dumper;
use Test::More tests => 14;

sub r { 'REQUEST' }
sub session { 'SESSION' }

sub debug_level { 0 }

sub create_config { Test::Config->new }

sub guess_filename {
    my ($self, $file) = @_;
    return "t/$file";
}

Test::Pages->send_mail(
    'foo.eml' => {
        Subject => 'Hi!',
        To      => 'tokuhirom@example.com',
        TmplParams => {
            name => 'tokuhirom',
        },
    },
);

like $msg, qr/Subject: Hi!\n/, 'subject';
like $msg, qr/To: tokuhirom\@example.com/, 'to';
like $msg, qr/From: info\@example.com/, 'from';
like $msg, qr/Hi, tokuhirom./, 'params';
like $msg, qr/session=SESSION/, 'tmpl session';
like $msg, qr/r=REQUEST/, 'tmpl request';

# -------------------------------------------------------------------------

Test::Pages->send_mail(
    'bar.eml' => {
        To      => 'kan@example.com',
        TmplParams => {
            name => 'kan',
        },
    },
);
like $msg, qr/Subject: SSSSUBJECT!!/, 'subject';
like $msg, qr/To: kan\@example.com/, 'to';
like $msg, qr/From: info\@example.com/, 'from';
like $msg, qr/Hi, kan./, 'params';

# -------------------------------------------------------------------------
# send option
my $msg2;
Test::Pages->send_mail(
    'bar.eml' => {
        To      => 'foo@example.com',
        TmplParams => {
            name => 'kan',
        },
    } => [ 'sub', sub { $msg2 = shift->as_string }]
);
like $msg2, qr/Subject: SSSSUBJECT!!/, 'subject';
like $msg2, qr/To: foo\@example.com/, 'to';
like $msg2, qr/From: info\@example.com/, 'from';
like $msg2, qr/Hi, kan./, 'params';

__END__
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=iso-2022-jp
MIME-Version: 1.0
X-Mailer: MIME::Lite 3.01 (F2.72; T1.16; A1.62; B3.04; Q3.03)
Subject: Hi!
To: tokuhirom@example.com
Date: Sun, 05 Mar 2006 20:58:08 +0900
From: info@example.com

Hi, tokuhirom.

I'm mailer!

