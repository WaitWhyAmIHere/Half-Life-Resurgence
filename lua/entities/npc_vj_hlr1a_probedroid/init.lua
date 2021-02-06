AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_hlr/hla/prdroid.mdl"} -- The game will pick a random model from the table when the SNPC is spawned | Add as many as you want
ENT.StartHealth = 100
ENT.HullType = HULL_HUMAN
ENT.MovementType = VJ_MOVETYPE_AERIAL -- How does the SNPC move?
ENT.Aerial_FlyingSpeed_Calm = 100 -- The speed it should fly with, when it's wandering, moving slowly, etc. | Basically walking compared to ground SNPCs
ENT.Aerial_FlyingSpeed_Alerted = 200 -- The speed it should fly with, when it's chasing an enemy, moving away quickly, etc. | Basically running compared to ground SNPCs
ENT.Aerial_AnimTbl_Calm = {ACT_IDLE} -- Animations it plays when it's wandering around while idle
ENT.Aerial_AnimTbl_Alerted = {ACT_IDLE} -- Animations it plays when it's moving while alerted
ENT.VJC_Data = {
	FirstP_Bone = "sphere01", -- If left empty, the base will attempt to calculate a position for first person
	FirstP_Offset = Vector(15, 0, -3), -- The offset for the controller when the camera is in first person
	FirstP_ShrinkBone = false, -- Should the bone shrink? Useful if the bone is obscuring the player's view
}
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_PLAYER_ALLY"} -- NPCs with the same class with be allied to each other
ENT.FriendsWithAllPlayerAllies = true -- Should this SNPC be friends with all other player allies that are running on VJ Base?
ENT.ConstantlyFaceEnemy = true -- Should it face the enemy constantly?

ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.MeleeAttackDamage = 20
ENT.MeleeAttackDistance = 45 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 80 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = false -- This counted in seconds | This calculates the time until it hits something

ENT.HasRangeAttack = true -- Should the SNPC have a range attack?
ENT.RangeAttackEntityToSpawn = "obj_vj_hlr1_probed_needle" -- The entity that is spawned when range attacking
ENT.RangeDistance = 1500 -- This is how far away it can shoot
ENT.RangeToMeleeDistance = 60 -- How close does it have to be until it uses melee?
ENT.TimeUntilRangeAttackProjectileRelease = false -- How much time until the projectile code is ran?
ENT.NextRangeAttackTime = 3 -- How much time until it can use a range attack?
ENT.NextRangeAttackTime_DoRand = 4 -- False = Don't use random time | Number = Picks a random number between the regular timer and this timer
ENT.RangeUseAttachmentForPos = true -- Should the projectile spawn on a attachment?
ENT.RangeUseAttachmentForPosID = "0" -- The attachment used on the range attack if RangeUseAttachmentForPos is set to true
ENT.DisableRangeAttackAnimation = true -- if true, it will disable the animation code

ENT.NoChaseAfterCertainRange = true -- Should the SNPC not be able to chase when it's between number x and y?
ENT.NoChaseAfterCertainRange_FarDistance = "UseRangeDistance" -- How far until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_CloseDistance = "UseRangeDistance" -- How near until it can chase again? | "UseRangeDistance" = Use the number provided by the range attack instead
ENT.NoChaseAfterCertainRange_Type = "OnlyRange" -- "Regular" = Default behavior | "OnlyRange" = Only does it if it's able to range attack

ENT.HasDeathAnimation = true -- Does it play an animation when it dies?
ENT.AnimTbl_Death = {ACT_DIESIMPLE} -- Death Animations
ENT.DeathAnimationTime = 0.6 -- Time until the SNPC spawns its corpse and gets removed
ENT.HasDeathRagdoll = false -- If set to false, it will not spawn the regular ragdoll of the SNPC
ENT.HasExtraMeleeAttackSounds = true -- Set to true to use the extra melee attack sounds
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_Breath = {"vj_hlr/hla_npc/prdroid/engine.wav"}
ENT.SoundTbl_Alert = {"vj_hlr/hla_npc/prdroid/alert.wav"}
ENT.SoundTbl_BeforeMeleeAttack = {"vj_hlr/hl1_npc/friendly/fr_attack.wav"}
ENT.SoundTbl_MeleeAttackMiss = {"vj_hlr/hl1_npc/zombie/claw_miss1.wav","vj_hlr/hl1_npc/zombie/claw_miss2.wav"}
ENT.SoundTbl_BeforeRangeAttack = {"vj_hlr/hla_npc/prdroid/readytoattack.wav"}
ENT.SoundTbl_RangeAttack = {"vj_hlr/hla_npc/prdroid/shoot.wav"}
ENT.SoundTbl_Death = {"vj_hlr/hla_npc/prdroid/die.wav"}

ENT.GeneralSoundPitch1 = 100

/*
vj_hlr/hla_npc/prdroid/shoot_heal.wav
*/
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetCollisionBounds(Vector(35, 35, 15), Vector(-35, -35, -50))
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnAcceptInput(key, activator, caller, data)
	//print(key)
	if key == "melee" then
		self:MeleeAttackCode()
	elseif key == "shoot" then
		self:RangeAttackCode()
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
local anim1 = ACT_ARM
local anim2 = ACT_RANGE_ATTACK1
--
function ENT:CustomOnRangeAttack_BeforeStartTimer()
	self.CurrentAttackAnimation = anim1
	self:VJ_ACT_PLAYACTIVITY(self.CurrentAttackAnimation, false, 0, true)
	local firstAct = self:DecideAnimationLength(self.CurrentAttackAnimation, false)
	self.CurrentAttackAnimationDuration = firstAct + VJ_GetSequenceDuration(self, anim2)
	self.PlayingAttackAnimation = true
	timer.Create("timer_act_playingattack"..self:EntIndex(), self.CurrentAttackAnimationDuration, 1, function() self.PlayingAttackAnimation = false self:VJ_ACT_PLAYACTIVITY(ACT_RELOAD, true, false, true) end)
	timer.Simple(firstAct, function()
		if IsValid(self) then
			self:VJ_ACT_PLAYACTIVITY(anim2, false, 0, true)
		end
	end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:RangeAttackCode_GetShootPos(projectile)
	return self:CalculateProjectile("Line", self:GetAttachment(self:LookupAttachment("0")).Pos, self:GetEnemy():GetPos() + self:GetEnemy():OBBCenter(), 1500)
end
---------------------------------------------------------------------------------------------------------------------------------------------
local collideSds = {"vj_hlr/fx/metal1.wav","vj_hlr/fx/metal2.wav","vj_hlr/fx/metal3.wav","vj_hlr/fx/metal4.wav","vj_hlr/fx/metal5.wav"}
--
function ENT:CustomOnKilled(dmginfo, hitgroup)
	util.VJ_SphereDamage(self, self, self:GetPos(), 75, 25, DMG_BLAST, false, true)
	VJ_EmitSound(self, "vj_hlr/hla_npc/prdroid/explode.wav", 90, 100)
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_cap.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("sphere01")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_armpiece.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed011")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_armpiece.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed007")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_claw.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed012")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_claw.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed008")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_dshooter.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed005")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_tail.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed014")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_upperarm.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed011")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_upperarm.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed007")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_body.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed003")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_forearm.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed011")),CollideSound=collideSds,Vel_ApplyDmgForce=false})
	self:CreateGibEntity("obj_vj_gib","models/vj_hlr/gibs/pb_forearm.mdl",{BloodDecal="",Ang=self:GetAngles(),Pos=self:GetBonePosition(self:LookupBone("unnamed007")),CollideSound=collideSds,Vel_ApplyDmgForce=false})

	local spr = ents.Create("env_sprite")
	spr:SetKeyValue("model","vj_hl/sprites/zerogxplode.vmt")
	spr:SetKeyValue("GlowProxySize","2.0")
	spr:SetKeyValue("HDRColorScale","1.0")
	spr:SetKeyValue("renderfx","14")
	spr:SetKeyValue("rendermode","5")
	spr:SetKeyValue("renderamt","255")
	spr:SetKeyValue("disablereceiveshadows","0")
	spr:SetKeyValue("mindxlevel","0")
	spr:SetKeyValue("maxdxlevel","0")
	spr:SetKeyValue("framerate","15.0")
	spr:SetKeyValue("spawnflags","0")
	spr:SetKeyValue("scale","2")
	spr:SetPos(self:GetPos())
	spr:Spawn()
	spr:Fire("Kill","",0.9)
	timer.Simple(0.9,function() if IsValid(spr) then spr:Remove() end end)
end

/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/