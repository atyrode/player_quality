local MOD_PREFIX = "player-quality-"
local HIDDEN_SURFACE = MOD_PREFIX .. "hidden-surface"
local ENERGY_MULTIPLIER_SETTING = MOD_PREFIX .. "energy-multiplier"

local GUI = {
  assembler_panel = MOD_PREFIX .. "assembler-panel",
  debug_frame = MOD_PREFIX .. "debug-frame",
  status_label = MOD_PREFIX .. "status-label",
  close_button = MOD_PREFIX .. "close-button",
  infinite_energy_checkbox = MOD_PREFIX .. "infinite-energy-checkbox",
  quality_dropdown = MOD_PREFIX .. "quality-dropdown",
  open_prefix = MOD_PREFIX .. "open-assembler-",
  enabled_prefix = MOD_PREFIX .. "enable-assembler-",
  give_assembler_prefix = MOD_PREFIX .. "give-assembler-",
  give_module_prefix = MOD_PREFIX .. "give-module-",
  research_prefix = MOD_PREFIX .. "research-"
}

local PERSONAL_ASSEMBLERS = {
  [MOD_PREFIX .. "personal-assembler-equipment"] = {
    tier = 1,
    item = MOD_PREFIX .. "personal-assembler-equipment",
    recipe = MOD_PREFIX .. "personal-assembler-equipment",
    entity = MOD_PREFIX .. "personal-assembler-entity",
    technology = "quality-module",
    energy_per_second = 150000
  },
  [MOD_PREFIX .. "personal-assembler-2-equipment"] = {
    tier = 2,
    item = MOD_PREFIX .. "personal-assembler-2-equipment",
    recipe = MOD_PREFIX .. "personal-assembler-2-equipment",
    entity = MOD_PREFIX .. "personal-assembler-2-entity",
    technology = "quality-module-2",
    energy_per_second = 300000
  },
  [MOD_PREFIX .. "personal-assembler-3-equipment"] = {
    tier = 3,
    item = MOD_PREFIX .. "personal-assembler-3-equipment",
    recipe = MOD_PREFIX .. "personal-assembler-3-equipment",
    entity = MOD_PREFIX .. "personal-assembler-3-entity",
    technology = "quality-module-3",
    energy_per_second = 600000
  }
}

local ASSEMBLER_BY_TIER = {
  PERSONAL_ASSEMBLERS[MOD_PREFIX .. "personal-assembler-equipment"],
  PERSONAL_ASSEMBLERS[MOD_PREFIX .. "personal-assembler-2-equipment"],
  PERSONAL_ASSEMBLERS[MOD_PREFIX .. "personal-assembler-3-equipment"]
}

local MODULE_BY_TIER = {
  "quality-module",
  "quality-module-2",
  "quality-module-3"
}

local QUALITY_TECHNOLOGIES = {
  "quality-module",
  "epic-quality",
  "legendary-quality"
}

local function ensure_storage()
  storage.player_quality = storage.player_quality or {}
  storage.player_quality.players = storage.player_quality.players or {}
end

local function get_player_state(player)
  ensure_storage()
  local state = storage.player_quality.players[player.index]
  if not state then
    state = {
      assemblers = {},
      infinite_energy = false,
      selected_quality_index = 1
    }
    storage.player_quality.players[player.index] = state
  end
  state.assemblers = state.assemblers or {}
  if state.infinite_energy == nil then
    state.infinite_energy = false
  end
  return state
end

local function starts_with(value, prefix)
  return string.sub(value, 1, string.len(prefix)) == prefix
end

local function format_percent(value)
  return string.format("%.2f", value * 100)
end

local function get_energy_multiplier()
  local setting = settings.global[ENERGY_MULTIPLIER_SETTING]
  if setting and type(setting.value) == "number" then
    return math.min(math.max(setting.value, 0.1), 10)
  end

  return 1
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

local function sync_force_recipe_unlocks(force)
  for _, spec in pairs(ASSEMBLER_BY_TIER) do
    local recipe = force.recipes[spec.recipe]
    local technology = force.technologies[spec.technology]
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

local function get_all_quality_options()
  local options = {}
  for name, quality in pairs(prototypes.quality) do
    table.insert(options, {
      name = name,
      level = quality.level or 0,
      localised_name = quality.localised_name or { "quality-name." .. name }
    })
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

local function get_unlocked_quality_names(force)
  local names = {}
  for _, option in pairs(get_all_quality_options()) do
    if is_quality_unlocked(force, option.name) then
      table.insert(names, option.name)
    end
  end

  if #names == 0 then
    table.insert(names, "normal")
  end

  return names
end

local function get_selected_debug_quality(player)
  local state = get_player_state(player)
  local options = get_all_quality_options()
  local index = state.selected_quality_index or 1
  local option = options[index]
  return option and option.name or "normal"
end

local function get_hidden_surface()
  local surface = game.surfaces[HIDDEN_SURFACE]
  if surface and surface.valid then
    return surface
  end

  surface = game.create_surface(HIDDEN_SURFACE, {})
  surface.request_to_generate_chunks({ 0, 0 }, 2)
  surface.force_generate_chunk_requests()
  surface.always_day = true
  return surface
end

local function hidden_position(player_index, slot_index)
  return {
    x = player_index * 64,
    y = slot_index * 8
  }
end

local function insert_or_spill(player, stack)
  local inserted = player.insert(stack)
  local remaining = stack.count - inserted
  if remaining > 0 then
    player.surface.spill_item_stack({
      position = player.position,
      stack = {
        name = stack.name,
        count = remaining,
        quality = stack.quality
      },
      enable_looted = true,
      force = player.force,
      allow_belts = false
    })
  end
end

local function move_inventory_to_player(player, inventory)
  if not inventory or not inventory.valid then
    return
  end

  for index = 1, #inventory do
    local stack = inventory[index]
    if stack and stack.valid_for_read then
      local count = stack.count
      local quality = quality_name_from_object(stack.quality)
      insert_or_spill(player, {
        name = stack.name,
        count = count,
        quality = quality
      })
      inventory.remove({
        name = stack.name,
        count = count,
        quality = quality
      })
    end
  end
end

local function get_assembler_inventory(entity, inventory_define)
  if not entity or not entity.valid or not inventory_define then
    return nil
  end

  local ok, inventory = pcall(function()
    return entity.get_inventory(inventory_define)
  end)

  if ok then
    return inventory
  end

  return nil
end

local function get_assembler_input_inventory(entity)
  return get_assembler_inventory(
    entity,
    defines.inventory.crafter_input or defines.inventory.assembling_machine_input
  )
end

local function get_assembler_output_inventory(entity)
  if not entity or not entity.valid or not entity.get_output_inventory then
    return get_assembler_inventory(
      entity,
      defines.inventory.crafter_output or defines.inventory.assembling_machine_output
    )
  end

  local ok, inventory = pcall(function()
    return entity.get_output_inventory()
  end)

  if ok then
    return inventory
  end

  return nil
end

local function get_assembler_module_inventory(entity)
  if not entity or not entity.valid or not entity.get_module_inventory then
    return get_assembler_inventory(entity, defines.inventory.assembling_machine_modules)
  end

  local ok, inventory = pcall(function()
    return entity.get_module_inventory()
  end)

  if ok then
    return inventory
  end

  return nil
end

local function return_assembler_contents(player, entity)
  move_inventory_to_player(player, get_assembler_input_inventory(entity))
  move_inventory_to_player(player, get_assembler_output_inventory(entity))
  move_inventory_to_player(player, get_assembler_module_inventory(entity))
  move_inventory_to_player(
    player,
    get_assembler_inventory(entity, defines.inventory.crafter_trash or defines.inventory.assembling_machine_trash)
  )
end

local function create_hidden_assembler(player, spec, slot_index)
  local surface = get_hidden_surface()
  local entity = surface.create_entity({
    name = spec.entity,
    position = hidden_position(player.index, slot_index),
    force = player.force,
    raise_built = false,
    create_build_effect_smoke = false
  })

  if entity then
    entity.destructible = false
    entity.active = false
  end

  return entity
end

local function destroy_slot(player, slot)
  if slot and slot.entity and slot.entity.valid then
    return_assembler_contents(player, slot.entity)
    slot.entity.destroy()
  end
end

local function get_equipped_personal_assemblers(player)
  local grid = get_player_armor_grid(player)
  if not grid then
    return {}
  end

  local equipped = {}
  for _, equipment in pairs(grid.equipment) do
    local spec = PERSONAL_ASSEMBLERS[equipment.name]
    if spec then
      local position = equipment.position or { x = 0, y = 0 }
      table.insert(equipped, {
        equipment = equipment,
        spec = spec,
        x = position.x or 0,
        y = position.y or 0
      })
    end
  end

  table.sort(equipped, function(a, b)
    if a.y == b.y then
      if a.x == b.x then
        return a.spec.tier < b.spec.tier
      end
      return a.x < b.x
    end
    return a.y < b.y
  end)

  return equipped
end

local function sync_personal_assemblers(player)
  local state = get_player_state(player)
  local equipped = get_equipped_personal_assemblers(player)

  for index, equipped_slot in ipairs(equipped) do
    local slot = state.assemblers[index]
    if slot and (not slot.entity or not slot.entity.valid or slot.tier ~= equipped_slot.spec.tier) then
      destroy_slot(player, slot)
      slot = nil
    end

    if not slot then
      slot = {
        tier = equipped_slot.spec.tier,
        enabled = true,
        entity = create_hidden_assembler(player, equipped_slot.spec, index)
      }
      state.assemblers[index] = slot
    end
  end

  for index = #equipped + 1, #state.assemblers do
    destroy_slot(player, state.assemblers[index])
    state.assemblers[index] = nil
  end

  return equipped
end

local function get_entity_recipe(entity)
  if not entity or not entity.valid or not entity.get_recipe then
    return nil
  end

  local ok, recipe = pcall(function()
    return entity.get_recipe()
  end)

  if ok then
    return recipe
  end

  return nil
end

local function push_recipe_ingredients(player, entity)
  local recipe = get_entity_recipe(entity)
  if not recipe or not recipe.valid then
    return
  end

  local input_inventory = get_assembler_input_inventory(entity)
  local player_inventory = player.get_main_inventory()
  if not input_inventory or not input_inventory.valid or not player_inventory or not player_inventory.valid then
    return
  end

  local quality_names = get_unlocked_quality_names(player.force)
  for _, ingredient in pairs(recipe.ingredients) do
    if (not ingredient.type or ingredient.type == "item") and ingredient.name and ingredient.amount and ingredient.amount > 0 then
      local target_buffer = math.max(ingredient.amount * 6, ingredient.amount)
      for _, quality_name in pairs(quality_names) do
        local in_machine = input_inventory.get_item_count({
          name = ingredient.name,
          quality = quality_name
        })
        local wanted = target_buffer - in_machine
        if wanted > 0 then
          local available = player_inventory.get_item_count({
            name = ingredient.name,
            quality = quality_name
          })
          if available > 0 then
            local inserted = input_inventory.insert({
              name = ingredient.name,
              quality = quality_name,
              count = math.min(available, wanted)
            })
            if inserted > 0 then
              player_inventory.remove({
                name = ingredient.name,
                quality = quality_name,
                count = inserted
              })
              break
            end
          end
        end
      end
    end
  end
end

local function pull_assembler_outputs(player, entity)
  move_inventory_to_player(player, get_assembler_output_inventory(entity))
end

local function get_module_quality_chance(entity)
  local module_inventory = get_assembler_module_inventory(entity)
  if not module_inventory or not module_inventory.valid then
    return 0
  end

  local chance = 0
  for index = 1, #module_inventory do
    local stack = module_inventory[index]
    if stack and stack.valid_for_read then
      local module = prototypes.item[stack.name]
      if module and module.get_module_effects then
        local effects = module.get_module_effects(quality_name_from_object(stack.quality))
        if effects and effects.quality then
          chance = chance + effects.quality * stack.count
        end
      end
    end
  end

  return math.max(chance, 0)
end

local function run_personal_assemblers(player, tick_delta)
  local state = get_player_state(player)
  local equipped = sync_personal_assemblers(player)

  for index, equipped_slot in ipairs(equipped) do
    local slot = state.assemblers[index]
    local entity = slot and slot.entity
    local equipment = equipped_slot.equipment
    if entity and entity.valid and equipment and equipment.valid then
      local has_recipe = get_entity_recipe(entity) ~= nil
      local energy_needed = equipped_slot.spec.energy_per_second * get_energy_multiplier() * tick_delta / 60
      local has_energy = state.infinite_energy or (equipment.energy or 0) >= energy_needed
      local enabled = slot.enabled ~= false

      entity.active = enabled and has_recipe and has_energy

      if entity.active then
        if not state.infinite_energy then
          equipment.energy = math.max((equipment.energy or 0) - energy_needed, 0)
        end
        push_recipe_ingredients(player, entity)
      end

      pull_assembler_outputs(player, entity)
    end
  end
end

local function position_panel(player, frame)
  local resolution = player.display_resolution or { width = 1920, height = 1080 }
  local scale = player.display_scale or 1
  local width = resolution.width / scale
  local height = resolution.height / scale

  frame.location = {
    x = math.max(0, width - 360),
    y = math.max(0, height - 260)
  }
end

local function close_assembler_panel(player)
  local panel = player.gui.screen[GUI.assembler_panel]
  if panel and panel.valid then
    panel.destroy()
  end
end

local function add_slot_row(frame, player, index, equipped_slot, slot)
  local entity = slot and slot.entity
  local equipment = equipped_slot.equipment
  local energy_percent = 0
  if equipment and equipment.valid and equipment.max_energy and equipment.max_energy > 0 then
    energy_percent = math.floor(((equipment.energy or 0) / equipment.max_energy) * 100)
  end

  local chance = entity and entity.valid and get_module_quality_chance(entity) or 0
  local powered = get_player_state(player).infinite_energy or energy_percent > 0
  local status_key = powered and "player-quality.assembler-ready" or "player-quality.assembler-no-energy"

  local row = frame.add({
    type = "flow",
    direction = "horizontal"
  })
  row.add({
    type = "label",
    caption = {
      "player-quality.assembler-row",
      index,
      equipped_slot.spec.tier,
      format_percent(chance),
      energy_percent,
      { status_key }
    }
  })
  row.add({
    type = "button",
    name = GUI.open_prefix .. index,
    caption = { "player-quality.open" }
  })
  row.add({
    type = "checkbox",
    name = GUI.enabled_prefix .. index,
    caption = { "player-quality.enabled" },
    state = slot.enabled ~= false
  })
end

local function refresh_assembler_panel(player)
  local equipped = sync_personal_assemblers(player)
  if #equipped == 0 then
    close_assembler_panel(player)
    return
  end

  close_assembler_panel(player)

  local state = get_player_state(player)
  local frame = player.gui.screen.add({
    type = "frame",
    name = GUI.assembler_panel,
    direction = "vertical",
    caption = { "player-quality.assembler-panel-title" }
  })
  position_panel(player, frame)

  frame.add({
    type = "label",
    caption = { "player-quality.assembler-panel-help" }
  })

  for index, equipped_slot in ipairs(equipped) do
    add_slot_row(frame, player, index, equipped_slot, state.assemblers[index])
  end
end

local function set_debug_status(player, message)
  local frame = player.gui.screen[GUI.debug_frame]
  if frame and frame.valid and frame[GUI.status_label] then
    frame[GUI.status_label].caption = message
  end
end

local function close_debug_gui(player)
  local frame = player.gui.screen[GUI.debug_frame]
  if frame and frame.valid then
    frame.destroy()
  end
end

local function open_debug_gui(player)
  close_debug_gui(player)

  local state = get_player_state(player)
  local frame = player.gui.screen.add({
    type = "frame",
    name = GUI.debug_frame,
    direction = "vertical",
    caption = { "player-quality.debug-gui-title" }
  })
  frame.auto_center = true

  local quality_items = {}
  for _, quality in pairs(get_all_quality_options()) do
    table.insert(quality_items, quality.localised_name)
  end

  local quality_flow = frame.add({
    type = "flow",
    direction = "horizontal"
  })
  quality_flow.add({
    type = "label",
    caption = { "player-quality.debug-quality" }
  })
  quality_flow.add({
    type = "drop-down",
    name = GUI.quality_dropdown,
    items = quality_items,
    selected_index = state.selected_quality_index or 1
  })

  frame.add({
    type = "checkbox",
    name = GUI.infinite_energy_checkbox,
    caption = { "player-quality.infinite-energy" },
    state = state.infinite_energy
  })

  local assembler_flow = frame.add({
    type = "flow",
    direction = "horizontal"
  })
  for tier, spec in ipairs(ASSEMBLER_BY_TIER) do
    assembler_flow.add({
      type = "button",
      name = GUI.give_assembler_prefix .. tier,
      caption = { "player-quality.give-assembler", tier }
    })
  end

  local module_flow = frame.add({
    type = "flow",
    direction = "horizontal"
  })
  for tier, module_name in ipairs(MODULE_BY_TIER) do
    module_flow.add({
      type = "button",
      name = GUI.give_module_prefix .. tier,
      caption = { "player-quality.give-module", tier }
    })
  end

  frame.add({
    type = "line",
    direction = "horizontal"
  })

  for _, spec in ipairs(ASSEMBLER_BY_TIER) do
    frame.add({
      type = "button",
      name = GUI.research_prefix .. spec.technology,
      caption = { "player-quality.research-tech", { "technology-name." .. spec.technology } }
    })
  end

  for _, technology_name in ipairs(QUALITY_TECHNOLOGIES) do
    frame.add({
      type = "button",
      name = GUI.research_prefix .. technology_name,
      caption = { "player-quality.research-tech", { "technology-name." .. technology_name } }
    })
  end

  frame.add({
    type = "label",
    name = GUI.status_label,
    caption = { "player-quality.ready" }
  })

  frame.add({
    type = "button",
    name = GUI.close_button,
    caption = { "player-quality.close" }
  })

  player.opened = frame
end

local function toggle_debug_gui(player)
  if player.gui.screen[GUI.debug_frame] then
    close_debug_gui(player)
  else
    open_debug_gui(player)
  end
end

local function give_debug_item(player, item_name, count)
  local quality = get_selected_debug_quality(player)
  local inserted = player.insert({
    name = item_name,
    quality = quality,
    count = count or 1
  })

  if inserted > 0 then
    set_debug_status(player, {
      "player-quality.gave-item",
      item_tag(item_name, quality),
      inserted
    })
  else
    set_debug_status(player, { "player-quality.no-inventory-space" })
  end
end

local function research_technology(player, technology_name)
  local technology = player.force.technologies[technology_name]
  if not technology then
    set_debug_status(player, { "player-quality.unknown-technology", technology_name })
    return
  end

  if not technology.researched then
    technology.researched = true
  end
  sync_force_recipe_unlocks(player.force)
  refresh_assembler_panel(player)
  set_debug_status(player, {
    "player-quality.researched-tech",
    technology.localised_name or { "technology-name." .. technology_name }
  })
end

local function setup_test_player(player)
  sync_force_recipe_unlocks(player.force)

  local state = get_player_state(player)
  state.infinite_energy = true

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

  local ok, equipment = pcall(function()
    return grid.put({
      name = MOD_PREFIX .. "personal-assembler-3-equipment",
      quality = "rare"
    })
  end)

  if not ok or not equipment then
    player.print({ "player-quality.test-setup-equipment-failed" })
    return
  end
  equipment.energy = equipment.max_energy or 8000000

  player.insert({ name = "quality-module-3", count = 8, quality = "rare" })
  player.insert({ name = "speed-module-3", count = 4 })
  player.insert({ name = "iron-plate", count = 1000 })
  player.insert({ name = "iron-plate", count = 1000, quality = "rare" })
  player.insert({ name = "copper-plate", count = 1000 })
  player.insert({ name = "copper-plate", count = 1000, quality = "rare" })
  player.insert({ name = "steel-plate", count = 500 })
  player.insert({ name = "electronic-circuit", count = 500 })

  refresh_assembler_panel(player)
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

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  if event.element.name == GUI.quality_dropdown then
    get_player_state(player).selected_quality_index = event.element.selected_index
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  if event.element.name == GUI.infinite_energy_checkbox then
    get_player_state(player).infinite_energy = event.element.state
    set_debug_status(player, { "player-quality.ready" })
    refresh_assembler_panel(player)
    return
  end

  if starts_with(event.element.name, GUI.enabled_prefix) then
    local slot_index = tonumber(string.sub(event.element.name, string.len(GUI.enabled_prefix) + 1))
    local slot = slot_index and get_player_state(player).assemblers[slot_index]
    if slot then
      slot.enabled = event.element.state
      refresh_assembler_panel(player)
    end
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local player = game.get_player(event.player_index)
  if not player or not event.element or not event.element.valid then
    return
  end

  local name = event.element.name
  if name == GUI.close_button then
    close_debug_gui(player)
    return
  end

  if starts_with(name, GUI.open_prefix) then
    local slot_index = tonumber(string.sub(name, string.len(GUI.open_prefix) + 1))
    local slot = slot_index and get_player_state(player).assemblers[slot_index]
    if slot and slot.entity and slot.entity.valid then
      player.opened = slot.entity
    end
    return
  end

  if starts_with(name, GUI.give_assembler_prefix) then
    local tier = tonumber(string.sub(name, string.len(GUI.give_assembler_prefix) + 1))
    local spec = tier and ASSEMBLER_BY_TIER[tier]
    if spec then
      give_debug_item(player, spec.item, 1)
    end
    return
  end

  if starts_with(name, GUI.give_module_prefix) then
    local tier = tonumber(string.sub(name, string.len(GUI.give_module_prefix) + 1))
    local module_name = tier and MODULE_BY_TIER[tier]
    if module_name then
      give_debug_item(player, module_name, 5)
    end
    return
  end

  if starts_with(name, GUI.research_prefix) then
    research_technology(player, string.sub(name, string.len(GUI.research_prefix) + 1))
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_assembler_panel(player)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.valid and event.element.name == GUI.debug_frame then
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
    refresh_assembler_panel(player)
  end
end)

script.on_configuration_changed(function()
  ensure_storage()
  sync_all_force_recipe_unlocks()
  for _, player in pairs(game.players) do
    refresh_assembler_panel(player)
  end
end)

script.on_event(defines.events.on_research_finished, function(event)
  sync_force_recipe_unlocks(event.research.force)
  for _, player in pairs(event.research.force.players) do
    if player.connected then
      refresh_assembler_panel(player)
    end
  end
end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_assembler_panel(player)
  end
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_assembler_panel(player)
  end
end)

script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_assembler_panel(player)
  end
end)

script.on_event(defines.events.on_player_placed_equipment, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_assembler_panel(player)
  end
end)

script.on_event(defines.events.on_player_removed_equipment, function(event)
  local player = game.get_player(event.player_index)
  if player then
    refresh_assembler_panel(player)
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
  if event.setting == ENERGY_MULTIPLIER_SETTING then
    for _, player in pairs(game.connected_players) do
      refresh_assembler_panel(player)
    end
  end
end)

script.on_nth_tick(30, function()
  for _, player in pairs(game.connected_players) do
    run_personal_assemblers(player, 30)
    refresh_assembler_panel(player)
  end
end)
