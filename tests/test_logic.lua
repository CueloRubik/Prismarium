package.path='./?.lua;'..package.path
local file={}
love={math={random=math.random},filesystem={read=function(p)return file[p] end,write=function(p,d)file[p]=d;return true end}}
local Progress=require('progression');Progress.load()
assert(Progress.getSkinStats('starter_rig').speed>0)
local uniqueStats={}
for _,id in ipairs(Progress.skinOrder) do
 local s=Progress.getSkinStats(id)
 assert(s.movement>0 and s.maxEnergy>0 and s.pulseRadius>0 and s.attack>0,'invalid stats '..id)
 local k=string.format('%0.2f/%0.2f/%0.2f/%0.2f',s.speed,s.attack,s.tech,s.guard)
 uniqueStats[k]=true
end
local count=0;for _ in pairs(uniqueStats) do count=count+1 end
assert(count>=12,'vehicle roster needs varied stats')
assert(Progress.isAbilityUnlocked('dash') and Progress.isAbilityUnlocked('pulse'),'two base actions')
assert(not Progress.isAbilityUnlocked('shield'),'secondary not free')
assert(Progress.getSecondarySlotCost()==28)
print('LOGIC OK: stats, initial controls, skill gating, roster diversity')
