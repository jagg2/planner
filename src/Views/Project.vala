public class Views.Project : Gtk.EventBox {
    public Objects.Project project { get; construct; }

    private Gtk.TextView note_textview;
    private Gtk.Label note_placeholder;

    private Gtk.ListBox listbox;
    private Gtk.ListBox section_listbox;
    private Widgets.NewItem new_item_widget;
    private Gtk.Revealer motion_revealer;

    private const Gtk.TargetEntry[] targetEntries = {
        {"ITEMROW", Gtk.TargetFlags.SAME_APP, 0}
    };

    public Project (Objects.Project project) {
        Object (
            project: project
        );
    }

    construct {
        var edit_button = new Gtk.Button.from_icon_name ("edit-symbolic", Gtk.IconSize.MENU);
        edit_button.valign = Gtk.Align.CENTER;
        edit_button.valign = Gtk.Align.CENTER;
        edit_button.can_focus = false;
        edit_button.margin_start = 6;
        edit_button.get_style_context ().add_class ("flat");
        edit_button.get_style_context ().add_class ("dim-label");
        
        var edit_revealer = new Gtk.Revealer ();
        edit_revealer.transition_type = Gtk.RevealerTransitionType.CROSSFADE;
        edit_revealer.add (edit_button);
        edit_revealer.reveal_child = false;

        var grid_color = new Gtk.Grid ();
        grid_color.set_size_request (16, 16);
        grid_color.valign = Gtk.Align.CENTER;
        grid_color.halign = Gtk.Align.CENTER;
        grid_color.get_style_context ().add_class ("project-%s".printf (project.id.to_string ()));

        var name_label = new Gtk.Label (project.name);
        //name_label.margin_start = 3;
        name_label.get_style_context ().add_class (Granite.STYLE_CLASS_H2_LABEL);
        name_label.get_style_context ().add_class ("font-bold");
        name_label.use_markup = true;

        var settings_popover = new Widgets.Popovers.ProjectSettings ();

        var add_button = new Gtk.Button.from_icon_name ("list-add-symbolic", Gtk.IconSize.MENU);
        add_button.valign = Gtk.Align.CENTER;
        add_button.valign = Gtk.Align.CENTER;
        add_button.tooltip_text = _("Add Task");
        add_button.can_focus = false;
        add_button.margin_start = 6;
        add_button.get_style_context ().add_class ("magic-button");
        add_button.get_style_context ().add_class ("suggested-action");

        var section_image = new Gtk.Image ();
        section_image.gicon = new ThemedIcon ("planner-header-symbolic");
        section_image.pixel_size = 21;

        var section_button = new Gtk.Button ();
        section_button.valign = Gtk.Align.CENTER;
        section_button.valign = Gtk.Align.CENTER;
        section_button.tooltip_text = _("Add Section");
        section_button.can_focus = false;
        section_button.margin_start = 6;
        section_button.get_style_context ().add_class ("flat");
        section_button.add (section_image);

        var add_person_button = new Gtk.Button.from_icon_name ("contact-new-symbolic", Gtk.IconSize.MENU);
        add_person_button.valign = Gtk.Align.CENTER;
        add_person_button.valign = Gtk.Align.CENTER;
        add_person_button.tooltip_text = _("Invite Person");
        add_person_button.can_focus = false;
        add_person_button.margin_start = 6;
        add_person_button.get_style_context ().add_class ("flat");
        //add_person_button.get_style_context ().add_class ("dim-label");

        var comment_button = new Gtk.Button.from_icon_name ("internet-chat-symbolic", Gtk.IconSize.MENU);
        comment_button.valign = Gtk.Align.CENTER;
        comment_button.valign = Gtk.Align.CENTER;
        comment_button.can_focus = false;
        comment_button.tooltip_text = _("Project Comments");
        comment_button.margin_start = 6;
        comment_button.get_style_context ().add_class ("flat");
        //comment_button.get_style_context ().add_class ("dim-label");

        var settings_button = new Gtk.MenuButton ();
        settings_button.can_focus = false;
        settings_button.valign = Gtk.Align.CENTER;
        settings_button.tooltip_text = _("More");
        settings_button.popover = settings_popover;
        settings_button.image = new Gtk.Image.from_icon_name ("view-more-symbolic", Gtk.IconSize.MENU);
        settings_button.get_style_context ().add_class (Gtk.STYLE_CLASS_FLAT);
        //settings_button.get_style_context ().add_class (Gtk.STYLE_CLASS_DIM_LABEL);

        var top_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 5);
        top_box.hexpand = true;
        top_box.valign = Gtk.Align.START;
        top_box.margin_end = 24;

        top_box.pack_start (edit_revealer, false, false, 0);
        //top_box.pack_start (grid_color, false, false, 0);
        top_box.pack_start (name_label, false, false, 0);
        
        top_box.pack_end (settings_button, false, false, 0);
        top_box.pack_end (add_person_button, false, false, 0);
        top_box.pack_end (comment_button, false, false, 0);
        top_box.pack_end (section_button, false, false, 0);
        
        var top_eventbox = new Gtk.EventBox ();
        top_eventbox.add_events (Gdk.EventMask.ENTER_NOTIFY_MASK | Gdk.EventMask.LEAVE_NOTIFY_MASK);
        top_eventbox.hexpand = true;
        top_eventbox.add (top_box);

        note_textview = new Gtk.TextView ();
        note_textview.hexpand = true;
        note_textview.margin_top = 6;
        note_textview.height_request = 24;
        note_textview.wrap_mode = Gtk.WrapMode.WORD;
        note_textview.get_style_context ().add_class ("project-textview");
        note_textview.get_style_context ().add_class ("welcome");
        note_textview.margin_start = 42;

        note_placeholder = new Gtk.Label (_("Add note"));
        note_placeholder.opacity = 0.7;
        note_textview.add (note_placeholder);
        
        note_textview.buffer.text = project.note;

        if (project.note != "") {
            note_placeholder.visible = false;
            note_placeholder.no_show_all = true;
        } else {
            note_placeholder.visible = true;
            note_placeholder.no_show_all = false;
        }

        listbox = new Gtk.ListBox  ();
        listbox.margin_top = 6;
        listbox.valign = Gtk.Align.START;
        listbox.get_style_context ().add_class ("welcome");
        listbox.get_style_context ().add_class ("listbox");
        listbox.activate_on_single_click = true;
        listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        listbox.hexpand = true;

        var motion_grid = new Gtk.Grid ();
        motion_grid.get_style_context ().add_class ("grid-motion");
        motion_grid.height_request = 24;
            
        motion_revealer = new Gtk.Revealer ();
        motion_revealer.transition_type = Gtk.RevealerTransitionType.SLIDE_UP;
        motion_revealer.add (motion_grid);

        bool is_todoist = false;
        if (project.is_todoist == 1) {
            is_todoist = true;
        }

        //new_item_widget = new Widgets.NewItem (project.id, is_todoist);

        section_listbox = new Gtk.ListBox  ();
        section_listbox.margin_top = 6;
        section_listbox.valign = Gtk.Align.START;
        section_listbox.get_style_context ().add_class ("welcome");
        section_listbox.get_style_context ().add_class ("listbox");
        section_listbox.activate_on_single_click = true;
        section_listbox.selection_mode = Gtk.SelectionMode.SINGLE;
        section_listbox.hexpand = true;
        
        var main_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        main_box.expand = true;
        main_box.pack_start (top_eventbox, false, false, 0);
        main_box.pack_start (note_textview, false, true, 0);
        main_box.pack_start (listbox, false, false, 0);
        main_box.pack_start (section_listbox, false, false, 0);
        main_box.pack_start (motion_revealer, false, false, 0);
        
        var main_scrolled = new Gtk.ScrolledWindow (null, null);
        main_scrolled.hscrollbar_policy = Gtk.PolicyType.NEVER;
        main_scrolled.width_request = 246;
        main_scrolled.expand = true;
        main_scrolled.add (main_box);

        add (main_scrolled);

        build_drag_and_drop (false);

        add_all_projects ();
        add_all_sections ();
        
        show_all ();

        listbox.row_activated.connect ((row) => {
            var item = ((Widgets.ItemRow) row);
            item.reveal_child = true;
        });

        top_eventbox.enter_notify_event.connect ((event) => {
            edit_revealer.reveal_child = true;

            return true;
        });

        top_eventbox.leave_notify_event.connect ((event) => {
            if (event.detail == Gdk.NotifyType.INFERIOR) {
                return false;
            }
            
            edit_revealer.reveal_child = false;

            return true;
        });

        top_eventbox.event.connect ((event) => {
            if (event.type == Gdk.EventType.@2BUTTON_PRESS) {
                var edit_dialog = new Dialogs.ProjectSettings (project);
                edit_dialog.destroy.connect (Gtk.main_quit);
                edit_dialog.show_all ();
            }

            return false;
        });

        edit_button.clicked.connect (() => {
            if (project != null) {
                var edit_dialog = new Dialogs.ProjectSettings (project);
                edit_dialog.destroy.connect (Gtk.main_quit);
                edit_dialog.show_all ();
            }
        });

        note_textview.focus_in_event.connect (() => {
            note_placeholder.visible = false;
            note_placeholder.no_show_all = true;

            return false;
        });

        note_textview.focus_out_event.connect (() => {
            if (note_textview.buffer.text == "") {
                note_placeholder.visible = true;
                note_placeholder.no_show_all = false;
            }

            return false;
        });

        note_textview.buffer.changed.connect (() => {
            save ();
        });

        section_button.clicked.connect (() => {
            var section = new Objects.Section ();
            section.name = _("New Header");
            section.project_id = project.id;

            if (Application.database.insert_section (section)) {

            }
        });

        Application.database.project_updated.connect ((p) => {
            if (project != null && p.id == project.id) {
                project = p;
                name_label.label = project.name;
            }
        });

        Application.database.section_added.connect ((section) => {
            if (project.id == section.project_id) {
                var row = new Widgets.SectionRow (section, project.is_todoist);
                section_listbox.add (row);
                section_listbox.show_all ();

                row.set_focus = true;
            }
        });

        Application.database.item_added.connect ((item) => {
            if (project.id == item.project_id && item.section_id == 0 && item.parent_id == 0) {
                var row = new Widgets.ItemRow (item);
                listbox.add (row);
                listbox.show_all ();
            }
        });

        Application.database.item_added_with_index.connect ((item, index) => {
            if (project.id == item.project_id && item.section_id == 0) {
                var row = new Widgets.ItemRow (item);
                listbox.insert (row, index);
                listbox.show_all ();
            }
        });

        Application.utils.magic_button_activated.connect ((project_id, section_id, is_todoist, last, index) => {
            if (project.id == project_id && section_id == 0) {
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
    }

    private void save () {
        if (project != null) {
            project.note = note_textview.buffer.text;
            project.save (); 
        }
    }

    private void add_all_projects () {
        foreach (var item in Application.database.get_all_items_by_project_no_section_no_parent (project.id)) {
            var row = new Widgets.ItemRow (item);
            listbox.add (row);
            listbox.show_all ();
        }
    }

    private void add_all_sections () {
        foreach (var section in Application.database.get_all_sections_by_project (project.id)) {
            var row = new Widgets.SectionRow (section, project.is_todoist);
            section_listbox.add (row);
            section_listbox.show_all ();
        }
    }

    private void build_drag_and_drop (bool is_magic_button_active) {
        Gtk.drag_dest_set (listbox, Gtk.DestDefaults.ALL, targetEntries, Gdk.DragAction.MOVE);
        listbox.drag_data_received.connect (on_drag_data_received);

        /*
        Gtk.drag_dest_set (name_entry, Gtk.DestDefaults.ALL, targetEntries, Gdk.DragAction.MOVE);
        name_entry.drag_data_received.connect (on_drag_item_received);
        name_entry.drag_motion.connect (on_drag_motion);
        name_entry.drag_leave.connect (on_drag_leave);
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
            source.get_parent ().remove (source); 

            source.item.section_id = 0;

            listbox.insert (source, target.get_index () + 1);
            listbox.show_all ();

            update_item_order ();
        }
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

    /*
    private void on_drag_item_received (Gdk.DragContext context, int x, int y, Gtk.SelectionData selection_data, uint target_type, uint time) {
        Widgets.ItemRow source;
        var row = ((Gtk.Widget[]) selection_data.get_data ())[0];
        source = (Widgets.ItemRow) row;

        source.get_parent ().remove (source); 
        listbox.insert (source, (int) listbox.get_children ().length);
        listbox.show_all ();
    
        update_item_order ();
    }

    public bool on_drag_motion (Gdk.DragContext context, int x, int y, uint time) {
        motion_revealer.reveal_child = true;
        return true;
    }

    public void on_drag_leave (Gdk.DragContext context, uint time) {
        motion_revealer.reveal_child = false;
    }
    */
}