-- Data-only reproduction. Never executes scripts from the source place.
local nodes = require(script.Parent.Data)
local Templates = {}
local byId, byPath, byName, children = {}, {}, {}, {}
for _, node in nodes do
 byId[node.id] = node
 byPath[node.path] = byPath[node.path] or {}
 table.insert(byPath[node.path], node)
 byName[node.name] = byName[node.name] or {}
 table.insert(byName[node.name], node)
 children[node.parent] = children[node.parent] or {}
 table.insert(children[node.parent], node)
end
local function resolve(key)
 if type(key) == "number" then return assert(byId[key], "Unknown template ID") end
 if byPath[key] then
  assert(#byPath[key]==1,"Ambiguous template path; use its numeric ID: "..key)
  return byPath[key][1]
 end
 local matches = byName[key]
 assert(matches and #matches > 0, "Unknown template: " .. tostring(key))
 assert(#matches == 1, "Ambiguous template name; use its full path or ID: " .. key)
 return matches[1]
end
function Templates.List(query)
 local result = {}
 query = query and string.lower(query)
 for _, n in nodes do
  if not query or string.find(string.lower(n.path), query, 1, true) then
   table.insert(result, {Id=n.id, Path=n.path, Name=n.name, ClassName=n.class})
  end
 end
 return result
end
function Templates.Describe(key) return table.clone(resolve(key)) end
function Templates.Clone(key, parent, overrides)
 local root = resolve(key)
 local made, references, errors = {}, {}, {}
 local function build(n, container)
  local object = Instance.new(n.class)
  object.Name = n.name
  made[n.id] = object
  for property, value in n.properties do
   if type(value) == "table" and value.__ref then
    table.insert(references, {object, property, value.__ref})
   else
    local ok, err = pcall(function() object[property] = value end)
    if not ok then table.insert(errors, n.path .. "." .. property .. ": " .. tostring(err)) end
   end
  end
  for name, value in n.attributes do object:SetAttribute(name, value) end
  for _, tag in n.tags do object:AddTag(tag) end
  for _, child in children[n.id] or {} do
   -- Preserve intermediate containers as inert Folders (never Script/Part).
   local target = object
   local relative = string.sub(child.path, #n.path + 2)
   local parts = string.split(relative, ".")
   for i=1,#parts-1 do
    local folder = target:FindFirstChild(parts[i])
    if not folder then folder=Instance.new("Folder"); folder.Name=parts[i]; folder.Parent=target end
    target=folder
   end
   build(child, target)
  end
  object.Parent=container
  return object
 end
 local result=build(root,nil)
 for _, ref in references do
  if made[ref[3]] then
   local ok,err=pcall(function() ref[1][ref[2]]=made[ref[3]] end)
   if not ok then table.insert(errors,tostring(err)) end
  end
 end
 for property,value in overrides or {} do result[property]=value end
 result.Parent=parent
 return result, errors, made
end
return Templates
