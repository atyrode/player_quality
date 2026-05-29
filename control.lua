local MOD_PREFIX = "player-quality-"

local GUI = {
  debug_frame = MOD_PREFIX .. "debug-frame",
  crafting_panel = MOD_PREFIX .. "crafting-panel",
  crafting_window = MOD_PREFIX .. "crafting-window",
  recipe_dropdown = MOD_PREFIX .. "recipe-dropdown",
  quality_dropdown = MOD_PREFIX .. "quality-dropdown",
  count_textfield = MOD_PREFIX .. "count-textfield",
  status_label = MOD_PREFIX .. "status-label",
  chance_label = MOD_PREFIX .. "chance-label",
  craft_button = MOD_PREFIX .. "craft-button",
  close_button = MOD_PREFIX .. "close-button",
  infinite_energy_checkbox = MOD_PREFIX .. "infinite-energy-checkbox",
  give_module_1_button = MOD_PREFIX .. "give-module-1-button",
  give_module_2_button = MOD_PREFIX .. "give-module-2-button",
  give_module_3_button = MOD_PREFIX .. "give-module-3-button",
  research_modules_button = MOD_PREFIX .. "research-modules-button",
  research_quality_button = MOD_PREFIX .. "research-quality-button",
  lock_qualities_button = MOD_PREFIX .. "lock-qualities-button",
  status_button = MOD_PREFIX .. "status-button"
}

local EQUIPMENT_TO_MODULE = {
  [MOD_PREFIX .. "quality-module-equipment"] = "quality-module",
  [MOD_PREFIX .. "quality-module-2-equipment"] = "quality-module-2",
  [MOD_PREFIX .. "quality-module-3-equipment"] = "quality-module-3"
}

local GIVE_MODULE_BUTTONS = {
  [GUI.give_module_1_button] = MOD_PREFIX .. "quality-module-equipment",
  [GUI.give_module_2_button] = MOD_PREFIX .. "quality-module-2-equipment",
  [GUI.give_module_3_button] = MOD_PREFIX .. "quality-module-3-equipment"
}

local MODULE_UNLOCKS = {
  {
    technology = "quality-module",
    recipe = MOD_PREFIX .. "quality-module-equipment"
  },
  {
    technology = "quality-module-2",
    recipe = MOD_PREFIX .. "quality-module-2-equipment"
  },
  {
    technology = "quality-module-3",
    recipe = MOD_PREFIX .. "quality-module-3-equipment"
  }
}

local QUALITY_TECHNOLOGIES = { "quality-module", "epic-quality", "legendary-quality" }
local QUALITY_NAMES = { "uncommon", "rare", "epic", "legendary" }

local ENERGY_PER_MODULE_PER_CRAFT = 10000
local CHANCE_MULTIPLIER_SETTING = "player-quality-chance-multiplier"

local function ensure_storage()
  storage.player_quality = storage.player_quality or {}
  storage.player_quality.players = storage.player_quality.players or {}
  storage.player_quality.rng = storage.player_quality.rng or game.create_random_generator()
end

local function get_player_state(player)
  ensure_storage()
  storage.player_quality.players[player.index] = storage.player_quality.players[player.index] or {}
  return storage.player_quality.players[player.index]
end

local function format_percent(value)
  return string.format("%.2f", value * 100)
end

local function get_chance_multiplier()
  local setting = settings.global[CHANCE_MULTIPLIER_SETTING]
  if setting and type(setting.value) == "number" then
    return math.min(math.max(setting.value, 0.01), 1)
  end

  return 0.1
end

local function item_localised_name(name)
  local item = prototypes.item[name]
  if item and item.localised_name then
    return item.localised_name
  end

  return { "item-name." .. name }
end

local function quality_localised_name(name)
  local quality = prototypes.quality[name]
  if quality and quality.localised_name then
    return quality.localised_name
  end

  return { "quality-name." .. name }
end

local function item_tag(name, quality)
  if quality and quality ~= "normal" then
    return "[quality=" .. quality .. "][item=" .. name .. "]"
  end

  return "[item=" .. name .. "]"
end

local function get_player_armor_grid(player)
  local armor_inventory = player.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid or armor_inventory.is_empty() then
    return nil
  end

  local armor = armor_inventory[1]
  if not armor or not armor.valid_for_read then
    return nil
  end

  return armor.grid
end

local function quality_name_from_object(quality)
  if type(quality) == "string" then
    return quality
  end

  if quality and quality.name then
    return quality.name
  end

  return "normal"
end

local function get_equipped_quality_modules(player, count)
  local grid = get_player_armor_grid(player)
  if not grid then
    return {}
  end

  local state = get_player_state(player)
  local required_energy = ENERGY_PER_MODULE_PER_CRAFT * (count or 1)
  local modules = {}

  for _, equipment in pairs(grid.equipment) do
    local module_name = EQUIPMENT_TO_MODULE[equipment.name]
    local module = module_name and prototypes.item[module_name]
    if module and module.get_module_effects then
      local effects = module.get_module_effects(quality_name_from_object(equipment.quality))
      if effects and effects.quality then
        table.insert(modules, {
          equipment = equipment,
          module_name = module_name,
          chance = math.max(effects.quality * get_chance_multiplier(), 0),
          powered = state.infinite_energy or (equipment.energy or 0) >= required_energy
        })
      end
    end
  end

  return modules
end

local function get_equipped_quality_chance(player, count)
  local total = 0
  local active = 0
  local total_modules = 0
  local active_modules = 0

  for _, module in pairs(get_equipped_quality_modules(player, count)) do
    total = total + module.chance
    total_modules = total_modules + 1
    if module.powered then
      active = active + module.chance
      active_modules = active_modules + 1
    end
  end

  return {
    total = math.max(total, 0),
    active = math.max(active, 0),
    total_modules = total_modules,
    active_modules = active_modules
  }
end

local function sync_force_recipe_unlocks(force)
  for _, unlock in pairs(MODULE_UNLOCKS) do
    local recipe = force.recipes[unlock.recipe]
    local technology = force.technologies[unlock.technology]
    if recipe and technology then
      recipe.enabled = technology.researched
    elseif recipe then
      recipe.enabled = false
    end
  end
end

local function sync_all_force_recipe_unlocks()
  for _, force in pairs(game.forces) do
    sync_force_recipe_unlocks(force)
  end
end

local function is_quality_unlocked(force, quality_name)
  if quality_name == "normal" then
    return true
  end

  if force.is_quality_unlocked then
    return force.is_quality_unlocked(quality_name)
  end

  return true
end

local function get_quality_options(force)
  local options = {}

  for name, quality in pairs(prototypes.quality) do
    if is_quality_unlocked(force, name) then
      table.insert(options, {
        name = name,
        level = quality.level or 0,
        localised_name = quality.localised_name or { "quality-name." .. name }
      })
    end
  end

  table.sort(options, function(a, b)
    if a.level == b.level then
      return a.name < b.name
    end
    return a.level < b.level
  end)

  if #options == 0 then
    table.insert(options, {
      name = "normal",
      level = 0,
      localised_name = { "quality-name.normal" }
    })
  end

  return options
end

local function has_crafting_category(recipe)
  if recipe.has_category then
    return recipe.has_category("crafting")
  end

  return recipe.category == "crafting"
end

local function read_simple_recipe(recipe)
  if not recipe or not recipe.valid or not recipe.enabled or recipe.hidden then
    return nil
  end

  if not has_crafting_category(recipe) then
    return nil
  end

  local ingredients = {}
  for _, ingredient in pairs(recipe.ingredients) do
    if ingredient.type and ingredient.type ~= "item" then
      return nil
    end

    local name = ingredient.name
    local amount = ingredient.amount
    if not name or not amount or amount <= 0 then
      return nil
    end

    table.insert(ingredients, {
      name = name,
      amount = amount
    })
  end

  local item_products = {}
  for _, product in pairs(recipe.products) do
    if not product.type or product.type == "item" then
      local amount = product.amount
      if not amount and product.amount_min and product.amount_max and product.amount_min == product.amount_max then
        amount = product.amount_min
      end

      if amount and amount > 0 and (not product.probability or product.probability == 1) then
        table.insert(item_products, {
          name = product.name,
          amount = amount
        })
      else
        return nil
      end
    else
      return nil
    end
  end

  if #ingredients == 0 or #item_products ~= 1 then
    return nil
  end

  return {
    recipe = recipe,
    ingredients = ingredients,
    product = item_products[1]
  }
end

local function get_recipe_options(player)
  local options = {}

  for _, recipe in pairs(player.force.recipes) do
    local simple_recipe = read_simple_recipe(recipe)
    if simple_recipe then
      table.insert(options, {
        name = recipe.name,
        localised_name = recipe.localised_name or { "recipe-name." .. recipe.name }
      })
    end
  end

  table.sort(options, function(a, b)
    return a.name < b.name
  end)

  return options
end

local function reset_player_options(player)
  local state = get_player_state(player)
  local recipes = get_recipe_options(player)
  local qualities = get_quality_options(player.force)

  state.recipe_names = {}
  state.quality_names = {}

  local recipe_items = {}
  for _, recipe in pairs(recipes) do
    table.insert(state.recipe_names, recipe.name)
    table.insert(recipe_items, recipe.localised_name)
  end

  local quality_items = {}
  for _, quality in pairs(qualities) do
    table.insert(state.quality_names, quality.name)
    table.insert(quality_items, quality.localised_name)
  end

  if not state.recipe_names[state.selected_recipe_index or 1] then
    state.selected_recipe_index = #state.recipe_names > 0 and 1 or 0
  end

  if not state.quality_names[state.selected_quality_index or 1] then
    state.selected_quality_index = 1
  end

  state.count = state.count or "1"

  return recipe_items, quality_items
end

local function get_selected_recipe(player)
  local state = get_player_state(player)
  local selected_index = state.selected_recipe_index or 1
  local recipe_name = state.recipe_names and state.recipe_names[selected_index]
  if not recipe_name then
    return nil
  end

  return read_simple_recipe(player.force.recipes[recipe_name])
end

local function get_selected_quality(player)
  local state = get_player_state(player)
  local selected_index = state.selected_quality_index or 1
  local quality_name = state.quality_names and state.quality_names[selected_index]
  if quality_name and is_quality_unlocked(player.force, quality_name) then
    return quality_name
  end

  return "normal"
end

local function get_selected_quality_next_probability(player)
  local current = prototypes.quality[get_selected_quality(player)] or prototypes.quality.normal
  if not current or not current.next then
    return 0
  end

  if not is_quality_unlocked(player.force, current.next.name) then
    return 0
  end

  return current.next_probability or 0
end

local function get_count(player)
  local state = get_player_state(player)
  local count = tonumber(state.count or "1") or 1
  count = math.floor(count)
  if count < 1 then
    return 1
  end

  if count > 100 then
    return 100
  end

  return count
end

local function set_status(player, message)
  for _, root in pairs({
    player.gui.screen[GUI.debug_frame],
    player.gui.screen[GUI.crafting_window],
    player.gui.relative[GUI.crafting_panel]
  }) do
    if root and root.valid and root[GUI.status_label] then
      root[GUI.status_label].caption = message
    end
  end
end

local function ensure_status_button(player)
  local button = player.gui.top[GUI.status_button]
  if button and button.valid then
    return button
  end

  return player.gui.top.add({
    type = "button",
    name = GUI.status_button,
    caption = { "player-quality.status-button", "0.00", 0, 0 },
    tooltip = { "player-quality.status-button-tooltip" }
  })
end

local function refresh_chance_label(player)
  local status = get_equipped_quality_chance(player, get_count(player))
  local next_probability = get_selected_quality_next_probability(player)
  local active_roll_chance = math.min(status.active * next_probability, 1)
  local total_roll_chance = math.min(status.total * next_probability, 1)

  for _, root in pairs({
    player.gui.screen[GUI.debug_frame],
    player.gui.screen[GUI.crafting_window],
    player.gui.relative[GUI.crafting_panel]
  }) do
    if root and root.valid and root[GUI.chance_label] then
      root[GUI.chance_label].caption = {
        "player-quality.equipped-quality-chance",
        format_percent(active_roll_chance),
        format_percent(total_roll_chance),
        status.active_modules,
        status.total_modules
      }
    end
  end

  local status_button = ensure_status_button(player)
  status_button.caption = {
    "player-quality.status-button",
    format_percent(active_roll_chance),
    status.active_modules,
    status.total_modules
  }
end

local function close_debug_gui(player)
  local frame = player.gui.screen[GUI.debug_frame]
  if frame and frame.valid then
    frame.destroy()
  end
end

local function add_crafting_controls(root, player, show_debug_controls)
  local state = get_player_state(player)
  local recipe_items, quality_items = reset_player_options(player)

  root.add({
    type = "label",
    name = GUI.chance_label,
    caption = { "player-quality.equipped-quality-chance", "0.00", "0.00", 0, 0 }
  })

  local recipe_flow = root.add({
    type = "flow",
    direction = "horizontal"
  })
  recipe_flow.add({
    type = "label",
    caption = { "player-quality.recipe" }
  })
  recipe_flow.add({
    type = "drop-down",
    name = GUI.recipe_dropdown,
    items = recipe_items,
    selected_index = state.selected_recipe_index or 0
  })

  local quality_flow = root.add({
    type = "flow",
    direction = "horizontal"
  })
  quality_flow.add({
    type = "label",
    caption = { "player-quality.ingredient-quality" }
  })
  quality_flow.add({
    type = "drop-down",
    name = GUI.quality_dropdown,
    items = quality_items,
    selected_index = state.selected_quality_index or 1
  })

  local count_flow = root.add({
    type = "flow",
    direction = "horizontal"
  })
  count_flow.add({
    type = "label",
    caption = { "player-quality.count" }
  })
  count_flow.add({
    type = "textfield",
    name = GUI.count_textfield,
    text = state.count,
    numeric = true,
    allow_decimal = false,
    allow_negative = false
  })

  if show_debug_controls then
    root.add({
      type = "checkbox",
      name = GUI.infinite_energy_checkbox,
      caption = { "player-quality.infinite-energy" },
      state = state.infinite_energy or false
    })

    local give_flow = root.add({
      type = "flow",
      direction = "horizontal"
    })
    give_flow.add({
      type = "button",
      name = GUI.give_module_1_button,
      caption = { "player-quality.give-module-1" }
    })
    give_flow.add({
      type = "button",
      name = GUI.give_module_2_button,
      caption = { "player-quality.give-module-2" }
    })
    give_flow.add({
      type = "button",
      name = GUI.give_module_3_button,
      caption = { "player-quality.give-module-3" }
    })

    root.add({
      type = "line",
      direction = "horizontal"
    })

    local research_flow = root.add({
      type = "flow",
      direction = "horizontal"
    })
    research_flow.add({
      type = "button",
      name = GUI.research_modules_button,
      caption = { "player-quality.research-modules" }
    })
    research_flow.add({
      type = "button",
      name = GUI.research_quality_button,
      caption = { "player-quality.research-quality" }
    })
    research_flow.add({
      type = "button",
      name = GUI.lock_qualities_button,
      caption = { "player-quality.lock-qualities" }
    })
  end

  root.add({
    type = "label",
    name = GUI.status_label,
    caption = #recipe_items > 0 and { "player-quality.ready" } or { "player-quality.no-recipes" }
  })

  local button_flow = root.add({
    type = "flow",
    direction = "horizontal"
  })
  button_flow.add({
    type = "button",
    name = GUI.craft_button,
    caption = { "player-quality.craft" }
  })

  if show_debug_controls then
    button_flow.add({
      type = "button",
      name = GUI.close_button,
      caption = { "player-quality.close" }
    })
  end

  refresh_chance_label(player)
end

local function open_debug_gui(player)
  close_debug_gui(player)

  local frame = player.gui.screen.add({
    type = "frame",
    name = GUI.debug_frame,
    direction = "vertical",
    caption = { "player-quality.debug-gui-title" }
  })
  frame.auto_center = true

  add_crafting_controls(frame, player, true)
  player.opened = frame
end

local function close_crafting_window(player)
  local frame = player.gui.screen[GUI.crafting_window]
  if frame and frame.valid then
    frame.destroy()
  end
end

local function open_crafting_window(player)
  close_crafting_window(player)

  local frame = player.gui.screen.add({
    type = "frame",
    name = GUI.crafting_window,
    direction = "vertical",
    caption = { "player-quality.crafting-panel-title" }
  })
  frame.auto_center = true

  add_crafting_controls(frame, player, false)
  player.opened = frame
end

local function toggle_crafting_window(player)
  if player.gui.screen[GUI.crafting_window] then
    close_crafting_window(player)
  else
    open_crafting_window(player)
  end
end

local function close_crafting_panel(player)
  local panel = player.gui.relative[GUI.crafting_panel]
  if panel and panel.valid then
    panel.destroy()
  end
end

local function open_crafting_panel(player)
  close_crafting_panel(player)

  local ok, panel = pcall(function()
    return player.gui.relative.add({
      type = "frame",
      name = GUI.crafting_panel,
      direction = "vertical",
      caption = { "player-quality.crafting-panel-title" },
      anchor = {
        gui = defines.relative_gui_type.controller_gui,
        position = defines.relative_gui_position.right
      }
    })
  end)

  if not ok or not panel then
    return
  end

  add_crafting_controls(panel, player, false)
end

local function ensure_player_gui(player)
  ensure_status_button(player)
  if not player.gui.relative[GUI.crafting_panel] then
    open_crafting_panel(player)
  end
  refresh_chance_label(player)
end

local function rebuild_player_guis(player)
  close_crafting_panel(player)
  open_crafting_panel(player)

  if player.gui.screen[GUI.crafting_window] then
    open_crafting_window(player)
  end

  if player.gui.screen[GUI.debug_frame] then
    open_debug_gui(player)
  end

  refresh_chance_label(player)
end

local function roll_output_quality(base_quality_name, quality_chance, force)
  ensure_storage()

  local current = prototypes.quality[base_quality_name] or prototypes.quality.normal
  if not current then
    return base_quality_name
  end

  local module_chance = math.max(quality_chance, 0)
  while current.next and module_chance > 0 do
    local roll_chance = math.min(module_chance * (current.next_probability or 0), 1)
    if roll_chance <= 0 then
      break
    end

    if storage.player_quality.rng() >= roll_chance then
      break
    end

    local next_quality = current.next
    if not next_quality or next_quality.name == current.name or not is_quality_unlocked(force, next_quality.name) then
      break
    end

    current = next_quality
  end

  return current.name
end

local function inventory_count(inventory, name, quality)
  if not inventory or not inventory.valid then
    return 0
  end

  return inventory.get_item_count({
    name = name,
    quality = quality
  })
end

local function remove_ingredients(inventory, ingredients, quality, count)
  for _, ingredient in pairs(ingredients) do
    inventory.remove({
      name = ingredient.name,
      quality = quality,
      count = ingredient.amount * count
    })
  end
end

local function consume_quality_energy(player, count)
  local state = get_player_state(player)
  if state.infinite_energy then
    return
  end

  local energy = ENERGY_PER_MODULE_PER_CRAFT * count
  for _, module in pairs(get_equipped_quality_modules(player, count)) do
    if module.powered then
      module.equipment.energy = math.max(module.equipment.energy - energy, 0)
    end
  end
end

local function insert_or_spill(player, stack)
  local inserted = player.insert(stack)
  local remaining = stack.count - inserted

  if remaining > 0 then
    local spill_stack = {
      name = stack.name,
      count = remaining,
      quality = stack.quality
    }
    player.surface.spill_item_stack({
      position = player.position,
      stack = spill_stack,
      enable_looted = true,
      force = player.force,
      allow_belts = false
    })
  end
end

local function craft_selected(player)
  local simple_recipe = get_selected_recipe(player)
  if not simple_recipe then
    set_status(player, { "player-quality.no-selected-recipe" })
    return
  end

  local quality = get_selected_quality(player)
  if not is_quality_unlocked(player.force, quality) then
    set_status(player, { "player-quality.quality-locked", quality_localised_name(quality) })
    return
  end

  local count = get_count(player)
  local chance = get_equipped_quality_chance(player, count)
  if chance.total_modules <= 0 then
    set_status(player, { "player-quality.no-equipment" })
    return
  end

  if chance.active <= 0 then
    set_status(player, { "player-quality.no-powered-equipment" })
    return
  end

  local inventory = player.get_main_inventory()
  if not inventory or not inventory.valid then
    set_status(player, { "player-quality.no-inventory" })
    return
  end

  for _, ingredient in pairs(simple_recipe.ingredients) do
    local needed = ingredient.amount * count
    local available = inventory_count(inventory, ingredient.name, quality)
    if available < needed then
      set_status(player, {
        "player-quality.missing-ingredient",
        item_localised_name(ingredient.name),
        needed,
        quality_localised_name(quality),
        available
      })
      return
    end
  end

  remove_ingredients(inventory, simple_recipe.ingredients, quality, count)
  consume_quality_energy(player, count)

  local rolled = {}
  for _ = 1, count do
    local output_quality = roll_output_quality(quality, chance.active, player.force)
    rolled[output_quality] = (rolled[output_quality] or 0) + simple_recipe.product.amount
  end

  local result_parts = {}
  for output_quality, amount in pairs(rolled) do
    insert_or_spill(player, {
      name = simple_recipe.product.name,
      quality = output_quality,
      count = amount
    })
    table.insert(result_parts, item_tag(simple_recipe.product.name, output_quality) .. " x" .. amount)
  end
  table.sort(result_parts)

  refresh_chance_label(player)
  set_status(player, {
    "player-quality.crafted",
    count,
    table.concat(result_parts, "  ")
  })
end

local function toggle_debug_gui(player)
  if player.gui.screen[GUI.debug_frame] then
    close_debug_gui(player)
  else
    open_debug_gui(player)
  end
end

local function give_debug_module(player, item_name)
  local quality = get_selected_quality(player)
  local inserted = player.insert({
    name = item_name,
    quality = quality,
    count = 1
  })

  if inserted > 0 then
    set_status(player, {
      "player-quality.gave-module",
      item_tag(item_name, quality),
      quality_localised_name(quality)
    })
  else
    set_status(player, { "player-quality.no-inventory-space" })
  end
end

local function research_technologies(force, technology_names)
  local researched = 0
  for _, technology_name in pairs(technology_names) do
    local technology = force.technologies[technology_name]
    if technology and not technology.researched then
      technology.researched = true
      researched = researched + 1
    end
  end

  sync_force_recipe_unlocks(force)
  return researched
end

local function research_module_technologies(player)
  local researched = research_technologies(player.force, {
    "quality-module",
    "quality-module-2",
    "quality-module-3"
  })

  rebuild_player_guis(player)
  set_status(player, { "player-quality.researched-modules", researched })
end

local function research_quality_technologies(player)
  local researched = research_technologies(player.force, QUALITY_TECHNOLOGIES)

  rebuild_player_guis(player)
  set_status(player, { "player-quality.researched-quality", researched })
end

local function lock_non_normal_qualities(player)
  if player.force.lock_quality then
    for _, quality_name in pairs(QUALITY_NAMES) do
      if prototypes.quality[quality_name] then
        player.force.lock_quality(quality_name)
      end
    end
  end

  rebuild_player_guis(player)
  set_status(player, { "player-quality.locked-qualities" })
end

local function setup_test_player(player)
  local force = player.force
  sync_force_recipe_unlocks(force)

  local armor_inventory = player.get_inventory(defines.inventory.character_armor)
  if not armor_inventory or not armor_inventory.valid then
    player.print({ "player-quality.test-setup-no-armor-inventory" })
    return
  end

  local armor = armor_inventory[1]
  armor.set_stack({ name = "power-armor-mk2", count = 1 })

  local grid = armor.grid
  if not grid then
    player.print({ "player-quality.test-setup-no-grid" })
    return
  end

  for _ = 1, 4 do
    local ok, equipment = pcall(function()
      return grid.put({
        name = MOD_PREFIX .. "quality-module-3-equipment",
        quality = "rare"
      })
    end)

    if not ok or not equipment then
      player.print({ "player-quality.test-setup-equipment-failed" })
      return
    end
    equipment.energy = equipment.max_energy or 1000000
  end

  player.insert({ name = "iron-plate", count = 1000 })
  player.insert({ name = "iron-plate", count = 1000, quality = "rare" })
  player.insert({ name = "copper-plate", count = 1000 })
  player.insert({ name = "copper-plate", count = 1000, quality = "rare" })
  rebuild_player_guis(player)
  player.print({ "player-quality.test-setup-ready" })
end

script.on_event(MOD_PREFIX .. "toggle-gui", function(event)
  local player = game.get_player(event.player_index)
  if player then
    toggle_debug_gui(player)
  end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= MOD_PREFIX .. "toggle-shortcut" then
    return
  end

  local player = game.get_player(event.player_index)
  if player then
    toggle_debug_gui(player)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if not player then
    return
  end

  if event.gui_type == defines.gui_type.controller then
    rebuild_player_guis(player)
  else
    ensure_player_gui(player)
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  local state = get_player_state(player)
  if event.element.name == GUI.recipe_dropdown then
    state.selected_recipe_index = event.element.selected_index
  elseif event.element.name == GUI.quality_dropdown then
    state.selected_quality_index = event.element.selected_index
  end
  refresh_chance_label(player)
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  if event.element.name == GUI.count_textfield then
    get_player_state(player).count = event.element.text
    refresh_chance_label(player)
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  if event.element.name == GUI.infinite_energy_checkbox then
    get_player_state(player).infinite_energy = event.element.state
    refresh_chance_label(player)
    set_status(player, { "player-quality.ready" })
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  local give_item = GIVE_MODULE_BUTTONS[event.element.name]
  if give_item then
    give_debug_module(player, give_item)
  elseif event.element.name == GUI.research_modules_button then
    research_module_technologies(player)
  elseif event.element.name == GUI.research_quality_button then
    research_quality_technologies(player)
  elseif event.element.name == GUI.lock_qualities_button then
    lock_non_normal_qualities(player)
  elseif event.element.name == GUI.status_button then
    toggle_crafting_window(player)
  elseif event.element.name == GUI.close_button then
    close_debug_gui(player)
  elseif event.element.name == GUI.craft_button then
    craft_selected(player)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.valid and event.element.name == GUI.debug_frame then
    event.element.destroy()
  elseif event.element and event.element.valid and event.element.name == GUI.crafting_window then
    event.element.destroy()
  end
end)

commands.add_command("player-quality", { "player-quality.command-help" }, function(event)
  local player = event.player_index and game.get_player(event.player_index)
  if player then
    toggle_debug_gui(player)
  end
end)

commands.add_command("player-quality-test-setup", { "player-quality.test-setup-command-help" }, function(event)
  local player = event.player_index and game.get_player(event.player_index)
  if player then
    setup_test_player(player)
  end
end)

script.on_init(function()
  ensure_storage()
  sync_all_force_recipe_unlocks()
  for _, player in pairs(game.players) do
    ensure_player_gui(player)
  end
end)

script.on_configuration_changed(function()
  ensure_storage()
  sync_all_force_recipe_unlocks()
  for _, player in pairs(game.players) do
    ensure_player_gui(player)
  end
end)

script.on_event(defines.events.on_research_finished, function(event)
  sync_force_recipe_unlocks(event.research.force)

  for _, player in pairs(event.research.force.players) do
    if player.connected then
      rebuild_player_guis(player)
    end
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if player then
    ensure_player_gui(player)
  end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if player then
    ensure_player_gui(player)
  end
end)

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_chance_label(player)
  end
end)

script.on_event(defines.events.on_player_placed_equipment, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_chance_label(player)
  end
end)

script.on_event(defines.events.on_player_removed_equipment, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_chance_label(player)
  end
end)

script.on_event(defines.events.on_force_reset, function(event)
  sync_force_recipe_unlocks(event.force)
end)

script.on_event(defines.events.on_technology_effects_reset, function(event)
  if event.force then
    sync_force_recipe_unlocks(event.force)
  end
end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting == CHANCE_MULTIPLIER_SETTING then
    for _, player in pairs(game.connected_players) do
      refresh_chance_label(player)
    end
  end
end)

script.on_nth_tick(60, function()
  for _, player in pairs(game.connected_players) do
    ensure_player_gui(player)
  end
end)
