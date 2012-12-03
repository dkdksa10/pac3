local PART = {}

PART.ClassName = "particles"

pac.StartStorableVars()
	pac.GetSet(PART, "Color1", Vector(255, 255, 255))
	pac.GetSet(PART, "Color2", Vector(255, 255, 255))
	pac.GetSet(PART, "Material", "effects/slime1")
	pac.GetSet(PART, "RandomColour", true) -- haaaa
	pac.GetSet(PART, "FireDelay", 0.2)
	pac.GetSet(PART, "NumberParticles", 1)
	pac.GetSet(PART, "Velocity", Vector(0, 250, 0))
	pac.GetSet(PART, "Spread", 0.1)
	pac.GetSet(PART, "DieTime", 3)
	pac.GetSet(PART, "StartAlpha", 255)
	pac.GetSet(PART, "EndAlpha", 0)
	pac.GetSet(PART, "StartSize", 10)
	pac.GetSet(PART, "EndSize", 20)
	pac.GetSet(PART, "StartLength", 0)
	pac.GetSet(PART, "EndLength", 0)
	pac.GetSet(PART, "RandomRollSpeed", 0)
	pac.GetSet(PART, "RollDelta", 0)
	pac.GetSet(PART, "AirResistance", 5)
	pac.GetSet(PART, "Bounce", 5)
	pac.GetSet(PART, "Gravity", Vector(0,0, -50))
	pac.GetSet(PART, "Collide", true)
	pac.GetSet(PART, "Lighting", true)
	pac.GetSet(PART, "Sliding", true)
	pac.GetSet(PART, "3D", true)
	pac.GetSet(PART, "AlignToSurface", true)
	pac.GetSet(PART, "StickToSurface", true)
	pac.GetSet(PART, "DoubleSided", true)
	pac.GetSet(PART, "ParticleAngleVelocity", Vector(50, 50, 50))
	pac.GetSet(PART, "StickLifetime", 2)
	pac.GetSet(PART, "StickStartSize", 20)
	pac.GetSet(PART, "StickStartSize", 0)
	pac.GetSet(PART, "StickStartAlpha", 255)
	pac.GetSet(PART, "StickStartAlpha", 0)
pac.EndStorableVars()

local function RemoveCallback(particle)
	particle:SetLifeTime(0)
	particle:SetDieTime(0)

	particle:SetStartSize(0)
	particle:SetEndSize(0)

	particle:SetStartAlpha(0)
	particle:SetEndAlpha(0)
end

local function SlideCallback(particle, hitpos, normal)
	particle:SetBounce(1)
	local vel = particle:GetVelocity()
	vel.z = 0
	particle:SetVelocity(vel)
	particle:SetPos(hitpos + normal)
end

local function StickCallback(particle, hitpos, normal)
	particle:SetAngleVelocity(Angle(0, 0, 0))

	if particle.Align then
		local ang = normal:Angle()
		ang:RotateAroundAxis(normal, particle:GetAngles().y)
		particle:SetAngles(ang)
	end

	if particle.Stick then
		particle:SetVelocity(Vector(0, 0, 0))
		particle:SetGravity(Vector(0, 0, 0))
	end

	particle:SetLifeTime(0)
	particle:SetDieTime(particle.StickLifeTime)

	particle:SetStartSize(particle.StickStartSize)
	particle:SetEndSize(particle.StickEndSize)

	particle:SetStartAlpha(particle.StickStartAlpha)
	particle:SetEndAlpha(particle.StickEndAlpha)
end

function PART:Initialize()
	self.NextShot = RealTime()
	self.Created = RealTime() + 0.1
	self.emitter = ParticleEmitter(self.cached_pos, false)
end

function PART:Set3D(b)
	self["3D"] = b 
	self.emitter = ParticleEmitter(self.cached_pos, b)
end

function PART:OnDraw(owner, pos, ang)
	if not self:IsHiddenEx() then
		self:EmitParticles(pos, ang)
	end
end

function PART:EmitParticles(pos, ang)
	local emt = self.emitter
	if not emt then return end
	
	if self.NextShot < RealTime() then
		local spread = self.Spread / 180
		
		if self.Material == "" then return end
		if self.Velocity == 500.01 then return end
		
		ang = ang:Forward()

		local double = 1
		if self.DoubleSided then
			double = 2
		end

		for i = 1, self.NumberParticles do

			local vec = Vector()
			
			if self.Spread ~= 0 then
				vec = Vector(
					math.sin(math.Rand(0, 360)) * math.Rand(-self.Spread, self.Spread), 
					math.cos(math.Rand(0, 360)) * math.Rand(-self.Spread, self.Spread), 
					math.sin(math.random()) * math.Rand(-self.Spread, self.Spread)
				)
			end
			
			local color
			
			if self.RandomColor then
				color = 
				{
					math.random(math.min(self.Color1.r, self.Color2.r), math.max(self.Color1.r, self.Color2.r)), 
					math.random(math.min(self.Color1.g, self.Color2.g), math.max(self.Color1.g, self.Color2.g)), 
					math.random(math.min(self.Color1.b, self.Color2.b), math.max(self.Color1.b, self.Color2.b))
				}
			else
				color = {self.Color1.r, self.Color1.g, self.Color1.b}
			end

			local roll = math.Rand(-self.RollDelta, self.RollDelta)

			for i = 1, double do
				local particle = emt:Add(self.Material, pos)

				if self.DoubleSided then
					local ang_
					if i == 1 then
						ang_ = (ang * -1):Angle()
					elseif i == 2 then
						ang_ = ang:Angle()
					end
					
					particle:SetAngles(ang_)
				else
					particle:SetAngles(ang:Angle())
				end

				particle:SetVelocity((vec + ang) * self.Velocity)
				particle:SetColor(unpack(color))
				particle:SetColor(unpack(color))
				particle:SetDieTime(self.DieTime)
				particle:SetStartAlpha(self.StartAlpha)
				particle:SetEndAlpha(self.EndAlpha)
				particle:SetStartSize(self.StartSize)
				particle:SetEndSize(self.EndSize)
				particle:SetStartLength(self.StartLength)
				particle:SetEndLength(self.EndLength)
				particle:SetRoll(self.RandomRollSpeed * 36)
				particle:SetRollDelta(self.RollDelta + roll)
				particle:SetAirResistance(self.AirResistance)
				particle:SetBounce(self.Bounce)
				particle:SetGravity(self.Gravity)
				particle:SetCollide(self.Collide)
				particle:SetLighting(self.Lighting)

				if self.Sliding then
					particle:SetCollideCallback(SlideCallback)
				end

				if self["3D"] then
					if not self.Sliding then
						if i == 1 then
							particle:SetCollideCallback(RemoveCallback)
						else
							particle:SetCollideCallback(StickCallback)
						end
					end

					particle:SetAngleVelocity(Angle(self.AngleVelocity.x, self.AngleVelocity.y, self.AngleVelocity.z))

					particle.Align = self.Align
					particle.Stick = self.Stick
					particle.StickLifeTime = self.StickLifeTime
					particle.StickStartSize = self.StickStartSize
					particle.StickEndSize = self.StickEndSize
					particle.StickStartAlpha = self.StickStartAlpha
					particle.StickEndAlpha = self.StickEndAlpha
				end
			end
		end

		self.NextShot = RealTime() + self.FireDelay
	end
end

pac.RegisterPart(PART)