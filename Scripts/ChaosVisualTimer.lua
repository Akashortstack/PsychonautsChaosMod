function ChaosVisualTimer(Ob)
    if ( not Ob ) then
        Ob = CreateObject('ScriptBase')

    end

    function Ob:beginStateTimingChaos()
        --get timer values from ChoasController
        self.chaosController = FindScriptObject('ChaosController', 'ChaosController')
        --initial visual timer appears off by 1 second, not sure why...
        self.firstTime = self.chaosController.chaosStartTime + 0.9
        self.repeatTime = self.chaosController.chaosTime
        self:initTimer()
        self.textHandle = nil
	end

    function Ob:stateTimingChaos()
		--Update the timer
        self:updateTimer()
	end

    function Ob:resetTimer()
        -- Reset the timer (this function is called when chaos effect goes off)
        self.startTime = GetGameTimeSecs() + self.repeatTime
    end

    function Ob:initTimer()
		--Set up initial timing variable
		self.startTime = GetGameTimeSecs() + self.firstTime
	end	

    -- Saving in case I need pause functions later
    function Ob:pauseTimer()
        self.pausedTime = self.startTime - GetGameTimeSecs()
    end

    function Ob:unpauseTimer()
        self.pausedTime = nil
    end

    function Ob:updateTimer()
        local time
        time = self.startTime - GetGameTimeSecs()

        -- Make sure timer never goes below 0, especially if we're in a cutscene
        if time <= 0 then
            time = 0 
        end

        self.timeString = '//'..self:formatTime(time)
        
        -- create display handle
        if (not self.timeDisplay) then
            self.timeDisplay = SpawnScript('Global.OtherEntities.UIElement', 'TimeDisplay')
            self.timeDisplay:createText(self.timeString, 550, 310,.8,.8, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 1)
            self.timeDisplay:textFadeOnHUD(0)							  
        else
            self.timeDisplay:adjustText(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil, self.timeString)
        end
	end

    function Ob:formatTime(time)
		local seconds = self:padZeros(floor(mod(time, 60)))
		local timeText = seconds
		return timeText
	end

    function Ob:padZeros(time)
		return ((time < 10) and ('0'..time)) or time
	end


    return Ob
end