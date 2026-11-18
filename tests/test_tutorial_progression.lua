package.path='./?.lua;'..package.path
local f={getWidth=function()return 200 end,getHeight=function()return 140 end,setFilter=function()end}
love={math={random=math.random},filesystem={getInfo=function()return nil end},graphics={newFont=function() return {} end}}
local UI=require('ui')
local Tutorial=require('tutorial')
local w={crystals={},hazards={},coins={},powerups={},beacons={},mines={},boss=nil,isVictory=false,
 addCrystal=function(x,y,g) local w=package.loaded.__tutorialWorld;w.crystals[#w.crystals+1]={x=x,y=y,golden=g} end,
 addEnemy=function(kind,x,y) local w=package.loaded.__tutorialWorld;w.hazards[#w.hazards+1]={type=kind,x=x,y=y} end}
package.loaded.__tutorialWorld=w
Tutorial.start(w)
assert(w.tutorialMode and not w.boss and #w.hazards==0,'tutorial separate, no boss')
table.remove(w.crystals,1);Tutorial.update(.1,w,{})
assert(Tutorial.step==2,'crystal -> dash')
Tutorial.onAbility('dash');Tutorial.update(.1,w,{})
assert(Tutorial.step==3 and #w.hazards==1,'dash -> wave enemy')
Tutorial.onAbility('pulse');Tutorial.update(.1,w,{})
assert(Tutorial.step==4,'wave trained')
w.hazards={};Tutorial.update(.1,w,{})
assert(Tutorial.step==5 and #w.hazards==2,'new enemy archetypes')
w.hazards={};Tutorial.update(.1,w,{})
assert(Tutorial.step==6,'secondary abilities guidance')
Tutorial.update(.8,w,{})
assert(Tutorial.step==7,'tutorial ending')
Tutorial.update(.8,w,{})
assert(w.isVictory,'tutorial completion without boss')
print('TUTORIAL OK: separate map, two base abilities, enemy progression')
