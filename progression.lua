local Progress={
 coins=0, unlocked=1, cleared={}, tutorialDone=false,
 cards={}, pending={}, skinsOwned={}, equippedSkin='starter_rig',
 secondaryOwned={}, secondaryEquipped={false,false,false}, secondarySlots=1
}

Progress.packDefs={ starter_pack={cost=18,count=2,name='SOBRE PEQUENO',guaranteed=1}, grand_pack={cost=42,count=5,name='SOBRE GRANDE',guaranteed=2}, giant_pack={cost=72,count=8,name='SOBRE GIGANTE',guaranteed=3} }
Progress.shop={ {id='starter_pack',name='SOBRE PEQUENO',desc='2 cartas de hangar',cost=18,category='SOBRES'}, {id='grand_pack',name='SOBRE GRANDE',desc='5 cartas con mejor novedad',cost=42,category='SOBRES'}, {id='giant_pack',name='SOBRE GIGANTE',desc='8 cartas para avanzar rapido',cost=72,category='SOBRES'} }
Progress.secondaryDefs={}
Progress.secondaryDefs['shield']={name='ESCUDO VECTOR',desc='Genera un escudo que bloquea un impacto.',cost=18,icon='shield'}
Progress.secondaryDefs['magnet']={name='IMÁN DE NÚCLEO',desc='Atrae prismas cercanos con una implosión breve.',cost=22,icon='singularity'}
Progress.secondaryDefs['overdrive']={name='OVERDRIVE',desc='Durante unos segundos no recibe daño.',cost=28,icon='overdrive'}
Progress.secondaryDefs['counter']={name='CONTRAGOLPE',desc='Parada corta que castiga al jefe y proyectiles.',cost=24,icon='counter'}
Progress.secondaryDefs['beacon']={name='BALIZA',desc='Coloca una baliza que atrae enemigos.',cost=26,icon='beacon'}
Progress.secondaryDefs['mine']={name='MINA PRISMA',desc='Deja una mina que estalla al contacto.',cost=30,icon='mine'}
Progress.secondaryOrder={'shield','magnet','overdrive','counter','beacon','mine'}
Progress.skinOrder={'starter_rig','moss_comet','ember_hound','quartz_manta','neon_raptor','iron_petal','aurora_scout','cobalt_ray','drift_beetle','dusk_runner','pulse_fox','jade_hopper','blaze_orbit','relic_sting','mist_walker','flare_serpent','silver_tusk','storm_kite','orbit_badger','crystal_lark','magma_lynx','lunar_gull','bronze_viper','frost_rook','solar_marrow','velvet_halo','turbo_mole','arc_whale','rune_harrier','nova_stag'}
Progress.cardOrder=Progress.skinOrder
Progress.cardDefs={}
Progress.skins={}
Progress.cardDefs['starter_rig']={name='ALA VECTOR',desc='Marco base del hangar prismático.',rarity='common'}
Progress.skins['starter_rig']={name='ALA VECTOR',desc='Marco base del hangar prismático.',rarity='common',stats={speed=4,attack=3,tech=3,guard=4},bonus=0}
Progress.cardDefs['moss_comet']={name='COMETA MUSGO',desc='Ágil explorador con aletas cortas y empuje sereno.',rarity='common'}
Progress.skins['moss_comet']={name='COMETA MUSGO',desc='Ágil explorador con aletas cortas y empuje sereno.',rarity='common',stats={speed=5,attack=2,tech=3,guard=3},bonus=0}
Progress.cardDefs['ember_hound']={name='SABUESO ASCUA',desc='Chasis agresivo de proa afilada y gran respuesta.',rarity='rare'}
Progress.skins['ember_hound']={name='SABUESO ASCUA',desc='Chasis agresivo de proa afilada y gran respuesta.',rarity='rare',stats={speed=4,attack=5,tech=2,guard=3},bonus=1}
Progress.cardDefs['quartz_manta']={name='MANTA CUARZO',desc='Vehículo ancho y estable de giro elegante.',rarity='common'}
Progress.skins['quartz_manta']={name='MANTA CUARZO',desc='Vehículo ancho y estable de giro elegante.',rarity='common',stats={speed=3,attack=3,tech=4,guard=5},bonus=0}
Progress.cardDefs['neon_raptor']={name='RAPTOR NEÓN',desc='Asalto veloz con ataque de barrido.',rarity='rare'}
Progress.skins['neon_raptor']={name='RAPTOR NEÓN',desc='Asalto veloz con ataque de barrido.',rarity='rare',stats={speed=5,attack=4,tech=3,guard=2},bonus=1}
Progress.cardDefs['iron_petal']={name='PÉTALO FÉRREO',desc='Casco floral blindado que resiste impactos.',rarity='common'}
Progress.skins['iron_petal']={name='PÉTALO FÉRREO',desc='Casco floral blindado que resiste impactos.',rarity='common',stats={speed=2,attack=3,tech=3,guard=5},bonus=0}
Progress.cardDefs['aurora_scout']={name='EXPLORADOR AURORA',desc='Unidad equilibrada para rutas largas.',rarity='common'}
Progress.skins['aurora_scout']={name='EXPLORADOR AURORA',desc='Unidad equilibrada para rutas largas.',rarity='common',stats={speed=4,attack=4,tech=4,guard=4},bonus=0}
Progress.cardDefs['cobalt_ray']={name='MANTARRAYA COBALTO',desc='Modelo técnico de gran eficiencia energética.',rarity='rare'}
Progress.skins['cobalt_ray']={name='MANTARRAYA COBALTO',desc='Modelo técnico de gran eficiencia energética.',rarity='rare',stats={speed=3,attack=3,tech=5,guard=4},bonus=1}
Progress.cardDefs['drift_beetle']={name='ESCARABAJO DRIFT',desc='Pequeño corredor con derrape corto.',rarity='common'}
Progress.skins['drift_beetle']={name='ESCARABAJO DRIFT',desc='Pequeño corredor con derrape corto.',rarity='common',stats={speed=5,attack=3,tech=2,guard=4},bonus=0}
Progress.cardDefs['dusk_runner']={name='CORREDOR OCASO',desc='Vehículo sigiloso de pulsos potentes.',rarity='rare'}
Progress.skins['dusk_runner']={name='CORREDOR OCASO',desc='Vehículo sigiloso de pulsos potentes.',rarity='rare',stats={speed=4,attack=5,tech=3,guard=3},bonus=1}
Progress.cardDefs['pulse_fox']={name='ZORRO DE PULSO',desc='Núcleo hiperreactivo y recuperación rápida.',rarity='epic'}
Progress.skins['pulse_fox']={name='ZORRO DE PULSO',desc='Núcleo hiperreactivo y recuperación rápida.',rarity='epic',stats={speed=5,attack=4,tech=5,guard=2},bonus=2}
Progress.cardDefs['jade_hopper']={name='SALTADOR JADE',desc='Plataforma saltarina con buen control.',rarity='common'}
Progress.skins['jade_hopper']={name='SALTADOR JADE',desc='Plataforma saltarina con buen control.',rarity='common',stats={speed=4,attack=3,tech=4,guard=4},bonus=0}
Progress.cardDefs['blaze_orbit']={name='ÓRBITA CANDENTE',desc='Aro delantero que amplifica la onda.',rarity='rare'}
Progress.skins['blaze_orbit']={name='ÓRBITA CANDENTE',desc='Aro delantero que amplifica la onda.',rarity='rare',stats={speed=3,attack=5,tech=4,guard=3},bonus=1}
Progress.cardDefs['relic_sting']={name='AGUIJÓN RELICARIO',desc='Unidad fina de ataques certeros.',rarity='rare'}
Progress.skins['relic_sting']={name='AGUIJÓN RELICARIO',desc='Unidad fina de ataques certeros.',rarity='rare',stats={speed=4,attack=4,tech=3,guard=4},bonus=1}
Progress.cardDefs['mist_walker']={name='CAMINANTE BRUMA',desc='Modelo suave con gran estabilidad.',rarity='common'}
Progress.skins['mist_walker']={name='CAMINANTE BRUMA',desc='Modelo suave con gran estabilidad.',rarity='common',stats={speed=3,attack=3,tech=5,guard=5},bonus=0}
Progress.cardDefs['flare_serpent']={name='SERPIENTE FULGOR',desc='Línea alargada enfocada al daño.',rarity='rare'}
Progress.skins['flare_serpent']={name='SERPIENTE FULGOR',desc='Línea alargada enfocada al daño.',rarity='rare',stats={speed=5,attack=5,tech=2,guard=2},bonus=1}
Progress.cardDefs['silver_tusk']={name='COLMILLO PLATA',desc='Blindaje frontal y gran empuje.',rarity='common'}
Progress.skins['silver_tusk']={name='COLMILLO PLATA',desc='Blindaje frontal y gran empuje.',rarity='common',stats={speed=3,attack=4,tech=3,guard=5},bonus=0}
Progress.cardDefs['storm_kite']={name='COMETA TORMENTA',desc='Alta velocidad y buena tecnología.',rarity='epic'}
Progress.skins['storm_kite']={name='COMETA TORMENTA',desc='Alta velocidad y buena tecnología.',rarity='epic',stats={speed=5,attack=4,tech=5,guard=3},bonus=2}
Progress.cardDefs['orbit_badger']={name='TEJÓN ORBITAL',desc='Unidad compacta de corto alcance.',rarity='common'}
Progress.skins['orbit_badger']={name='TEJÓN ORBITAL',desc='Unidad compacta de corto alcance.',rarity='common',stats={speed=3,attack=4,tech=4,guard=5},bonus=0}
Progress.cardDefs['crystal_lark']={name='ALONDRA PRISMA',desc='Elegante, ligera y precisa.',rarity='rare'}
Progress.skins['crystal_lark']={name='ALONDRA PRISMA',desc='Elegante, ligera y precisa.',rarity='rare',stats={speed=5,attack=3,tech=5,guard=3},bonus=1}
Progress.cardDefs['magma_lynx']={name='LINCE MAGMA',desc='Modelo feroz de contacto cercano.',rarity='epic'}
Progress.skins['magma_lynx']={name='LINCE MAGMA',desc='Modelo feroz de contacto cercano.',rarity='epic',stats={speed=4,attack=5,tech=3,guard=4},bonus=2}
Progress.cardDefs['lunar_gull']={name='GAVIOTA LUNAR',desc='Chasis flotante de maniobra limpia.',rarity='common'}
Progress.skins['lunar_gull']={name='GAVIOTA LUNAR',desc='Chasis flotante de maniobra limpia.',rarity='common',stats={speed=4,attack=3,tech=5,guard=4},bonus=0}
Progress.cardDefs['bronze_viper']={name='VÍBORA BRONCE',desc='Daño alto con defensa media.',rarity='rare'}
Progress.skins['bronze_viper']={name='VÍBORA BRONCE',desc='Daño alto con defensa media.',rarity='rare',stats={speed=4,attack=5,tech=2,guard=4},bonus=1}
Progress.cardDefs['frost_rook']={name='TORRE ESCARCHA',desc='Vehículo robusto y sereno.',rarity='common'}
Progress.skins['frost_rook']={name='TORRE ESCARCHA',desc='Vehículo robusto y sereno.',rarity='common',stats={speed=2,attack=4,tech=4,guard=5},bonus=0}
Progress.cardDefs['solar_marrow']={name='MÉDULA SOLAR',desc='Conversión energética notable.',rarity='epic'}
Progress.skins['solar_marrow']={name='MÉDULA SOLAR',desc='Conversión energética notable.',rarity='epic',stats={speed=3,attack=4,tech=5,guard=4},bonus=2}
Progress.cardDefs['velvet_halo']={name='HALO TERCIOPELO',desc='Unidad refinada con mucha defensa.',rarity='rare'}
Progress.skins['velvet_halo']={name='HALO TERCIOPELO',desc='Unidad refinada con mucha defensa.',rarity='rare',stats={speed=3,attack=3,tech=4,guard=5},bonus=1}
Progress.cardDefs['turbo_mole']={name='TOPO TURBO',desc='Motor agresivo de explosión rápida.',rarity='epic'}
Progress.skins['turbo_mole']={name='TOPO TURBO',desc='Motor agresivo de explosión rápida.',rarity='epic',stats={speed=5,attack=4,tech=3,guard=3},bonus=2}
Progress.cardDefs['arc_whale']={name='BALLENA ARCO',desc='Casco pesado con potencia sostenida.',rarity='epic'}
Progress.skins['arc_whale']={name='BALLENA ARCO',desc='Casco pesado con potencia sostenida.',rarity='epic',stats={speed=2,attack=5,tech=5,guard=5},bonus=2}
Progress.cardDefs['rune_harrier']={name='CETRERO RÚNICO',desc='Excelente balance y control técnico.',rarity='epic'}
Progress.skins['rune_harrier']={name='CETRERO RÚNICO',desc='Excelente balance y control técnico.',rarity='epic',stats={speed=4,attack=4,tech=5,guard=4},bonus=2}
Progress.cardDefs['nova_stag']={name='CIERVO NOVA',desc='Prototipo final del hangar.',rarity='legendary'}
Progress.skins['nova_stag']={name='CIERVO NOVA',desc='Prototipo final del hangar.',rarity='legendary',stats={speed=5,attack=5,tech=5,guard=4},bonus=3}
Progress.levelCopies={1,2,4,7,11}
local mapRewards={6,8,10,12,14,18}
local function integer(v,low,high) return math.max(low,math.min(high,math.floor(tonumber(v) or 0))) end
local function shallowCopy(tab) local r={} for i,v in ipairs(tab) do r[i]=v end return r end
local function contains(tab,val) for i,v in ipairs(tab) do if v==val then return i end end return nil end
function Progress.getCardCount(id) return integer(Progress.cards[id] or 0,0,9999) end
function Progress.getUniqueCardCount() local n=0 for _,id in ipairs(Progress.cardOrder) do if Progress.getCardCount(id)>0 then n=n+1 end end return n end
function Progress.getSkinLevel(id) local copies=Progress.getCardCount(id) local lvl=0 for i,need in ipairs(Progress.levelCopies) do if copies>=need then lvl=i end end return lvl end
function Progress.getSkinProgress(id) local copies=Progress.getCardCount(id) local lvl=Progress.getSkinLevel(id) local nextNeed=Progress.levelCopies[math.min(#Progress.levelCopies,lvl+1)] if lvl>=#Progress.levelCopies then return copies,Progress.levelCopies[#Progress.levelCopies] end return copies,nextNeed end
function Progress.getOwnedSkins() local arr={} for _,id in ipairs(Progress.skinOrder) do if Progress.skinsOwned[id] then arr[#arr+1]=id end end return arr end
function Progress.getSkinStats(id)
 local skin=Progress.skins[id] or Progress.skins['starter_rig']
 local base=skin.stats or {speed=3,attack=3,tech=3,guard=3}
 local lvl=math.max(1,Progress.getSkinLevel(id))
 local bonus=(lvl-1)*0.45 + (skin.bonus or 0)*0.18
 local speed=base.speed+bonus
 local attack=base.attack+bonus
 local tech=base.tech+bonus
 local guard=base.guard+bonus
 return {speed=speed,attack=attack,tech=tech,guard=guard,level=lvl,maxLevel=#Progress.levelCopies, movement=228+speed*14, dashForce=930+speed*70, maxEnergy=68+guard*10, drain=2.5-tech*0.18, pulseRadius=132+attack*10, pulseCost=math.max(10,20-tech*1.0), dashCost=math.max(7,12-tech*0.55), pulseBossDamage=2+math.floor((attack+lvl)/2), damageReduction=math.min(0.30,guard*0.03)}
end
function Progress.evaluateUnlocks() for _,id in ipairs(Progress.skinOrder) do Progress.skinsOwned[id]=Progress.getCardCount(id)>0 end Progress.skinsOwned['starter_rig']=true if not Progress.skinsOwned[Progress.equippedSkin] then Progress.equippedSkin='starter_rig' end if Progress.getCardCount('starter_rig')==0 then Progress.cards['starter_rig']=1 end for i=1,3 do if i>Progress.secondarySlots then Progress.secondaryEquipped[i]=false end end end
function Progress.isAbilityUnlocked(id) if id=='dash' or id=='pulse' then return true end return Progress.secondaryOwned[id]==true end
function Progress.getEquippedSecondary() local arr={} for i=1,Progress.secondarySlots do arr[i]=Progress.secondaryEquipped[i] or false end return arr end
function Progress.isSecondaryOwned(id) return Progress.secondaryOwned[id]==true end
function Progress.save() if not love.filesystem or not love.filesystem.write then return false end local lines={'coins='..Progress.coins,'unlocked='..Progress.unlocked,'equippedSkin='..Progress.equippedSkin,'tutorial='..tostring(Progress.tutorialDone),'secondarySlots='..Progress.secondarySlots} for id,v in pairs(Progress.cleared) do lines[#lines+1]='clear_'..id..'='..tostring(v) end for id,v in pairs(Progress.cards) do lines[#lines+1]='card_'..id..'='..integer(v,0,9999) end for id,v in pairs(Progress.secondaryOwned) do lines[#lines+1]='skill_'..id..'='..tostring(v) end for i=1,3 do if Progress.secondaryEquipped[i] then lines[#lines+1]='slot_'..i..'='..Progress.secondaryEquipped[i] end end lines[#lines+1]='pendingCount='..#Progress.pending for i,id in ipairs(Progress.pending) do lines[#lines+1]='pending'..i..'='..id end local ok,res=pcall(love.filesystem.write,'progress.dat',table.concat(lines,'\n')) return ok and res~=false end
function Progress.load() if love.filesystem and love.filesystem.read then local raw=love.filesystem.read('progress.dat') if raw then local pendingCount=0 for k,v in raw:gmatch('([%w_]+)=([%w_]+)') do if k=='coins' then Progress.coins=integer(v,0,999999) elseif k=='unlocked' then Progress.unlocked=integer(v,1,6) elseif k=='equippedSkin' and Progress.skins[v] then Progress.equippedSkin=v elseif k=='tutorial' then Progress.tutorialDone=v=='true' elseif k=='secondarySlots' then Progress.secondarySlots=integer(v,1,3) elseif k=='pendingCount' then pendingCount=integer(v,0,8) elseif k:match('^pending%d+$') then local n=tonumber(k:match('%d+')); if n and Progress.cardDefs[v] then Progress.pending[n]=v end elseif k:match('^clear_') then local n=tonumber(k:sub(7)); if n then Progress.cleared[n]=v=='true' end elseif k:match('^card_') and Progress.cardDefs[k:sub(6)] then Progress.cards[k:sub(6)]=integer(v,0,9999) elseif k:match('^skill_') and Progress.secondaryDefs[k:sub(7)] then Progress.secondaryOwned[k:sub(7)]=v=='true' elseif k:match('^slot_') then local i=tonumber(k:sub(6)); if i and Progress.secondaryDefs[v] then Progress.secondaryEquipped[i]=v end end end for i=#Progress.pending,1,-1 do if i>pendingCount then Progress.pending[i]=nil end end end end Progress.evaluateUnlocks() end
function Progress.reward(amount) Progress.coins=integer(Progress.coins+math.max(0,amount or 0),0,999999) Progress.save() end
function Progress.clear(index) Progress.cleared[index]=true Progress.unlocked=math.max(Progress.unlocked,math.min(6,index+1)) Progress.coins=integer(Progress.coins+(mapRewards[index] or 8),0,999999) Progress.save() end
function Progress.buyPack(id) local pack=Progress.packDefs[id] if not pack then return false,'SOBRE DESCONOCIDO' end if #Progress.pending>0 then return false,'REVELA PRIMERO EL SOBRE ABIERTO' end if Progress.coins<pack.cost then return false,'MONEDAS INSUFICIENTES' end local result,missing={},{} for _,cid in ipairs(Progress.cardOrder) do if Progress.getCardCount(cid)==0 then missing[#missing+1]=cid end end for i=1,math.min(pack.guaranteed,#missing) do local j=love.math.random(1,#missing) result[#result+1]=missing[j] table.remove(missing,j) end while #result<pack.count do result[#result+1]=Progress.cardOrder[love.math.random(1,#Progress.cardOrder)] end for i=#result,2,-1 do local j=love.math.random(1,i) result[i],result[j]=result[j],result[i] end Progress.coins=Progress.coins-pack.cost for _,cid in ipairs(result) do Progress.cards[cid]=Progress.getCardCount(cid)+1 end Progress.pending=shallowCopy(result) Progress.evaluateUnlocks(); Progress.save(); return true,pack.name..' ABIERTO',shallowCopy(result) end
function Progress.claimPending() if #Progress.pending==0 then return false end Progress.pending={} Progress.save() return true end
function Progress.equipSkin(id) if not Progress.skinsOwned[id] then return false,'NO DESBLOQUEADA' end Progress.equippedSkin=id Progress.save() return true,'SKIN EQUIPADA' end
function Progress.buySecondary(id) local def=Progress.secondaryDefs[id] if not def then return false,'HABILIDAD DESCONOCIDA' end if Progress.secondaryOwned[id] then return false,'YA COMPRADA' end if Progress.coins<def.cost then return false,'MONEDAS INSUFICIENTES' end Progress.coins=Progress.coins-def.cost Progress.secondaryOwned[id]=true Progress.save() return true,'HABILIDAD COMPRADA' end
function Progress.buySlot() if Progress.secondarySlots>=3 then return false,'RANURAS AL MAXIMO' end local cost=Progress.secondarySlots==1 and 28 or 46 if Progress.coins<cost then return false,'MONEDAS INSUFICIENTES' end Progress.coins=Progress.coins-cost Progress.secondarySlots=Progress.secondarySlots+1 Progress.save() return true,'RANURA DESBLOQUEADA' end
function Progress.equipSecondary(slot,id) if slot<1 or slot>Progress.secondarySlots then return false,'RANURA BLOQUEADA' end if id and not Progress.secondaryOwned[id] then return false,'HABILIDAD NO COMPRADA' end for i=1,3 do if i~=slot and Progress.secondaryEquipped[i]==id then Progress.secondaryEquipped[i]=false end end Progress.secondaryEquipped[slot]=id or false Progress.save() return true,id and 'HABILIDAD EQUIPADA' or 'RANURA LIMPIA' end
function Progress.getSecondarySlotCost() return Progress.secondarySlots==1 and 28 or (Progress.secondarySlots==2 and 46 or nil) end
function Progress.buy(id,player) return false,'USA EL LABORATORIO' end
return Progress