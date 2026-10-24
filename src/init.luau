-- Mansion UI - standalone client-side UI components and exact visual templates.
local TweenService=game:GetService("TweenService")
local UserInputService=game:GetService("UserInputService")
local GuiService=game:GetService("GuiService")
local Theme=require(script.Theme)
local Templates=require(script.Templates)
local UI={Theme=Theme,Templates=Templates,Version="1.0.0"}
local colors=table.clone(Theme.Colors)
local tracked=setmetatable({}, {__mode="k"})
local states=setmetatable({}, {__mode="k"})
local hoverBound=setmetatable({}, {__mode="k"})
local activeDropdown=nil
local tooltip=nil
local tooltipsEnabled=true
local function track(object,property,token)
 tracked[object]=tracked[object] or {}
 tracked[object][property]=token
 object[property]=colors[token] or token
end
local function manage(object)
 local connections={}
 local function connect(signal,fn)
  local c=signal:Connect(fn);table.insert(connections,c);return c
 end
 object.Destroying:Once(function()
  for _,c in connections do c:Disconnect() end
  tracked[object]=nil;states[object]=nil;hoverBound[object]=nil
 end)
 return connect
end
local function apply(object,props)
 for k,v in props or {} do if k~="Parent" then object[k]=v end end
 if props and props.Parent then object.Parent=props.Parent end
 return object
end
function UI.Create(className,props,children)
 local o=Instance.new(className)
 local ok,err=pcall(function() apply(o,props);for _,child in children or {} do child.Parent=o end end)
 if not ok then o:Destroy();error(err,2) end
 return o
end
UI.New=UI.Create
function UI.Clone(key,parent,overrides) return Templates.Clone(key,parent,overrides) end
function UI.GetColor(token) return assert(colors[token],"Unknown color token: "..tostring(token)) end
function UI.SetTheme(mode,overrides)
 colors=table.clone(Theme.Colors)
 if mode=="dark" then for k,v in Theme.Dark do colors[k]=v end end
 for k,v in overrides or {} do colors[k]=v end
 for o,props in tracked do for p,t in props do o[p]=colors[t] or t end end
end
function UI.SetThemeColor(token,color)
 colors[token]=color
 for o,props in tracked do for p,t in props do if t==token then o[p]=color end end end
end
function UI.BindColor(object,property,token) track(object,property,token);return object end
function UI.Corner(parent,radius) return UI.Create("UICorner",{CornerRadius=UDim.new(0,radius or Theme.Radius),Parent=parent}) end
function UI.Stroke(parent,props) return UI.Create("UIStroke",apply({Color=colors.NeutralLight,Thickness=1},props),nil) end
-- Stroke uses the parent argument consistently with the other modifier helpers.
local stroke=UI.Stroke
UI.Stroke=function(parent,props) local o=stroke(parent,props);o.Parent=parent;return o end
function UI.Gradient(parent,props) local o=UI.Create("UIGradient",props);o.Parent=parent;return o end
function UI.Padding(parent,amount)
 amount=amount or 7
 return UI.Create("UIPadding",{PaddingTop=UDim.new(0,amount),PaddingBottom=UDim.new(0,amount),PaddingLeft=UDim.new(0,amount),PaddingRight=UDim.new(0,amount),Parent=parent})
end
function UI.List(parent,props) local o=UI.Create("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder});apply(o,props);o.Parent=parent;return o end
function UI.Grid(parent,props) local o=UI.Create("UIGridLayout",{CellSize=UDim2.fromOffset(100,100),CellPadding=UDim2.fromOffset(7,7),SortOrder=Enum.SortOrder.LayoutOrder});apply(o,props);o.Parent=parent;return o end
function UI.Screen(parent,props) local o=UI.Create("ScreenGui",{Name="MansionUI",ResetOnSpawn=false,ZIndexBehavior=Enum.ZIndexBehavior.Sibling});apply(o,props);o.Parent=parent;return o end
function UI.Surface(parent,props) local o=UI.Create("SurfaceGui",props);o.Parent=parent;return o end
function UI.Billboard(parent,props) local o=UI.Create("BillboardGui",props);o.Parent=parent;return o end
function UI.Canvas(parent,props) local o=UI.Create("CanvasGroup",props);o.Parent=parent;return o end
function UI.Viewport(parent,props) local o=UI.Create("ViewportFrame",props);o.Parent=parent;return o end
function UI.Frame(parent,props)
 local o=UI.Create("Frame",{BorderSizePixel=0,Size=UDim2.fromOffset(250,100)})
 track(o,"BackgroundColor3","Background");apply(o,props);o.Parent=parent;return o
end
function UI.Panel(parent,props)
 local o=UI.Create("ImageLabel",{Name="Panel",BackgroundTransparency=1,Image=Theme.PanelImage,ScaleType=Enum.ScaleType.Slice,SliceCenter=Theme.SliceCenter,SliceScale=Theme.SliceScale,Size=UDim2.fromOffset(500,300)})
 track(o,"ImageColor3","Background");apply(o,props);o.Parent=parent;return o
end
function UI.Label(parent,text,props)
 local o=UI.Create("TextLabel",{Name="Label",Text=text or "",Font=Theme.Font,TextSize=Theme.TextSize,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextWrapped=true,Size=UDim2.new(1,0,0,30)})
 track(o,"TextColor3","Text");apply(o,props);o.Parent=parent;return o
end
function UI.Icon(parent,image,props)
 local o=UI.Create("ImageLabel",{Name="Icon",BackgroundTransparency=1,Image=image or "",Size=UDim2.fromOffset(30,30)})
 apply(o,props);o.Parent=parent;return o
end
function UI.ImageButton(parent,image,callback,props)
 local o=UI.Create("ImageButton",{BackgroundTransparency=1,Image=image or "",Size=UDim2.fromOffset(40,40),AutoButtonColor=false})
 apply(o,props);o.Parent=parent;UI.HoverEffect(o)
 if callback then manage(o)(o.Activated,function(...) if UI.GetButtonState(o) then callback(...) end end) end
 return o
end
function UI.Button(parent,text,callback,props)
 local o=UI.ImageButton(parent,Theme.ButtonImage,nil,{Name="Button",ScaleType=Enum.ScaleType.Slice,SliceCenter=Theme.SliceCenter,SliceScale=Theme.SliceScale,Size=UDim2.fromOffset(160,40)})
 track(o,"ImageColor3","Main")
 UI.Label(o,text,{Name="TextLabel",Font=Theme.Bold,TextColor3=colors.ButtonLabel,TextXAlignment=Enum.TextXAlignment.Center,Position=UDim2.fromOffset(10,3),Size=UDim2.new(1,-20,1,-8)})
 apply(o,props)
 if callback then manage(o)(o.Activated,function(...) if UI.GetButtonState(o) then callback(...) end end) end
 return o
end
function UI.SetButtonState(button,enabled)
 states[button]=enabled
 button.Active=enabled;button.Selectable=enabled
 button:SetAttribute("MansionEnabled",enabled)
 if button:IsA("ImageButton") then button.ImageTransparency=enabled and 0 or 0.55 else button.TextTransparency=enabled and 0 or 0.55 end
end
function UI.GetButtonState(button) return states[button]~=false end
function UI.HoverEffect(button,amount)
 if hoverBound[button] then return button end
 hoverBound[button]=true
 local connect=manage(button)
 local key=button:IsA("ImageButton") and "ImageTransparency" or "BackgroundTransparency"
 local original=button[key]
 local tween=nil
 local function state(hover)
  if not UI.GetButtonState(button) then return end
  if tween then tween:Cancel() end
  tween=TweenService:Create(button,TweenInfo.new(0.12),{[key]=hover and math.min(1,original+(amount or 0.15)) or original});tween:Play()
 end
 connect(button.MouseEnter,function() state(true) end);connect(button.MouseLeave,function() state(false) end)
 connect(button.SelectionGained,function() state(true) end);connect(button.SelectionLost,function() state(false) end)
 return button
end
function UI.PressedButtonEffect(button)
 local connect=manage(button)
 local scale=button:FindFirstChild("MansionPressScale") or UI.Create("UIScale",{Name="MansionPressScale",Parent=button})
 connect(button.InputBegan,function(input)
  if UI.GetButtonState(button) and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch or input.KeyCode==Enum.KeyCode.ButtonA) then scale.Scale=0.97 end
 end)
 connect(UserInputService.InputEnded,function(input)
  if input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch or input.KeyCode==Enum.KeyCode.ButtonA then scale.Scale=1 end
 end)
 return button
end
UI.RoundedButtonEffect=UI.HoverEffect
function UI.SelectedButtonEffect(button,selected)
 local s=button:FindFirstChild("MansionSelection") or UI.Stroke(button,{Name="MansionSelection",Color=colors.Main,Thickness=2})
 s.Enabled=selected~=false;return s
end
function UI.SetHoverFunctions(button,onEnter,onLeave)
 local connect=manage(button)
 if onEnter then connect(button.MouseEnter,onEnter);connect(button.SelectionGained,onEnter) end
 if onLeave then connect(button.MouseLeave,onLeave);connect(button.SelectionLost,onLeave) end
end
function UI.GroupHoverEffect(group)
 for _,o in group:GetDescendants() do if o:IsA("GuiButton") then UI.HoverEffect(o) end end
end
function UI.Scroll(parent,props)
 local o=UI.Create("ScrollingFrame",{Name="ScrollFrame",BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ScrollBarThickness=8,TopImage="rbxassetid://296016482",MidImage="rbxassetid://472252033",BottomImage="rbxassetid://296016336"})
 apply(o,props);o.Parent=parent;return o
end
function UI.AdjustScrollSize(scroll) scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y end
function UI.TextInput(parent,placeholder,callback,props)
 local panel=UI.Panel(parent,{Name="Input",Size=UDim2.new(1,0,0,40),ImageColor3=colors.BackgroundSecondary})
 local box=UI.Create("TextBox",{Name="TextBox",Text="",PlaceholderText=placeholder or "",Font=Theme.Font,TextSize=24,TextColor3=colors.Text,PlaceholderColor3=colors.Neutral,BackgroundTransparency=1,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-20,1,0),Parent=panel})
 apply(panel,props)
 if callback then manage(box)(box.FocusLost,function(enter) callback(box.Text,enter) end) end
 return panel,box
end
function UI.Search(parent,callback,props)
 local panel,box=UI.TextInput(parent,"Search...",nil,props);panel.Name="SearchBox"
 if callback then manage(box)(box:GetPropertyChangedSignal("Text"),function() callback(box.Text) end) end
 return panel,box
end
UI.CreateSearch=UI.Search
local function controller(frame)
 local c={Frame=frame,Enabled=true}
 function c:SetEnabled(enabled)
  self.Enabled=enabled
  for _,v in self.Frame:GetDescendants() do if v:IsA("GuiButton") then UI.SetButtonState(v,enabled) end end
 end
 function c:Destroy() self.Frame:Destroy() end
 return c
end
function UI.Toggle(parent,text,initial,callback,props)
 local row=UI.Frame(parent,{Name="Toggle",BackgroundTransparency=1,Size=UDim2.new(1,0,0,40)})
 UI.Label(row,text,{Font=Theme.Bold,Size=UDim2.new(0.65,-7,1,0),TextXAlignment=Enum.TextXAlignment.Right})
 local c=controller(row);c.Value=initial==true
 local b=UI.Button(row,"",nil,{Position=UDim2.fromScale(0.65,0),Size=UDim2.new(0.35,0,1,0)})
 function c:Set(value,silent)
  self.Value=value==true;b.TextLabel.Text=self.Value and "ON" or "OFF";b.ImageColor3=self.Value and colors.Main or colors.NeutralLight
  if callback and not silent then callback(self.Value) end
 end
 manage(b)(b.Activated,function() if c.Enabled then c:Set(not c.Value) end end)
 c:Set(c.Value,true);apply(row,props);return c
end
function UI.Dropdown(parent,items,initial,callback,props)
 local row=UI.Panel(parent,{Name="Dropdown",Size=UDim2.new(1,0,0,40),ImageColor3=colors.BackgroundSecondary})
 local c=controller(row);c.Items=table.clone(items);c.Value=initial or items[1]
 local baseZ=row.ZIndex
 local b=UI.Button(row,tostring(c.Value or "Select"),nil,{Size=UDim2.fromScale(1,1),ImageColor3=colors.BackgroundSecondary})
 b.TextLabel.TextColor3=colors.Text
 local menu=UI.Panel(row,{Name="DropdownMenu",Position=UDim2.new(0,0,1,3),Size=UDim2.new(1,0,0,math.min(#items,5)*37+14),Visible=false,ZIndex=50})
 local scroll=UI.Scroll(menu,{Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,1,-14),ZIndex=51});UI.List(scroll)
 function c:Close() menu.Visible=false;row.ZIndex=baseZ;if activeDropdown==self then activeDropdown=nil end end
 function c:SetText(value) b.TextLabel.Text=value end
 function c:SetSelected(value,silent)
  assert(table.find(self.Items,value),"Dropdown selection is absent from Items")
  self.Value=value;self:SetText(tostring(value));self:Close();if callback and not silent then callback(value) end
 end
 function c:Update(values)
  self.Items=table.clone(values)
  for _,child in scroll:GetChildren() do if child:IsA("GuiObject") then child:Destroy() end end
  menu.Size=UDim2.new(1,0,0,math.min(#values,5)*37+14)
  for i,item in values do UI.Button(scroll,tostring(item),function() if c.Enabled then c:SetSelected(item) end end,{LayoutOrder=i,Size=UDim2.new(1,-8,0,30),ZIndex=52}) end
 end
 function c:MatchFrame(frame) row.Size=frame.Size;row.Position=frame.Position end
 manage(b)(b.Activated,function()
  if not c.Enabled then return end
  local show=not menu.Visible;if activeDropdown and activeDropdown~=c then activeDropdown:Close() end
  menu.Visible=show;row.ZIndex=show and math.max(baseZ,50) or baseZ;activeDropdown=show and c or nil
 end)
 manage(row)(UserInputService.InputBegan,function(input)
  if input.KeyCode==Enum.KeyCode.Escape then c:Close() end
  if menu.Visible and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then
   local p=input.Position;local a=row.AbsolutePosition;local s=row.AbsoluteSize;local h=s.Y+menu.AbsoluteSize.Y+3
   if p.X<a.X or p.X>a.X+s.X or p.Y<a.Y or p.Y>a.Y+h then c:Close() end
  end
 end)
 row.Destroying:Once(function() if activeDropdown==c then activeDropdown=nil end end)
 c:Update(items);apply(row,props);baseZ=row.ZIndex;return c
end
UI.CreateDropdown=UI.Dropdown
function UI.CloseDropdown() if activeDropdown then activeDropdown:Close() end end
function UI.Slider(parent,text,min,max,initial,step,callback,props)
 assert(max>min,"Slider maximum must exceed minimum")
 step=step or 1;assert(step>0,"Slider step must be positive")
 local row=UI.Frame(parent,{Name="Slider",BackgroundTransparency=1,Size=UDim2.new(1,0,0,65)})
 local label=UI.Label(row,text,{Size=UDim2.new(1,0,0,28)})
 local bar=UI.Button(row,"",nil,{Name="Bar",Position=UDim2.fromOffset(0,37),Size=UDim2.new(1,0,0,14),ImageColor3=colors.BackgroundSecondary})
 local fill=UI.Panel(bar,{Name="Fill",Size=UDim2.fromScale(0,1),ImageColor3=colors.Main})
 local knob=UI.Button(bar,"",nil,{Name="Knob",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0,0.5),Size=UDim2.fromOffset(22,26)})
 local c=controller(row);c.Value=initial or min
 function c:Set(value,silent)
  local clamped=math.clamp(min+math.round((value-min)/step)*step,min,max);self.Value=clamped
  local ratio=(clamped-min)/(max-min);fill.Size=UDim2.fromScale(ratio,1);knob.Position=UDim2.fromScale(ratio,0.5)
  label.Text=text..": "..string.format("%.4g",clamped)
  if callback and not silent then callback(clamped) end
 end
 local dragging=nil;local connect=manage(row)
 local function update(x) if c.Enabled and bar.AbsoluteSize.X>0 then c:Set(min+math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)*(max-min)) end end
 local function begin(input)
  if c.Enabled and (input.UserInputType==Enum.UserInputType.MouseButton1 or input.UserInputType==Enum.UserInputType.Touch) then dragging=input;update(input.Position.X) end
 end
 connect(bar.InputBegan,begin);connect(knob.InputBegan,begin)
 connect(UserInputService.InputChanged,function(input)
  if dragging and (input==dragging or input.UserInputType==Enum.UserInputType.MouseMovement and dragging.UserInputType==Enum.UserInputType.MouseButton1) then update(input.Position.X) end
 end)
 connect(UserInputService.InputEnded,function(input) if input==dragging then dragging=nil end end)
 connect(bar.InputBegan,function(input)
  if c.Enabled and (input.KeyCode==Enum.KeyCode.Left or input.KeyCode==Enum.KeyCode.DPadLeft) then c:Set(c.Value-step)
  elseif c.Enabled and (input.KeyCode==Enum.KeyCode.Right or input.KeyCode==Enum.KeyCode.DPadRight) then c:Set(c.Value+step) end
 end)
 c:Set(c.Value,true);apply(row,props);return c
end
function UI.Progress(parent,value,props)
 local back=UI.Panel(parent,{Name="Progress",Size=UDim2.new(1,0,0,24),ImageColor3=colors.BackgroundSecondary,ClipsDescendants=true})
 local fill=UI.Panel(back,{Name="Fill",Size=UDim2.fromScale(math.clamp(value or 0,0,1),1),ImageColor3=colors.Main})
 local c=controller(back)
 function c:Set(n) self.Value=math.clamp(n,0,1);fill.Size=UDim2.fromScale(self.Value,1) end
 c:Set(value or 0);apply(back,props);return c
end
function UI.UpdateProgressionBar(control,value,total) control:Set(total and value/total or value) end
function UI.Window(parent,title,props)
 local panel=UI.Panel(parent,{Name="Window",AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(500,450)})
 UI.Label(panel,title,{Name="Title",Font=Theme.Bold,Position=UDim2.fromOffset(14,3),Size=UDim2.new(1,-64,0,34)})
 local content=UI.Panel(panel,{Name="Content",ImageColor3=colors.BackgroundSecondary,Position=UDim2.fromOffset(7,40),Size=UDim2.new(1,-14,1,-47)})
 local scroll=UI.Scroll(content,{Name="Body",Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,1,-14)})
 UI.List(scroll)
 local c=controller(panel);c.Body=scroll
 function c:Open() panel.Visible=true end
 function c:Close() panel.Visible=false end
 local close=UI.Button(panel,"×",function() c:Close() end,{Name="Close",AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-7,0,4),Size=UDim2.fromOffset(30,30)})
 close.TextLabel.Position=UDim2.new()
 close.TextLabel.Size=UDim2.fromScale(1,1)
 close.TextLabel.TextSize=24
 apply(panel,props);return c
end
function UI.Section(parent,title,props)
 local panel=UI.Panel(parent,{Name="Section",Size=UDim2.new(1,-8,0,0),AutomaticSize=Enum.AutomaticSize.Y})
 UI.Padding(panel);UI.List(panel)
 UI.Label(panel,title,{Name="Title",LayoutOrder=-100,Size=UDim2.new(1,0,0,30)})
 apply(panel,props);return panel
end
function UI.Fit(window,viewport,padding)
 padding=padding or 24
 local scale=window:FindFirstChild("MansionFit") or UI.Create("UIScale",{Name="MansionFit",Parent=window})
 local size=window.Size
 assert(size.X.Scale==0 and size.Y.Scale==0,"Fit expects an offset-sized design canvas")
 scale.Scale=math.min(1,(viewport.X-padding*2)/size.X.Offset,(viewport.Y-padding*2)/size.Y.Offset)
 scale.Scale=math.max(0.1,scale.Scale);return scale
end
function UI.SetZIndex(root,z)
 local base=root:IsA("GuiObject") and root.ZIndex or 0
 if root:IsA("GuiObject") then root.ZIndex=z end
 for _,o in root:GetDescendants() do if o:IsA("GuiObject") then o.ZIndex=math.max(1,o.ZIndex+z-base) end end
end
UI.SetPromptZIndex=UI.SetZIndex
function UI.GetInset() return GuiService:GetGuiInset() end
function UI.GetPlayerlistHeight() return 0 end -- Core player-list geometry is not exposed.
function UI.LinkTextSize(labels)
 local connect=manage(labels[1]);local updating=false
 local function update()
  if updating then return end;updating=true
  local size=math.huge
  for _,o in labels do size=math.min(size,o.TextSize) end
  for _,o in labels do o.TextSize=size end;updating=false
 end
 for _,o in labels do connect(o:GetPropertyChangedSignal("TextSize"),update) end
 update()
end
function UI.ToggleAllGUI(container,enabled)
 for _,o in container:GetChildren() do if o:IsA("ScreenGui") then o.Enabled=enabled end end
end
function UI.TogglePrompt(window,enabled) window.Frame.Visible=enabled end
function UI.CreatePromptGUI(parent,title,props) return UI.Window(parent,title,props) end
function UI.CreateOverlay(parent,props)
 local o=UI.Create("TextButton",{Name="Overlay",Text="",BackgroundColor3=Color3.new(),BackgroundTransparency=0.45,BorderSizePixel=0,AutoButtonColor=false,Modal=true,Size=UDim2.fromScale(1,1),ZIndex=100})
 apply(o,props);o.Parent=parent;return o
end
function UI.CreateOverlayBlur(parent,size) return UI.Create("BlurEffect",{Name="MansionOverlayBlur",Size=size or 12,Parent=parent or game:GetService("Lighting")}) end
function UI.GetOverlayBlur(parent) return (parent or game:GetService("Lighting")):FindFirstChild("MansionOverlayBlur") end
function UI.Glow(object,color)
 local s=UI.Stroke(object,{Name="MansionGlow",Color=color or colors.Main,Thickness=3,Transparency=0.3})
 return s
end
function UI.CreateScrollGradient(scroll,props) return UI.Gradient(scroll,props) end
function UI.CenterSelectedInScrollingFrame(scroll,object)
 scroll.CanvasPosition=Vector2.new(scroll.CanvasPosition.X,math.max(0,scroll.CanvasPosition.Y+object.AbsolutePosition.Y-scroll.AbsolutePosition.Y-(scroll.AbsoluteSize.Y-object.AbsoluteSize.Y)/2))
end
function UI.ShowTooltip(parent,text,position)
 if not tooltipsEnabled then return end
 UI.HideTooltip()
 tooltip=UI.Panel(parent,{Name="Tooltip",Position=position or UDim2.fromOffset(20,20),Size=UDim2.fromOffset(250,55),ZIndex=200})
 UI.Label(tooltip,text,{Position=UDim2.fromOffset(7,7),Size=UDim2.new(1,-14,1,-14),TextSize=20,ZIndex=201})
 return tooltip
end
function UI.HideTooltip() if tooltip then tooltip:Destroy();tooltip=nil end end
function UI.ToggleTooltips(enabled) tooltipsEnabled=enabled;if not enabled then UI.HideTooltip() end end
function UI.AttachTooltip(object,text,parent)
 local connect=manage(object)
 local function show()
  local p=object.AbsolutePosition
  UI.ShowTooltip(parent or object:FindFirstAncestorOfClass("ScreenGui"),text,UDim2.fromOffset(p.X,p.Y+object.AbsoluteSize.Y+7))
 end
 connect(object.MouseEnter,show);connect(object.MouseLeave,UI.HideTooltip)
 connect(object.SelectionGained,show);connect(object.SelectionLost,UI.HideTooltip)
 object.Destroying:Once(UI.HideTooltip)
end
function UI.ShowLabel(parent,text,seconds,props)
 local o=UI.Label(parent,text,props)
 if seconds then task.delay(seconds,function() if o.Parent then o:Destroy() end end) end
 return o
end
function UI.CenterError(parent,text,seconds)
 return UI.ShowLabel(parent,text,seconds or 3,{TextColor3=colors.MainNegative,AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=UDim2.new(1,-28,0,60),ZIndex=150})
end
function UI.Notify(parent,title,message,seconds)
 local w=UI.Window(parent,title,{Name="Notification",Size=UDim2.fromOffset(340,150),AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-14,0,14)})
 UI.Label(w.Body,message,{TextSize=22,Size=UDim2.new(1,-7,0,65)})
 if seconds then task.delay(seconds,function() w:Destroy() end) end
 return w
end
function UI.MessageBox(parent,options)
 options=options or {}
 local overlay=UI.CreateOverlay(parent)
 local w=UI.Window(overlay,options.Title or "Message",{ZIndex=101,Size=UDim2.fromOffset(440,240)})
 UI.Label(w.Body,options.Message or "",{TextSize=24,Size=UDim2.new(1,-7,0,80)})
 local closed=false
 local function finish(value)
  if closed then return end;closed=true
  overlay:Destroy();if options.OnResult then options.OnResult(value) end
 end
 local actions=options.Actions or {{Text="OK",Value=true}}
 for i,action in actions do UI.Button(w.Body,action.Text,function() finish(action.Value) end,{LayoutOrder=i,Size=UDim2.new(1,-8,0,36)}) end
 function w:Close() finish(nil) end
 function w:Destroy() finish(nil) end
 return w
end
function UI.ConfirmBox(parent,options)
 options=table.clone(options or {});options.Actions=options.Actions or {{Text="Confirm",Value=true},{Text="Cancel",Value=false}}
 return UI.MessageBox(parent,options)
end
UI.AlertBox=UI.MessageBox
UI.MultiMessageBox=UI.MessageBox
function UI.InputBox(parent,options)
 options=table.clone(options or {})
 local result=options.OnResult;local input
 options.OnResult=function(value) if result then result(value==true and input.Text or nil) end end
 local w=UI.ConfirmBox(parent,options)
 local _,box=UI.TextInput(w.Body,options.Placeholder or "Enter value",nil,{LayoutOrder=-1})
 input=box;return w,box
end
function UI.RGB(parent,initial,callback,props)
 local panel=UI.Frame(parent,{BackgroundTransparency=1,Size=UDim2.new(1,0,0,215)})
 UI.List(panel)
 local c=controller(panel);c.Value=initial or colors.Main
 local sliders={}
 local function changed()
  c.Value=Color3.fromRGB(sliders[1].Value,sliders[2].Value,sliders[3].Value)
  if callback then callback(c.Value) end
 end
 local rgb={c.Value.R*255,c.Value.G*255,c.Value.B*255}
 for i,name in {"Red","Green","Blue"} do sliders[i]=UI.Slider(panel,name,0,255,rgb[i],1,changed,{LayoutOrder=i}) end
 function c:Set(color,silent)
  self.Value=color;sliders[1]:Set(color.R*255,true);sliders[2]:Set(color.G*255,true);sliders[3]:Set(color.B*255,true)
  if callback and not silent then callback(color) end
 end
 apply(panel,props);return c
end
UI.CreateRGBFrame=UI.RGB
function UI.ColorMenu(parent,options)
 options=options or {};local w=UI.Window(parent,options.Title or "Color",{Size=UDim2.fromOffset(400,310)})
 local c=UI.RGB(w.Body,options.Color,options.OnChanged);return w,c
end
function UI.GetIconQuality() return 420 end
function UI.GetIcon(id) return type(id)=="number" and "rbxassetid://"..id or id end
function UI.GetAssetIconURL(id,size) return string.format("rbxthumb://type=Asset&id=%s&w=%d&h=%d",tostring(id),size or 420,size or 420) end
UI.GetAssetIcon=UI.GetAssetIconURL
function UI.GetThumb(kind,id,size) return string.format("rbxthumb://type=%s&id=%s&w=%d&h=%d",kind,tostring(id),size or 150,size or 150) end
function UI.GetUserIcon(id,size) return UI.GetThumb("Avatar",id,size) end
function UI.GetUserHeadIcon(id,size) return UI.GetThumb("AvatarHeadShot",id,size) end
function UI.GetUserBustIcon(id,size) return UI.GetThumb("AvatarBust",id,size) end
function UI.SetItemIcon(image,id) image.Image=UI.GetIcon(id) end
function UI.SetCornerIcon(parent,id,props) return UI.Icon(parent,UI.GetIcon(id),props) end
function UI.GetModelZoomOffset(model)
 local _,size=model:GetBoundingBox();return math.max(size.X,size.Y,size.Z)*1.5
end
function UI.SetCenteredWaitDots(label,enabled)
 label:SetAttribute("MansionWaitDots",enabled)
 if enabled then task.spawn(function()
  local i=0
  while label.Parent and label:GetAttribute("MansionWaitDots") do label.Text=string.rep(".",i%3+1);i+=1;task.wait(0.4) end
 end) end
end
local queueTail={}
function UI.Queue(name,callback,...)
 local args=table.pack(...)
 local previous=queueTail[name];local done=Instance.new("BindableEvent")
 local entry={Done=done,Finished=false};queueTail[name]=entry
 task.spawn(function()
  if previous and not previous.Finished then previous.Done.Event:Wait() end
  local ok,err=pcall(callback,table.unpack(args,1,args.n))
  entry.Finished=true;done:Fire();task.defer(function() done:Destroy() end)
  if queueTail[name]==entry then queueTail[name]=nil end
  if not ok then warn(err) end
 end)
 return entry
end
-- Domain-specific helpers accept caller-owned content and callbacks.
-- They render UI only and never grant currency, permissions, products or rewards.
UI.BlockbuxConfirmBox=UI.ConfirmBox
UI.MissingGamepassesPrompt=UI.MessageBox
UI.EarlyAccessRewards=UI.MessageBox
UI.AcceptGuidelines=UI.ConfirmBox
UI.CallToAction=UI.MessageBox
UI.IconMessageBox=UI.MessageBox
UI.OnboardingGUI=UI.MessageBox
UI.DecalMenu=UI.InputBox
UI.HalloweenHub=UI.MessageBox
UI.WinterEventHub=UI.MessageBox
UI.EventCurrencyConversion=UI.ConfirmBox
function UI.InitAutoStyles(root)
 for _,o in root:GetDescendants() do if o:IsA("GuiButton") then UI.HoverEffect(o) end end
 return root
end
function UI.InitWindowFrame(frame)
 local c=controller(frame)
 function c:Open() frame.Visible=true end
 function c:Close() frame.Visible=false end
 local close=frame:FindFirstChild("Close",true)
 if close and close:IsA("GuiButton") then manage(frame)(close.Activated,function() c:Close() end) end
 return c
end
function UI.Init(parent) return UI.Screen(parent) end
function UI.Start(parent) return UI.Init(parent) end
return UI
