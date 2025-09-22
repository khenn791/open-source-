-- beta by khen.cc

local HttpService = game:GetService("HttpService")

function discord_Info()
    local url = "https://discord.com/api/v9/invites/9e2NguKugZ?with_counts=true"
    local request = (syn and syn.request) or (http and http.request) or (HttpService and HttpService.RequestAsync) or request
    local content = {}
    pcall(function()
        local response = request({
            Url = url,
            Method = "GET",
            Headers = {["Content-Type"] = "application/json"}
        })
        if response.StatusCode == 200 then
            local decoded = HttpService:JSONDecode(response.Body)
            content = {
                server_name = decoded["guild"] and decoded["guild"]["name"] or "Unknown",
                token = decoded["code"] or "",
                member_count = decoded["approximate_member_count"] or 0,
                online_count = decoded["approximate_presence_count"] or 0
            }
        end
    end)
    return content
end

local Library = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local Window = Library:CreateWindow({
    Name = "khen.cc",
    Icon = 0,
    LoadingTitle = "...",
    LoadingSubtitle = "test",
    Theme = "Default",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "SaverForsaken",
        FileName = "K"
    },
    Discord = {
        Enabled = false,
        Invite = "noinvitelink",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "Untitled",
        Subtitle = "Key System",
        Note = "",
        FileName = "Key",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = {"Hello"}
    }
})

local gay = Window:CreateTab("Discord Status")

local data = discord_Info()
if next(data) ~= nil then
    gay:CreateLabel(
        "Server: "..data.server_name..
        " | Members: "..tostring(data.member_count)..
        " | Online: "..tostring(data.online_count)
    )
else
    gay:CreateLabel("error: Failed to load data")
end

gay:CreateButton({
    Name = "Copy Discord Invite",
    Callback = function()
        local d = discord_Info()
        if d.token and d.token ~= "" then
            if setclipboard then setclipboard("https://discord.gg/"..d.token) end
            Library:Notify({
                Title = "Discord",
                Content = "Copied invite: discord.gg/"..d.token,
                Duration = 5
            })
        end
    end
})
