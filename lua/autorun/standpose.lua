
local propt = {}

propt.MenuLabel = "Stand Pose"
propt.Order = 5000

propt.Filter = function( self, ent )
	if ( !IsValid( ent ) ) then return false end
	if ( ent:GetClass() != "prop_ragdoll" ) then return false end
	return true 
end

propt.Action = function( self, ent )
	self:MsgStart()
	net.WriteEntity( ent )
	self:MsgEnd()
end

propt.Receive = function( self, length, player )

	local rag = net.ReadEntity()
	
	if ( !IsValid( rag ) ) then return end
	if ( !IsValid( player ) ) then return end
	if ( rag:GetClass() != "prop_ragdoll" ) then return end
	
	local tr = util.TraceLine({start = rag:GetPos(),endpos = rag:GetPos() - Vector(0,0,3000),filter = rag})
	
	local ent = ents.Create("prop_dynamic")
	ent:SetModel(rag:GetModel())
	ent:SetPos(tr.HitPos)
	local angle = (tr.HitPos - player:GetPos()):Angle()
	ent:SetAngles(Angle(0,angle.y-180,0))
	ent:Spawn()
	for i=0,rag:GetPhysicsObjectCount()-1 do
		local phys = rag:GetPhysicsObjectNum(i)
		local b = rag:TranslatePhysBoneToBone(i)
		local pos,ang = ent:GetBonePosition(b)
		phys:EnableMotion(true)
		phys:Wake()
		phys:SetPos(pos)
		phys:SetAngles(ang)
		if string.sub(rag:GetBoneName(b),1,4) == "prp_" then
			phys:EnableMotion(true)
			phys:Wake()
		else
			phys:EnableMotion(false)
			phys:Wake()
		end
	end
	ent:Remove()
	
end	

properties.Add("standpose",propt)