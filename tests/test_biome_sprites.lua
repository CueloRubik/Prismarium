package.path='./?.lua;'..package.path
local calls=0
love={filesystem={getInfo=function(p)local f=io.open(p,'rb');if f then f:close();return true end return nil end},
 graphics={newImage=function(p)local file=assert(io.open(p,'rb'),'missing '..p);file:close();
 return {getWidth=function()return 256 end,getHeight=function()return 256 end,setFilter=function()end}end,
 setColor=function()end, draw=function()calls=calls+1 end, circle=function()end,rectangle=function()end,
 setLineWidth=function()end,line=function()end,polygon=function()end,arc=function()end}}
local S=require('sprites')
local total=0
for biome=0,4 do
 S.setBiome(biome)
 for _,typeId in ipairs({'star','seeker','splitter','turret','charger','orbiter','leech','armored','bolt','ember','thorn','shard','void'}) do
  local prev=calls
  S.drawHazard(300,250,0,1,typeId,1,1,'roam',0)
  assert(calls>prev,'sprite not rendered: '..typeId..' biome '..biome)
  total=total+1
 end
end
local Progress=require('progression')
assert(#Progress.skinOrder==30)
for _,skin in ipairs(Progress.skinOrder) do
 local prev=calls
 S.drawPlayer(400,300,0,1,false,false,1,.8,false,skin,1)
 assert(calls>prev,'player skin failed render: '..skin)
end
print('BIOME SPRITES OK '..total..' enemy/projectile combinations + 30 unique player skin paths')
