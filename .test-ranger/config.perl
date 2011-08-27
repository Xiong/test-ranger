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
-mw_anchor              => 'none',          # placement
#~ -mw_anchor              => 'center-always', # placement
#~ -mw_anchor              => 'center',        # placement

# for each Frame
-frame_type             => 'etched-in',     # framing of panes
#~ -frame_type             => 'out',     # framing of panes
#~ -frame_labels           => [ 'A', 'B', 'C', 'D' ],  # label the frame
-frame_labels           => [ '0', '1', '2', '3' ],  # label the frame

# for each Pane (VBox)
-pane_homo              => FALSE,       # expand all children
-pane_spacing           => 5,           # spacing between children

# specific Frame defaults
# You may specify a Frame by number 0..3 or by letter 'A'..'D'
-terminal_frame         => 'D',         # pane to create terminal windows
