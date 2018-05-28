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

################################################################################

sub test_create_admin {
    my $vm = shift;

    my $domain = create_domain($vm->type);
    ok($domain) or return;

    is(user_admin->can_list_machines, 1 );
    is(user_admin->can_list_own_machines, 1 );

    my $list =rvd_front->list_machines(user_admin);
    is( scalar @$list, 1);

    $domain->remove(user_admin);

}

sub test_create_grant {
    my $vm = shift;

    my $base = create_domain($vm->type);

    my $user = create_user('rebecca.bunch','josh');
    is ($user->can_list_machines, 0);
    is ($user->can_list_own_machines, 0);
    is ($user->can_list_clones, 0);

    my $list =rvd_front->list_machines($user);
    is( scalar @$list, 0);

    user_admin->grant($user, 'create_machine');
    is ($user->can_list_clones, 0);
    is ($user->can_list_machines, 0);
    $list =rvd_front->list_machines($user);
    is( scalar @$list, 0);

    my $domain = create_domain($vm->type, $user);

    $list =rvd_front->list_machines($user);
    is( scalar @$list, 1);

    $domain->prepare_base(user_admin);
    $domain->is_public(1);

    my $clone = $domain->clone(
        user  => user_admin
        ,name =>  new_domain_name()
    );

    $list =rvd_front->list_machines($user);
    is( scalar @$list, 1);

    $user->remove();

    $clone->remove(user_admin);
    $base->remove(user_admin);
    $domain->remove(user_admin);
}
################################################################################

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

        test_create_admin($vm);
        test_create_grant($vm);

    }
}

clean();

done_testing();

