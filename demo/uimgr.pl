#!/run/bin/perl

use strict;
use warnings;
use Gtk2 '-init';
use Glib qw/TRUE FALSE/; 

#===========================================================
#Declare all the data first, to keep it away from the part 
#containing the widgets.

#--------------------------
my @entries = (
  #Fields for each action item:
  #[name, stock_id, value, label, accelerator, tooltip, callback]
  
  #file menus  
  [ "FileMenu",undef,"_File"],
  [ "New",    'gtk-new',  "_New",   "<control>N", "Create a new file", \&activate_action ],
  [ "Open",   'gtk-open', "_Open",  "<control>O", "Open a file",       \&activate_action ],
  [ "Quit",   'gtk-quit', "_Quit",  "<control>Q", "Quit",              \&activate_action ],
  
  #Media menus
  [ "Media",undef,"_Media"],
  [ "media_optical",'gtk-cdrom', "_Optical"],
  
);
#--------------------------

use constant CD_R_M     => 0;
use constant CD_R_P     => 1;
use constant CD_RW_M    => 3;
use constant CD_RW_P    => 4;

my @cd_types = (

  #Fields for each radio-action item:
  #[name, stock_id, value, label, accelerator, tooltip, value]

[ "cd_r_m",   undef, "CD-R",  undef, "CD-R media", CD_R_M  ],
[ "cd_r_p",   undef, "CD+R",  undef, "CD+R media", CD_R_P  ],
[ "cd_rw_m",   undef, "CD-RW",  undef, "CD-RW media", CD_RW_M  ],
[ "cd_rw_p",   undef, "CD+RW",  undef, "CD+RW media", CD_RW_P  ],

);
#--------------------------

use constant DVD_R_M    => 5;
use constant DVD_R_P    => 6;
use constant DVD_RW_M   => 7;
use constant DVD_RW_P   => 8;

my @dvd_types = (

[ "dvd_r_m",   undef, "DVD-R",  undef, "DVD-R media", DVD_R_M  ],
[ "dvd_r_p",   undef, "DVD+R",  undef, "DVD+R media", DVD_R_P  ],
[ "dvd_rw_m",   undef, "DVD-RW",  undef, "DVD-RW media", DVD_RW_M  ],
[ "dvd_rw_p",   undef, "DVD+RW",  undef, "DVD+RW media", DVD_RW_P  ],

);
#--------------------------
#
#===========================================================
#Declare the two XML structures, one contains the basics
#the other one contains the elements for the DVD

my $ui_basic = "<ui>
  <menubar name='MenuBar'>
    <menu action='FileMenu'> 
     <menuitem action='New' position='top'/>
     <menuitem action='Open' position='top'/>
     <separator/>
     <menuitem action='Quit'/>
    </menu>
    <menu action='Media'> 
     <menu action='media_optical'>
            <menuitem  action='cd_r_m'/>
            <menuitem action='cd_r_p'/>
            <menuitem  action='cd_rw_m'/>
            <menuitem  action='cd_rw_p'/>
        </menu>
    </menu>
   </menubar>
   <toolbar name='Toolbar'>
    <placeholder name='optical'>
        <separator/>
            <toolitem  action='cd_r_m'/>
            <toolitem action='cd_r_p'/>
            <toolitem  action='cd_rw_m'/>
            <toolitem  action='cd_rw_p'/>
      </placeholder>   
   </toolbar>
</ui>";

my $ui_dvd = "<ui>
  <menubar name='MenuBar'>
    <menu action='Media'> 
     <menu action='media_optical'>
            <menuitem  action='dvd_r_m'/>
            <menuitem action='dvd_r_p'/>
            <menuitem  action='dvd_rw_m'/>
            <menuitem  action='dvd_rw_p'/>
      </menu>
    </menu>
   </menubar>
   <toolbar name='Toolbar'>
      <placeholder name='optical'>
            <toolitem  action='dvd_r_m'/>
            <toolitem action='dvd_r_p'/>
            <toolitem  action='dvd_rw_m'/>
            <toolitem  action='dvd_rw_p'/>
      </placeholder>
   </toolbar>
</ui>";
#===========================================================

#standard window creation, placement, and signal connecting
my $window = Gtk2::Window->new('toplevel');
$window->signal_connect('delete_event' => sub { Gtk2->main_quit; });
$window->set_border_width(5);
$window->set_position('center_always');

#this vbox will return the bulk of the gui
my $vbox = &ret_vbox();

#add and show the vbox
$window->add($vbox);
$window->show();

#our main event-loop
Gtk2->main();

sub ret_vbox {

#Flag indicating if the DVD was added or not
my $merge_flag = 0;

my $vbox = Gtk2::VBox->new(FALSE,5);
$vbox->set_size_request (600, 200);

#===========================================================
#This part has to do with the Gtk2::UIManager:

    # Create a Gtk2::UIManager instance 
    my $uimanager = Gtk2::UIManager->new;
    
    #________
        #extract the accelgroup and add it to the window
        my $accelgroup = $uimanager->get_accel_group;
        $window->add_accel_group($accelgroup);
        
    #________
        # Create the basic Gtk2::ActionGroup instance
        #and fill it with Gtk2::Action instances
        my $actions_basic = Gtk2::ActionGroup->new ("actions_basic");
        $actions_basic->add_actions (\@entries, undef);
    
    # Add the actiongroup to the uimanager  
    $uimanager->insert_action_group($actions_basic,0);
    
    #________   
        # Create the CD Gtk2::ActionGroup instance
        #and fill it with Gtk2::RadioAction instances
        my $actions_media_cd = Gtk2::ActionGroup->new ("media_cd");
        $actions_media_cd->add_radio_actions(\@cd_types,CD_R_M,undef);
        
        #get the group, this will be needed when we add radio actions
        my $group = ($actions_media_cd->get_action('cd_r_m'))->get_group;
    
    # Add the actiongroup to the uimanager      
    $uimanager->insert_action_group($actions_media_cd,0);
    
    #________   
        # Create the DVD Gtk2::ActionGroup instance
        #and fill it with Gtk2::RadioAction instances
        my $actions_media_dvd = Gtk2::ActionGroup->new ("media_dvd");
        $actions_media_dvd->add_radio_actions(\@dvd_types,CD_R_M,undef);
    
        #run through the DVD types list, getting each action,
        #and set its group ans state
        foreach my $name (@dvd_types){
    
            my $action = $actions_media_dvd->get_action(${$name}[0]);
            #here we use the group :)
            $action->set_group($group);
            #need to specify, else we will have TWO ACTIVE radio buttons
            $action->set_active(FALSE);
        }
            
    # Add the actiongroup to the uimanager
    $uimanager->insert_action_group($actions_media_dvd,0);
    
    #________
    #add the basic XML description of the GUI
    $uimanager->add_ui_from_string ($ui_basic);
    
    #________
    #extract the menubar
    my $menubar = $uimanager->get_widget('/MenuBar');
    
$vbox->pack_start($menubar,FALSE,FALSE,0);

    #________
    #extract the toolbar
    my $toolbar = $uimanager->get_widget('/Toolbar');
    $toolbar->set_show_arrow(FALSE);
    
    #Create a menu tool button and set its menu to the opticals.
        my $t_mbtn_optical = Gtk2::MenuToolButton->new_from_stock('gtk-cdrom');
        $t_mbtn_optical->set_label('Optical');
            
            #the UIManager created an Gtk2::ImageMenuItem, we extract it and
            #use its 'get_submenu' to get its attached menu widget :)
            my $menu_item = $uimanager->get_widget('/MenuBar/Media/media_optical');
        $t_mbtn_optical->set_menu ($menu_item->get_submenu);
                                
    $toolbar->insert($t_mbtn_optical,0);
    $toolbar->insert(Gtk2::SeparatorToolItem->new,1);
#===========================================================
    
$vbox->pack_start($toolbar,FALSE,FALSE,0);

    my $h_bb = Gtk2::HButtonBox->new;
    $h_bb->set_layout('edge');
    
        my $cb_sensitive = Gtk2::CheckButton->new('CD Sensitive');
        $cb_sensitive->set_active(TRUE);
        $cb_sensitive->signal_connect('toggled' =>sub{
            #sets the sensitivity of the CD menus
            $actions_media_cd->set_sensitive($cb_sensitive->get_active);
        });
        
    $h_bb->pack_start_defaults($cb_sensitive);
    
        my $cb_visible = Gtk2::CheckButton->new('CD Visible');
        $cb_visible->set_active(TRUE);
        $cb_visible->signal_connect('toggled' =>sub{
            #set the visibility of the CD menus
            $actions_media_cd->set_visible($cb_visible->get_active);
        });
        
    $h_bb->pack_start_defaults($cb_visible);
    
        my $cb_dvd = Gtk2::CheckButton->new('Add a DVD Writer');
        $cb_dvd->signal_connect('toggled' =>sub {
        #this will add or remove the DVD ui descriptions
        #it returns a number greater than 0 if successful
            if ($merge_flag){
                $uimanager->remove_ui($merge_flag);
                $merge_flag = 0;
            }else{
                $merge_flag = $uimanager->add_ui_from_string ($ui_dvd);
            }
        });
        
    $h_bb->pack_start_defaults($cb_dvd);

$vbox->pack_end($h_bb,FALSE,FALSE,0);   
$vbox->show_all();
return $vbox;
}
