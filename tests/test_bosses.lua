package.path='./?.lua;'..package.path
math.atan2=math.atan2 or function(y,x) return math.atan(y,x) end
love={math={random=math.random,setRandomSeed=math.randomseed},graphics={},filesystem={getInfo=function()return nil end}}
local g=love.graphics
for _,k in ipairs({'push','pop','translate','rotate','scale','setColor','setLineWidth','circle','rectangle','polygon','line','arc','print','printf','clear','draw','ellipse'}) do g[k]=function()end end
g.getFont=function()return {getWidth=function(_,s)return #s*8 end} end
local World=require('world');local Player=require('player');local Bosses=require('bosses')
local tests=0
for index=1,4 do
 Player.reset();World.reset();World.level=index;World.spawnBoss()
 local b=World.boss
 assert(b and b.maxHp>=70)
 for i=1,900 do
  Player.update(1/60,400,430)
  World.update(1/60,Player)
  if i%30==0 then World.draw() end
 end
 assert(World.boss,'boss still exists')
 if index==1 or index==4 then
  local nodes=index==1 and b.nodes or b.portals
  for _,n in ipairs(nodes) do n.cooldown=0;Bosses.hitNode(World,Player,n.x,n.y,25,9) end
 end
 if index==2 then b.cycle=6 end
 b.hitCooldown=0
 local hp=b.hp
 assert(Bosses.damage(World,Player,5,'dash'))
 assert(b.hp==hp-5)
 tests=tests+1
end
print('BOSS STRESS OK '..tests..' encounters x 900 frames')
