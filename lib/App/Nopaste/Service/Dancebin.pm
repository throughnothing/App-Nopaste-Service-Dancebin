use strict;
use warnings;
package App::Nopaste::Service::Dancebin;
use Encode qw( decode_utf8 );

use base q[App::Nopaste::Service];

# ABSTRACT: nopaste service for L<Dancebin>

sub uri { $ENV{DANCEBIN_URL} || 'http://danceb.in/' }

sub fill_form {
    my ($self, $mech) = (shift, shift);
    my %args = @_;

    my $content = {
        code    => decode_utf8($args{text}),
        title   => decode_utf8($args{desc}),
        #lang    => $args{lang},
    };

    my $form = $mech->form_number(1) || return;

    # do not follow redirect please
    @{$mech->requests_redirectable} = ();

    my $paste = HTML::Form::Input->new(
        type  => 'text',
        value => 'Send',
        name  => 'paste'
    )->add_to_form($form);

    return $mech->submit_form( form_number => 1, fields => $content );
}

sub return {
    my ( $self, $mech ) = @_;

    if($mech->response->is_redirect) {
      return ( 1, $mech->response->header("Location") );
    } else {
      return ( 0, "Cannot find URL" );
    }
}

1;

=head1 SYNOPSIS

L<Dancebin|https://github.com/throughnothing/Dancebin> Service for L<nopaste>.

To use, simple use:

    $ echo "text" | nopaste -s Dancebin

By default it pastes to L<http://danceb.in/|http://danceb.in/>, but you can
override this be setting the C<DANCEBIN_URL> environment variable.
