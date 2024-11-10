local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local HOME = os.getenv('HOME')
local ICON_DIR = HOME .. '/.config/awesome/widgets/LogoutMenuWidget/icons/'

local logout_menu_widget = wibox.widget {
    {
        {
            id = "icon_role",
            image = ICON_DIR .. 'power_w.svg',
            resize = true,
            widget = wibox.widget.imagebox,
        },
        margins = 1,
        layout = wibox.container.margin
    },
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 10)
    end,
    widget = wibox.container.background,
}

local popup = awful.popup {
    ontop = true,
    visible = false,
    shape = function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, 4)
    end,
    minimum_width = 400,
    maximum_height = 600,
    placement = awful.placement.centered,
    widget = {}
}

local function closePopup()
    popup.visible = false
    logout_menu_widget:get_children_by_id("icon_role")[1].image = gears.color.recolor_image(ICON_DIR .. 'power_w.svg',
        beautiful.fg_normal)
end

local function openPopup()
    popup.visible = true
    logout_menu_widget:get_children_by_id("icon_role")[1].image = gears.color.recolor_image(ICON_DIR .. 'power_w.svg',
        beautiful.fg_focus)
end

local function worker(user_args)
    local rows = { layout = wibox.layout.fixed.vertical }

    local args = user_args or {}
    local font = args.font or beautiful.font
    local onlogout = args.onlogout or function() awesome.quit() end
    local onreboot = args.onreboot or function() awful.spawn.with_shell("reboot") end

    local menu_items = {
        { name = 'Log out',    icon_name = 'log-out.svg',               command = onlogout },
        { name = 'Reboot',     icon_name = 'refresh-cw.svg',            command = onreboot },
        { name = 'Close menu', icon_name = 'window-close-symbolic.svg', command = closePopup },
    }

    for _, item in ipairs(menu_items) do
        local icon_path = ICON_DIR .. item.icon_name
        local row = wibox.widget {
            {
                {
                    {
                        id = "icon_role",
                        image = icon_path,
                        resize = false,
                        widget = wibox.widget.imagebox
                    },
                    {
                        text = item.name,
                        font = font,
                        widget = wibox.widget.textbox
                    },
                    spacing = 12,
                    layout = wibox.layout.fixed.horizontal
                },
                margins = 10,
                layout = wibox.container.margin
            },
            bg = beautiful.bg_normal,
            shape = function(cr, width, height) gears.shape.rounded_rect(cr, width, height, 4) end,
            widget = wibox.container.background
        }

        row:connect_signal("mouse::enter", function(c)
            c:set_bg(beautiful.bg_focus)
            c:set_fg(beautiful.bg_normal)
            c:get_children_by_id("icon_role")[1].image = gears.color.recolor_image(icon_path, beautiful.bg_normal)
        end)

        row:connect_signal("mouse::leave", function(c)
            c:set_bg(beautiful.bg_normal)
            c:set_fg(beautiful.fg_normal)
            c:get_children_by_id("icon_role")[1].image = icon_path
        end)

        row:buttons(awful.util.table.join(awful.button({}, 1, function()
            popup.visible = not popup.visible
            item.command()
        end)))

        table.insert(rows, {
            row,
            margins = 2,
            layout = wibox.container.margin
        })
    end

    popup:setup {
        {
            rows,
            margins = 10,
            layout = wibox.container.margin,
        },
        bg = beautiful.bg_normal,
        widget = wibox.container.background
    }

    logout_menu_widget:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                if popup.visible then
                logout_menu_widget:get_children_by_id("icon_role")[1].image = gears.color.recolor_image(
                    ICON_DIR .. 'power_w.svg', beautiful.fg_normal)
                else
                logout_menu_widget:get_children_by_id("icon_role")[1].image = gears.color.recolor_image(
                    ICON_DIR .. 'power_w.svg', beautiful.fg_focus)
                end
                popup.visible = not popup.visible
            end)
        )
    )

    return logout_menu_widget
end

return { worker = worker, openPopup = openPopup }

