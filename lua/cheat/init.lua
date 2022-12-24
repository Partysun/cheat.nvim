local curl = require 'plenary.curl'
local Input = require 'nui.input'
local Popup = require 'nui.popup'
local event = require('nui.utils.autocmd').event

-- $ curl cheat.sh/TOPIC       show cheat sheet on the TOPIC
-- $ curl cheat.sh/TOPIC/SUB   show cheat sheet on the SUB topic in TOPIC
-- $ curl cheat.sh/~KEYWORD    search cheat sheets for KEYWORD
local function make_chtsh_url_from_query(search_query)
  local url_cht = 'https://cht.sh/:help'
  local topic = search_query
  local sub = ''
  local words = {}

  for word in string.gmatch(search_query, "%w+") do
    table.insert(words, word)
  end

  if #words > 1 then
    for i = 2, #words do
      sub = sub .. words[i] .. "+"
    end
    -- Remove the last '+' symbol from the string
    sub = string.sub(sub, 1, -2)

    topic = words[1]
    url_cht = string.format('https://cht.sh/%s/%s?T', topic, sub)
  end

  if #words == 1 then
    url_cht = string.format('https://cht.sh/%s?T', topic)
  end

  return url_cht
end

local function fetch_cheats(search_query, callback)
  local url_cht = make_chtsh_url_from_query(search_query)

  curl.get{
    url = url_cht,
    callback = function(response)
      vim.schedule(function()
        assert(response.exit == 0 and response.status < 400 and response.status >= 200, "Failed to fetch cht.sh")
        callback(response.body)
      end)
    end,
  }
end

local Cheat = {}

Cheat.setup = function()

	vim.api.nvim_create_user_command('Cheat', function(args)
		if args.args ~= nil then
			if string.len(args.args) > 1 then
				Cheat.open_chtsh_popup(args.args)
			else
				Cheat.input()
			end
		else
			Cheat.input()
		end
	end, { nargs = "?" }
	)

end

Cheat.input = function()
	local input = Input({
    position = {
      row = '25%',
      col = '50%',
    },
		size = {
			width = "60%",
		},
		border = {
			style = "double",
			text = {
				top = "[Search cht.sh]",
				top_align = "center",
        bottom = ':help, TOPIC SUB, ~keyword'
			},
		},
		win_options = {
			winhighlight = "Normal:Normal,FloatBorder:Normal",
		},
	}, {
		prompt = "> ",
		default_value = "",
		on_close = function()
		end,
		on_submit = function(value)
			Cheat.open_chtsh_popup(value)
		end,
	})

	-- mount/open the component
	input:mount()

	-- unmount component when cursor leaves buffer
	input:on(event.BufLeave, function()
		input:unmount()
	end)
end

-- Pops up a window containing the results of the search
Cheat.open_chtsh_popup = function(search_query)
	local popup = Popup({
		enter = true,
		focusable = true,
		border = {
			style = "double",
			text = {
				top = "[cht.sh]",
				top_align = "center",
			}
		},
		position = "50%",
		size = {
			width = "80%",
			height = "60%",
		},
	})

	-- mount/open the component
	popup:mount()

	-- unmount component when cursor leaves buffer
	popup:on(event.BufLeave, function()
		popup:unmount()
	end)

  local function previewer(articles)
    local lines = {}
    for line in articles:gmatch("[^\n]+") do
      local clean = string.gsub(line, "\x1b[.[0-9;]*[mK]", "")
      lines[#lines + 1] = clean
    end
    vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, lines)
    vim.bo.filetype = 'python'
  end

  fetch_cheats(search_query, previewer)
	vim.keymap.set("n", "q", ":q!<cr>", { buffer = true })

end

return Cheat
