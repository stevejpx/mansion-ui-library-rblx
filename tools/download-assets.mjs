import fs from 'node:fs';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const manifest=JSON.parse(fs.readFileSync(path.join(root,'assets/manifest.json'),'utf8'));
const results=[];let cursor=0;
async function worker(){while(cursor<manifest.assets.length){const a=manifest.assets[cursor++];const filename=`assets/images/${a.id}.png`;if(fs.existsSync(path.join(root,filename))){results.push({id:a.id,status:'downloaded',file:filename});continue;}
 try{const r=await fetch(`https://assetdelivery.roblox.com/v1/asset/?id=${a.id}`,{signal:AbortSignal.timeout(20000)});if(!r.ok)throw Error(`HTTP ${r.status}`);const b=Buffer.from(await r.arrayBuffer());const png=b.subarray(0,8).equals(Buffer.from([137,80,78,71,13,10,26,10]));const jpg=b[0]===255&&b[1]===216;const webp=b.subarray(8,12).toString()==='WEBP';if(!png&&!jpg&&!webp)throw Error('Response is not a PNG/JPEG/WebP image');const file=`assets/images/${a.id}.${png?'png':jpg?'jpg':'webp'}`;fs.writeFileSync(path.join(root,file),b);results.push({id:a.id,status:'downloaded',file,bytes:b.length});}
 catch(e){results.push({id:a.id,status:'unavailable',reason:e.message});}
 if(results.length%40===0)console.log(`${results.length}/${manifest.assets.length}`);
}}
await Promise.all(Array.from({length:10},worker));results.sort((a,b)=>a.id.localeCompare(b.id));fs.writeFileSync(path.join(root,'assets/download-status.json'),JSON.stringify(results,null,2));console.log(JSON.stringify({downloaded:results.filter(r=>r.status==='downloaded').length,unavailable:results.filter(r=>r.status!=='downloaded').length}));
