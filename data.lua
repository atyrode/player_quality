local MOD_PREFIX = "player-quality-"

local equipment_specs = {
  {
    module = "quality-module",
    equipment = MOD_PREFIX .. "quality-module-equipment",
    item = MOD_PREFIX .. "quality-module-equipment",
    recipe = MOD_PREFIX .. "quality-module-equipment",
    technology = "quality-module",
    order = "a[quality-module-equipment]-a[quality-module]",
    ingredients = {
      { type = "item", name = "quality-module", amount = 1 },
      { type = "item", name = "electronic-circuit", amount = 5 },
      { type = "item", name = "battery", amount = 2 }
    }
  },
  {
    module = "quality-module-2",
    equipment = MOD_PREFIX .. "quality-module-2-equipment",
    item = MOD_PREFIX .. "quality-module-2-equipment",
    recipe = MOD_PREFIX .. "quality-module-2-equipment",
    technology = "quality-module-2",
    order = "a[quality-module-equipment]-b[quality-module-2]",
    ingredients = {
      { type = "item", name = "quality-module-2", amount = 1 },
      { type = "item", name = "advanced-circuit", amount = 5 },
      { type = "item", name = "battery", amount = 4 }
    }
  },
  {
    module = "quality-module-3",
    equipment = MOD_PREFIX .. "quality-module-3-equipment",
    item = MOD_PREFIX .. "quality-module-3-equipment",
    recipe = MOD_PREFIX .. "quality-module-3-equipment",
    technology = "quality-module-3",
    order = "a[quality-module-equipment]-c[quality-module-3]",
    ingredients = {
      { type = "item", name = "quality-module-3", amount = 1 },
      { type = "item", name = "processing-unit", amount = 5 },
      { type = "item", name = "battery", amount = 8 }
    }
  }
}

local function module_icon(module_name)
  local module = data.raw.module[module_name]
  if module and module.icon then
    return module.icon, module.icon_size or 64
  end

  return "__quality__/graphics/icons/" .. module_name .. ".png", 64
end

local function module_icons(module_name)
  local module = data.raw.module[module_name]
  if module and module.icons then
    return table.deepcopy(module.icons)
  end

  local icon, icon_size = module_icon(module_name)
  return {
    {
      icon = icon,
      icon_size = icon_size
    }
  }
end

local prototypes = {}

for _, spec in pairs(equipment_specs) do
  local icon, icon_size = module_icon(spec.module)

  table.insert(prototypes, {
    type = "battery-equipment",
    name = spec.equipment,
    sprite = {
      filename = icon,
      size = icon_size,
      priority = "medium"
    },
    shape = {
      width = 1,
      height = 1,
      type = "full"
    },
    energy_source = {
      type = "electric",
      buffer_capacity = "1J",
      input_flow_limit = "1W",
      output_flow_limit = "1W",
      usage_priority = "tertiary"
    },
    take_result = spec.item,
    categories = { "armor" }
  })

  table.insert(prototypes, {
    type = "item",
    name = spec.item,
    icons = module_icons(spec.module),
    subgroup = "equipment",
    order = spec.order,
    stack_size = 20,
    place_as_equipment_result = spec.equipment
  })

  table.insert(prototypes, {
    type = "recipe",
    name = spec.recipe,
    enabled = false,
    energy_required = 10,
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
  icons = module_icons("quality-module"),
  small_icons = module_icons("quality-module"),
  order = "a[player-quality]"
})

data:extend(prototypes)

for _, spec in pairs(equipment_specs) do
  local technology = data.raw.technology[spec.technology]
  if technology then
    technology.effects = technology.effects or {}
    table.insert(technology.effects, {
      type = "unlock-recipe",
      recipe = spec.recipe
    })
  elseif data.raw.recipe[spec.recipe] then
    data.raw.recipe[spec.recipe].enabled = true
  end
end
