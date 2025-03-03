-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Custom widgets
local spotify_widget = require("widgets.SpotifyWidget")
local create_taglist = require("widgets.TagListWidget")
local create_systemdata_widget = require("widgets.SystemDataWidget")
local logout_menu_m = require("widgets.LogoutMenuWidget.logout-menu")
local open_logout_menu = logout_menu_m.openPopup

-- Brightness state for xrandr
local brightness = 0.75

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init("/home/joemar/.config/awesome/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "vi"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.floating,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    { "restart", awesome.restart },
    { "quit",    function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = myawesomemenu })

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})
-- }}}

-- {{{ Wibar
awful.screen.connect_for_each_screen(function(s)
    local taglist = create_taglist(s)
    local systemdata = create_systemdata_widget(s)

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s, height = beautiful.wibox_height })

    -- Add widgets to the wibox
    s.mywibox:setup {
        {     -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            taglist
        },
        {     -- Middle widget (centered)
            layout = wibox.layout.flex.horizontal,
            systemdata,
        },
        {     -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            spotify_widget
        },
        layout = wibox.layout.align.horizontal,
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() open_logout_menu() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey, }, "s", hotkeys_popup.show_help,
        { description = "show help", group = "awesome" }),
    awful.key({ modkey, }, "Left", awful.tag.viewprev,
        { description = "view previous", group = "tag" }),
    awful.key({ modkey, }, "Right", awful.tag.viewnext,
        { description = "view next", group = "tag" }),
    awful.key({ modkey, }, "Escape", awful.tag.history.restore,
        { description = "go back", group = "tag" }),

    awful.key({ modkey, }, "j",
        function()
            awful.client.focus.byidx(1)
        end,
        { description = "focus next by index", group = "client" }
    ),
    awful.key({ modkey, }, "k",
        function()
            awful.client.focus.byidx(-1)
        end,
        { description = "focus previous by index", group = "client" }
    ),
    awful.key({ modkey, }, "w", function() open_logout_menu() end,
        { description = "show main menu", group = "awesome" }),
    awful.key({modkey, }, "i", function() awful.spawn.with_shell("iwmenu -m rofi") end,
    { description = "show wifi menu", group = "client"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),
    awful.key({ modkey, "Control" }, "j", function() awful.screen.focus_relative(1) end,
        { description = "focus the next screen", group = "screen" }),
    awful.key({ modkey, "Control" }, "k", function() awful.screen.focus_relative(-1) end,
        { description = "focus the previous screen", group = "screen" }),
    awful.key({ modkey, }, "u", awful.client.urgent.jumpto,
        { description = "jump to urgent client", group = "client" }),
    awful.key({ modkey, }, "Tab",
        function()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        { description = "go back", group = "client" }),

    -- Standard program
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "open a terminal", group = "launcher" }),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),
    awful.key({ modkey, "Shift" }, "q", awesome.quit,
        { description = "quit awesome", group = "awesome" }),
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),
    awful.key({ modkey, "Shift" }, "h", function() awful.tag.incnmaster(1, nil, true) end,
        { description = "increase the number of master clients", group = "layout" }),
    awful.key({ modkey, "Shift" }, "l", function() awful.tag.incnmaster(-1, nil, true) end,
        { description = "decrease the number of master clients", group = "layout" }),
    awful.key({ modkey, "Control" }, "h", function() awful.tag.incncol(1, nil, true) end,
        { description = "increase the number of columns", group = "layout" }),
    awful.key({ modkey, "Control" }, "l", function() awful.tag.incncol(-1, nil, true) end,
        { description = "decrease the number of columns", group = "layout" }),
    awful.key({ modkey, }, "space", function() awful.layout.inc(1) end,
        { description = "select next", group = "layout" }),
    awful.key({ modkey, "Shift" }, "space", function() awful.layout.inc(-1) end,
        { description = "select previous", group = "layout" }),

    awful.key({ modkey, "Control" }, "n",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Volume widget controls
    awful.key({}, "XF86AudioRaiseVolume", function()
        awful.spawn.with_shell("amixer set Master 9%+")
    end),
    awful.key({}, "XF86AudioLowerVolume", function()
        awful.spawn.with_shell("amixer set Master 9%-")
    end),
    awful.key({}, "XF86AudioMute", function()
        awful.spawn.with_shell("amixer sset Master toggle")
    end),

    -- Prompt
    awful.key({ modkey }, "r", function() awful.spawn.with_shell("~/.config/rofi/scripts/launcher_t4") end,
        { description = "run prompt", group = "launcher" }),

    -- Screenshot keybindings
    awful.key({}, "Print", function() awful.spawn.with_shell("scrot ~/Pictures/screenshot_%Y-%m-%d-%H-%M-%S.png") end,
        { description = "take a screenshot", group = "screenshot" }),
    awful.key({ "Shift" }, "Print",
        function() awful.spawn.with_shell("scrot -s ~/Pictures/screenshot_%Y-%m-%d-%H%M%S.png") end,
        { description = "take a screenshot of selected area", group = "custom" }),
    -- Increase brightness
    awful.key({ modkey }, ";", function()
        brightness = math.min(brightness + 0.05, 1.0) -- Limit to 1.0 max
        awful.spawn.with_shell("xrandr --output eDP-1 --brightness " .. brightness)
    end, { description = "increase brightness", group = "custom" }),

    -- Decrease brightness
    awful.key({ modkey, "Shift" }, ";", function()
        brightness = math.max(brightness - 0.05, 0.1) -- Limit to 0.1 min
        awful.spawn.with_shell("xrandr --output eDP-1 --brightness " .. brightness)
    end, { description = "decrease brightness", group = "custom" }),
    awful.key({ modkey }, "d",
        function() awful.spawn.with_shell("bash /home/joemar/.config/awesome/scripts/configureDoubleDisplay.sh") end),
    awful.key({ modkey, "Shift" }, "d",
        function() awful.spawn.with_shell("bash /home/joemar/.config/awesome/scripts/configureSingleDisplay.sh") end)



-- awful.key({ modkey }, "x",
--           function ()
--               awful.prompt.run {
--                 prompt       = "Run Lua code: ",
--                 textbox      = awful.screen.focused().mypromptbox.widget,
--                 exe_callback = awful.util.eval,
--                 history_path = awful.util.get_cache_dir() .. "/history_eval"
--               }
--           end,
--           {description = "lua execute prompt", group = "awesome"}),
-- Menubar
-- awful.key({ modkey }, "p", function() menubar.show() end,
--  { description = "show the menubar", group = "launcher" })
)

clientkeys = gears.table.join(
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),
    awful.key({ modkey, "Shift" }, "c", function(c) c:kill() end,
        { description = "close", group = "client" }),
    awful.key({ modkey, "Control" }, "space", awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }),
    awful.key({ modkey, "Control" }, "Return", function(c) c:swap(awful.client.getmaster()) end,
        { description = "move to master", group = "client" }),
    awful.key({ modkey, }, "o", function(c) c:move_to_screen() end,
        { description = "move to screen", group = "client" }),
    awful.key({ modkey, }, "t", function(c) c.ontop = not c.ontop end,
        { description = "toggle keep on top", group = "client" }),
    awful.key({ modkey, }, "n",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),
    awful.key({ modkey, }, "m",
        function(c)
            c.maximized = not c.maximized
            c:raise()
        end,
        { description = "(un)maximize", group = "client" }),
    awful.key({ modkey, "Control" }, "m",
        function(c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end,
        { description = "(un)maximize vertically", group = "client" }),
    awful.key({ modkey, "Shift" }, "m",
        function(c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end,
        { description = "(un)maximize horizontally", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey, "Shift" }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen
        }
    },

    -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA",   -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry",
            },
            class = {
                "Arandr",
                "Blueman-manager",
                "Gpick",
                "Kruler",
                "MessageWin",  -- kalarm.
                "Sxiv",
                "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui",
                "veromix",
                "xtightvncviewer" },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester", -- xev.
            },
            role = {
                "AlarmWindow",   -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = { type = { "normal", "dialog" }
        },
        properties = { titlebars_enabled = false }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({}, 1, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.move(c)
        end),
        awful.button({}, 3, function()
            c:emit_signal("request::activate", "titlebar", { raise = true })
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c):setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        {     -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", {raise = false})
-- end)
--
-- client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
-- client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- Define the function to spawn an application
local function spawn_application(cmd, x, y, width, height, tag_name)
    awful.spawn(cmd, {
        tag = tag_name,
        x = x,
        y = y,
        width = width,
        height = height,
        callback = function(c)
            -- Move the client to the specified tag
            local tag = awful.tag.find_by_name(c.screen, tag_name)
            if tag then
                awful.client.movetotag(tag, c)
            end
        end
    })
end

-- Background / Wallpaper
awful.spawn.with_shell("nitrogen --restore")

-- Auto launch applications
awful.spawn.with_shell("picom")

-- Spawn usable applications
spawn_application("pavucontrol", 600, 50, 1000, 1000, "4")
spawn_application("blueman-manager", 50, 50, 500, 500, "4")

local function show_image_with_feh(image_path)
    awful.spawn.with_shell(string.format([[
        resized_image=$(mktemp --suffix=.png) &&
        convert %s -resize 15%% "$resized_image" &&
        feh --auto-zoom --image-bg black "$resized_image" &&
        rm "$resized_image"
    ]], image_path))
end

local gallery_images = {"/home/joemar/Downloads/hard_eiffel_pic_w_tommy.png", "/home/joemar/Downloads/gran_via.png", "/home/joemar/Downloads/tommy_missing_the_point.png", "/home/joemar/Downloads/intruso.png",
                        "/home/joemar/Downloads/blurry_bern.png", "/home/joemar/Downloads/malachi_with_kitty.png", "/home/joemar/Downloads/toledo_street_view.png", "/home/joemar/Downloads/tirso_de_molina_flowers.png",
                        "/home/joemar/Downloads/tommy_plus_grass.png", "/home/joemar/Downloads/happy_gang.png", "/home/joemar/Downloads/madrid_stone_wall.png", "/home/joemar/Downloads/barcelona_building.png",
                        "/home/joemar/Downloads/wabbo_banana.png", "/home/joemar/Downloads/joe_and_jimbus.png", "/home/joemar/Downloads/state_park.png", "/home/joemar/Downloads/mn_state_fair_work_friends.png",
                        "/home/joemar/Downloads/scary_john_and_i.png", "/home/joemar/Downloads/mom_and_dad_yay.png", "/home/joemar/Downloads/red_tree.png", "/home/joemar/Downloads/papa_and_i.png",
                        "/home/joemar/Downloads/pretty_madrid_buildings.png", "/home/joemar/Downloads/me_at_eiffel.png", "/home/joemar/Downloads/bern_people.png", "/home/joemar/Downloads/cute_tucker.png",
                        "/home/joemar/Downloads/me_in_street.png", "/home/joemar/Downloads/green_italian_steps.png", "/home/joemar/Downloads/beautiful_italy_town.png"}

local img_idx_0 = math.random(27)
local img_idx_1 = math.random(27)
while img_idx_0==img_idx_1 do
    img_idx_1 = math.random(27)
end
local img_idx_2 = math.random(27)
while (img_idx_0==img_idx_2) or (img_idx_1==img_idx_2) do
    img_idx_2 = math.random(27)
end
show_image_with_feh(gallery_images[img_idx_0])
show_image_with_feh(gallery_images[img_idx_1])
show_image_with_feh(gallery_images[img_idx_2])

-- spawn_application("kitty cbonsai --live", 100, 300, 500, 500, "1")
-- spawn_application("kitty tclock", 700, 100, 1000, 500, "1")
-- spawn_application("kitty bash -c 'curl us.getnews.tech; read -p \"Press <CTRL-C> to close...\"'", 700, 100, 750, 500, "1")
