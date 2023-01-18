local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local NetManaged = ReplicatedStorage.rbxts_include.node_modules.net.out._NetManaged 

function GetItem(Name)
    for i, v in pairs(Player.Backpack:GetChildren()) do
        if v:FindFirstChild("DisplayName") and v.DisplayName.Value == Name then
            return v
        end
    end
    return nil
end

function TeleportItem(Name, Part)
    for i, v in pairs(workspace.Islands:GetChildren()) do
        for i2, v2 in pairs(v.Drops:GetChildren()) do
            if v2.Name == Name and v2:FindFirstChildWhichIsA("BasePart") then
                v2:FindFirstChildWhichIsA("BasePart").CFrame = Part.CFrame
            end
        end
    end
end

function Deposit(Block, Name)
    task.spawn(function()
        NetManaged.CLIENT_BLOCK_WORKER_DEPOSIT_TOOL_REQUEST:InvokeServer({
            ["amount"] = 1,
            ["block"] = Block,
            ["player_tracking_category"] = "join_from_web",
            ["toolName"] = Name
        })
    end)
end

task.spawn(function()
    while task.wait() and Config.AutoCopperPress do
        for i, v in pairs(workspace.Islands:GetChildren()) do
            for i2, v2 in pairs(v.Blocks:GetChildren()) do
                if v2.Name == "copperPress" then
                    task.spawn(function()
                        local Tool = GetItem("Copper Ingot")

                        if Tool then
                            task.spawn(function()
                                NetManaged.CLIENT_DROP_TOOL_REQUEST:InvokeServer({
                                    ["player_tracking_category"] = "join_from_web", 
                                    ["tool"] = Tool, 
                                    ["amount"] = 1 
                                })
                            end)
                            TeleportItem(Tool.Name, v2.Processor.Input)
                        end
                    end)
                end
            end
        end
    end
end)

task.spawn(function()
    while task.wait() and Config.AutoOven do
        local Tool = Player.Character and Player.Character:FindFirstChildWhichIsA("Tool")
            
        for i, v in pairs(workspace.Islands:GetChildren()) do
            for i2, v2 in pairs(v.Blocks:GetChildren()) do
                if v2.Name == "ovenIndustrial" and #v2.WorkerContents:GetChildren() < 3 and Tool then
                    Deposit(v2, Tool)
                    Deposit(v2, "coal")
                end
            end
        end
    end
end)
