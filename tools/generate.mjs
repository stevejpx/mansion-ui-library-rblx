import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const snapshot=JSON.parse(fs.readFileSync(path.join(root,'reference/snapshot.json'),'utf8'));
const mkdir=p=>fs.mkdirSync(path.join(root,p),{recursive:true});
for(const p of ['src/Data','assets/images','reference','docs','examples','tests','dist'])mkdir(p);
const write=(p,s)=>fs.writeFileSync(path.join(root,p),s);
const quote=s=>JSON.stringify(s).replace(/\\u([0-9a-f]{4})/gi,(_,h)=>`\\u{${h}}`);
function lua(v){
 if(v===null)return 'nil';
 if(typeof v==='string')return quote(v);
 if(typeof v!=='object')return String(v);
 if(Array.isArray(v))return '{'+v.map(lua).join(',')+'}';
 if(v.t){const a=v.v;
  if(v.t==='numeric')return a==='inf'?'math.huge':a==='-inf'?'-math.huge':'0/0';
  if(v.t==='Enum')return a[0];
  if(v.t==='Ref')return '{__ref='+a[0]+'}';
  if(v.t==='Font')return `Font.new(${quote(a[0])},${a[1]},${a[2]})`;
  if(v.t==='ColorSequence')return 'ColorSequence.new({'+a.map(k=>`ColorSequenceKeypoint.new(${k[0]},Color3.new(${k.slice(1).join(',')}))`).join(',')+'})';
  if(v.t==='NumberSequence')return 'NumberSequence.new({'+a.map(k=>`NumberSequenceKeypoint.new(${k.join(',')})`).join(',')+'})';
  return v.t+'.new('+a.map(lua).join(',')+')';
 }
 return '{'+Object.entries(v).map(([k,v])=>'['+quote(k)+']='+lua(v)).join(',')+'}';
}
// Keep data modules small; each returns only an inert table.
const chunks=[];
for(let i=0;i<snapshot.nodes.length;i+=150){const name='Chunk'+String(i/150+1).padStart(3,'0');chunks.push(name);write('src/Data/'+name+'.luau','-- Generated from reference/snapshot.json. No source-place scripts.\nreturn '+lua(snapshot.nodes.slice(i,i+150))+'\n');}
write('src/Data/init.luau','local nodes={}\nfor _,name in '+lua(chunks)+' do\n for _,node in require(script[name]) do table.insert(nodes,node) end\nend\nreturn nodes\n');
const assets=new Map(),uses=[];
for(const n of snapshot.nodes)for(const key of ['Image','TopImage','MidImage','BottomImage']){
 const uri=n.properties[key];if(!uri)continue;
 const id=uri.match(/(?:rbxassetid:\/\/|[?&]id=)(\d+)/)?.[1];
 const u={node:n.id,path:n.path,property:key,uri,assetId:id??null,rectOffset:n.properties.ImageRectOffset?.v??[0,0],rectSize:n.properties.ImageRectSize?.v??[0,0],tint:n.properties.ImageColor3?.v??[1,1,1],scaleType:n.properties.ScaleType?.v?.[0]??'Enum.ScaleType.Stretch',sliceCenter:n.properties.SliceCenter?.v??[0,0,0,0],sliceScale:n.properties.SliceScale??1};uses.push(u);
 if(id){if(!assets.has(id))assets.set(id,{id,uri,uses:[]});assets.get(id).uses.push({node:n.id,path:n.path,property:key});}
}
write('assets/manifest.json',JSON.stringify({source:snapshot.source,assets:[...assets.values()],uses},null,2));
write('reference/method-inventory.json',JSON.stringify(snapshot.methods,null,2));
const classes={};for(const n of snapshot.nodes)classes[n.class]=(classes[n.class]??0)+1;
write('reference/coverage.json',JSON.stringify({nodes:snapshot.nodes.length,classes,assetIds:assets.size,imageUses:uses.length,omissions:snapshot.omissions},null,2));
const style={};for(const n of snapshot.nodes)for(const k of ['FontFace','CornerRadius','SliceScale','SliceCenter','BackgroundColor3','TextColor3','ImageColor3','Thickness'])if(k in n.properties){const val=JSON.stringify(n.properties[k]);style[k]??={};style[k][val]=(style[k][val]??0)+1;}
write('reference/style-tokens.json',JSON.stringify(Object.fromEntries(Object.entries(style).map(([k,v])=>[k,Object.entries(v).sort((a,b)=>b[1]-a[1]).map(([value,count])=>({value:JSON.parse(value),count}))])),null,2));
console.log(JSON.stringify({nodes:snapshot.nodes.length,assets:assets.size,uses:uses.length,chunks:chunks.length}));
