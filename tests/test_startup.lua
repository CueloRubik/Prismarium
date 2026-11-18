package.path='./?.lua;'..package.path
local readCalls=0
local files={}
love={
 math={setRandomSeed=math.randomseed,random=math.random},
 graphics={
  newFont=function()return {getWidth=function(_,text)return #tostring(text)*7 end,getHeight=function()return 14 end}end,
 },
 filesystem={
  getInfo=function()return nil end,
  read=function(path)
   readCalls=readCalls+1
   if files[path]~=nil then return files[path] end
   return nil,'File does not exist'
  end,
  write=function(path,data) files[path]=data return true end,
 },
 event={quit=function()end},
}
dofile('main.lua')
local ok,err=pcall(love.load)
assert(ok, 'initial load with missing best_score.txt must not crash: '..tostring(err))
assert(readCalls>0,'startup should attempt loading save data')
files['best_score.txt']='247'
ok,err=pcall(love.load)
assert(ok,'startup with existing best score must not crash: '..tostring(err))
print('STARTUP OK: absent and present save files')
