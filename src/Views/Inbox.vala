public class Views.Inbox : Gtk.EventBox {
    private Gtk.ListBox listbox;
    private int64 project_id;
    private bool is_todoist;

    private Gtk.Revealer motion_revealer;
    private const Gtk.TargetEntry[] targetEntries = {
        {"ITEMROW", Gtk.TargetFlags.SAME_APP, 0}
    };

    construct {
        project_id = Application.settings.get_int64 ("inbox-project");
        is_todoist = Application.settings.get_boolean ("inbox-project-sync");

        var icon_image = new Gtk.Image ();
        icon_image.valign = Gtk.Align.CENTER;
        icon_image.gicon = new ThemedIcon ("mail-mailbox-symbolic");
        icon_image.get_style_context ().add_class ("inbox-icon");
        icon_image.pixel_size = 21;

        var title_label = new Gtk.Label ("<b>%s</b>".printf (_("Inbox")));
        title_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        title_label.use_markup = true;
 
        var settings_button = new Gtk.MenuButton ();
        settings_button.valign = Gtk.Align.CENTER;
        //settings_button.tooltip_text = _("Edit Name and Appearance");
        //settings_button.popover = list_settings_popover;
        settings_button.image = new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.MENU);
        settings_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        settings_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 6);
        top_box.hexpand = true;
        top_box.valign = Gtk.Align.START;
        top_box.margin_start = 41;
        top_box.margin_end = 24; 

        top_box.pack_start (icon_image, false, false, 0);
        top_box.pack_start (title_label, false, false, 0);
        top_box.pack_end (settings_button, false, false, 0);

        listbox = new Gtk.ListBox  ();
        listbox.valign = Gtk.Align.START;
        listbox.margin_top = 12;
        listbox.get_style_context ().add_class ("welcome");
        listbox.get_style_context ().add_class ("listbox");
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        listbox.hexpand = true;

        var placeholder_image = new Gtk.Image ();
        placeholder_image.margin_bottom = 96;
        placeholder_image.expand = true;
        placeholder_image.valign = Gtk.Align.CENTER;
        placeholder_image.halign = Gtk.Align.CENTER;
        placeholder_image.gicon = new ThemedIcon ("mail-mailbox-symbolic");
        placeholder_image.pixel_size = 96;
        placeholder_image.opacity = 0.3;

        var stack = new Gtk.Stack ();
        stack.hexpand = true;
        stack.transition_type = Gtk.StackTransitionType.CROSSFADE;

        //stack.add_named (listbox, "listbox");
        stack.add_named (placeholder_image, "placeholder");
        
        var motion_grid = new Gtk.Grid ();
        motion_grid.get_style_context ().add_class ("grid-motion");
        motion_grid.height_request = 24;
            
        motion_revealer = new Gtk.Revealer ();
        motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_DOWN;
        motion_revealer.add (motion_grid);

        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (top_box, false, false, 0);
        main_box.pack_start (listbox, false, false, 0);
        
        var main_scrolled = new Gtk.ScrolledWindow (null, null);
        main_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        main_scrolled.width_request = 246;
        main_scrolled.expand = true;
        main_scrolled.add (main_box);

        add (main_scrolled);
        add_all_projects (project_id);
        build_drag_and_drop ();

        listbox.row_activated.connect ((row) => {
            var item = ((Widgets.ItemRow) row);
            item.reveal_child = true;
        });

        Application.database.item_added.connect ((item) => {
            if (project_id == item.project_id && item.section_id == 0 && item.parent_id == 0) {
                var row = new Widgets.ItemRow (item);
                listbox.add (row);
                listbox.show_all ();
            }
        });

        Application.database.item_added_with_index.connect ((item, index) => {
            if (project_id == item.project_id && item.section_id == 0 && item.parent_id == 0) {
                var row = new Widgets.ItemRow (item);
                listbox.insert (row, index);
                listbox.show_all ();
            }
        });

        Application.utils.magic_button_activated.connect ((id, section_id, is_todoist, last, index) => {
            if (project_id == id && section_id == 0) {
                var new_item = new Widgets.NewItem (
                    project_id,
                    section_id, 
                    is_todoist
                );

                if (last) {
                    listbox.add (new_item);
                } else {
                    new_item.index = index;
                    listbox.insert (new_item, index);
                }

                listbox.show_all ();
            }
        });

        Application.settings.changed.connect (key => {
            if (key == "inbox-project") {
                project_id = Application.settings.get_int64 ("inbox-project");
                add_all_projects (project_id);
            } else if (key == "inbox-project-sync") {
                is_todoist = Application.settings.get_boolean ("inbox-project-sync");
            }
        });
    }

    public void add_new_item () {
        
    }

    private void add_all_projects (int64 id) { 
        foreach (var item in Application.database.get_all_items_by_project_no_section_no_parent (id)) {
            var row = new Widgets.ItemRow (item);
            listbox.add (row);
            listbox.show_all ();
        }
    }

    private void build_drag_and_drop () {
        Gtk.drag_dest_set (listbox, Gtk.DestDefaults.ALL, targetEntries, Gdk.DragAction.MOVE);
        listbox.drag_data_received.connect (on_drag_data_received);

        /*
        Gtk.drag_dest_set (new_item_widget, Gtk.DestDefaults.ALL, targetEntries, Gdk.DragAction.MOVE);
        new_item_widget.drag_motion.connect (on_drag_motion);
        new_item_widget.drag_leave.connect (on_drag_leave);
        new_item_widget.drag_data_received.connect (on_drag_item_received);
        */
    }

    private void on_drag_data_received (Gdk.DragContext context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time) {
        Widgets.ItemRow target;
        Widgets.ItemRow source;
        Gtk.Allocation alloc;

        target = (Widgets.ItemRow) listbox.get_row_at_y (y);
        target.get_allocation (out alloc);
        
        var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
        source = (Widgets.ItemRow) row;

        if (target != null) {        
            if (target.get_index () != source.get_index ()) {
                source.get_parent ().remove (source); 
                listbox.insert (source, target.get_index ());
                listbox.show_all ();

                //update_item_order ();
            }   
        } else {
            source.get_parent ().remove (source); 
            listbox.insert (source, (int) listbox.get_children ().length);
            listbox.show_all ();
    
            //update_item_order ();
        }
    }

    private void on_drag_item_received (Gdk.DragContext context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time) {
        Widgets.ItemRow source;
        var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
        source = (Widgets.ItemRow) row;

        source.get_parent ().remove (source); 
        listbox.insert (source, (int) listbox.get_children ().length);
        listbox.show_all ();
    
        //update_item_order ();
    }

    public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
        motion_revealer.reveal_child = true;
        return true;
    }

    public void on_drag_leave (Gdk.DragContext context, uint time) {
        motion_revealer.reveal_child = false;
    }

    private void update_item_order () {
        listbox.foreach ((widget) => {
            var row = (Gtk.ListBoxRow) widget;
            int index = row.get_index ();

            var item = ((Widgets.ItemRow) row).item;

            new Thread<void*> ("update_item_order", () => {
                Application.database.update_item_order (item.id, 0, index);

                return null;
            });
        });
    }
}