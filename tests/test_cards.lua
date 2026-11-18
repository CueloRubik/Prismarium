package.path='./?.lua;'..package.path
local files={}
love={math={random=math.random},filesystem={read=function(p)return files[p] end,write=function(p,d)files[p]=d;return true end}}
local P=require('progression')
math.randomseed(180)
P.load()
assert(#P.skinOrder==30,'30 collectible vehicles')
assert(P.getUniqueCardCount()==1,'starter card')
local unique={}
for _,id in ipairs(P.skinOrder) do
 assert(not unique[id],'duplicate card ID')
 unique[id]=true
 assert(P.cardDefs[id] and P.skins[id] and P.skins[id].name and P.skins[id].stats,'complete vehicle definition: '..id)
end
assert(#P.levelCopies==5,'five separate levels')
P.reward(300)
for _,pack in ipairs({'starter_pack','grand_pack','giant_pack'}) do
 local spec=P.packDefs[pack]
 local before=P.coins
 local ok,_,drawn=P.buyPack(pack)
 assert(ok and #drawn==spec.count and P.coins==before-spec.cost,'pack quantity or price: '..pack)
 assert(not P.buyPack(pack),'pending prevents repeat purchase')
 assert(P.claimPending(),'claim pack')
end
local sid=P.skinOrder[5]
P.cards[sid]=11
P.evaluateUnlocks()
assert(P.getSkinLevel(sid)==5 and P.skinsOwned[sid],'duplicates level up and unlock')
assert(P.equipSkin(sid),'skin equip')
print('CARDS OK: 30 distinct definitions, 3 packs, levels, purchases')
