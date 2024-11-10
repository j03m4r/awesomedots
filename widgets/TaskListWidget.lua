local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init("/home/joemar/.config/awesome/default/theme.lua")

local tasklist_buttons = gears.table.join(
    awful.button({}, 1, function(c)
        if c == client.focus then
            c.minimized = true
        else
            c:emit_signal(
                "request::activate",
                "tasklist",
                { raise = true }
            )
        end
    end),
    awful.button({}, 3, function()
        awful.menu.client_list({ theme = { width = 250 } })
    end),
    awful.button({}, 4, function()
        awful.client.focus.byidx(1)
    end),
    awful.button({}, 5, function()
        awful.client.focus.byidx(-1)
    end))

local function create_tasklist(s)
    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen          = s,
        filter          = awful.widget.tasklist.filter.currenttags,
        buttons         = tasklist_buttons,
        layout          = {
            spacing        = 20,
            spacing_widget = {
                {
                    forced_width = 5,
                    shape        = gears.shape.circle,
                    widget       = wibox.widget.separator
                },
                valign = 'center',
                halign = 'center',
                widget = wibox.container.place,
            },
            layout         = wibox.layout.flex.horizontal
        },
        widget_template = {
            {
                {
                    {
                        id     = 'icon_role',
                        widget = wibox.widget.imagebox,
                    },
                    margins = beautiful.default_margin,
                    widget  = wibox.container.margin,
                },
                {
                    id = 'text_role',
                    widget = wibox.widget.textbox,
                },
                layout = wibox.layout.fixed.horizontal,
            },
            id                 = 'background_role',
            bg                 = beautiful.bg_normal,
            fg                 = beautiful.fg_normal,
            shape              = beautiful.default_shape,
            shape_border_width = beautiful.default_border_width,
            shape_border_color = beautiful.bg_normal,
            widget             = wibox.container.background
        },
        update_callback = function(self, c, objects)
            -- Update border color based on focus
            for _, item in ipairs(objects) do
                local bg = item:get_children_by_id('background_role')[1]
                if item:tags()[1] == c.focus and c.focus then
                    self.shape_border_color = beautiful.bg_focus
                else
                    self.shape_border_color = beautiful.bg_normal
                end
                bg:emit_signal('widget::redraw_needed')
            end
        end,
    }

    return s.mytasklist
end

return create_tasklist
