local MOD_PREFIX = "player-quality-"

local GUI = {
  frame = MOD_PREFIX .. "frame",
  recipe_dropdown = MOD_PREFIX .. "recipe-dropdown",
  quality_dropdown = MOD_PREFIX .. "quality-dropdown",
  count_textfield = MOD_PREFIX .. "count-textfield",
  status_label = MOD_PREFIX .. "status-label",
  chance_label = MOD_PREFIX .. "chance-label",
  craft_button = MOD_PREFIX .. "craft-button",
  close_button = MOD_PREFIX .. "close-button"
}

local EQUIPMENT_TO_MODULE = {
  [MOD_PREFIX .. "quality-module-equipment"] = "quality-module",
  [MOD_PREFIX .. "quality-module-2-equipment"] = "quality-module-2",
  [MOD_PREFIX .. "quality-module-3-equipment"] = "quality-module-3"
}

local function ensure_storage()
  storage.player_quality = storage.player_quality or {}
  storage.player_quality.players = storage.player_quality.players or {}
  storage.player_quality.rng = storage.player_quality.rng or game.create_random_generator()
end

script.on_init(ensure_storage)
script.on_configuration_changed(ensure_storage)

local function get_player_state(player)
  ensure_storage()
  storage.player_quality.players[player.index] = storage.player_quality.players[player.index] or {}
  return storage.player_quality.players[player.index]
end

local function format_percent(value)
  return string.format("%.2f", value * 100)
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

local function get_equipped_quality_chance(player)
  local grid = get_player_armor_grid(player)
  if not grid then
    return 0
  end

  local chance = 0
  for _, equipment in pairs(grid.equipment) do
    local module_name = EQUIPMENT_TO_MODULE[equipment.name]
    local module = module_name and prototypes.item[module_name]
    if module and module.get_module_effects then
      local effects = module:get_module_effects(quality_name_from_object(equipment.quality))
      if effects and effects.quality then
        chance = chance + effects.quality
      end
    end
  end

  return math.max(chance, 0)
end

local function is_quality_unlocked(force, quality_name)
  if quality_name == "normal" then
    return true
  end

  if force.is_quality_unlocked then
    return force:is_quality_unlocked(quality_name)
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
    return recipe:has_category("crafting")
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
  if quality_name then
    return quality_name
  end

  return "normal"
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
  local frame = player.gui.screen[GUI.frame]
  if frame and frame.valid and frame[GUI.status_label] then
    frame[GUI.status_label].caption = message
  end
end

local function refresh_chance_label(player)
  local frame = player.gui.screen[GUI.frame]
  if not frame or not frame.valid or not frame[GUI.chance_label] then
    return
  end

  frame[GUI.chance_label].caption = {
    "player-quality.equipped-quality-chance",
    format_percent(get_equipped_quality_chance(player))
  }
end

local function close_gui(player)
  local frame = player.gui.screen[GUI.frame]
  if frame and frame.valid then
    frame.destroy()
  end
end

local function open_gui(player)
  close_gui(player)

  local state = get_player_state(player)
  local recipes = get_recipe_options(player)
  local qualities = get_quality_options(player.force)

  state.recipe_names = {}
  state.quality_names = {}
  state.selected_recipe_index = 1
  state.selected_quality_index = 1
  state.count = state.count or "1"

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

  local frame = player.gui.screen.add({
    type = "frame",
    name = GUI.frame,
    direction = "vertical",
    caption = { "player-quality.gui-title" }
  })
  frame.auto_center = true

  frame.add({
    type = "label",
    name = GUI.chance_label,
    caption = { "player-quality.equipped-quality-chance", format_percent(get_equipped_quality_chance(player)) }
  })

  local recipe_flow = frame.add({
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
    selected_index = #recipe_items > 0 and 1 or 0
  })

  local quality_flow = frame.add({
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
    selected_index = #quality_items > 0 and 1 or 0
  })

  local count_flow = frame.add({
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

  frame.add({
    type = "label",
    name = GUI.status_label,
    caption = #recipe_items > 0 and { "player-quality.ready" } or { "player-quality.no-recipes" }
  })

  local button_flow = frame.add({
    type = "flow",
    direction = "horizontal"
  })
  button_flow.add({
    type = "button",
    name = GUI.craft_button,
    caption = { "player-quality.craft" }
  })
  button_flow.add({
    type = "button",
    name = GUI.close_button,
    caption = { "player-quality.close" }
  })

  player.opened = frame
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
  local chance = get_equipped_quality_chance(player)
  if chance <= 0 then
    set_status(player, { "player-quality.no-equipment" })
    return
  end

  local count = get_count(player)
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
        { "item-name." .. ingredient.name },
        needed,
        { "quality-name." .. quality },
        available
      })
      return
    end
  end

  remove_ingredients(inventory, simple_recipe.ingredients, quality, count)

  local rolled = {}
  for _ = 1, count do
    local output_quality = roll_output_quality(quality, chance, player.force)
    rolled[output_quality] = (rolled[output_quality] or 0) + simple_recipe.product.amount
  end

  for output_quality, amount in pairs(rolled) do
    insert_or_spill(player, {
      name = simple_recipe.product.name,
      quality = output_quality,
      count = amount
    })
  end

  refresh_chance_label(player)
  set_status(player, {
    "player-quality.crafted",
    count,
    simple_recipe.product.amount * count,
    { "item-name." .. simple_recipe.product.name }
  })
end

local function toggle_gui(player)
  if player.gui.screen[GUI.frame] then
    close_gui(player)
  else
    open_gui(player)
  end
end

script.on_event(MOD_PREFIX .. "toggle-gui", function(event)
  local player = game.get_player(event.player_index)
  if player then
    toggle_gui(player)
  end
end)

script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name ~= MOD_PREFIX .. "toggle-shortcut" then
    return
  end

  local player = game.get_player(event.player_index)
  if player then
    toggle_gui(player)
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
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  if event.element.name == GUI.count_textfield then
    get_player_state(player).count = event.element.text
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  if event.element.name == GUI.close_button then
    close_gui(player)
  elseif event.element.name == GUI.craft_button then
    craft_selected(player)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.valid and event.element.name == GUI.frame then
    event.element.destroy()
  end
end)

commands.add_command("player-quality", { "player-quality.command-help" }, function(event)
  local player = event.player_index and game.get_player(event.player_index)
  if player then
    toggle_gui(player)
  end
end)
