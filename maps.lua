local Sprites = require('sprites')
local Maps = {}
Maps.list = {
 {name='BOSQUE PRISMATICO', subtitle='Raices y resonancia', bg={0.075,0.15,0.15}, line={0.17,0.36,0.31}, accent={0.28,0.85,0.61}, mechanic='roots', boss='GUARDIAN DE RAICES'},
 {name='FUNDICION CARMESI', subtitle='Prensas y hornos', bg={0.19,0.11,0.11}, line={0.42,0.24,0.18}, accent={1,0.48,0.24}, mechanic='press', boss='COLOSO DE ACERO'},
 {name='CAVERNAS DE CRISTAL', subtitle='Reflejos y hielo', bg={0.10,0.14,0.24}, line={0.23,0.35,0.52}, accent={0.39,0.78,1}, mechanic='ice', boss='ESPECTRO DE CRISTAL'},
 {name='VACIO FRACTURADO', subtitle='Portales y gravedad', bg={0.12,0.08,0.21}, line={0.31,0.22,0.48}, accent={0.77,0.48,1}, mechanic='portal', boss='ARQUITECTO DEL VACIO'},
 {name='JARDINES DE TORMENTA', subtitle='Niebla y descargas', bg={0.08,0.15,0.18}, line={0.18,0.34,0.38}, accent={0.44,0.96,0.98}, mechanic='storm', boss='HERALDO DEL CIELO'},
 {name='SANTUARIO SOLAR', subtitle='Luz y coronas', bg={0.22,0.16,0.10}, line={0.44,0.32,0.18}, accent={1.00,0.82,0.36}, mechanic='sun', boss='REY DEL AMANECER'}
}
local time=0
local textures={}
local sceneImages={}
local arenaFrame=nil
local portalCooldown=0
function Maps.load()
 if love.filesystem.getInfo('assets/ui/arena_frame.png') then arenaFrame=love.graphics.newImage('assets/ui/arena_frame.png') end
 for i=1,#Maps.list do
  local path='assets/maps/map'..i..'.png'
  if love.filesystem.getInfo(path) then textures[i]=love.graphics.newImage(path) end
  local scene='assets/scenes/scene'..i..'.jpg'
  if love.filesystem.getInfo(scene) then sceneImages[i]=love.graphics.newImage(scene) end
 end
end
function Maps.set(index)
 Maps.isTutorial=(index==0)
 Maps.index=Maps.isTutorial and 1 or math.max(1,math.min(#Maps.list,index))
 Maps.current=Maps.list[Maps.index]
 Sprites.setBiome(Maps.isTutorial and 0 or math.min(4,Maps.index))
 time=0;portalCooldown=0
end
function Maps.update(dt) time=time+dt;portalCooldown=math.max(0,portalCooldown-dt) end
function Maps.draw(showGrid)
 local m=Maps.current or Maps.list[1]
 love.graphics.clear(m.bg[1],m.bg[2],m.bg[3])
 local im=sceneImages[Maps.index] or textures[Maps.index]
 if im then love.graphics.setColor(1,1,1,1);love.graphics.draw(im,0,0,0,800/im:getWidth(),600/im:getHeight()) end
 if arenaFrame then love.graphics.setColor(1,1,1,1);love.graphics.draw(arenaFrame,24,58,0,752/arenaFrame:getWidth(),480/arenaFrame:getHeight()) end
 if showGrid then
  love.graphics.setLineWidth(1)
  for x=40,760,40 do love.graphics.setColor(m.line[1],m.line[2],m.line[3],0.18);love.graphics.line(x,60,x,538) end
  for y=60,540,40 do love.graphics.setColor(m.line[1],m.line[2],m.line[3],0.18);love.graphics.line(28,y,772,y) end
 end
end
function Maps.hazardZones()
 local m=Maps.current or Maps.list[1]
 if m.mechanic=='roots' then return {{x=190,y=210,r=32},{x=610,y=390,r=32}} end
 if m.mechanic=='press' then return {{x=210,y=250,r=38},{x=590,y=340,r=38}} end
 if m.mechanic=='ice' then return {{x=220,y=220,r=42},{x=580,y=370,r=42}} end
 if m.mechanic=='portal' then return {{x=170,y=180,r=34},{x=630,y=400,r=34}} end
 if m.mechanic=='storm' then return {{x=200,y=170,r=34},{x=400,y=310,r=38},{x=610,y=420,r=34}} end
 return {{x=210,y=190,r=34},{x=590,y=390,r=34}}
end
function Maps.drawZones()
 local m=Maps.current;if not m then return end
 for i,z in ipairs(Maps.hazardZones()) do
  local active=(math.floor(time*0.7+i)%2==0)
  Sprites.drawMapZone(z.x,z.y,z.r,m.accent,time+i,active)
 end
end
function Maps.effect(player,dt)
 local m=Maps.current;if not m then return end
 local zones=Maps.hazardZones()
 for i,z in ipairs(zones) do
  local dx,dy=player.x-z.x,player.y-z.y
  if dx*dx+dy*dy<z.r*z.r then
   if m.mechanic=='roots' and player.polarity==-1 then player.vx=player.vx*0.96;player.vy=player.vy*0.96
   elseif m.mechanic=='press' and math.floor(time*0.7+i)%2==0 and not player.isDashing then player.takeHit(15)
   elseif m.mechanic=='ice' then player.slipperyTimer=0.28
   elseif m.mechanic=='portal' then
    if portalCooldown<=0 and not player.isDashing then local other=zones[3-i] player.x=other.x+love.math.random(-30,30) player.y=other.y+love.math.random(-30,30) player.prevX,player.prevY=player.x,player.y portalCooldown=4 end
   elseif m.mechanic=='storm' and math.floor(time*1.1+i)%2==0 then player.energy=math.max(0,player.energy-8*dt)
   elseif m.mechanic=='sun' then player.energy=math.min(player.maxEnergy,player.energy+5*dt) end
  end
 end
end
return Maps
