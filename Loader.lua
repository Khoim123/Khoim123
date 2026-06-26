local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()


local Window = Fluent:CreateWindow({
    Title = "Negen hub" ,
    SubTitle = "by ThanhKhoi",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

Fluent:Notify({
        Title = "Negen hub",
        Content = "Script is free",
        SubContent = "By ThanhKhoi", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
})

-- Fluent provides Lucide Icons, they are optional
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

Window:SelectTab(1)

local DialogButton = Tabs.Main:AddButton({
    Title = "Mở Dialog",
    Description = "Click để hiện dialog xác nhận",
    Callback = function()
        Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                { 
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end 
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end 
                }
            }
        })
    end
})

local DialogButton = Tabs.Main:AddButton({
    Title = "Mở Dialog",
    Description = "Click để hiện dialog xác nhận",
    Callback = function()
        Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                { 
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end 
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end 
                }
            }
        })
    end
})

local DialogButton = Tabs.Main:AddButton({
    Title = "Mở Dialog",
    Description = "Click để hiện dialog xác nhận",
    Callback = function()
        Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                { 
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end 
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end 
                }
            }
        })
    end
})

local DialogButton = Tabs.Main:AddButton({
    Title = "Mở Dialog",
    Description = "Click để hiện dialog xác nhận",
    Callback = function()
        Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                { 
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end 
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end 
                }
            }
        })
    end
})

local DialogButton = Tabs.Main:AddButton({
    Title = "Mở Dialog",
    Description = "Click để hiện dialog xác nhận",
    Callback = function()
        Window:Dialog({
            Title = "Title",
            Content = "This is a dialog",
            Buttons = {
                { 
                    Title = "Confirm",
                    Callback = function()
                        print("Confirmed the dialog.")
                    end 
                },
                {
                    Title = "Cancel",
                    Callback = function()
                        print("Cancelled the dialog.")
                    end 
                }
            }
        })
    end
})