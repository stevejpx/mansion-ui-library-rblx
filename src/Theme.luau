local Theme = {}
Theme.Colors = {
 Main=Color3.fromRGB(0,170,255), MainDefault=Color3.fromRGB(0,170,255),
 MainNegative=Color3.fromRGB(255,50,50), MainWarning=Color3.fromRGB(255,162,48),
 MainPositive=Color3.fromRGB(0,170,0), Money=Color3.fromRGB(0,170,0),
 Blockbux=Color3.fromRGB(170,0,255), BlockbuxSecondary=Color3.fromRGB(205,105,255),
 Background=Color3.fromRGB(255,255,255), BackgroundSecondary=Color3.fromRGB(220,220,220),
 Neutral=Color3.fromRGB(150,150,150), NeutralLight=Color3.fromRGB(200,200,200),
 Text=Color3.fromRGB(150,150,150), TextSecondary=Color3.fromRGB(150,150,150), ButtonLabel=Color3.new(1,1,1),
}
Theme.Dark={Background=Color3.fromRGB(60,60,60),BackgroundSecondary=Color3.fromRGB(35,35,35),Neutral=Color3.fromRGB(29,29,29),NeutralLight=Color3.fromRGB(45,45,45),Text=Color3.fromRGB(230,230,230)}
Theme.Font=Enum.Font.SourceSans
Theme.Bold=Enum.Font.SourceSansBold
Theme.TextSize=28
Theme.Radius=7.5
Theme.PanelImage="rbxassetid://8523912402"
Theme.ButtonImage="rbxassetid://8523942620"
Theme.SliceCenter=Rect.new(30,30,50,50)
Theme.SliceScale=0.25
return Theme
