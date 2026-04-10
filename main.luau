if not game:IsLoaded() then game.Loaded:Wait(); end;

local cloneref = cloneref or function(i: Instance) return i; end;
local clonefunction = clonefunction or function(f: (...any) -> (...any)) return f; end;
local newcclosure = newcclosure or clonefunction;
local executor = (identifyexecutor and select(2, pcall(identifyexecutor))) and identifyexecutor() or "Your executor";
local SG = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-notifications/refs/heads/main/main.luau"))();

if not (hookfunction and (filtergc or (getgc and debug.getconstants))) then
    local err = executor .. " is missing " .. (not hookfunction and "hookfunction " or "") .. (not (filtergc and (getgc and debug.getconstants)) and "filtergc getgc debug.getconstants" or "")
    SG["error"](err);
    return error(err);
end;

local RS: ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"));
local Players: Players = cloneref(game:GetService("Players"));
local UIS: UserInputService = cloneref(game:GetService("UserInputService"));

local plr = Players.LocalPlayer;
local cam = workspace.CurrentCamera;

local filter: (script: (LocalScript|ModuleScript)?, strict: boolean, ...any) -> ((...any) -> (...any)) = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-filtergc/refs/heads/main/main.luau"))();

local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled and not UIS.MouseEnabled;

local cont = plr.PlayerScripts:FindFirstChild("Controller");
if not cont then
    local err = "Script needs updating";
    SG["error"](err);
    return warn(err);
end;
cont = filter(cont, false, "Bullet", "EasterEggThing", "SCP-066");
if not cont then
    local err = "Failed to retrieve function";
    SG["error"](err);
    return warn(err);
end;

local teams = loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/SCP-Roleplay-Silent-Aim-Keyless/refs/heads/main/Teams.luau"))();

local isSameTeam = function(player: Player): boolean
    return teams[plr.Team.Name] == teams[player.Team.Name];
end;

local rp = RaycastParams.new();
rp.FilterType = Enum.RaycastFilterType.Exclude;
rp.IgnoreWater = true;

local isVisible = function(part: BasePart, origin: Vector3): (boolean, Instance?)
    local char = plr.Character;
    if not (char and part) then return false, nil; end;

    rp.FilterDescendantsInstances = {char};

    local dir = part.Position - origin;
    local result: RaycastResult = workspace:Raycast(origin, dir, rp);
    if not result then return true, nil; end;

    if result.Instance:IsDescendantOf(part.Parent) then
        return true, result.Instance;
    end;

    return false, result.Instance;
end;

local getTarget = function(origin: Vector3)
    local cPart, cDistance = nil, getgenv().fov or 300;

    for _, player: Player in next, Players:GetPlayers() do
        if player == plr or isSameTeam(player) then continue; end;

        local char = player.Character;
        if not char or char:FindFirstChildOfClass("ForceField") or (char:FindFirstChild("Humanoid") and char.Humanoid.Health <= 0) then continue; end;

        local tPart: BasePart = char:FindFirstChild("Head") or char.PrimaryPart or char:FindFirstChild("HumanoidRootPart");
        if not tPart then continue; end;

        local pos, onScreen = cam:WorldToViewportPoint(tPart.Position);
        if not onScreen then continue; end;

        local v, nTPart = isVisible(tPart, origin);
        if not v then
            v, nTPart = isVisible(char.PrimaryPart or char:FindFirstChild("HumanoidRootPart"), origin);
            if not v then continue; end;
        end;

        if nTPart then tPart = nTPart; end;

        local distance = (Vector2.new(pos.X, pos.Y) - (isMobile and Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2) or UIS:GetMouseLocation())).Magnitude;
        if distance < cDistance then
            cPart = tPart;
            cDistance = distance;
        end;
    end;

    return cPart;
end;

loadstring(game:HttpGet("https://raw.githubusercontent.com/sneekygoober/sneeky-s-fov-lib/refs/heads/main/main.luau"))()(getgenv().fov or 300, getTarget, true);

local old; old = clonefunction(hookfunction(cont, newcclosure(function(_, __, ...)
    local origin = cam.CFrame.Position;
    local c = getTarget(origin);
    if c then
        return old(_, {
            ["Instance"] = c,
            ["Position"] = c.Position,
            ["Normal"] = Vector3.new(0, 1, 0),
            ["Material"] = c.Material
        }, ...);
    end;
    return old(_, __, ...);
end)));

SG["success"]("Silent aim successfully executed!\nIf you have any issues press F9 or type /console in chat and then send me a screenshot of the console.");
