-- Run in Studio command bar after importing dist/MansionUI.rbxm to ReplicatedStorage.
-- Detached test instances are destroyed after assertions; no source-place scripts run.
return function(UI)
 local root=Instance.new("Folder")
 local passed=0
 local function check(condition,message) assert(condition,message);passed+=1 end
 local ok,err=pcall(function()
  local screen=UI.Screen(root)
  local w=UI.Window(screen,"Test")
  check(w.Body:IsA("ScrollingFrame"),"Window content must scroll")
  local button=UI.Button(w.Body,"Action")
  check(button.Image==UI.Theme.ButtonImage,"Button must use extracted nine-slice texture")
  check(button.SliceCenter==Rect.new(30,30,50,50),"Button slice rectangle")
  UI.SetButtonState(button,false);check(not UI.GetButtonState(button) and not button.Active,"Disabled button gate")
  UI.SetButtonState(button,true);check(UI.GetButtonState(button) and button.Active,"Re-enable button")
  local count=0
  local toggle=UI.Toggle(w.Body,"Test",false,function() count+=1 end)
  toggle:Set(true);check(toggle.Value and count==1,"Toggle callback")
  toggle:Set(false,true);check(not toggle.Value and count==1,"Silent toggle update")
  local dropdown=UI.Dropdown(w.Body,{"A","B"},"A")
  dropdown:SetSelected("B");check(dropdown.Value=="B","Dropdown selection")
  check(not pcall(function() dropdown:SetSelected("C") end),"Dropdown rejects missing choice")
  dropdown:Update({"C","D"});dropdown:SetSelected("C");check(dropdown.Value=="C","Dropdown option replacement")
  local slider=UI.Slider(w.Body,"Value",10,20,15,2)
  slider:Set(100);check(slider.Value==20,"Slider upper clamp")
  slider:Set(9);check(slider.Value==10,"Slider lower clamp")
  slider:Set(13.1);check(slider.Value==14,"Slider steps relative to minimum")
  local progress=UI.Progress(w.Body,0.5);progress:Set(2);check(progress.Value==1,"Progress clamp")
  UI.SetThemeColor("Main",Color3.new(1,0,1));check(button.ImageColor3==Color3.new(1,0,1),"Theme propagation")
  UI.SetTheme("light")
  local rgb=UI.RGB(w.Body,Color3.new(1,0,0));rgb:Set(Color3.new(0,1,0),true);check(rgb.Value==Color3.new(0,1,0),"RGB state")
  local template,errors=UI.Clone("StarterGui.MainGUI.Design Lounge Chair.MatrikzGUI.OptionsFrame",screen,{Visible=true})
  check(template.Background.Image==UI.Theme.PanelImage,"Exact template panel texture")
  check(template.Background.SliceScale==0.25,"Exact template slice scale")
  check(#errors==0,"Template property assignment failures: "..table.concat(errors,"; "))
  check(#template:GetDescendants()==101,"Custom UI descendant coverage")
  check(#UI.Templates.List()==7841,"Snapshot node coverage")
  local panel=UI.Create("Frame",{Size=UDim2.fromOffset(500,600)})
  local fit=UI.Fit(panel,Vector2.new(390,844));check(fit.Scale<1 and fit.Scale>0,"Phone scaling")
  panel:Destroy()
  local calls=0
  local prompt=UI.ConfirmBox(screen,{OnResult=function() calls+=1 end})
  prompt:Close();prompt:Close();check(calls==1,"Prompt result fires once")
 end)
 root:Destroy()
 if not ok then error(err) end
 return {passed=passed}
end
