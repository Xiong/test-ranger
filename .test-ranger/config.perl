# Test Ranger configuration file
#
# This file will be evaluated using string eval() and the list stored to hash.
# Be *very* sure each line is terminated with a comma, not a semi!
# 
use Glib                        # Gtk constants
    'TRUE', 'FALSE',
; ## Glib
#============================================================================#

# main Window
-mw_initial_V           => 300,             # initial height
-mw_initial_H           => 300,             # initial width
#~ -mw_anchor              => 'none',          # placement
#~ -mw_anchor              => 'center-always', # placement
-mw_anchor              => 'center',        # placement

# for each Frame
#~ -frame_type             => 'etched-in',     # framing of panes
-frame_type             => 'in',            # framing of panes
#~ -frame_type             => 'none',          # framing of panes

#~ -frame_labels           => [ 'A', 'B', 'C', 'D' ],  # label the frames
#~ -frame_labels           => [ '0', '1', '2', '3' ],  # label the frames
#~ -frame_labels           => 'b',                     # nonsense - don't ship!
#~ -frame_labels           => '',                      # don't label the frames
#~ -frame_labels           => [''],                    # don't label the frames

# for each Pane (VBox)
-pane_homo              => FALSE,       # expand all children
-pane_spacing           => 5,           # spacing between children

# specific Frame defaults
# You may specify a Frame by number 0..3 or by letter 'A'..'D'
-history_frame          => 'C',         # pane to create terminal windows
-terminal_frame         => 'D',         # pane to create terminal windows
#~ -terminal_frame         => '1',         # pane to create terminal windows

# terminal widget settings
-terminal_color_background      => 'straw',
-terminal_color_foreground      => 'black',

# File names
-db_file        => '.test-ranger/tr_db',        # SQLite database file
-sql_file       => 'file/db/tr_db.sql',         # setup file contains SQL
-ipc_file       => '.test-ranger/tr_ipc.perl',  # For parent-child IPC



