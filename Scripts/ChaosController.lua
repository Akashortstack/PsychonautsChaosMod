-- gets length of a table, used in Ob:chaosTableFill()
function tableLength(tbl)
    local count = 0
    local i = 1
    while tbl[i] ~= nil do
        count = count + 1
        i = i + 1
    end
    return count
end

function ChaosController(Ob)
    if ( not Ob ) then
        Ob = CreateObject('ScriptBase')

        --[[turns debugging on and off for testing single chaos effect.
        0 = off, 1 = on
        Change Ob.debugEffect to only trigger the chosen effect]]
        Ob.debug = 0
        Ob.debugEffect = "RazColorChange"

        --Initial time for first chaos effect when loading a level, in seconds
        Ob.chaosStartTime = 5

        --Time between each following chaos effect, in seconds
        --Values lower than 5 can cause effects to not end properly
        Ob.chaosTime = 20

        --name for the internal timer
        Ob.TIMER_CHAOS = '7006'
        --Used to increment name of each spawned entity
        Ob.bearcount = 1
        Ob.cougarcount = 1
        Ob.burlycount = 1
        Ob.grabbercount = 1
        Ob.demonbunnycount = 1
        Ob.knifethrowercount = 1
        Ob.explodingcensorscount = 1
        --Ob.fatladycount = 1
        --Ob.squirrelcount = 1

        --Used for Recolor Effects
        Ob.colorTable = {
            'Red', 'Green', 'Blue', 'Orange', 'Pink',
        }

        Ob.razColorTable = {
            --Normal = {Ob.razRed = 255, Ob.razGreen = 255, Ob.razBlue = 255},
            Red = {razRed = 255, razGreen = 0, razBlue = 0},
            Green = {razRed = 0, razGreen = 255, razBlue = 0},
            Blue = {razRed = 0, razGreen = 0, razBlue = 255},
            Orange = {razRed = 255, razGreen = 120, razBlue = 0},
            Pink = {razRed = 200, razGreen = 0, razBlue = 255},
        }

        
    end

    --used to avoid max lua variable limitations
    function Ob:chaosTableFill()
        -- A table full of potential Chaos Effects, created states to match
        local chaosbaseTable = {
            --These Effects are all functional
            "Ignite",
            "Confused",
            "FacePlant",
            "BearAttack",
            "CougarAttack",
            "BurlyCensor",
            "DemonBunny",
            "ExplodingCensors",
            "KnifeThrower",
            "TKGrabber",
            "InstantDeath",
            "Stunned",
            "Earthquake",
            "Teleport",
            "Invisible",
            "Extraction",
            "BlackOut",
            "CinematicCamera",
            "TopDownCamera",
            "ForgetPowers",
            "NoMoreAmmo",
            "ArrowheadToll",
            "WaterCurse",
            "ThoughtColorChange",
            "99Lives",
            "OneLife",
            "FullHeal",
            "CriticalHealth",
            "LookforTags",
            "BigRaz",
            "SmallRaz",
            "IcePhysics",
            "FastRaz",
            "SludgePhysics",
            "NoJumping",

            --new effects for v0.2.0
            "ZoomedOut",
            "ZoomedIn",
            "UpsideDown",
            "MoreFOV",
            "VictoryDance",
            "PogoStick",
            "Pause",
            "CheckInventory",
            "Bacon",
            "Spin",
            "RazColorChange",
            
            --These Effects still need adjusting/reworked
            --[[
            "Goggalor",
            "TKMonster",
            "BrainMode",
            "Squirrels",
            "ToggleSuperJump",
            "FatLady",


            ]]

        }    
        
        --write results to new tables
        self.chaosTable = chaosbaseTable
    end

    function Ob:onBeginLevel()		
        %Ob.Parent.onBeginLevel(self)

        --force chaos time to never be less than 5 seconds
        if self.chaosTime < 5 then
            self.chaosTime = 5
        end

        --check to make sure we're not in the opening menu or creating a new profile
        local level = (Global.levelScript:getLevelName())
        if level == 'CABU' or level == 'STMU' then
            self:killSelf()
            return
        end
        self:chaosTableFill()
        --create something to show Ford's Janitor Sayline Head
        self.voicelinePlayer = SpawnScript('Global.Props.Geometry', 'FordAnnouncer', 'self.collSphereRadius = 1 self.startCollidee = 0 self.charName=\'FordNinja_sayline\'')
        self.voicelinePlayer:makeInvisible()
        --create an internal timer for the first instance of Chaos, future instances are the Ob.chaosTime value
        self:createTimer(self.chaosStartTime*1000, self.TIMER_CHAOS)
        --create visual timer for Chaos Countdown!
        self.chaosTimeDisplay = SpawnScript('ChaosVisualTimer', 'ChaosVisualTimer')
        self.chaosTimeDisplay:setState('TimingChaos')

    end

    function Ob:onTimer(data,from)
        self:killTimer(data)
		if data == self.TIMER_CHAOS then
            --not during cutscenes
            if Global.cutsceneScript.cutscenePlaying ~= 1 then
                self:setState('ChooseChaos')
			else
				--if we were prevented from changing state, set up a timer for 1 second until we do
				self:createTimer(1000, self.TIMER_CHAOS)
			end
        end
    end

    function Ob:stateChooseChaos()
        --pick a random effect from the list
        local n = tableLength(self.chaosTable)
        local i = random(1,n)
        self.randomEffect = nil
        --Debug for testing specific effects
        if self.debug == 1 then
            self.randomEffect = self.debugEffect
        else
            self.randomEffect = self.chaosTable[i]
        end

        --start a new timer, multiply by 1000 to match game time
        self:createTimer(self.chaosTime*1000, self.TIMER_CHAOS)

        PrintMessage("Random Effect: "..self.randomEffect.."!!!")

        self:sleep(0.5)

        self.chaosTimeDisplay:resetTimer()

        --set state to trigger the matching Chaos Effect
        self:setState(self.randomEffect)
        
    end

    --use this to have effects end after 15 seconds, or just before the next effect
    function Ob:longEffectSleep()
        self.longSleepTime = nil
        --makes sure effect will end before next effect if chaos timer is 15 seconds or less
        if self.chaosTime <= 15 then
            self.longSleepTime = self.chaosTime - 2
        else
            self.longSleepTime = 15
        end
        -- make sure sleep is never less than 1 second
        if self.longSleepTime <= 1 then
            self.longSleepTime = 1
        end
        self:sleep(self.longSleepTime)
    end

    --use this to have effects end after 5 seconds, or just before the next effect
    function Ob:shortEffectSleep()
        self.shortSleepTime = nil
        --makes sure effect will end before next effect if chaos timer is 15 seconds or less
        if self.chaosTime <= 15 then
            self.shortSleepTime = (self.chaosTime / 3) - 0.5
        else
            self.shortSleepTime = 5
        end

        self:sleep(self.shortSleepTime)
    end

    function Ob:stateIgnite()
        self:sendMessage(Global.player, 'FirestartPlayer', '')
        self:setState(nil)
    end

    function Ob:stateConfused()
        PlaySound(nil, 'ConfusionGrenadeExplosion')
        self:sendMessage(Global.player, 'Confusion', '',0)
        self:setState(nil)
    end

    function Ob:stateExtraction()
        --50% chance we actually teleport
        local teleportchance = random (1,2)
        --teleport successful
        if teleportchance == 1 then
            --make Ford call out a voiceline to warn us
            self.voicelinePlayer:sayLine("/GLAE002FO/",1,1, nil, 1, nil, 1)--DIALOG=<<Affirmative. Prepare for extraction.>>
            --Respawns Raz as if he's run out of lives
            if Global.levelScript.levelType == 'mental' then

                --If the player entered the mental realm by braining a characer, then we should put him back near
                --that character for the sake of clarity.  If not, he is sent back to CASA.
                local lastBrainingLevel = Global:loadGlobal('LastBrainingLevel')
                if (lastBrainingLevel) then
                    --LastBrainingLevel will get cleared out in startPlayer of the next level, because
                    --it needs it to know where to place the player.
                    Global.levelScript:loadNewLevel(Global:getPhysicalLevel(lastBrainingLevel))
                else
                    --Otherwise, the player must have entered from the CU, so send him to CASA.
                    Global.levelScript:loadNewLevel('CASA')
                end
            elseif Global.levelScript.Type == 'as.ASRU' then
                Global.player:setState('Respawn')
            else
                Global:saveGlobal('bCabinned', 1)
                if Global.levelScript:getLevelName() == 'LLLL' then
                    Global.levelScript:loadNewLevel('LLLL')
                elseif Global.levelScript:getLevelPrefix() == 'AS' then
                    Global.levelScript:loadNewLevel('ASGR')
                else
                    if (Global:load('CALevelState', 'CA') == 7) then
                        Global.levelScript:loadNewLevel('CAKC_NIGHT')
                    else
                        Global.levelScript:loadNewLevel('CAKC')
                    end
                end
            end
        --teleport fail, Raz Refused
        else
            Global.player:sayLine("/GLAA002RA/",1,1,nil,1)--DIALOG=<<No, I think I\'ll stay in this mind for a while longer.>>)
        end
        self:setState(nil)
    end

    function Ob:stateFacePlant()
        Global.player:facePlant()
        self:setState(nil)
    end

    function Ob:stateStunned()
        PlaySound(nil, 'MeleeAir_LandBoom')
        self:screenShakeAndRumble(3, 0.5)
        Global.player:playLoopingAnimOnPlayer('etherdance.jan', 2.9)
        self:setState(nil)
    end

    function Ob:stateEarthquake()
        self.rumbleTime = nil
        if self.chaosTime <= 15 then
            self.rumbleTime = self.chaosTime - 2
        else
            self.rumbleTime = 15
        end
        self:screenShakeAndRumble(0.5, self.rumbleTime)
        self:setState(nil)
    end

    --used to create a screen shake effect
    function Ob:screenShakeAndRumble(magnitude, duration)
		--if magnitude > 1 then magnitude = 1 end
		if magnitude < 0 then magnitude = 0 end
		local camMag = magnitude * 10
		duration = duration or 0.35	
		CameraStartShakePeriodic(duration, 0, 0, camMag, camMag, camMag, 50)
		RumbleLeft( duration, 0, magnitude )
		RumbleRight( duration, 0, magnitude )
	end

    function Ob:stateNoMoreAmmo()
        Global.player.stats.psiBlastAmmo = 0
        Global.player.stats.confusionAmmo = 0
        SetPsiBlastAmmo(Global.player.stats.psiBlastAmmo)
        self:setState(nil)
    end

    function Ob:stateBearAttack()
        local x, y, z = Global.player:getPosInFrontOf(700, 500)
        local bear = SpawnScript('Global.Enemies.Bear', 'CHAOSBEAR'..self.bearcount)
        self.bearcount = self.bearcount + 1
        bear:setPosition(x, y, z)
        SnapEntityToGround(bear)
        bear:scriptSpawned()
        self:setState(nil)
    end

    function Ob:stateCougarAttack()
        local x, y, z = Global.player:getPosInFrontOf(700, 500)
        local cougar = SpawnScript('Global.Enemies.Cougar', 'CHAOSCOUGAR'..self.cougarcount)
        self.cougarcount = self.cougarcount + 1
        cougar:setPosition(x, y, z)
        SnapEntityToGround(cougar)
        cougar:scriptSpawned()
        self:setState(nil)
    end

    function Ob:stateBurlyCensor()
        local x, y, z = Global.player:getPosInFrontOf(700, 500)
        local burly = SpawnScript('Global.Enemies.CensorBurly', 'CHAOSBURLY'..self.burlycount)
        self.burlycount = self.burlycount + 1
        burly:setPosition(x, y, z)
        SnapEntityToGround(burly)
        burly:scriptSpawned()
        self:setState(nil)
    end

    function Ob:stateDemonBunny()
        local x, y, z = Global.player:getPosInFrontOf(700, 500)
        local bunny = SpawnScript('MC.Characters.DemonBunny', 'CHAOSDEMONBUNNY'..self.demonbunnycount)
        self.demonbunnycount = self.demonbunnycount + 1
        bunny:setPosition(x, y, z)
        SnapEntityToGround(bunny)
        bunny:scriptSpawned()
        self:setState(nil)
    end

    function Ob:stateExplodingCensors()
        local totalexploders = 0
        while totalexploders < 3 do
            -- seperates each entity by 100 from left to right
            local x, y, z = Global.player:getPosInFrontOf(650, 500, (-100 + (totalexploders*100)))
            local exploders = SpawnScript('Global.Enemies.CensorSuicide', 'CHAOSEXPLODER'..self.explodingcensorscount)
            self.explodingcensorscount = self.explodingcensorscount + 1
            exploders:setPosition(x, y, z)
            SnapEntityToGround(exploders)
            exploders:scriptSpawned()
            totalexploders = totalexploders + 1
        end
        self:setState(nil)
    end

    function Ob:stateTKGrabber()
        local x, y, z = Global.player:getPosInFrontOf(0, 100)
        local grabber = SpawnScript('Global.Enemies.BearTKClaw', 'CHAOSGRABBER'..self.grabbercount)
        self.grabbercount = self.grabbercount + 1
		grabber:activate(Global.player, 'Grab')
        grabber:setPosition(x, y, z)
        grabber:setState('GrabbingPlayer')
        self:setState(nil)
    end

    function Ob:stateInstantDeath()
        Global.player:setState('DartDie')
        self:setState(nil)
    end

    --Places Raz at the nearest Respawn location
    function Ob:stateTeleport()
        local levelScript = fso('LevelScript')
        levelScript:startPlayer()
        self:setState(nil)
    end

    function Ob:stateBlackOut()
		Global.cutsceneScript:fadeToBlack(1)
        self:sleep(1)
        self.voicelinePlayer:sayLine("/GLAO016FO/",1,1, nil, 1, nil, 1)--DIALOG=<<I can/'t see a thing.>>
		self:sleep(1)
		Global.cutsceneScript:fadeIn(0.5)
        self:setState(nil)
    end

    function Ob:stateVictoryDance()
        Global.player:playSound('YouWin', 0, 0, 1)
        PausePlayerControls(1)
        SetVelocity(Global.player, 0,0,0)
		Global.player:doNothing()
        SnapEntityToGround(Global.player)
        Global.player:loadAnim('Anims/DartNew/VictoryDance.jan', 0.1, 0)
        self:sleep(3)
        PausePlayerControls(0)
        Global.player:goToDefaultState()
        self:setState(nil)
    end

    function Ob:stateInvisible()
        Global.player:playSound('Psi_invisable', 0, 0, 1)
        Global.player:makeInvisible()
        self:longEffectSleep()
        Global.player:playSound('Psi_invisable', 0, 0, 1)
        Global.player:makeVisible()
        self:setState(nil)
    end

    function Ob:stateKnifeThrower()
        local x, y, z = Global.player:getPosInFrontOf(700, 500)
        local thrower = SpawnScript('Global.Enemies.KnifeThrower', 'CHAOSKNIFETHROWER'..self.knifethrowercount)
        self.knifethrowercount = self.knifethrowercount + 1
        thrower:setPosition(x, y, z)
        SnapEntityToGround(thrower)
        thrower:scriptSpawned()
        self:setState(nil)
    end
    
    -- needs adjusting, other level camera changes overwrite this too often
    function Ob:stateCinematicCamera()
        Global.player:overShoulderCam(0,350,-400,Global.player,100)
        self:shortEffectSleep()
        Global.player:overShoulderCam(0,350,-400,Global.player,100)
        self:shortEffectSleep()
        Global.player:overShoulderCam(0,350,-400,Global.player,100)
        self:shortEffectSleep()
		SetCamera(kCAMERA_CHASE)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    function Ob:stateTopDownCamera()
        SetChaseCameraAltitude(60)
        SetChaseCameraRadius(3000)
        self:longEffectSleep()
        SetChaseCameraAltitude(14)
        SetChaseCameraRadius(800)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    function Ob:stateZoomedOut()
        SetChaseCameraRadius(3000)
        self:longEffectSleep()
        SetChaseCameraRadius(800)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    function Ob:stateZoomedIn()
        SetChaseCameraRadius(250)
        self:longEffectSleep()
        SetChaseCameraRadius(800)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    function Ob:stateMoreFOV()
        SetCameraFieldOfView(270)
        SetChaseCameraRadius(400)
        self:longEffectSleep()
        SetCameraFieldOfView(110)
        SetChaseCameraRadius(800)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    function Ob:stateUpsideDown()
        SetCameraFieldOfView(610)
        SetCameraTargetHeight(180)
        SetMirrorScene(1)
        self:longEffectSleep()
        SetCameraFieldOfView(110)
        SetCameraTargetHeight(110)
        SetMirrorScene(0)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    function Ob:stateForgetPowers()
        Global.player:savePowerMappings()
		DisablePower(kPOWER_PSIBLAST)
		DisablePower(kPOWER_FIRESTARTING)
		DisablePower(kPOWER_LEVITATION)
		DisablePower(kPOWER_TELEKINESIS)
		DisablePower(kPOWER_CONFUSION)
		DisablePower(kPOWER_INVISIBILITY)
		DisablePower(kPOWER_CLAIRVOYANCE)
		DisablePower(kPOWER_SHIELD)
        self:longEffectSleep()
        Global.levelScript:enableAppropriatePowers()
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)
    end

    --Disabled, major issue, brain does not respawn like Raz does, falling into a pit will softlock, dying leaves the brain exactly where it was
    function Ob:stateBrainMode()
        local brain = SpawnScript('Global.Characters.ChaosBrainRaz', 'ChaosBrainRaz')
		local x,y,z = Global.player:getPosInFrontOf(20, 0)
        local rx,ry,rz = Global.player:getOrientation()
        brain:setPosition(x,y,z)
        brain:setOrientation(rx,ry,rz)
        brain:takeOverRaz()
        EnablePower(kPOWER_TELEKINESIS)
        --store previous power to be re-mapped
        local currentPower = GetMappedPower(kQUICKPICK_TRIGR)
        MapPowerToButton(kPOWER_TELEKINESIS, kQUICKPICK_TRIGR)
        self:longEffectSleep()
        brain:releaseRaz()
        brain:killSelf()
        DisablePower(kPOWER_TELEKINESIS)
        Global.levelScript:enableAppropriatePowers()
        --re-mapping the previous power
        if currentPower ~= nil then
            MapPowerToButton(currentPower, kQUICKPICK_TRIGR)
        end
        self:setState(nil)
    end

    function Ob:stateArrowheadToll()
        self.franke = SpawnScript('Global.Props.Geometry', 'FrankeAnnouncer', 'self.collSphereRadius = 1 self.startCollidee = 0 self.charName=\'Franke\'')
        self.franke:makeInvisible()
        self.kitty = SpawnScript('Global.Props.Geometry', 'KittyAnnouncer', 'self.collSphereRadius = 1 self.startCollidee = 0 self.charName=\'Kitty\'')
        self.kitty:makeInvisible()

        --custom method for loading English Subtitles in any level
        self.propLine = "/CAAV008FA/"
        local cueName = gsub(self.propLine,'/','')
        local hLine = self:loadVoiceLine(cueName) --loading hLine tells SayLine() when to disappear after done talking
		self.franke:sayLine(self.propLine, 0, 1, nil, 1) --DIALOG=<<One arrowhead.>>
        SayLine(self.franke, 'One arrowhead.', 0,0,0,0,'main',255,255,255,255,0,0,0,0.9,0.9,700, 1,hLine,1)

        --sleep to prevent voicelines overlapping
        self:sleep(1.2)

        --custom method for loading English Subtitles in any level
        self.propLine = "/caav009ki/"
        local cueName = gsub(self.propLine,'/','')
        local hLine = self:loadVoiceLine(cueName) --loading hLine tells SayLine() when to disappear after done talking
		self.kitty:sayLine(self.propLine, 0, 1, nil, 1) --DIALOG=<<PAY UP!>>
        SayLine(self.kitty, 'PAY UP!', 0,0,0,0,'main',255,255,255,255,0,0,0,0.9,0.9,700, 1,hLine,1)

        self:sleep(1)
        --remove One Arrowhead
        if (Global.player.stats.arrowheads > 0) then
            SendMessage(Global.player, Global.player, 'ArrowheadAmmo', -1)
            PlaySound(nil, 'ArrowheadPop')
        end
        self.franke:killSelf()
		self.kitty:killSelf()	
        self:setState(nil)
    end

    --Diasbled, currently has no sound effects or screen shake, very underwhelming
    function Ob:stateGoggalor()
        Global.levelScript:startSlowLORaz()
        Global.player.Razilla = 1
        LoadAnim(Global.player, 'anims/DartNew/LO/run.jan', .1, 0)
        Global.player:doNothing()
        Global.player:goToDefaultState()

        self:longEffectSleep()
        
        Global.levelScript:endSlowLORaz()
        LoadAnim(Global.player, 'anims/DartNew/run.jan', .1, 0)
        Global.player:doNothing()
        Global.player:goToDefaultState()

        self:setState(nil)

    end

    function Ob:stateWaterCurse()
        local curse = SpawnScript('Global.Characters.Watercurse', 'CHAOSWATERCURSE')
        --makes sure the curse works in Meat Circus
        Global.player:extinguish()
		Global.player:interruptPowers(1)
		curse.origX, curse.origY, curse.origZ = Global.player:getPosition()
		curse.origY = curse.origY + curse.trigPlaneYOffset
        PlaySound(nil, curse.ScarySound)		
        curse:setState('ArmMiss')
        self:shortEffectSleep()

        Global.player:extinguish()
		Global.player:interruptPowers(1)
		curse.origX, curse.origY, curse.origZ = Global.player:getPosition()
		curse.origY = curse.origY + curse.trigPlaneYOffset
        PlaySound(nil, curse.ScarySound)		
        curse:setState('ArmMiss')
        self:shortEffectSleep()

        Global.player:extinguish()
		Global.player:interruptPowers(1)
		curse.origX, curse.origY, curse.origZ = Global.player:getPosition()
		curse.origY = curse.origY + curse.trigPlaneYOffset
        PlaySound(nil, curse.ScarySound)		
        curse:setState('ArmMiss')
        self:shortEffectSleep()

        curse:killSelf()
        self:setState(nil)
    end

    function Ob:stateThoughtColorChange()
        local psiballColors = {'white', 'pink', 'yellow', 'purple', 'blue', 'light_purple', 'cyan', 'green', 'orange', 'light_green', 'light_peach', 'red', 'light_pink', 'lighter_pink'}
        local n = tableLength(psiballColors)
        local i = random(1,n)
        local colorChoice = psiballColors[i]
        local rPsiBall = FindScriptObject('ThoughtBubble')
		if (rPsiBall) then
			rPsiBall:changeColor(colorChoice)
		end
        self.voicelinePlayer:sayLine("/GLAH000FO/",1,1, nil, 1, nil, 1)--DIALOG=<<Hope that makes you feel pretty.>>
        self:setState(nil)
    end

    --Disabled, melee not working as intended, no idea why
    function Ob:stateTKMonster()
        Global.player:TKMonster(1)
        self:longEffectSleep()
        Global.player:TKMonster(0)
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)

    end

    function Ob:stateNoJumping()
        Global.player:savePowerMappings()
        EnablePlayerJumping(0)
        Global.player:interruptPowers(1)
        DisablePower(kPOWER_LEVITATION)
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        EnablePlayerJumping(1)
        Global.levelScript:enableAppropriatePowers()
        self:setState(nil)

    end

    function Ob:state99Lives()
        Global.player.stats.dartLives = 99
        self:setState(nil)
    end

    function Ob:stateOneLife()
        Global.player.stats.dartLives = 1
        self:setState(nil)
    end

    function Ob:stateFullHeal()
		Global.player.stats.psiHealth = Global.player.stats.maxHealth
        Global.player:playWarningSound()
        self:setState(nil)
    end

    function Ob:stateCriticalHealth()
        Global.player:sayRandomOuchLines()
		Global.player.stats.psiHealth = 1
        Global.player:playWarningSound()
        self:setState(nil)
    end

    function Ob:stateLookforTags()
        local linesready = 0
        while linesready ~= 5 do
            local baggageline = random (1, 5)
            if baggageline == 1 then
                Global.player:sayLine("/GLEB000RA/",1, 1, nil, 1, nil, 1)	--DIALOG=<<This guy needs a duffle bag tag.>>
            elseif baggageline == 2 then
                Global.player:sayLine("/GLEB002RA/",1, 1, nil, 1, nil, 1)	--DIALOG=<<I need the purse tag here.>>
            elseif baggageline == 3 then
                Global.player:sayLine("/GLEB003RA/",1, 1, nil, 1, nil, 1)	--DIALOG=<<I need the steamer trunk tag for this guy.>>
            elseif baggageline == 4 then
                Global.player:sayLine("/GLEB004RA/",1, 1, nil, 1, nil, 1)	--DIALOG=<<Suitcase tag.  That\'s what I need here.>>
            elseif baggageline == 5 then
                Global.player:sayLine("/GLEB001RA/",1, 1, nil, 1, nil, 1)	--DIALOG=<<This hat box needs a hat box tag.>>
            end
            linesready = linesready + 1
        end   
        self:setState(nil)
    end

    function Ob:stateBigRaz()
        Global.player:setScale(2,2,2)
		SetEntityAnimationMovementScale(Global.player, 1)
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        Global.player:setScale(1,1,1)
		SetEntityAnimationMovementScale(Global.player, 1)
        self:setState(nil)
    end

    function Ob:stateSmallRaz()
		Global.player:setScale(0.5,0.5,0.5)
        SetEntityAnimationMovementScale(Global.player, 1)
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        Global.player:setScale(1,1,1)
        SetEntityAnimationMovementScale(Global.player, 1)
        self:setState(nil)
    end

    function Ob:stateIcePhysics()
        SetPhysicsConstant(Global.player,PHYSICS_GroundWalkAccel,1000)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleAccel,1000)
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        SetPhysicsConstant(Global.player,PHYSICS_GroundWalkAccel,6000)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleAccel,3300)
        self:setState(nil)
    end

    function Ob:stateFastRaz()
        SetPlayerMovementScale(2.5)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleMaxUserSpeed,2500)
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        SetPlayerMovementScale(1)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleMaxUserSpeed,1000)
        self:setState(nil)
    end

    function Ob:stateSludgePhysics()
        SetPlayerMovementScale(0.5)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleMaxUserSpeed,600)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleTerminalSpeed,900)
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        SetPlayerMovementScale(1)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleMaxUserSpeed,1000)
        SetPhysicsConstant(Global.player,PHYSICS_BubbleTerminalSpeed,6000)
        self:setState(nil)
    end

    --Disabled, Not noticeable when spawning.
    function Ob:stateFatLady()
        local x, y, z = Global.player:getPosInFrontOf(500, -100)
        local lady = SpawnScript('MC.Props.FatLady', 'CHAOSFATLADY'..self.fatladycount)
        self.fatladycount = self.fatladycount + 1
        lady:setPosition(x, y, z)
        --SnapEntityToGround(lady)
        self:setState(nil)
    end

    --Disabled, Subtitles do not work outside of Campgrounds
    function Ob:stateSquirrels()
        local totalsquirrels = 0
        while totalsquirrels < 5 do
            local x, y, z = Global.player:getPosInFrontOf(650, 500, (-200 + (totalsquirrels*100)))
            local squirrel = SpawnScript('CA.Characters.Squirrel', 'CHAOSSQUIRREL'..self.squirrelcount)
            self.squirrelcount = self.squirrelcount + 1
            squirrel:setPosition(x, y, z)
            SnapEntityToGround(squirrel)
            totalsquirrels = totalsquirrels + 1
        end
        self:setState(nil)
    end

    --Disabled, If effect doesn't end properly, SuperJump will remain toggled off between levels.
    function Ob:stateToggleSuperJump()
        ToggleSuperJump()
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        ToggleSuperJump()
        self:setState(nil)
    end

    --forces Raz to jump whenever he touches the ground!
    function Ob:statePogoStick()
        self.forcejumping = 1
        Global.player:addSpamListener('NewGroundCollide', self)
        ForceRazJump('anims/dartnew/longjump.jan')
        self:longEffectSleep()
        PlaySound(nil, 'ShieldReady')
        self.forcejumping = 0
        self:setState(nil)
    end

    --listener for when Raz touches ground
    function Ob:listenerNewGroundCollide()
        if self.forcejumping == 1 then
            ForceRazJump('anims/dartnew/longjump.jan')
        end
    end

    function Ob:statePause()
        ShowJournal(1)
        self:shortEffectSleep()
        self:setState(nil)
    end

    function Ob:stateCheckInventory()
        OpenThoughtBubble()
        self:shortEffectSleep()
        OpenThoughtBubble()
        self:shortEffectSleep()
        OpenThoughtBubble()
        self:shortEffectSleep()
        self:setState(nil)
    end

    function Ob:stateBacon()
        --[[tests removing our old Bacon first
        GamePrint('Remove Bacon')
        self.findbacon = FindScriptObject('Bacon')
        Global.player:removeFromInventory(self.findbacon)
        self.findbacon:killSelf()
        self:shortEffectSleep()
        ]]

        --make sure we already have the Bacon. If not, spawn a temporary one
        if (Global.player:isInInventory('Bacon') ~= 1) then
            GamePrint('Spawning Temp Bacon')
            self.spawnedBacon = 1
            local bacon = SpawnScript('Global.Props.InstaHintFordItem', 'Bacon')
            Global.player:addToInventory(bacon,0,1)
        end

        --Use that Bacon!
        Global.player:setSelectedItem('Bacon')

        self:sleep(1)

        --Delete the Bacon if we spawned it in
        if self.spawnedBacon ~= nil then
            GamePrint('Remove Bacon')
            self.findbacon = FindScriptObject('Bacon')
            Global.player:removeFromInventory(self.findbacon)
            self.findbacon:killSelf()
            self.spawnedBacon = nil
        end
        self:setState(nil)

    end

    function Ob:stateSpin()

        --determine time to spin
        if self.chaosTime <= 15 then
            self.spineffectDuration = (self.chaosTime -2)
        else
            self.spineffectDuration = 15
        end

        --Randomly choose negative or positive rotation
        local i = random(1,2)
        if i == 1 then
            self.spineffectDirection = 720*(self.spineffectDuration)
        else
            self.spineffectDirection = -720*(self.spineffectDuration)
        end
        --degrees, axis, timeinseconds
        Global.player:rotateLSO(self.spineffectDirection, "Y", (self.spineffectDuration))
        PlaySound(nil, 'ShieldReady')
        self:setState(nil)

    end

    function Ob:stateRazColorChange()
        local n = tableLength(self.colorTable)
        local i = random(1,n)
        local color = nil
        local colorName = nil
        colorName = self.colorTable[i]
        color = self.razColorTable[colorName]
        SetEntityColor(Global.player, color.razRed/255, color.razGreen/255, color.razBlue/255)
        self:setState(nil)
    end


    return Ob
end
