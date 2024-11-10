local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
beautiful.init("/home/joemar/.config/awesome/default/theme.lua")

-- Create a widget for Spotify album art with rounded corners
local spotify_widget = wibox.widget {
    {
        {
            {
                id = "image",
                image = gears.filesystem.get_configuration_dir() .. "icons/spotify.png", -- default image
                widget = wibox.widget.imagebox,
            },
            valign = "center",
            widget = wibox.container.place,
        },
        {
            {
                {
                    id = "song_title",
                    text = "Spotify",
                    align = "center",  -- Center the text horizontally
                    widget = wibox.widget.textbox
                },
                left = beautiful.default_margin,
                right = beautiful.default_margin,
                top = beautiful.default_margin / 2,
                bottom = beautiful.default_margin / 2,
                widget = wibox.container.margin,
            },
            forced_width = 100,     -- Adjust as needed
            widget = wibox.container.constraint,
        },
        layout = wibox.layout.fixed.horizontal,
    },
    id     = 'background_role',
    bg     = beautiful.bg_normal,
    fg     = beautiful.fg_normal,
    shape  = beautiful.default_shape,
    widget = wibox.container.background
}

local function truncate_text(text, max_length)
    if #text > max_length then
        return text:sub(1, max_length - 3) .. "..."
    end
    return text
end

-- Function to update the album art
local function update_album_art()
    awful.spawn.easy_async_with_shell(
        "~/.config/awesome/scripts/get_spotify_album_art.sh",
        function(stdout)
            local cover_path = stdout:gsub("%s+", "")
            spotify_widget:get_children_by_id("image")[1].image = gears.surface.load_uncached(cover_path)
        end
    )
    awful.spawn.easy_async_with_shell(
        "playerctl metadata --player=spotify --format '{{ title }}'",
        function(stdout)
            local song_title = stdout:gsub("%s+$", "")
            spotify_widget:get_children_by_id("song_title")[1].text = truncate_text(song_title, 15)
        end
    )
end

-- Update album art every 30 seconds
gears.timer({
    timeout = 30,
    call_now = true,
    autostart = true,
    callback = update_album_art
})

return wibox.container.margin(spotify_widget, beautiful.wibox_margin, beautiful.wibox_margin, beautiful.wibox_margin / 2, beautiful.wibox_margin / 2)
