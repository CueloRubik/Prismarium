package.path='./?.lua;'..package.path
math.atan2=math.atan2 or function(y,x) return math.atan(y,x) end
local function fakeFont(a,b) local n=type(a)=='number' and a or b or 12; return {getWidth=function(_,s) return #tostring(s)*n*0.55 end,getHeight=function()return n end} end
local font=fakeFont(14)
local g={}
for _,k in ipairs({'push','pop','translate','rotate','scale','setColor','setLineWidth','circle','rectangle','polygon','line','arc','print','printf','clear','draw','ellipse','setScissor','setBlendMode'}) do g[k]=function(...) end end
g.newFont=fakeFont;g.setFont=function(f)font=f end;g.getFont=function()return font end
g.newImage=function(path) return {getWidth=function()return 800 end,getHeight=function()return 600 end,setFilter=function()end} end
local x,y=400,300
local files={}
love={graphics=g,mouse={getPosition=function()return x,y end,getX=function()return x end,getY=function()return y end},
 math={random=math.random,setRandomSeed=math.randomseed,newRandomGenerator=function(seed) local n=seed;return {random=function(_,a,b) n=(1103515245*n+12345)%2147483647;local r=n/2147483647;if a and b then return a+math.floor(r*(b-a+1)) end;return r end} end},
 filesystem={getInfo=function(path)local f=io.open(path,'rb');if f then f:close();return true end end,
  read=function(path)return files[path] end,write=function(path,data)files[path]=data;return true end},
 event={quit=function()end}}
dofile('main.lua')
love.load()
love.draw()
love.mousepressed(120,285,1) -- menu play
love.draw()
love.mousepressed(735,268,1) -- next map
love.draw()
love.mousepressed(60,268,1) -- previous map
love.draw()
love.mousepressed(380,542,1) -- start map1
for i=1,120 do love.update(1/60);love.draw() end
love.keypressed('c');love.keypressed('b');love.keypressed('v')
for i=1,120 do love.update(1/60);love.draw() end
love.keypressed('u');love.draw()
love.mousepressed(170,220,1);love.draw()
love.keypressed('u');love.draw()
local world=require('world');local player=require('player');local bosses=require('bosses')
for map=1,4 do
 world.reset();world.level=map;world.spawnBoss();player.reset()
 for i=1,150 do world.update(1/60,player);player.update(1/60,400,300);world.draw() end
 local b=world.boss
 if b then
  bosses.onPulse(world,player,200)
  for _,node in ipairs(map==1 and b.nodes or (map==4 and b.portals or {})) do
   bosses.hitNode(world,player,node.x,node.y,50,3)
  end
  if map==2 then b.cycle=6 end
  b.hitCooldown=0
  bosses.damage(world,player,8,'dash')
  world.draw()
 end
 print('map',map,'boss hp',world.boss and world.boss.hp or 0,'hazards',#world.hazards)
end
print('SMOKE OK')
