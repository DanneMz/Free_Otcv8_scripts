# Setup

Step 1: Init EnterGame & load restartConfig.json 
- add at bottom of /Init.lua

### Code: 

-- Load restartConfig 
restartConfig = {}  
restartfile =  "restartConfig.json"
if g_resources.fileExists(restartfile) then
    	local status, result = pcall(function() 
		return json.decode(g_resources.readFileContents(restartfile)) 
    	end)
	if not status then
		g_logger.fatal('error cannot load restartConfig.json')
	return 
    	end
	restartConfig = result
	if restartConfig.restart then
		EnterGame.doLogin()	
	end
else
    	restartConfig = {restart = false, loginChar = ""}
    	local status, result = pcall(function() 
    		return json.encode(restartConfig, 2) 
	end)
	g_resources.writeFileContents(restartfile, result)
end 


Step 2: Entergame.CharacterList choose player
- /modules/client_entergame/entergame.lua
- find string: **<ins>CharacterList.save()</ins>**
- add code below

### Code: 

-- CharacterList.save() -- add code below this line

if restartConfig.restart then	
	local characters = g_ui.getRootWidget().charactersWindow.characters 
	for index, child in ipairs(characters:getChildren()) do
		local name = child:getChildren()[1]:getText()
		-- CharacterList choose restartCharacter
		if name == restartConfig.loginChar then
			child:focus()
			-- LoginChar
			CharacterList.doLogin()
			CharacterList.hide()
			EnterGame.hide()	
			-- Reset Restart
			restartConfig.restart = false
			restartConfig.loginChar = ""
			-- Save restartConfig
			local status, result = pcall(function() 
				return json.encode(restartConfig, 2) 
			end)
			g_resources.writeFileContents(restartfile, result)
		end
	end
end 
