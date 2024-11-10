local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init("/home/joemar/.config/awesome/default/theme.lua")

local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local function create_taglist(s)
    local names = { "1", "2", "3", "4" }
    local l = awful.layout.suit
    local layouts = { l.floating, l.tile, l.tile, l.floating }
    awful.tag(names, s, layouts)

    s.mytaglist = awful.widget.taglist {
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        widget_template = {
            {
                {
                    {
                        {
                            {
                                id     = 'index_role',
                                widget = wibox.widget.textbox,
                            },
                            margins = 4,
                            widget  = wibox.container.margin,
                        },
                        id     = "shape_role",
                        bg     = beautiful.bg_normal,
                        shape  = gears.shape.rounded_rect,
                        widget = wibox.container.background,
                    },
                    valign = "center",
                    halign = "center",
                    widget = wibox.container.place,
                },
                widget = wibox.container.margin,
            },
            id              = 'background_role',
            widget          = wibox.container.background,
            create_callback = function(_, _, _, _)
            end,
            update_callback = function(self, c3, index, _)
                self:get_children_by_id('index_role')[1].markup = '<b> ' .. index .. ' </b>'

                if c3.selected then
                    self:get_children_by_id('shape_role')[1].bg = beautiful.bg_focus .. "0f"
                    self:get_children_by_id('shape_role')[1].fg = beautiful.fg_focus
                else
                    self:get_children_by_id('shape_role')[1].bg = beautiful.bg_normal
                    self:get_children_by_id('shape_role')[1].fg = beautiful.fg_normal
                end
            end,
        },

        buttons         = taglist_buttons
    }

    s.tagListContainer = wibox.widget {
        {
            {
                s.mytaglist,
                left = beautiful.default_margin,
                right = beautiful.default_margin,
                top = 1,
                bottom = 1,
                widget = wibox.container.margin,
            },
            shape = beautiful.default_shape,
            bg = beautiful.bg_normal,
            widget = wibox.container.background,
        },
        layout = wibox.layout.fixed.horizontal,
    }

    return wibox.container.margin(s.tagListContainer, beautiful.wibox_margin, beautiful.wibox_margin,
        beautiful.wibox_margin / 2, beautiful.wibox_margin / 2)
end

return create_taglist
