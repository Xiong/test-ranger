use Test::More tests => 1;

BEGIN {
    $SIG{__DIE__}   = sub {
        warn @_;
        BAIL_OUT( q[Couldn't use module; can't continue.] );    
        
    };
}   

BEGIN {
    use Test::Ranger;               # Airtight testing with database and valet
    use Test::Ranger::Base          # Base class and procedural utilities
        qw( :all );
    use Test::Ranger::Trap;         # Comprehensive airtight trap and test
    use Test::Ranger::Tool;         # Command line testing valet with GUI
    use Test::Ranger::CS;           # Class for 'context state' football
    use Test::Ranger::DB;           # Database interactions with SQLite
    
    use DBI;                # Generic interface to a large number of databases
    use DBD::SQLite;        # Self-contained RDBMS in a DBI Driver
    use DBIx::RunSQL;       # run SQL to create a database schema
}

pass( 'Load modules.' );
diag( "Testing Test::Ranger $Test::Ranger::VERSION" );
