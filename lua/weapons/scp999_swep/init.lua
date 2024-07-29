AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

if SERVER then
    AddCSLuaFile()
end

SWEP.LastHealTime = 0
SWEP.LastSecondaryHealTime = 0
SWEP.LastSoundTime = 0
SWEP.HealthStages = {60, 80, 100}

local scpsounds = {
    "swep/scp999x1.wav",
    "swep/scp999x2.wav",
    "swep/scp999x3.wav",
    "swep/scp999x4.wav",
    "swep/scp999x5.wav",
    "swep/scp999x6.wav"
}


local function HealEntityOverTime(ply, target, healAmount, targetHealthStage)
    local healPerTick = 1 
    local healInterval = 0.1 
    local healTicks = healAmount 

    timer.Create("HealingTimer_" .. target:EntIndex(), healInterval, healTicks, function()
        if not IsValid(target) or not IsValid(ply) then
            timer.Remove("HealingTimer_" .. target:EntIndex())
            return
        end

        if target:Health() < targetHealthStage then
            local newHealth = math.min(target:Health() + healPerTick, targetHealthStage)
            target:SetHealth(newHealth)
        else
            timer.Remove("HealingTimer_" .. target:EntIndex())
        end
    end)
end

function SWEP:PrimaryAttack()
    local ply = self:GetOwner()
    local curTime = CurTime()

    if curTime - self.LastSoundTime < 1.5 then
        return
    end

    local randomSound = scpsounds[math.random(#scpsounds)]

    if SERVER then
        local pos = ply:GetPos()
        sound.Play(randomSound, pos)
    end

    self.LastSoundTime = curTime
end

function SWEP:SecondaryAttack()
    local curTime = CurTime()

    if curTime - self.LastSecondaryHealTime < 30 then
        return
    end

    self:SetNextSecondaryFire(curTime + 1)

    if SERVER then
        local ply = self:GetOwner()
        local pos = ply:GetPos()
        local trace = ply:GetEyeTrace()
        local target = trace.Entity
        local healSound = "swep/scp999xheal.wav"

        if IsValid(target) and (target:IsPlayer() or target:IsNPC()) then
            local currentHealth = target:Health()
            local targetHealthStages = {5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60}
            local nextStageHealth = nil

            for _, healthStage in ipairs(targetHealthStages) do
                if currentHealth < healthStage then
                    nextStageHealth = healthStage
                    break
                end
            end

            if nextStageHealth then
                
                sound.Play(healSound, pos)

                
                HealEntityOverTime(ply, target, nextStageHealth - currentHealth, nextStageHealth)

                
                self.LastSecondaryHealTime = curTime
            end
        end
    end
end

function SWEP:Reload()
end

function SWEP:Initialize()
    self:SetHoldType("normal")
end

function SWEP:Deploy()
    return true
end

function SWEP:Holster()
    return true
end
