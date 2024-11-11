print("Hello world!")
local RunService = game:GetService("RunService")
if (RunService:IsRunMode() or RunService:IsRunning()) then
	return
end

-- Create the plugin toolbar and button
local toolbar = plugin:CreateToolbar("Visibility Manager")
print("Hello world!")
local toggleButton = toolbar:CreateButton(
	"V.2 Quick Visibility Tool", 
	"Toggle visibility of selected instance's children", 
	"rbxassetid://87906108033242")

toggleButton.ClickableWhenViewportHidden = true
-- Dock widget setup for the plugin UI
local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	true,  -- Initially enabled
	true,  -- Can override other widgets
	300,   -- Default width
	400,   -- Default height
	300,   -- Min width
	400    -- Min height,

)

local widget = plugin:CreateDockWidgetPluginGui("VisibilityToggler", widgetInfo)
widget.Title = "Visibility Manager"
widget.Enabled = false  -- Start hidden until toggled by button


-- Toggle widget visibility when the button is clicked
toggleButton.Click:Connect(function()
	widget.Enabled = not widget.Enabled
end)

-- Main UI container for the widget
local ui = Instance.new("ScrollingFrame", widget)
ui.Size = UDim2.new(1, 0, 1, 0)
ui.CanvasSize = UDim2.new(0, 0, 1, 0)
ui.ScrollBarThickness = 8

-- Create a new GuiObject with a Color property
local backgroundColor = Instance.new("Frame")
backgroundColor.BackgroundColor3 = Color3.new(1, 1, 1)  
backgroundColor.Size = UDim2.new(1, 0, 1, 0)
backgroundColor.Position = UDim2.new(0, 0, 0, 0)
backgroundColor.Parent = ui

-- Header for the widget
local title = Instance.new("TextLabel", ui)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Toggle Child Visibility"
title.TextSize = 16
title.Font = Enum.Font.SciFi
title.TextColor3 = Color3.fromRGB(8, 8, 8)
title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundTransparency = 0

-- Function to clear UI
local function clearUI()
	for _, child in ipairs(ui:GetChildren()) do
		if child:IsA("Frame") and child ~= title and child ~= backgroundColor then
			child:Destroy()
		end
	end
end

-- Function to create a toggle button for each child
local function createCheckbox(child, isParent)
	local childName = child.Name
	local isVisible = child.Visible

	local checkboxFrame = Instance.new("Frame")
	checkboxFrame.Size = UDim2.new(1, -20, 0, 30)
	checkboxFrame.BackgroundTransparency = 1

	local checkbox = Instance.new("TextButton", checkboxFrame)
	checkbox.Size = UDim2.new(0, 20, 1, 0)
	checkbox.Position = UDim2.new(0, 0, 0, 0)
	checkbox.Text = isVisible and "✓" or ""
	checkbox.BackgroundColor3 = isVisible and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)

	local label = Instance.new("TextLabel", checkboxFrame)
	label.Size = UDim2.new(1, -30, 1, 0)
	label.Position = UDim2.new(0, 30, 0, 0)
	label.Text = isParent and childName .. "(Parent)" or childName
	label.TextSize = 14
	label.Font = Enum.Font.SourceSans
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.fromRGB(0, 0, 0)
	label.Font = Enum.Font.SciFi
	-- Toggle the visibility on click
	checkbox.MouseButton1Click:Connect(function()
		child.Visible = not child.Visible
		checkbox.Text = child.Visible and "✓" or ""
		checkbox.BackgroundColor3 = child.Visible and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
	end)

	return checkboxFrame
end

-- Function to populate UI with checkboxes for each child that has a Visible property
local function populateUI(selectedInstance)
	clearUI()  -- Clear existing checkboxes
	title.Text = "Target: " .. selectedInstance.Name

	local layoutY = 40

	-- Handle Parent (selected instance)

	if (selectedInstance:IsA("GuiObject")) then
		local checkboxFrame = createCheckbox(selectedInstance, true)
		checkboxFrame.Position = UDim2.new(0, 10, 0, layoutY)
		checkboxFrame.Parent = ui
		layoutY = layoutY + 35  -- Move down for the next checkbox
	end



	for _, child in ipairs(selectedInstance:GetChildren()) do
		if child:IsA("Instance") and child:IsA("GuiObject") then
			-- Create checkbox only if the child has a Visible property
			local checkboxFrame = createCheckbox(child)
			checkboxFrame.Position = UDim2.new(0, 10, 0, layoutY)
			checkboxFrame.Parent = ui
			layoutY = layoutY + 35  -- Move down for the next checkbox
		end
	end


end

-- Detect selection changes
game:GetService("Selection").SelectionChanged:Connect(function()
	local selectedInstance = game:GetService("Selection"):Get()  -- Get the first selected object

	if (#selectedInstance == 1) then
		print(selectedInstance[1].Name)
		-- Populate UI with checkboxes for the children of the selected instance
		populateUI(selectedInstance[1])
	else
		-- Clear UI if there is no valid selection
		clearUI()
		title.Text = "Select an Instance"
	end
end)
