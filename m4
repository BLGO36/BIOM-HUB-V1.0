local function cloneToBackpack(toolName)
   local clonedTool = toolName:Clone()
   clonedTool.Parent = game:GetService("Players").LocalPlayer:WaitForChild("Backpack")
end

for i, v in pairs(game:GetDescendants()) do
   if v:IsA("Tool") and v.Name == "M4" and v.Parent.Parent ~= game:GetService("Players").LocalPlayer then
      cloneToBackpack(v)
      break
   end
end
