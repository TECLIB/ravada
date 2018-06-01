#!perl

use strict;
use warnings;

use Data::Dumper;
use Mojo::Template;
use Test::More;
use Test::SQL::Data;

no warnings "experimental::signatures";
use feature qw(signatures);

use lib 't/lib';
use Test::Ravada;

my $test = Test::SQL::Data->new(config => 't/etc/sql.conf');

init($test->connector);

sub _fetch($file) {

    my $template = '';
    open my $in,"<", $file or die "$! $file";
    while (<$in>) {
        $_ = "\n" if /^\s*%=\s*include/;
        s/<%=\s*l/<%=/g;
        $template .= $_;
    }
    return $template;
}

sub test_render($file, $vars) {

    $vars = { @$vars };
    $vars->{user} = user_admin if !exists $vars->{user};

    my $text = Mojo::Template->new(vars => 1)->render(_fetch($file), $vars);
    is($@,'',$file) or BAIL_OUT;
    ok($text, $file) ;
}

sub _find_templates($templates) {
    open my $find,'-|',"find templates -type f" or die $!;
    while(<$find>) {
        chomp;
        next unless /\.html.ep$/;
        next if $templates->{$_};

        $templates->{$_} = [];
    }
}
################################################

my $user = create_user('venus','flytrap');
my %templates = (
    "templates/main/about.html.ep", [version => 1]
    ,'templates/main/list_bases2.html.ep'
        => [ _anonymous => undef, machines => []
            , user => user_admin , guide => 0
        ]
    ,'templates/main/list_bases2.html.ep'
        => [ _anonymous => undef, machines => []
            , user => $user , guide => 0
        ]
    ,'templates/bootstrap/user_settings.html.ep'
        => [ c => undef
            ,_user => user_admin
            ,errors => []
            ,changed_lang => undef
            ,changed_pass => undef
        ]

);

_find_templates(\%templates);

while (my ($template, $vars) = each %templates ) {
    test_render($template, $vars);
}

done_testing();
