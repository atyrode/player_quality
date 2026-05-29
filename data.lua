local MOD_PREFIX = "player-quality-"

local assembler_specs = {
  {
    tier = 1,
    equipment = MOD_PREFIX .. "personal-assembler-equipment",
    item = MOD_PREFIX .. "personal-assembler-equipment",
    recipe = MOD_PREFIX .. "personal-assembler-equipment",
    entity = MOD_PREFIX .. "personal-assembler-entity",
    base_entity = "assembling-machine",
    technology = "quality-module",
    crafting_speed = 0.75,
    module_slots = 2,
    energy_usage = "150kW",
    buffer_capacity = "2MJ",
    input_flow_limit = "300kW",
    order = "a[personal-assembler]-a[tier-1]",
    ingredients = {
      { type = "item", name = "assembling-machine-2", amount = 1 },
      { type = "item", name = "quality-module", amount = 2 },
      { type = "item", name = "electronic-circuit", amount = 50 },
      { type = "item", name = "steel-plate", amount = 30 },
      { type = "item", name = "battery", amount = 40 }
    }
  },
  {
    tier = 2,
    equipment = MOD_PREFIX .. "personal-assembler-2-equipment",
    item = MOD_PREFIX .. "personal-assembler-2-equipment",
    recipe = MOD_PREFIX .. "personal-assembler-2-equipment",
    entity = MOD_PREFIX .. "personal-assembler-2-entity",
    base_entity = "assembling-machine-2",
    technology = "quality-module-2",
    crafting_speed = 1.25,
    module_slots = 3,
    energy_usage = "300kW",
    buffer_capacity = "4MJ",
    input_flow_limit = "600kW",
    order = "a[personal-assembler]-b[tier-2]",
    ingredients = {
      { type = "item", name = "assembling-machine-3", amount = 1 },
      { type = "item", name = "quality-module-2", amount = 3 },
      { type = "item", name = "advanced-circuit", amount = 80 },
      { type = "item", name = "processing-unit", amount = 20 },
      { type = "item", name = "battery", amount = 80 }
    }
  },
  {
    tier = 3,
    equipment = MOD_PREFIX .. "personal-assembler-3-equipment",
    item = MOD_PREFIX .. "personal-assembler-3-equipment",
    recipe = MOD_PREFIX .. "personal-assembler-3-equipment",
    entity = MOD_PREFIX .. "personal-assembler-3-entity",
    base_entity = "assembling-machine-3",
    technology = "quality-module-3",
    crafting_speed = 2.0,
    module_slots = 4,
    energy_usage = "600kW",
    buffer_capacity = "8MJ",
    input_flow_limit = "1200kW",
    order = "a[personal-assembler]-c[tier-3]",
    ingredients = {
      { type = "item", name = "assembling-machine-3", amount = 2 },
      { type = "item", name = "quality-module-3", amount = 4 },
      { type = "item", name = "processing-unit", amount = 80 },
      { type = "item", name = "low-density-structure", amount = 40 },
      { type = "item", name = "battery", amount = 160 }
    }
  }
}

local function icon_for_item(item_name)
  local item = data.raw.item[item_name]
  if item and item.icon then
    return item.icon, item.icon_size or 64
  end

  return "__base__/graphics/icons/" .. item_name .. ".png", 64
end

local function icons_for_item(item_name)
  local item = data.raw.item[item_name]
  if item and item.icons then
    return table.deepcopy(item.icons)
  end

  local icon, icon_size = icon_for_item(item_name)
  return {
    {
      icon = icon,
      icon_size = icon_size
    }
  }
end

local function assembler_tooltip_fields(spec)
  return {
    {
      name = { "player-quality.crafting-speed" },
      value = tostring(spec.crafting_speed),
      show_in_tooltip = true,
      show_in_factoriopedia = true,
      order = 40
    },
    {
      name = { "player-quality.module-slots" },
      value = tostring(spec.module_slots),
      show_in_tooltip = true,
      show_in_factoriopedia = true,
      order = 41
    },
    {
      name = { "player-quality.armor-energy-draw" },
      value = spec.energy_usage,
      show_in_tooltip = true,
      show_in_factoriopedia = true,
      order = 42
    }
  }
end

local function make_hidden_assembler(spec)
  local base = data.raw["assembling-machine"][spec.base_entity] or data.raw["assembling-machine"]["assembling-machine-3"]
  local assembler = table.deepcopy(base)

  assembler.name = spec.entity
  assembler.localised_name = { "entity-name." .. spec.entity }
  assembler.localised_description = { "entity-description." .. spec.entity }
  assembler.flags = {
    "not-on-map",
    "not-blueprintable",
    "not-deconstructable",
    "not-flammable",
    "hide-alt-info",
    "placeable-off-grid"
  }
  assembler.minable = nil
  assembler.next_upgrade = nil
  assembler.fast_replaceable_group = nil
  assembler.corpse = nil
  assembler.dying_explosion = nil
  assembler.collision_mask = { layers = {} }
  assembler.energy_source = {
    type = "void"
  }
  assembler.energy_usage = spec.energy_usage
  assembler.crafting_speed = spec.crafting_speed
  assembler.module_slots = spec.module_slots

  return assembler
end

local prototypes = {}

for _, spec in pairs(assembler_specs) do
  local icon, icon_size = icon_for_item(spec.base_entity)

  table.insert(prototypes, make_hidden_assembler(spec))

  table.insert(prototypes, {
    type = "battery-equipment",
    name = spec.equipment,
    sprite = {
      filename = icon,
      size = icon_size,
      priority = "medium"
    },
    shape = {
      width = 4,
      height = 4,
      type = "full"
    },
    energy_source = {
      type = "electric",
      buffer_capacity = spec.buffer_capacity,
      input_flow_limit = spec.input_flow_limit,
      usage_priority = "tertiary"
    },
    custom_tooltip_fields = assembler_tooltip_fields(spec),
    take_result = spec.item,
    categories = { "armor" }
  })

  table.insert(prototypes, {
    type = "item",
    name = spec.item,
    icons = icons_for_item(spec.base_entity),
    subgroup = "equipment",
    order = spec.order,
    stack_size = 10,
    place_as_equipment_result = spec.equipment
  })

  table.insert(prototypes, {
    type = "recipe",
    name = spec.recipe,
    enabled = false,
    energy_required = 20,
    ingredients = spec.ingredients,
    results = {
      { type = "item", name = spec.item, amount = 1 }
    }
  })
end

table.insert(prototypes, {
  type = "custom-input",
  name = MOD_PREFIX .. "toggle-gui",
  key_sequence = "CONTROL + SHIFT + Q",
  consuming = "none",
  order = "a"
})

table.insert(prototypes, {
  type = "shortcut",
  name = MOD_PREFIX .. "toggle-shortcut",
  action = "lua",
  associated_control_input = MOD_PREFIX .. "toggle-gui",
  icons = icons_for_item("assembling-machine-3"),
  small_icons = icons_for_item("assembling-machine-3"),
  order = "a[player-quality]"
})

data:extend(prototypes)

for _, spec in pairs(assembler_specs) do
  local technology = data.raw.technology[spec.technology]
  if technology then
    technology.effects = technology.effects or {}
    table.insert(technology.effects, {
      type = "unlock-recipe",
      recipe = spec.recipe
    })
  elseif data.raw.recipe[spec.recipe] then
    data.raw.recipe[spec.recipe].enabled = false
  end
end
