#!perl

use strict;
use warnings;

use Data::Dumper;
use Test::More;
use Test::SQL::Data;

use lib 't/lib';
use Test::Ravada;

my $test = Test::SQL::Data->new(config => 't/etc/sql.conf');

init($test->connector);

##############################################################################

sub test_change_owner {
    my $vm = shift;
    my $domain = create_domain($vm->type);
    ok($domain);

    is($domain->id_owner, user_admin->id);

    my $user2 = create_user('colonel.dax','anthill');
    my $user3 = create_user('George.Broulard','win');

    my $req = Ravada::Request->change_owner(
        uid => $user2->id
        ,id_owner => $user3->id
        ,id_domain => $domain->id
    );
    rvd_back->_process_requests_dont_fork();

    is($req->status, 'done');
    like($req->error, qr'.');

    $domain = Ravada::Domain->open($domain->id);
    is($domain->id_owner, user_admin->id);

    is($user2->is_operator,0);

    user_admin->grant($user2,'change_owner_all');

    is($user2->is_operator,1);

    $req = Ravada::Request->change_owner(
        uid => $user2->id
        ,id_owner => $user3->id
        ,id_domain => $domain->id
    );
    rvd_back->_process_requests_dont_fork();

    is($req->status, 'done');
    is($req->error, '');

    $domain = Ravada::Domain->open($domain->id);
    is($domain->id_owner, $user3->id);


    $domain->remove(user_admin);

    $user2->remove();
    $user3->remove();
}

##############################################################################

clean();

for my $vm_name ( vm_names() ) {
    my $vm;
    eval { $vm = rvd_back->search_vm($vm_name) };

    SKIP: {
        my $msg = "SKIPPED test: No $vm_name VM found ";
        if ($vm && $vm_name =~ /kvm/i && $>) {
            $msg = "SKIPPED: Test must run as root";
            $vm = undef;
        }

        diag($msg)      if !$vm;
        skip $msg       if !$vm;

        test_change_owner($vm);
    }
}

clean();
done_testing();

