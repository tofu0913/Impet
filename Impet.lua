_addon.name = 'Impet'
_addon.author = 'Cliff'
_addon.version = '1.0.0'
_addon.commands = {'im'}

require('actions')
require('logger')
local texts = require('texts')
local config = require('config')
require('mylibs/utils')

function setup_text(text)
    text:bg_alpha(255)
    text:bg_visible(true)
    text:font('ＭＳ ゴシック')
    text:size(20)
    text:draggable(false)
    text:bg_visible(false)
    text:color(255,255,255,255)
    text:stroke_alpha(200)
    text:stroke_color(20,20,20)
    text:stroke_width(2)
	text:show()
end
local default_settings = {
	widget = {
		pos = {
			x = 1100,
			y = 400
		}
	},
}
local settings = config.load('data\\settings.xml',default_settings)
local widgets = {}
widgets.hit = texts.new("${text}", settings.widget, default_settings.widget)
widgets.count = texts.new("${text}", settings.widget, default_settings.widget)
setup_text(widgets.hit)
setup_text(widgets.count)
local hit_pos_x = widgets.hit:pos_x()
local hit_pos_y = widgets.hit:pos_y()

local count = 0

function get_combo_color(count)
    if count >= 50 then
        return '\\cs(255,215,0)'
    end

    local t = count / 50          -- 0.0 ~ 0.98
    local r = 255
    local g = math.floor(255 - 40 * t)   -- 255 → 215
    local b = math.floor(255 - 255 * t)  -- 255 → 0

    return string.format('\\cs(%d,%d,%d)', r, g, b)
end

ActionPacket.open_listener(function(act)
	if not hasBuff('インピタス') then
		widgets.count.text = ''
		widgets.hit.text = ''
	else
		local actionpacket = ActionPacket.new(act)
		local category = actionpacket:get_category_string()
		-- log(windower.ffxi.get_mob_by_id(actionpacket:get_id()).name..' '..category..' '..actionpacket:get_targets()():get_actions()():get_message_id())
		if T{'melee','weaponskill_finish'}:contains(category) then
			local actor = actionpacket:get_id()
			if windower.ffxi.get_mob_by_id(actor).name == 'Felicya' then
				local target = actionpacket:get_targets()()
				for action in target:get_actions() do
					local message_id = action:get_message_id()
					if T{15,63,188}:contains(message_id) then
						count = 0
					elseif T{1,67,185}:contains(message_id) then
						count = count + 1--TODO, count ws hits
					end
				end
				if count >= 50 then
					texts.size(widgets.count, 30)
					texts.bold(widgets.count, true)
					widgets.hit:pos(hit_pos_x+(count>99 and 40 or 35), hit_pos_y+22)
					widgets.hit.text = 'HIT!!'
				else
					texts.size(widgets.count, 20)
					texts.bold(widgets.count, false)
					widgets.hit:pos(hit_pos_x+(count<10 and 25 or 30), hit_pos_y)
					widgets.hit.text = 'HIT'
				end
				widgets.count.text = get_combo_color(count) .. count .. '\\cr'
			end
		end
	end
end)

windower.register_event('lose buff', function(buff_id)
	if buff_id == 461 then
		count = 0
	end
end)

-- windower.register_event('gain buff', function(buff_id)
	-- if buff_id == 461 then
	-- end
-- end)