AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_hlr/hl1/flower.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.SightDistance = 512 -- How far it can see
ENT.SightAngle = 180 -- The sight angle | Example: 180 would make the it see all around it | Measured in degrees and then converted to radians
ENT.StartHealth = 160
ENT.MovementType = VJ_MOVETYPE_STATIONARY -- How does the SNPC move?
ENT.CanTurnWhileStationary = false -- If set to true, the SNPC will be able to turn while it's a stationary SNPC
ENT.HullType = HULL_SMALL_CENTERED
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_XEN"} -- NPCs with the same class with be allied to each other
ENT.HasMeleeAttack = false -- Should the SNPC have a melee attack?

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.DisableDefaultRangeAttackCode = true -- When true, it won't spawn the range attack entity, allowing you to make your own
ENT.DisableRangeAttackAnimation = true -- if true, it will disable the animation code
ENT.RangeDistance = 512 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 1 -- How close does it have to be until it uses melee?
ENT.RangeAttackAngleRadius = 180 -- What is the attack angle radius? | 100 = In front of the SNPC | 180 = All around the SNPC
ENT.TimeUntilRangeAttackProjectileRelease = 0 -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 1.5 -- How much time until it can use a range attack?

ENT.DeathCorpseEntityClass = "prop_vj_animatable" -- The entity class it creates | "UseDefaultBehavior" = Let the base automatically detect the type
ENT.DeathCorpseBodyGroup = VJ_Set(0,1) -- #1 = the category of the first bodygroup | #2 = the value of the second bodygroup | Set -1 for #1 to let the base decide the corpse's bodygroup
ENT.GibOnDeathDamagesTable = {"All"} -- Damages that it gibs from | "UseDefault" = Uses default damage types | "All" = Gib from any damage
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Idle = {}
ENT.SoundTbl_Death = {"vj_hlr/hl1_npc/xenceiling_turret/bustflesh1.wav","vj_hlr/hl1_npc/xenceiling_turret/bustflesh2.wav"}

ENT.GeneralSoundPitch1 = 100
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(25,25,0), Vector(-25,-25,-162))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomRangeAttackCode()
	local startpos = self:GetAttachment(1).Pos
	local tr = util.TraceLine({
		start = startpos,
		endpos = self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(),
		filter = self
	})
	local hitpos = tr.HitPos
	local elec = EffectData()
	elec:SetStart(startpos)
	elec:SetOrigin(hitpos)
	elec:SetEntity(self)
	elec:SetAttachment(1)
	elec:SetScale(0.5)
	util.Effect("VJ_HLR_Electric_Xen_Turretc", elec)
	
	util.VJ_SphereDamage(self, self, hitpos, 10, 30, DMG_SHOCK, true, false, {Force=90})
	VJ_EmitSound(self, "vj_hlr/hl1_npc/xenceiling_turret/beamstart10.wav", 90, 100)
	//sound.Play("vj_hlr/hl1_npc/pitworm/pit_worm_attack_eyeblast_impact.wav", hitpos, 60)
	
	local StartGlow1 = ents.Create("env_sprite")
	StartGlow1:SetKeyValue("model","vj_hl/sprites/xflare1.vmt")
	//StartGlow1:SetKeyValue("rendercolor","0 0 255")
	StartGlow1:SetKeyValue("GlowProxySize","5.0")
	StartGlow1:SetKeyValue("HDRColorScale","1.0")
	StartGlow1:SetKeyValue("renderfx","14")
	StartGlow1:SetKeyValue("rendermode","3")
	StartGlow1:SetKeyValue("renderamt","255")
	StartGlow1:SetKeyValue("disablereceiveshadows","0")
	StartGlow1:SetKeyValue("mindxlevel","0")
	StartGlow1:SetKeyValue("maxdxlevel","0")
	StartGlow1:SetKeyValue("framerate","60.0")
	StartGlow1:SetKeyValue("spawnflags","0")
	StartGlow1:SetKeyValue("scale","1")
	StartGlow1:SetPos(self:GetPos())
	StartGlow1:Spawn()
	StartGlow1:SetParent(self)
	StartGlow1:Fire("SetParentAttachment", "0")
	self:DeleteOnRemove(StartGlow1)
	timer.Simple(0.2, function() SafeRemoveEntity(StartGlow1) end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_BeforeDamage(dmginfo,hitgroup)
	if hitgroup != 2 && dmginfo:GetDamageType() != DMG_BLAST then -- Take damage only if the bottom part is hit or it's a blast damage!
		dmginfo:SetDamage(0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:SetUpGibesOnDeath(dmginfo,hitgroup)
	if self.HasGibDeathParticles == true then
	end
	
	local pos = self:GetAttachment(1).Pos + Vector(0,0,12)
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh1.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(1,0,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh2.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(2,0,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh3.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(3,0,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh4.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(4,0,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh1.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(5,0,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh2.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(6,0,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh3.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(0,1,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh4.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(0,2,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh1.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(0,3,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh2.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(0,4,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh3.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(0,5,0)})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/flesh4.mdl",{BloodDecal="VJ_HLR_Blood_Red",Pos=pos + Vector(0,6,0)})
	return true, {AllowCorpse=true} -- Return to true if it gibbed!
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomGibOnDeathSounds(dmginfo,hitgroup)
	VJ_EmitSound(self,"vj_gib/default_gib_splat.wav",90,math.random(100,100))
	return false
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2019 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/