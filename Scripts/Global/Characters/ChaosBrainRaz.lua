
--[[WARNING: This Script is currently unused and not fully functional.
The main issue with Brain Mode is that the brain does not move on Raz Respawn or teleport.
If this can be fixed, the chaos effect can be re-introduced
]]

function ChaosBrainRaz(Ob)

	if not Ob then
		Ob = CreateObject('Global.Characters.ActionActor')
		--Ob.meshName = 'GlobalModels/Objects/HeldObjects/brainPup.plb' 
		Ob.meshName = 'GlobalModels/GO_GlobalObjects/RazBrain.plb' 
		Ob.animsDir = 'Objects/brainPup'
		Ob.charName = 'RazsBrain'
		Ob.TK_YOffset = 10
		Ob.animsTable = { 	Idle = { fileName='brainPup_writhe', preload = 1, blendTime = 0.2, loop = 1 },													
		}		
	end

	function Ob:onBeginLevel()      
		%Ob.Parent.onBeginLevel(self)
		SetEntityFlag(self,ENTITY_NO_TARGET_AURA,1)
		SetPhysicsFlag(self,PHYSICS_APPLYGRAVITY,1)
		SetPhysicsFlag(self, PHYSICS_COLLIDER, 1)
		SetPhysicsFlag(self, PHYSICS_COLLIDEE, 0)
		SetEntityCollideSphere(self,20,0,20,0)
        --edit change scale from (2.5,2.5,2.5)
		self:setScale(2.0,2.0,2.0)
--		SetSkeletonScale(self,1.2,1.2,1.2)
		self.oldCameraTargetHeight = GetCameraTargetHeight()
		self.oldChaseCameraRadius = GetChaseCameraRadius()
		self.oldChaseCameraAltitude = GetChaseCameraAltitude()
		-- hide brain
		SetEntityAlpha(self,0,0) 	
		SetPhysicsFlag(self, PHYSICS_CHECKTRIGGERS, 1)
	end

	function Ob:onEndLevel()      
		%Ob.Parent.onEndLevel(self)
		self:releaseRaz()
	end

	function Ob:onTriggerSurface(new,from,old)
		Global.player:onTriggerSurface(new,from,old)
	end

	function Ob:clearInventory()	
		Global.player.Inventory = {}
	end
				   
	function Ob:takeOverRaz()
		GamePrint('Taking over control from player ');		
		Global:saveGlobal('RazIsABrainNow', 1)
        --edit removed
		--self:clearInventory()
		self:setAnim(self.animsTable.Idle)
		self.Telekinesis = kTKBEHAVIOR_STANDARD
        
		-- brain camera
		 SetCameraPrimaryTarget( self,1);
		self.oldCameraTargetHeight = GetCameraTargetHeight()
		self.oldChaseCameraRadius = GetChaseCameraRadius()
		self.oldChaseCameraAltitude = GetChaseCameraAltitude()
		SetChaseCameraRadius(1000)
		SetChaseCameraAltitude(5)
		SetCameraTargetHeight(200)
		MoveCameraToIdeal()
		
		--Global.camControl:setSecondaryTarget(self, kSECONDARYFLAG_AUTO_ROTATE, 0)		
		
		-- mess with Raz's physics and position
		SnapEntityToGround(Global.player)
		Global.player:setNewAction('Stand')
		SetPhysicsFlag(Global.player,PHYSICS_APPLYGRAVITY,0)
		--SetPhysicsFlag(Global.player, PHYSICS_COLLIDER, 0)
		--SetPhysicsFlag(Global.player, PHYSICS_COLLIDEE, 0) 				
		Global.player:setPosition(self:getPosition())
		Global.player:setVelocity(0,0,0)
		
		-- hide raz
		SetEntityAlpha(Global.player,0,0) 	

		-- show brain
		SetEntityAlpha(self,1,0) 			

		-- Lock Raz's look target onto brain, then turn off brain's aura
    	LookAtEntity(Global.player, self)

		-- deactivate powers
		Global.player:brainModeOn()

		self:setState('TrackRaz')
	end
	
	
	function Ob:stateTrackRaz()		
		local x,y,z = self:getPosition()
        --edit adjusted y from -50 to avoid clipping
		Global.player:setPosition(x, y-90, z)
		x,y,z = Global.player:getOrientation()
        -- Lock Raz's look target onto brain
    	LookAtEntity(Global.player, self)
		-- make sure that the player is always in the stand state so that he can TK
		if (self.bTKed ~= 1) then
			Global.player:setNewAction('Stand')
		end
		if ( self.bTKed ~= 1 ) then
--			self:setOrientation(x,y+90,z)
		end
	end

				
	function Ob:releaseRaz()
		GamePrint('Sending control back to player ');
		
		self.Telekinesis = kTKBEHAVIOR_PICKUP_ONLY_NO_LIFT
		-- unbrain camera
		SetCameraPrimaryTarget(Global.player,1);
		SetCameraTargetHeight(self.oldCameraTargetHeight)
		SetChaseCameraAltitude(self.oldChaseCameraAltitude)
		SetChaseCameraRadius(self.oldChaseCameraRadius)
		MoveCameraToIdeal()
		
		-- restore Raz's physics and position
		SetPhysicsFlag(Global.player,PHYSICS_APPLYGRAVITY,1)
		SetPhysicsFlag(Global.player, PHYSICS_COLLIDER, 1)
		SetPhysicsFlag(Global.player, PHYSICS_COLLIDEE, 1)		
		x,y,z = self:getPosition()
		Global.player:setPosition(x,y+150,z)
				
		-- show raz
		SetEntityAlpha(Global.player,1,0) 	

		-- release look lock
    	LookAtEntity(Global.player, nil)

		-- reactivate powers		
		Global.player:brainModeOff()

		self:setState(nil)
	end		

	function Ob:onTKPickup(data,from)
		self.bTKed = 1
	end
	
	function Ob:onTKRelease(data,from)
		LookAtEntity(Global.player, self)
		self.bTKed = 0
	end
	
	return Ob
  
end
