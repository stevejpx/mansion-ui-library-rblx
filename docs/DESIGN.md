# Observed design anatomy

The primary panel uses `rbxassetid://8523912402`; the button uses `rbxassetid://8523942620`. Both use `ScaleType.Slice`, `SliceCenter=Rect.new(30,30,50,50)` and `SliceScale=0.25`. Preserve these together: replacing only the image or approximating the silhouette with UICorner changes the edge rendering.

The common accent is RGB (0,170,255). White panels contain RGB (220,220,220) inset areas, white section cards and RGB (150,150,150) labels. Positive, negative, warning and alternate currency accents are present in `Theme.luau`. SourceSans and SourceSansBold dominate the original text styles.

The custom options panel is 500 pixels wide, centered using AnchorPoint (0.5,0.5), with a 40-pixel title region. Its inset begins at (7,40) and measures (1,-14,1,-47). Its scrolling content has a further 7-pixel inset and an 8-pixel scrollbar. Many controls are 40 pixels tall; labels and buttons divide rows using scale proportions. These exact values remain in the template snapshot, including source float precision.

Icons can be standalone images or atlas rectangles. Copying an asset ID alone can show the entire atlas. Preserve `ImageRectOffset`, `ImageRectSize`, `ImageColor3`, `ImageTransparency`, sizing constraints and `ScaleType` from the use record. The offline gallery's sprite mode displays each distinct crop/tint combination and its implementation metadata.

The place also contains native UICorner, UIStroke, UIGradient, list/grid/page layouts, canvas groups and world-space GUIs. `reference/style-tokens.json` reports observed values and frequencies; exact styles vary between templates. `UI.Create` and the modifier helpers expose these mechanisms directly, and `UI.Clone` retains their original values.

Sources for native property/event semantics: [ImageLabel](https://create.roblox.com/docs/reference/engine/classes/ImageLabel), [GuiButton](https://create.roblox.com/docs/reference/engine/classes/GuiButton). UI extraction came from the provided local place rather than these documentation examples.
