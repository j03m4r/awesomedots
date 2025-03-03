-- local awful = require("awful")
-- local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
beautiful.init("/home/joemar/.config/awesome/default/theme.lua")

local photo_display = {}

-- Function to show an image
function photo_display.show_image(image_path, x, y, width, height)
    -- local image_widget = wibox({
    --     ontop = false,    -- Make it part of the desktop
    --     visible = true,
    --     bg = "#00000000", -- Transparent background
    --     border_width = 2,
    --     border_color = "#ffffff00",
    -- })


    local image_widget = wibox.widget {
        {
            {
                image         = image_path,
                forced_height = height,
                forced_width  = width,
                resize        = true,
                widget        = wibox.widget.imagebox
            },
            widget = wibox.container.place
        },
        widget = wibox.container.background
    }

    -- Setup geometry and content
    -- image_widget:geometry({
    --     x = x,
    --     y = y,
    --     width = width,
    --     height = height,
    -- })

    return image_widget
end

return photo_display
