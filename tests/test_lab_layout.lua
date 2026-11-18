package.path='./?.lua;'..package.path
local noop=function()end
local font={getWidth=function(_,s)return #(tostring(s))*7 end,getHeight=function()return 12 end}
love={math={random=math.random},filesystem={
 read=function()return nil end,write=function()return true end,
 getInfo=function(path) local f=io.open(path,'rb');if f then f:close();return {type='file'} end end
}}
love.graphics={newImage=function(path)assert(love.filesystem.getInfo(path),path);return {setFilter=noop,getWidth=function()return 256 end,getHeight=function()return 256 end}end,
 newFont=function()return font end,setFont=noop,getFont=function()return font end,
 setColor=noop,draw=noop,print=noop,printf=noop,setScissor=noop}
local Progress=require('progression');Progress.load()
local CardsUI=require('cards_ui');CardsUI.load();CardsUI.open()
for t=1,3 do
 CardsUI.tab=t
 CardsUI.draw()
 assert(#CardsUI.buttons>0,'tab has controls')
 for _,b in ipairs(CardsUI.buttons) do
  assert(b.x>=0 and b.y>=0 and b.x+b.w<=800 and b.y+b.h<=600,'button out of screen: '..b.id)
  assert(b.w>0 and b.h>0,'invalid bounds')
 end
end
CardsUI.tab=2;CardsUI.wheelmoved(0,-12);CardsUI.draw()
assert(CardsUI.scroll>0,'album scroll must move')
local maxScroll=30/4*218
assert(CardsUI.scroll<=maxScroll,'scroll bounded')
CardsUI.tab=1
for _,n in ipairs({5,8}) do
 Progress.pending={}
 for i=1,n do Progress.pending[i]=Progress.skinOrder[i] end
 CardsUI.flipped={}
 CardsUI.flipTime={}
 CardsUI.draw()
 local claim
 local buttons=CardsUI.buttons
 for _,b in ipairs(buttons) do
  if b.id=='claim' then claim=b end
  assert(b.y+b.h<=600,'pack control outside screen: '..b.id)
 end
 assert(claim,'claim button missing for '..n..' cards')
 for _,b in ipairs(buttons) do
  if b.id:match('^flip:') then assert(b.y+b.h<claim.y,'pack reveal overlaps claim button') end
 end
end
CardsUI.flipTime={[2]=0}
CardsUI.update(0.25)
assert(CardsUI.flipTime[2]>0,'second card flip animation must advance')
print('LAB UI OK: 3 tabs, 30-card grid, 5/8-card packs, scrolling and animations')
