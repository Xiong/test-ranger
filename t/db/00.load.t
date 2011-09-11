use Test::More tests => 1;

BEGIN {
    $SIG{__DIE__}   = sub {
        warn @_;
        BAIL_OUT( q[Couldn't use module; can't continue.] );    
        
    };
}   

BEGIN {
    use Test::Ranger::DB;
}

pass( 'Load module.' );
diag( "Testing Test::Ranger::DB $Test::Ranger::DB::VERSION" );
