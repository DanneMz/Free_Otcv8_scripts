-- Restart Client v.1

-- Restart_Now_Config --
local restartSeconds = 5 -- seconds befor restart

-- By DanneMz - Discord: DanneMz#1509 --
UI.Label("OTClient Restart")
UI.Separator() 
-- storage.restarted
storage.restarted = storage.restarted or false
-- refillPos
UI.Label("Refill position:")
storage.refillPos = storage.refillPos or "100,100,7,0"
refillEdit = UI.TextEdit(storage.refillPos or "x,y,z,dist", function(widget, refillNew)	
	if (#regexMatch(refillNew, "^\\s*([0-9]+)\\s*,\\s*([0-9]+)\\s*,\\s*([0-9]+),?\\s*([0-9]?)$") == 1) then
		storage.refillPos = refillNew
	else
		warn("Invalid position, should be a position area. (x,y,z,dist)") 		
		refillEdit:setText(storage.refillPos)
	end
end)
-- restart after seconds
UI.Button("Restart [Now]", function()
	if isInPz() then 
		countRestart = restartSeconds
		restartNow:setOn() -- start restartNow     
	else
		restartNow:setOff() -- stop restartNow   
		warn("You can only Restart Client in ProtectedZone.") 
	end	
end)
-- restart at refill safeSpot
UI.Button("Restart [Refill]", function()
	restartRefill:setOn() -- start refill macro
	warn("Restart Client in next refill.")
end)
-- setTime to restart Client at refill safeSpot.
restartTime = macro(1000, 'Restart [Time]', function() 
	if restartTime:isOn() and storage.restarted == false then 		
		local time = os.date("%H:%M:%S") >= storage.restartTime..":00" and os.date("%H:%M:%S") <= storage.restartTime..":59"
		if time and restartRefill:isOff() then 
			restartRefill:setOn() -- start refill macro
			info("Restart_Time["..os.date("%H:%M").."]")
			warn("Restart Client in next refill.")
		end
	end
end)
-- restartTime, safety macro 60sec delay after restart
if storage.restarted == true then
afterRestart = macro(60000, function()	
	storage.restarted = false -- restarted delay finish
	afterRestart:setOff() -- stop safety macro		
end)
end



-- edit restartTime
timeEdit = UI.TextEdit(storage.restartTime or "03:00", function(widget, newTime)
	if (#regexMatch(newTime, "^([0-1][0-9]|[2][0-3]):([0-5][0-9])$") == 1) then
		storage.restartTime = newTime
	else
		timeEdit:setText(storage.restartTime or "03:00")
		storage.restartTime = storage.restartTime or "03:00"
		warn("Invalid time, should be (HH:MM)") 
	end
end)
-- cancel restart
UI.Button("Restart Cancel", function()
	if restartNow:isOn() then 
		restartNow:setOff() -- stop restartNow  
		warn("Restart[Now] Canceled.")
	end
	if restartRefill:isOn() then
		restartRefill:setOff() -- stop refill macro
		warn("Restart[Refill] Canceled.")
	end
end)
UI.Separator() 

-- restartNow macro
restartNow = macro(1500, function()   
	if restartNow:isOn() and isInPz() then
		if countRestart >= 1 then		
			warn("Restarting in "..countRestart.." seconds.")    
			countRestart = (countRestart - 1)
		else                  
			restart_loginChar() -- try restartClient
		end
	else
		restartNow:setOff() -- stop restartNow  
		warn("You can only Restart Client in ProtectedZone.") 
	end
end) 
restartNow:setOff() -- restartNow default

	

-- restartRefill macro
restartRefill = macro(1000, function()
	if restartRefill:isOn() then
		local refillPos = { x = 0, y = 0, z = 0, dist = 0 }
		if storage.refillPos then
			local refillCords = {}
			for cord in string.gmatch(storage.refillPos, "([^"..",".."]+)") do
			   table.insert(refillCords, cord)
			end		
			refillPos.x = tonumber(refillCords[1])
			refillPos.y = tonumber(refillCords[2])
			refillPos.z = tonumber(refillCords[3])
			if refillCords[4] then
				refillPos.dist = tonumber(refillCords[4])
			else
				refillPos.dist = 0
			end
		end
		if isInPz() and (refillPos.z  ==  player:getPosition().z) and getDistanceBetween(player:getPosition(), refillPos) <= refillPos.dist then
			restart_loginChar() -- try restartClient
		end   
	end
end)
restartRefill:setOff() -- refill default 

-- restart.loginChar()
function restart_loginChar()
	if isInPz() then	
		loadRestart() -- load restartConfig
		-- Check if someone using Restart.
		if not restartConfig.restart then	
			restartNow:setOff() -- stop restartNow
			restartRefill:setOff() -- stop refill macro			
			-- Restart Client
			if saveRestart() then				
				modules.client.g_app.restart() -- restartClient
			end
		else
			warn("Restart is busy, retrying.")		
		end
	else
		restartNow:setOff() -- stop restartNow
		restartRefill:setOff() -- stop refill macro
		warn("You can only Restart Client in ProtectedZone.") 
	end
end

-- load restartConfig
function loadRestart()
	restartConfig = {}
	local restartfile =  "restartConfig.json"
	if g_resources.fileExists(restartfile) then		  
		local status, result = pcall(function()
			return json.decode(g_resources.readFileContents(restartfile)) 
		end)

		if not status then
			print("error cannot load "..restartfile)
		return     
		end    
		restartConfig = result
	else
		restartConfig = {restart = false, loginChar = ""}

		local status, result = pcall(function() 
		return json.encode(restartConfig, 2) 
		end)    
		g_resources.writeFileContents(restartfile, result)
	end
end

-- save restartConfig
function saveRestart()  
	storage.restarted = true -- client being restarted
	modules.game_bot.save() -- save bot settings
	restartConfig.restart = true -- take restart place
	restartConfig.loginChar = name() -- save loginCharacter
	local restartfile =  "restartConfig.json"

	local status, result = pcall(function() 
		return json.encode(restartConfig, 2) 
	end)
	
	if not status then
		print("error while saving "..restartfile..", Details: " .. result)
		return
	end
  
	if result:len() > 100 * 1024 * 1024 then
		return print(restartfile.." is too big, above 100MB, it won't be saved")
	end  
	g_resources.writeFileContents(restartfile, result)
	return true
end
