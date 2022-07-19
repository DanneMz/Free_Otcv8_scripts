# OTClientv8 RestartClient
*By DanneMz - Discord: DanneMz#1509*

## Functions:
- Restart[Now] - Restart after 5 seconds.
- Restart[Refill] - Restart at refill at depot.
- Restart[Time] - Restart at refill safeSpot, after a selected clock time(03:00). 
- Restart[Cancel] - Cancel restart.

 ## Preview image:

  ![Alt text](https://media.discordapp.net/attachments/940724833233285200/998378480465105057/unknown.png)

## Requirements: 
- Setup 
- RestartClient.lua

## If using Regular Client:
- Make setup in the OTClient.exe folder.

## If using Updating Client (data.zip): 
- Do the disable updater at the bottom,
  befor the setup.

# Setup

## Step 1: Init EnterGame & load restartConfig.json 
- add at bottom of /Init.lua

### Code: 
```ruby -- Load restartConfig 
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
```

## Step 2: Entergame.CharacterList choose player
- /modules/client_entergame/entergame.lua
- find string: **<ins>CharacterList.save()</ins>**
- add code below

### Code: 

```ruby -- CharacterList.save() -- add code below this line

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
```

## F.A.Q
### How to setup autoLogin?
- Follow the steps in the Setup.

### Where to put RestartClient.lua?
- In Ingame script Editor or if your using private script dir folder.

### How does the refill restart work?
- At Refill Position, insert position coordinates of a area that you know is safe to restart like depot. 
- With exact position [x,y,z] or with distance allowed [x,y,z,dist].
- Be certain that you pass that area in your CaveBot waypoints script.
- The Client will restart when passing this area.

### Why Restart Client?
- Running client for a long time builds up alot of memory, if its hits max limit client will crash or be unplayable.
- Restarting resets all memory to client.

### How to Disable updater? 
- Be sure client is updated to latest version.
- Open <ins>\%appdata%\Roaming\OTClientV8\YOUR_SERVER_FOLDER</ins>, should be your servername etc.
- Open data.zip in the server folder in <ins>\%appdata%\Roaming\OTClientV8</ins>. 
- data.zip in %appdata% is just rubbish text, copy code from Init.lua & <ins>\modules\client_entergame\entergame.lua</ins> at your OTClient.exe folder in data.zip.
- Paste code instead rubbish text in your %appdata% data.zip files and save files.
- <ins>Important</ins> to update the archive(data.zip) after changes, by select open data.zip in Winrar etc and press "yes" on the "do you wish to update in the archive?"
- Open the Init.lua at your OTClient.exe folder & disable Update Client, by removing the link from updater="http://otclient.ovh/api/updater.php".
- Storage updater link if wanna update client again.
- Save file.
- <ins>Important</ins> to update the archive(data.zip), by select open data.zip in Winrar etc and press "yes" on the "do you wish to update in the archive?"
- Now you can edit the data.zip without the updater changing it back to default.

### Setup Changes 
- Setup changes are made in %appdata% server folder.
- <ins>Important</ins> after every Setup changes in %appdata% data.zip, to update the archive(data.zip)
  select open data.zip in Winrar etc and press "yes" on the "do you wish to update in the archive?".

### How to enable update in Client again: 
- Save the Init.lua & Entergame.lua from %appdata%.
- Put Updater Link back in Init.lua in data.zip at OTClient.exe folder.
- <ins>Important</ins> after every Setup changes in data.zip, to update the archive(data.zip)
  select open data.zip in Winrar etc and press "yes" on the "do you wish to update in the archive?".

