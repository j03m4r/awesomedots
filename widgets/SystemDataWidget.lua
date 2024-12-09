local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init("/home/joemar/.config/awesome/default/theme.lua")
local logout_menu_m = require("widgets.LogoutMenuWidget.logout-menu")
local logout_menu_widget = logout_menu_m.worker
local lain = require("lain")

-- Battery widget
local mybattery = lain.widget.bat({
    settings = function()
        local bat_header = "🔋 " -- You can replace this with an icon from your theme
        local bat_p = bat_now.perc .. "%"

        if bat_now.ac_status == 1 then
            bat_header = "⚡ " -- Plugged in icon
        end

        -- Color based on battery percentage
        local bat_color = beautiful.fg_normal
        widget:set_markup(string.format('<span color="%s">%s%s</span>', bat_color, bat_header, bat_p))
    end,
    timeout = 10 -- Update every 10 seconds
})

local separator = wibox.widget {
    widget = wibox.widget.separator,
    orientation = "vertical",
    forced_width = 1,
    color = beautiful.fg_normal, -- or any color you prefer
}

local function create_systemdata_widget(s)
    s.systemDataWidget = wibox.widget {
        {
            {
                {
                    wibox.container.constraint(wibox.container.place(mybattery.widget, "center"), "exact", 60),
                    separator,
                    wibox.container.constraint(wibox.container.place(wibox.widget.textclock('%H:%M'), "center"), "exact", 60),
                    separator,
                    wibox.container.constraint(wibox.container.place(logout_menu_widget(), "center"), "exact", 60),
                    spacing = beautiful.default_margin, -- Space between elements
                    layout = wibox.layout.fixed.horizontal,
                },
                margins = beautiful.default_margin,
                widget = wibox.container.margin,
            },
            shape = beautiful.default_shape,
            bg = beautiful.bg_normal,
            fg = beautiful.fg_normal,
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal,
    }

    return wibox.container.place(wibox.container.margin(s.systemDataWidget, beautiful.wibox_margin, beautiful.wibox_margin, beautiful.wibox_margin / 2, beautiful.wibox_margin / 2), "center")
end

return create_systemdata_widget
