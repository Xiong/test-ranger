use Test::More tests => 1;

BEGIN {
    $SIG{__DIE__}   = sub {
        warn @_;
        BAIL_OUT( q[Couldn't use module; can't continue.] );    
        
    };
}   

BEGIN {
    use Test::Ranger;       # Testing tool base class and utilities
    use Test::Ranger::DB;   # Database interactions for Test-Ranger
    use DBI;                # Generic interface to a large number of databases
    #~ use DBD::mysql;         # DBI driver for MySQL
    use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver
    use DBIx::RunSQL;       # run SQL to create a database schema
}

pass( 'Load modules.' );
diag( "Testing Test::Ranger $Test::Ranger::VERSION" );
