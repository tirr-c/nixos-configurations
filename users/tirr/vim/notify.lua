vim.api.nvim_set_hl(0, 'NotifyBackground', { bg = 'NONE', ctermbg = 'NONE' })

vim.notify = require('notify')
vim.notify.setup({
  render = 'wrapped-compact',
  stages = 'no_animation',
  max_width = 60,
})

local client_notifs = {}

local function get_notif_data(client_id, token)
  if not client_notifs[client_id] then
    client_notifs[client_id] = {}
  end

  if not client_notifs[client_id][token] then
    client_notifs[client_id][token] = {}
  end

  return client_notifs[client_id][token]
end

local spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' }

local function update_spinner(client_id, token)
  local notif_data = get_notif_data(client_id, token)

  if notif_data.spinner then
    local new_spinner = (notif_data.spinner % #spinner_frames) + 1
    notif_data.spinner = new_spinner

    notif_data.notification = vim.notify(nil, nil, {
      hide_from_history = true,
      icon = spinner_frames[new_spinner],
      replace = notif_data.notification,
    })

    vim.defer_fn(function() update_spinner(client_id, token) end, 200)
  end
end

local function format_title(title, client_name)
  return client_name .. (#title > 0 and ': ' .. title or '')
end

local originalProgressHandler = vim.lsp.handlers['$/progress']
local originalMessageHandler = vim.lsp.handlers['window/showMessage']
local severityMap = { 'error', 'warn', 'info', 'info' }

vim.lsp.handlers['$/progress'] = function(x, result, ctx)
  if originalProgressHandler then
    originalProgressHandler(x, result, ctx)
  end

  local client_id = ctx.client_id

  local val = result.value

  if not val.kind then
    return
  end

  local notif_data = get_notif_data(client_id, result.token)

  if val.kind == 'begin' then
    local message = val.message or ''

    notif_data.notification = vim.notify(message, 'info', {
      title = format_title(val.title, vim.lsp.get_client_by_id(client_id).name),
      icon = spinner_frames[1],
      timeout = false,
      hide_from_history = false,
    })

    notif_data.spinner = 1
    update_spinner(client_id, result.token)
  elseif val.kind == 'report' and notif_data then
    local message = val.message or ''

    notif_data.notification = vim.notify(message, 'info', {
      replace = notif_data.notification,
      hide_from_history = false,
    })
  elseif val.kind == 'end' and notif_data then
    local message = val.message or nil

    notif_data.notification = vim.notify(message, 'info', {
      icon = '',
      replace = notif_data.notification,
      timeout = 1,
    })

    notif_data.spinner = nil
  end
end

vim.lsp.handlers['window/showMessage'] = function(err, method, params, client_id)
  if originalMessageHandler then
    originalMessageHandler(err, method, params, client_id)
  end
  vim.notify(method.message, severityMap[params.type])
end
