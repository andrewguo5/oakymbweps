
AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "ttt_basegrenade_proj"
ENT.Model = Model("models/weapons/w_eq_smokegrenade_thrown.mdl")

ENT.IsHitExploder = true

AccessorFunc( ENT, "radius", "Radius", FORCE_NUMBER )

function ENT:Initialize()
   if not self:GetRadius() then self:SetRadius(20) end

   return self.BaseClass.Initialize(self)
end

if CLIENT then

   local smokeparticles = {
	  --Model("particle/mat1"),
      Model("particle/particle_smokegrenade"),
      --Model("particle/particle_noisesphere")
   };

   function ENT:CreateSmoke(center)
      local em = ParticleEmitter(center)

      local r = self:GetRadius()
      for i=1, 100 do
         local prpos = VectorRand() * r
         prpos.z = prpos.z + 32
         local p = em:Add(table.Random(smokeparticles), center + prpos)
         if p then
            local gray = math.random(100, 110)
            p:SetColor(math.random(140, 145), math.random(140, 140), math.random(110, 120))
			--p:SetColor(render.ComputeLighting(p:GetPos(), Vector(0,0,1)))
            p:SetStartAlpha(250)
            p:SetEndAlpha(240)
            p:SetVelocity(VectorRand() * math.Rand(1600, 2400))
            p:SetLifeTime(0)
            
            p:SetDieTime(math.Rand(55, 65))

            p:SetStartSize(math.random(80, 90))
            p:SetEndSize(math.random(10, 80))
            p:SetRoll(math.random(-180, 180))
            p:SetRollDelta(math.Rand(-0.1, 0.1))
            p:SetAirResistance(800)

            p:SetCollide(true)
            p:SetBounce(0.4)

            --p:SetLighting(true)
         end
      end

      em:Finish()
   end
end

function ENT:Explode(tr)
   if SERVER then
      self:SetNoDraw(true)
      self:SetSolid(SOLID_NONE)

      -- pull out of the surface
      if tr.Fraction != 1.0 then
         self:SetPos(tr.HitPos + tr.HitNormal * 0.6)
      end

      local pos = self:GetPos()

      self:Remove()
   else
      local spos = self:GetPos()
      local trs = util.TraceLine({start=spos + Vector(0,0,64), endpos=spos + Vector(0,0,-128), filter=self})
      util.Decal("SmallScorch", trs.HitPos + trs.HitNormal, trs.HitPos - trs.HitNormal)      

      self:SetDetonateExact(0)

      if tr.Fraction != 1.0 then
         spos = tr.HitPos + tr.HitNormal * 0.6
      end

      -- Smoke particles can't get cleaned up when a round restarts, so prevent
      -- them from existing post-round.
      if GetRoundState() == ROUND_POST then return end

      self:CreateSmoke(spos)
   end
end
