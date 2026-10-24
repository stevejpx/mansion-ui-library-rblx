# Standalone API

All module functions use dot syntax, such as UI.Window(parent, title). Controller methods use colon syntax. This API is independent from the source game's calling conventions.

## Functions

| Function | Arguments |
| --- | --- |
| `Create` | `className,props,children` |
| `Clone` | `key,parent,overrides` |
| `GetColor` | `token` |
| `SetTheme` | `mode,overrides` |
| `SetThemeColor` | `token,color` |
| `BindColor` | `object,property,token` |
| `Corner` | `parent,radius` |
| `Stroke` | `parent,props` |
| `Gradient` | `parent,props` |
| `Padding` | `parent,amount` |
| `List` | `parent,props` |
| `Grid` | `parent,props` |
| `Screen` | `parent,props` |
| `Surface` | `parent,props` |
| `Billboard` | `parent,props` |
| `Canvas` | `parent,props` |
| `Viewport` | `parent,props` |
| `Frame` | `parent,props` |
| `Panel` | `parent,props` |
| `Label` | `parent,text,props` |
| `Icon` | `parent,image,props` |
| `ImageButton` | `parent,image,callback,props` |
| `Button` | `parent,text,callback,props` |
| `SetButtonState` | `button,enabled` |
| `GetButtonState` | `button` |
| `HoverEffect` | `button,amount` |
| `PressedButtonEffect` | `button` |
| `SelectedButtonEffect` | `button,selected` |
| `SetHoverFunctions` | `button,onEnter,onLeave` |
| `GroupHoverEffect` | `group` |
| `Scroll` | `parent,props` |
| `AdjustScrollSize` | `scroll` |
| `TextInput` | `parent,placeholder,callback,props` |
| `Search` | `parent,callback,props` |
| `Toggle` | `parent,text,initial,callback,props` |
| `Dropdown` | `parent,items,initial,callback,props` |
| `CloseDropdown` | `` |
| `Slider` | `parent,text,min,max,initial,step,callback,props` |
| `Progress` | `parent,value,props` |
| `UpdateProgressionBar` | `control,value,total` |
| `Window` | `parent,title,props` |
| `Section` | `parent,title,props` |
| `Fit` | `window,viewport,padding` |
| `SetZIndex` | `root,z` |
| `GetInset` | `` |
| `GetPlayerlistHeight` | `` |
| `LinkTextSize` | `labels` |
| `ToggleAllGUI` | `container,enabled` |
| `TogglePrompt` | `window,enabled` |
| `CreatePromptGUI` | `parent,title,props` |
| `CreateOverlay` | `parent,props` |
| `CreateOverlayBlur` | `parent,size` |
| `GetOverlayBlur` | `parent` |
| `Glow` | `object,color` |
| `CreateScrollGradient` | `scroll,props` |
| `CenterSelectedInScrollingFrame` | `scroll,object` |
| `ShowTooltip` | `parent,text,position` |
| `HideTooltip` | `` |
| `ToggleTooltips` | `enabled` |
| `AttachTooltip` | `object,text,parent` |
| `ShowLabel` | `parent,text,seconds,props` |
| `CenterError` | `parent,text,seconds` |
| `Notify` | `parent,title,message,seconds` |
| `MessageBox` | `parent,options` |
| `ConfirmBox` | `parent,options` |
| `InputBox` | `parent,options` |
| `RGB` | `parent,initial,callback,props` |
| `ColorMenu` | `parent,options` |
| `GetIconQuality` | `` |
| `GetIcon` | `id` |
| `GetAssetIconURL` | `id,size` |
| `GetThumb` | `kind,id,size` |
| `GetUserIcon` | `id,size` |
| `GetUserHeadIcon` | `id,size` |
| `GetUserBustIcon` | `id,size` |
| `SetItemIcon` | `image,id` |
| `SetCornerIcon` | `parent,id,props` |
| `GetModelZoomOffset` | `model` |
| `SetCenteredWaitDots` | `label,enabled` |
| `Queue` | `name,callback,...` |
| `InitAutoStyles` | `root` |
| `InitWindowFrame` | `frame` |
| `Init` | `parent` |
| `Start` | `parent` |

## Aliases

- `New` → `Create`
- `RoundedButtonEffect` → `HoverEffect`
- `CreateSearch` → `Search`
- `CreateDropdown` → `Dropdown`
- `SetPromptZIndex` → `SetZIndex`
- `AlertBox` → `MessageBox`
- `MultiMessageBox` → `MessageBox`
- `CreateRGBFrame` → `RGB`
- `GetAssetIcon` → `GetAssetIconURL`
- `BlockbuxConfirmBox` → `ConfirmBox`
- `MissingGamepassesPrompt` → `MessageBox`
- `EarlyAccessRewards` → `MessageBox`
- `AcceptGuidelines` → `ConfirmBox`
- `CallToAction` → `MessageBox`
- `IconMessageBox` → `MessageBox`
- `OnboardingGUI` → `MessageBox`
- `DecalMenu` → `InputBox`
- `HalloweenHub` → `MessageBox`
- `WinterEventHub` → `MessageBox`
- `EventCurrencyConversion` → `ConfirmBox`

## Return values and state

Create/New, Frame, Panel, Label, Icon, Button, ImageButton, Screen, Surface, Billboard, Canvas, Viewport, Scroll, Section and modifier helpers return native Roblox Instances. Access native properties, methods and events directly. TextInput/Search return the panel and TextBox.

Window returns a controller with Frame, Body, Open(), Close(), SetEnabled(boolean) and Destroy(). Toggle, Slider, RGB and Progress return controllers with Frame, Value, Set(value, silent?), SetEnabled(boolean) and Destroy(). Dropdown returns Frame, Items, Value, SetSelected(value, silent?), SetText(text), Update(items), MatchFrame(frame), Close(), SetEnabled(boolean) and Destroy(). Use parent=window.Body for content.

Props are native Roblox property tables applied to the returned root instance. Child-specific overrides can be applied after creation. Controller callbacks are optional. Toggle and slider initial values do not fire callbacks. Destroying controls disconnects their managed global input subscriptions. Themes update library-bound properties, not every color inside raw cloned templates.

MessageBox/ConfirmBox/AlertBox accept an options table: Title, Message, Actions={{Text=string,Value=any}}, and OnResult(value). Close returns nil. InputBox adds Placeholder and returns the controller plus TextBox; OnResult receives text on confirmation or nil on cancellation. RGB uses Color3 values; Slider uses numeric min/max/step.

## Exact templates

Templates.List(query?) returns {Id, Path, Name, ClassName} entries. Templates.Describe(idOrPathOrUniqueName) returns the snapshot record. Clone(key, parent?, overrides?) returns root, assignmentErrors, idToInstance. Duplicate paths/names require numeric IDs. No original scripts run. Clone preserves saved visibility and doesn't wire controls automatically.

## Native escape hatch

UI.Create(className, props?, children?) creates any native Instance class and passes through properties. UI.Create("UICorner", {CornerRadius=UDim.new(0,12),Parent=panel}) is supported alongside UI.Corner(panel,12). Native event APIs are available on returned objects.

## Source name coverage

71 source method names, 104 public assignments/functions detected; all source names are present. See COMPATIBILITY.md for semantic limitations and domain-specific dialog aliases.
