/*--------------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
--------------------------------------------------*/
AddCSLuaFile()
if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end

ENT.Type 			= "anim"
ENT.Base 			= "obj_vj_projectile_base"
ENT.PrintName		= "Probe Droid Needle"
ENT.Author 			= "DrVrej"
ENT.Contact 		= "http://steamcommunity.com/groups/vrejgaming"
ENT.Information		= "Projectiles for my addons"
ENT.Category		= "Projectiles"

if (CLIENT) then
	local Name = "Probe Droid Needle"
	local LangName = "obj_vj_hlr1_probed_needle"
	language.Add(LangName, Name)
	killicon.Add(LangName,"HUD/killicons/default",Color(255,80,0,255))
	language.Add("#"..LangName, Name)
	killicon.Add("#"..LangName,"HUD/killicons/default",Color(255,80,0,255))
end
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
if !SERVER then return end

ENT.Model = {"models/vj_hlr/hla/pb_dart.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.DoesDirectDamage = true -- Should it do a direct damage when it hits something?
ENT.DirectDamage = 15 -- How much damage should it do when it hits something
ENT.DirectDamageType = DMG_POISON -- Damage type
ENT.DecalTbl_DeathDecals = {"Impact.Concrete"}
ENT.SoundTbl_OnCollide = {"vj_hlr/hl1_weapon/crossbow/xbow_hit1.wav"}

local defAng = Angle(0 ,0, 0)

-- Custom
ENT.Needle_Heal = false -- Is this a healing needle?
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomPhysicsObjectOnInitialize(phys)
	phys:SetMass(1)
	phys:EnableGravity(false)
	phys:EnableDrag(false)
	phys:SetBuoyancyRatio(0)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	if self.Needle_Heal == true then
		self.DoesDirectDamage = false
	else
		ParticleEffect("vj_hl_spit_drone_spawn", self:GetPos(), defAng, nil)
		ParticleEffectAttach("vj_hl_spit_drone", PATTACH_ABSORIGIN_FOLLOW, self, 0)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPhysicsCollide(data,phys)
	if IsValid(data.HitEntity) then
		self.SoundTbl_OnCollide = {"vj_hlr/hl1_weapon/crossbow/xbow_hitbod1.wav","vj_hlr/hl1_weapon/crossbow/xbow_hitbod2.wav"}
	else
		local spike = ents.Create("prop_dynamic")
		spike:SetModel("models/vj_hlr/hla/pb_dart.mdl")
		spike:SetPos(data.HitPos + data.HitNormal + self:GetForward()*-5)
		spike:SetAngles(self:GetAngles())
		spike:Activate()
		spike:Spawn()
		timer.Simple(6, function() if IsValid(spike) then spike:Remove() end end)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnPhysicsCollide(data,phys)
	-- Only for healing
	if self.Needle_Heal == false or !IsValid(self:GetOwner()) then return end
	local hitEnt = data.HitEntity
	if self:GetOwner():Disposition(hitEnt) then
		self.SoundTbl_OnCollide = {"items/smallmedkit1.wav"}
		hitEnt:RemoveAllDecals()
		local fricurhp = hitEnt:Health()
		hitEnt:SetHealth(math.Clamp(fricurhp + 40, fricurhp, hitEnt:GetMaxHealth()))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnDoDamage(data,phys,hitEnt)
	-- Only for attacks
	if self.Needle_Heal == true then return end
	VJ_ApplySpeedEffect(hitEnt, 0.2, 5)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data,phys)
	if self.Needle_Heal == true then return end
	ParticleEffect("vj_hl_spit_drone_impact", self:GetPos(), defAng, nil)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2021 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/