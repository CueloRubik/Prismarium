local Effects = require('effects')
local Audio = require('audio')
local Sprites = require('sprites')
local Bosses = {}

local names = {'GUARDIAN DE RAICES','COLOSO DE ACERO','ESPECTRO DE CRISTAL','ARQUITECTO DEL VACIO'}
local colors = {{0.31,1,0.66},{1,0.45,0.18},{0.36,0.81,1},{0.79,0.40,1}}
local function dist2(a,b,x,y) local dx,dy=a-x,b-y;return dx*dx+dy*dy end
local function clamp(v,a,b) return math.max(a,math.min(b,v)) end
local function pulse(x,y,r,c)
 Effects.addShockwave(x,y,330,r,c[1],c[2],c[3])
end
local function node(x,y,hp) return {x=x,y=y,hp=hp or 2,angle=0} end
local function projectile(world,x,y,angle,speed,radius,kind)
 world.addProjectile(x,y,math.cos(angle)*speed,math.sin(angle)*speed,radius or 9,kind or 'bolt')
end
local function aimed(world,b,player,spread,count,speed,kind)
 local a=math.atan2(player.y-b.y,player.x-b.x)
 for i=1,count do projectile(world,b.x,b.y,a+(i-(count+1)/2)*spread,speed,9,kind) end
end
function Bosses.create(index)
 local hp=({70,90,82,110})[index] or 70
 local b={kind=index,name=names[index],color=colors[index],x=400,y=178,vx=70,vy=36,
  radius=34,hp=hp,maxHp=hp,angle=0,attackTimer=0,hitCooldown=0.5,
  phase=1,time=0,warnings={},reveal=0,cycle=0,shield=true,stun=0,
  nodes={},portals={},decoys={},vulnerable=0,teleportWarning=0}
 if index==1 then b.nodes={node(195,190,2),node(605,190,2),node(400,412,2)}
 elseif index==4 then b.portals={node(172,250,2),node(628,250,2)} end
 return b
end
local function activeNodes(b)
 local a=b.kind==1 and b.nodes or b.portals;local count=0
 for _,n in ipairs(a) do if n.hp>0 then count=count+1 end end
 return count
end
function Bosses.hitNode(world,player,x,y,radius,damage)
 local b=world.boss;if not b or (b.kind~=1 and b.kind~=4) then return false end
 local a=b.kind==1 and b.nodes or b.portals
 local success=false
 for _,n in ipairs(a) do
  if n.hp>0 and (n.cooldown or 0)<=0 and dist2(x,y,n.x,n.y)<(radius+19)^2 then
   n.hp=math.max(0,n.hp-(damage or 1));n.cooldown=0.36;success=true
   pulse(n.x,n.y,70,b.color);Effects.addText(n.x,n.y-26,n.hp==0 and 'DESTRUIDO' or 'GOLPE',b.color[1],b.color[2],b.color[3]);Audio.play('hit')
  end
 end
 if success and activeNodes(b)==0 then
  b.shield=false;b.vulnerable=b.kind==4 and 9 or 999
  Effects.addText(b.x,b.y-55,'NUCLEO EXPUESTO',1,0.82,0.3)
  pulse(b.x,b.y,150,b.color);Audio.play('boss')
 end
 return success
end
function Bosses.onPulse(world,player,radius)
 local b=world.boss;if not b then return end
 Bosses.hitNode(world,player,player.x,player.y,radius,1)
 if b.kind==2 then b.cycle=math.min(8,b.cycle+1.3)
 elseif b.kind==3 then b.reveal=4.5;Effects.addText(b.x,b.y-60,'ORIGINAL REVELADO',0.4,0.9,1) end
 if dist2(player.x,player.y,b.x,b.y)<(radius+b.radius)^2 then Bosses.damage(world,player,2,'pulse') end
end
function Bosses.damage(world,player,amount,source)
 local b=world.boss
 if not b or b.hitCooldown>0 then return false end
 if b.kind==1 and activeNodes(b)>0 or b.kind==4 and activeNodes(b)>0 then
  Effects.addText(b.x,b.y-55,'ESCUDO: DESTRUYE LOS SELLOS',0.95,0.73,0.31)
  b.hitCooldown=0.3;return false
 end
 if b.kind==2 and b.cycle<5 then
  Effects.addText(b.x,b.y-52,'BLINDAJE ACTIVO',1,0.62,0.30)
  b.hitCooldown=0.3;return false
 end
 b.hp=math.max(0,b.hp-amount)
 b.hitCooldown=source=='counter' and 0.13 or 0.27
 b.stun=0.08
 Effects.addText(b.x,b.y-50,'-'..amount,1,0.91,0.44)
 pulse(b.x,b.y,85,b.color);Effects.shake(0.13,4);Audio.play('hit')
 if b.hp<=0 then world.defeatBoss(player) end
 return true
end
local function addWarning(b,x,y,r,duration,kind)
 b.warnings[#b.warnings+1]={x=x,y=y,r=r,t=duration or 0.9,max=duration or 0.9,kind=kind or 'circle',active=0}
end
local function updateWarnings(b,world,dt,player)
 for i=#b.warnings,1,-1 do
  local w=b.warnings[i]
  if w.t>0 then
   w.t=w.t-dt
   if w.t<=0 then
    w.active=0.42
    if w.kind=='crush' then pulse(w.x,w.y,w.r,b.color);Effects.shake(0.16,5) end
   end
  else
   w.active=w.active-dt
   if w.active<=0 then table.remove(b.warnings,i)
   end
  end
  if w.t<=0 and w.active>0 then
   local hit=false
   if w.kind=='lane' then hit=math.abs(player.x-w.x)<w.r and math.abs(player.y-w.y)<160
   else hit=dist2(player.x,player.y,w.x,w.y)<w.r*w.r end
   if hit and not player.isDashing then player.takeHit(w.kind=='crush' and 20 or 14) end
  end
 end
end
local function updateMovement(b,dt)
 if b.kind==2 then
  b.x=400+math.sin(b.time*0.64)*145;b.y=180+math.sin(b.time*1.2)*28
 elseif b.kind==3 then
  b.x=400+math.sin(b.time*0.86)*205;b.y=220+math.sin(b.time*1.65)*62
 elseif b.kind==4 then
  b.x=clamp(b.x+math.sin(b.time*2.1)*35*dt,105,695)
  b.y=170+math.sin(b.time*0.8)*48
 else
  b.x=400+math.sin(b.time*0.72)*180;b.y=175+math.sin(b.time*1.15)*52
 end
 b.angle=b.angle+dt*(0.6+0.15*b.phase)
end
local function attackForest(world,b,player)
 addWarning(b,player.x,player.y,58,1.0,'roots')
 if b.phase>=2 then
  addWarning(b,clamp(player.x+love.math.random(-120,120),70,730),clamp(player.y+love.math.random(-110,110),112,510),46,1.05,'roots')
 end
 if b.phase>=3 then aimed(world,b,player,0.32,3,145,'thorn') end
 if #world.hazards<12 then world.addEnemy('leech',b.x+love.math.random(-45,45),b.y+50) end
end
local function attackFoundry(world,b,player)
 addWarning(b,player.x,player.y,60,0.85,'crush')
 if b.phase>=2 then addWarning(b,clamp(player.x+110,70,730),player.y,47,0.95,'crush') end
 aimed(world,b,player,0.26,b.phase+1,185,'ember')
 if b.phase==3 and #world.hazards<12 then world.addEnemy('charger',b.x,b.y+45) end
end
local function attackCrystal(world,b,player)
 b.decoys={}
 for i=1,3 do local a=b.time+i*math.pi*2/3
  b.decoys[#b.decoys+1]={x=clamp(b.x+math.cos(a)*155,65,735),y=clamp(b.y+math.sin(a)*112,108,495)}
 end
 for i=1,4+b.phase*2 do
  local a=b.time*0.7+i*math.pi*2/(4+b.phase*2)
  projectile(world,b.x,b.y,a,135+b.phase*12,8,'shard')
 end
 if b.phase>=2 then aimed(world,b,player,0.18,3,210,'shard') end
end
local function attackVoid(world,b,player)
 local x=clamp(player.x+love.math.random(-120,120),95,705)
 local y=clamp(player.y-105,125,350)
 b.teleportWarning=0.65;b.teleportX=x;b.teleportY=y
 addWarning(b,player.x,player.y,65,1.1,'gravity')
 for i=1,3+b.phase do
  local a=b.time+i*math.pi*2/(3+b.phase)
  projectile(world,b.x,b.y,a,170,8,'void')
 end
end
function Bosses.update(world,dt,player)
 local b=world.boss;if not b then return end
 b.time=b.time+dt;b.hitCooldown=math.max(0,b.hitCooldown-dt)
 for _,n in ipairs(b.nodes) do n.cooldown=math.max(0,(n.cooldown or 0)-dt) end
 for _,n in ipairs(b.portals) do n.cooldown=math.max(0,(n.cooldown or 0)-dt) end
 if player.isDashing then Bosses.hitNode(world,player,player.x,player.y,player.radius+13,1) end
 b.stun=math.max(0,b.stun-dt);b.reveal=math.max(0,b.reveal-dt)
 local phase=b.hp/b.maxHp>0.66 and 1 or (b.hp/b.maxHp>0.33 and 2 or 3)
 if phase~=b.phase then
  b.phase=phase;Effects.addText(b.x,b.y-60,'FASE '..phase,1,0.85,0.35)
  pulse(b.x,b.y,180,b.color);Audio.play('boss')
  if b.kind==1 and phase==3 then b.nodes={node(225,235,1),node(575,235,1)};b.shield=true end
 end
 if b.kind==2 then b.cycle=(b.cycle+dt)%8 end
 if b.kind==4 then
  if activeNodes(b)==0 then
   b.vulnerable=b.vulnerable-dt
   if b.vulnerable<=0 then
    b.portals={node(180,280,1),node(620,280,1)};b.shield=true
    Effects.addText(b.x,b.y-55,'PORTALES REACTIVADOS',1,0.6,1)
   end
  end
  if b.teleportWarning>0 then
   b.teleportWarning=b.teleportWarning-dt
   if b.teleportWarning<=0 then b.x,b.y=b.teleportX,b.teleportY;pulse(b.x,b.y,100,b.color) end
  end
 end
 updateMovement(b,dt)
 updateWarnings(b,world,dt,player)
 b.attackTimer=b.attackTimer+dt
 local interval=({2.65,2.3,2.6,2.6})[b.kind]-0.24*(b.phase-1)
 if b.attackTimer>=interval then
  b.attackTimer=b.attackTimer-interval
  if b.kind==1 then attackForest(world,b,player)
  elseif b.kind==2 then attackFoundry(world,b,player)
  elseif b.kind==3 then attackCrystal(world,b,player)
  else attackVoid(world,b,player) end
  Audio.play('shot')
 end
 if dist2(player.x,player.y,b.x,b.y)<(player.radius+b.radius)^2 then
  if player.isDashing or player.overdriveTimer>0 then
   Bosses.damage(world,player,player.isDashing and (5+player.speedUpgrade) or 2,'contact')
  else player.takeHit(21) end
 end
 if b.kind==3 and b.reveal<=0 then
  for _,d in ipairs(b.decoys) do
   if dist2(player.x,player.y,d.x,d.y)<(player.radius+25)^2 and not player.isDashing then player.takeHit(14) end
  end
 end
end
function Bosses.draw(world)
 local b=world.boss;if not b then return end
 local t=b.time
 for _,w in ipairs(b.warnings) do
  local rem=w.t>0 and w.t/math.max(0.01,w.max) or 0
  if w.kind=='lane' then
   for offset=-2,2 do Sprites.drawTelegraph(w.x,w.y+offset*70,w.r,rem,'lane') end
  else
   Sprites.drawTelegraph(w.x,w.y,w.r,rem,w.kind)
  end
 end
 local nodes=b.kind==1 and b.nodes or (b.kind==4 and b.portals or {})
 for _,n in ipairs(nodes) do
  if n.hp>0 then Sprites.drawBossNode(n.x,n.y,b.kind,t) end
 end
 if b.kind==3 and b.reveal<=0 then
  for _,d in ipairs(b.decoys) do
   Sprites.drawBoss({kind=3,x=d.x,y=d.y,angle=-t,hp=1,maxHp=1,time=t,decoy=true})
  end
 end
 if b.kind==4 and b.teleportWarning>0 then
  Sprites.drawTelegraph(b.teleportX,b.teleportY,42,b.teleportWarning/.65,'portal')
 end
 Sprites.drawBoss(b)
end
function Bosses.hint(b)
 if not b then return '' end
 if b.kind==1 then return activeNodes(b)>0 and ('ROMPE LOS SELLOS ('..activeNodes(b)..') CON DASH O PULSO') or 'NUCLEO EXPUESTO: ATACA'
 elseif b.kind==2 then return b.cycle<5 and 'ESPERA EL SOBRECALENTAMIENTO / F ACELERA' or 'SOBRECALENTADO: ATACA AHORA'
 elseif b.kind==3 then return b.reveal>0 and 'ORIGINAL REVELADO' or 'LOS REFLEJOS ENGANAN / PULSO REVELA'
 else return activeNodes(b)>0 and ('DESACTIVA LOS PORTALES ('..activeNodes(b)..')') or 'ESCUDO CAIDO: APROVECHA LA VENTANA' end
end
return Bosses
