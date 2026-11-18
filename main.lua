local Player=require('player')
local World=require('world')
local Effects=require('effects')
local UI=require('ui')
local Audio=require('audio')
local Maps=require('maps')
local Progress=require('progression')
local Screens=require('screens')
local Tutorial=require('tutorial')
local CardsUI=require('cards_ui')

local state='menu'
local selected=1
local aimX,aimY=500,300
local bestScore=0

local function change(nextState)
 state=nextState
 UI.buttons={}
 if nextState=='playing' then UI.buildPlayingButtons()
 elseif nextState=='paused' then UI.buildPauseButtons()
 elseif nextState=='victory' then UI.buildVictoryButtons()
 elseif nextState=='gameover' then UI.buildGameOverButtons() end
end

local function start(index)
 if index ~= 0 and index>Progress.unlocked then UI.toast('MAPA BLOQUEADO');return end
 selected=index
 Player.reset();World.reset();Effects.reset();Maps.set(index)
 local targets={160,220,280,340,410,500}
 local hazards={3,4,5,6,7,8}
 World.level=index==0 and 1 or index
 World.levelTargetScore=targets[index] or (220+math.max(1,index)*80)
 World.maxHazards=hazards[index] or (4+math.max(1,index)*2)
 UI.showUpgrades=false
 UI.gridVisible=false
 aimX,aimY=500,300
 if index==0 then
  Tutorial.start(World)
 else
  Tutorial.stop(World)
 end
 change('playing')
 Audio.play('click')
end

local function finish(win)
 World.coinsCount=0
 if win then
  if selected==0 then
   Progress.tutorialDone=true
   Progress.reward(4)
   Progress.save()
   Tutorial.stop(World)
   selected=1
  else
   Progress.clear(selected)
  end
 end
 if World.score>bestScore then
  bestScore=World.score
  pcall(love.filesystem.write,'best_score.txt',tostring(bestScore))
 end
 UI.showUpgrades=false
 change(win and 'victory' or 'gameover')
end

local function resolveAbility(id)
 if id == 'secondary1' or id == 'secondary2' or id == 'secondary3' then
  local slot = tonumber(id:sub(-1))
  return Progress.getEquippedSecondary()[slot]
 end
 return id
end

local function ability(id)
 local use = resolveAbility(id)
 if not use then UI.toast('RANURA VACIA'); return end
 local ok=false
 if use=='dash' then ok=Player.dash(aimX,aimY)
 elseif use=='pulse' then ok=Player.triggerPulse(World)
 elseif use=='shield' then ok=Player.activateShield()
 elseif use=='magnet' then ok=Player.triggerSingularity(World)
 elseif use=='overdrive' then ok=Player.triggerOverdrive()
 elseif use=='counter' then ok=Player.counter()
 elseif use=='beacon' then ok=Player.deployBeacon(World)
 elseif use=='mine' then ok=Player.deployMine(World) end
 if not ok then UI.toast('HABILIDAD EN RECARGA O SIN ENERGIA');return end
 Tutorial.onAbility(use)
 local sounds={dash='dash',pulse='pulse',shield='shield',magnet='singularity',overdrive='overdrive',counter='shield',beacon='singularity',mine='pulse'}
 Audio.play(sounds[use] or 'click')
end

function love.load()
 love.math.setRandomSeed(os.time())
 UI.init();Audio.init();Progress.load();Maps.load();Maps.set(1);Screens.load();Tutorial.load();CardsUI.load()
 bestScore=tonumber(love.filesystem.read('best_score.txt')) or 0
end

function love.update(dt)
 dt=math.max(0,math.min(0.1,dt))
 Screens.update(dt)
 CardsUI.update(dt)
 local mx,my=love.mouse.getPosition()
 UI.update(mx,my,dt)
 if state=='playing' and not UI.showUpgrades then
  if mx>=40 and mx<=760 and my>=116 and my<=526 then aimX,aimY=mx,my end
  local left=dt
  while left>0 do
   local step=math.min(left,1/60);left=left-step
   Maps.update(step)
   Player.update(step,aimX,aimY)
   Maps.effect(Player,step)
   World.update(step,Player)
   Effects.update(step)
   Tutorial.update(step,World,Player)
   if Player.energy<=0 then finish(false);break end
   if World.isVictory then finish(true);break end
  end
 end
end

function love.keypressed(key)
 if key=='m' then Audio.toggle();return end
 if state=='menu' then
  if key=='return' or key=='space' then change('select')
  elseif key=='escape' then love.event.quit()
  elseif key=='h' then change('help') end
  return
 elseif state=='select' then
  if key=='left' or key=='a' then selected=(selected-2)%#Maps.list+1
  elseif key=='right' or key=='d' then selected=selected%#Maps.list+1
  elseif key=='return' or key=='space' then start(selected)
  elseif key=='t' then start(0)
  elseif key=='escape' or key=='backspace' then change('menu')
  elseif tonumber(key) and tonumber(key)>=1 and tonumber(key)<=#Maps.list then selected=tonumber(key) end
  return
 elseif state=='help' or state=='laboratory' then
  if key=='escape' or key=='backspace' then change('menu') end
  return
 elseif state=='paused' then
  if key=='escape' or key=='p' then change('playing') end
  return
 elseif state=='victory' or state=='gameover' then
  if key=='return' or key=='space' then change('select')
  elseif key=='r' then start(selected)
  elseif key=='escape' then change('menu') end
  return
 end
 if state~='playing' then return end
 if UI.showUpgrades then
  if key=='u' or key=='escape' then UI.showUpgrades=false;UI.buildPlayingButtons() end
  return
 end
 if key=='escape' or key=='p' then change('paused')
 elseif key=='space' or key=='w' then ability('dash')
 elseif key=='s' or key=='f' then ability('pulse')
 elseif key=='1' then ability('secondary1')
 elseif key=='2' then ability('secondary2')
 elseif key=='3' then ability('secondary3')
 end
end

function love.mousepressed(x,y,button)
 if state=='menu' then
  local id=Screens.click(x,y)
  if id=='play' then change('select')
  elseif id=='laboratory' then CardsUI.open();change('laboratory')
  elseif id=='help' then change('help')
  elseif id=='quit' then love.event.quit() end
  return
 elseif state=='select' then
  local id=Screens.click(x,y)
  if id=='prev' then selected=(selected-2)%#Maps.list+1
  elseif id=='next' then selected=selected%#Maps.list+1
  elseif id=='start' then start(selected)
  elseif id=='tutorial' then start(0)
  elseif id=='back' then change('menu') end
  return
 elseif state=='help' then
  if Screens.click(x,y)=='back' then change('menu') end
  return
 elseif state=='laboratory' then
  local action=CardsUI.click(x,y)
  if action=='close' then change('menu')
  elseif action then UI.toast(action) end
  return
 elseif state=='playing' and UI.showUpgrades then
  local id=Screens.click(x,y)
  if id=='close' then UI.showUpgrades=false;UI.buildPlayingButtons()
  elseif id and id:match('^tab') then Screens.tab=math.max(1,math.min(2,tonumber(id:sub(4)) or 1))
  elseif id and id:match('^buy:') then
   local ok,msg=Progress.buy(id:sub(5),Player)
   UI.toast(msg);Audio.play(ok and 'buy' or 'click')
  end
  return
 end
 local id=UI.mousepressed(x,y,button)
 if state=='paused' then
  if id=='resume' then change('playing')
  elseif id=='restart' then start(selected)
  elseif id=='menu' then change('menu') end
  return
 elseif state=='victory' or state=='gameover' then
  if id=='restart' then start(selected)
  elseif id=='menu' then change('menu') end
  return
 elseif state~='playing' then return end
 if id=='pause' then change('paused')
 elseif id=='restart' then start(selected)
 elseif id then ability(id)
 elseif x>=40 and x<=760 and y>=115 and y<=526 then
  aimX,aimY=x,y
  if button==1 then ability('pulse')
  elseif button==2 then ability('dash') end
 end
end

function love.wheelmoved(x,y)
 if state=='laboratory' then CardsUI.wheelmoved(x,y) end
end

function love.focus(focused)
 if not focused and state=='playing' and not UI.showUpgrades then change('paused') end
end

function love.draw()
 if state=='menu' then
  Screens.drawMain(Progress,bestScore)
 elseif state=='select' then
  Screens.drawMap(Progress,selected)
 elseif state=='help' then
  Screens.drawHelp()
 elseif state=='laboratory' then
  CardsUI.draw()
  UI.drawFloatingFeedback(nil,nil)
 else
  Maps.draw(UI.gridVisible)
  love.graphics.push()
  if state=='playing' then Effects.applyCamera() end
  Maps.drawZones();World.draw();Player.draw();Effects.draw()
  if state=='playing' or state=='paused' then UI.drawAimReticle(aimX,aimY,Player) end
  love.graphics.pop()
  UI.drawHUD(Player,World)
  UI.drawBottomBar(Audio.enabled)
  UI.drawBossHUD(World)
  if state=='playing' and not UI.showUpgrades then UI.drawButtons(Player,World) end
  if state=='paused' then
   UI.drawOverlayPanel(320,186)
   UI.drawPauseInfo();UI.drawButtons(Player,World)
  end
  if state=='victory' or state=='gameover' then
   UI.drawOverlayPanel(544,328,state=='victory' and 'victory' or 'defeat')
   love.graphics.setColor(1,1,1)
   love.graphics.setFont(UI.fonts.heading)
   love.graphics.printf(state=='victory' and 'EXPEDICION COMPLETADA' or 'FIN DE LA PARTIDA',168,243,464,'center')
   love.graphics.setFont(UI.fonts.medium)
   love.graphics.printf('PUNTOS '..World.score..'   |   RECORD '..bestScore,150,312,500,'center')
   UI.drawButtons(nil,nil)
  end
  if UI.showUpgrades then Screens.drawShop(Progress,Player,false) end
  if Tutorial.isActive() and state=='playing' and not UI.showUpgrades then Tutorial.draw(World) end
  UI.drawFloatingFeedback(Player,World)
 end
 love.graphics.setColor(1,1,1,1)
end
