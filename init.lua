
consoleWindow = gui.newWindow("aap_console")
outputCount = 20
outputVals = {}
currOutput = 1
activitySpeed = 0.1
feedDataCount = 62
destination = ""
timerOn = false
drefCDUpre = "T7Avionics/CDU/"

feedData = {"non,AUTO_FUEL,1","anim/90/button,1, CONNECT BATTERY POWER","anim/20/switch, 2, STARTING APU",
	  "anim/91/button,1, ENGAGING APU GENERATOR","anim/88/button,1, SETTING ADIRU ALIGNMENT",
	  "anim/25/switch,1, SETTING CARGO HEAT", "anim/89/button,1, SETTING Assymetric THRUST COMPENSATION",
	  "anim/92/button,1, SETTING AC L BUS", "anim/93/button,1, SETTING AC R BUS",
	  "anim/103/button,1, WINDOW HEAT ON SIDE L","anim/104/button,1, WINDOW HEAT ON FWD L",
	  "anim/105/button,1, WINDOW HEAT ON SIDE R","anim/106/button,1, WINDOW HEAT ON FWD R",
	  "anim/108/button,1, ENGAGING LEFT PRIMARY HYDRAULIC PUMP","anim/111/button,1, ENGAGING RIGHT PRIMARY HYDRAULIC PUMP",
	  "anim/108/button,1, ENGAGING LEFT PRIMARY HYDRAULIC PUMP","anim/111/button,1, ENGAGING RIGHT PRIMARY HYDRAULIC PUMP",
	  "anim/50/switch,1, TESTING FIRE ALERT SYSTEM", "anim/116/button,1, ENGAGING EEC MODE L",
	  "anim/117/button,1, ENGAGING EEC MODE R", "anim/154/button,1, SET ENGINE AUTO START",
	  "anim/14/switch,1, SETTING WING ANTI-ICE TO AUTO", "anim/15/switch,1, SETTING ENGINE L ANTI-ICE TO AUTO",
	  "anim/16/switch,1, SETTING ENGINE R ANTI-ICE TO AUTO", "anim/130/button,1, SETTING NAVIGATION LIGHTS",
	  "anim/134/button,1, L RECIRCULATION FANS ON","anim/135/button,1, R RECIRCULATION FANS ON",
	  "anim/136/button,1, SETTING L AIR PACK ON","anim/147/button,1, SETTING R AIR PACK ON",
	  "anim/137/button,1, SETTING L TRIM AIR ON","anim/138/button,1, SETTING R TRIM AIR ON",
	  "anim/139/button,1, SETTING BLEED AIR ISLN VALVE L ON","anim/140/button,1,SETTING BLEED AIR ISLN VALVE C ON",
	  "anim/141/button,1, SETTING BLEED AIR ISLN VALVE R ON", "anim/143/button,1, ENGAGING APU BLEED AIR",
	  "anim/145/button,1, SETTING PRESSURE OUT FLOW VALVES AUTO L", "anim/146/button,1, SETTING PRESSURE OUT FLOW VALVES AUTO R",
	  "anim/7/switch, -1, SETTING AUTOBRAKES TO RTO", "anim/109/button,1, SETTING ELECTRICAL HYDRAULIC PUMPS C1",
	  "anim/110/button,1, SETTING ELECTRICAL HYDRAULIC PUMPS C2", "anim/121/button,1, SETTING LEFT FUEL PUMPS ON FWD",
	  "anim/121/button,1, SETTING LEFT FUEL PUMPS ON FWD", "anim/121/button,1, SETTING LEFT FUEL PUMPS ON FWD",
	  "anim/124/button,1, SETTING LEFT FUEL PUMPS ON AFT","anim/123/button,1, SETTING RIGHT FUEL PUMPS ON FWD",
	  "anim/126/button,1, SETTING RIGHT FUEL PUMPS ON AFT", "anim/129/button,1, ENGAGING BEACON LIGHTS",
	  "anim/142/button,1, ENGAGING ENGINE BLEED AIR L", "anim/144/button,1, ENGAGING ENGINE BLEED AIR R",
	  "anim/96/button,1, ENGAGING ENGINE GENERATOR L", "anim/97/button,1, ENGAGING ENGINE GENERATOR R",
	  "anim/2/switch, 2, OPENING FUEL FLOW TO L ENGINE", "anim/18/switch, 0, STARTING L ENGINE",
	  "anim/3/switch, 2, OPENING FUEL FLOW TO R ENGINE", "anim/19/switch, 0, STARTING R ENGINE",
	  "T7Avionics/CDU/LLSK1,1, SELECTING FMC MENU", "T7Avionics/CDU/clear,1, CLEARING FMC MESSAGES",
	  "T7Avionics/CDU/RLSK6,1, GOING TO POS INIT DATA","T7Avionics/CDU/RLSK4,1, COPYING POSITION DATA",
	  "T7Avionics/CDU/RLSK5,1, SAVING POSITION DATA", "non,AUTO_FMC,0",
	  "T7Avionics/CDU/clear,1, CLEARING FMC MESSAGES", --add to count
	  }
executeID = 1


--Start, render console
function aap_console_OnCreate()
	gui.setWindowCaption(consoleWindow, "Auto Auto Pilot")
	gui.setWindowSize( consoleWindow, 100,100, 640,480)
	headerMsg =  "Welcome to AAP. Please enter your desired destination by the aiport's code (e.g EGLL).";
	footerMsg = " Created by Caspar Wylie"
	headerMsgWidget = gui.newLabel(consoleWindow, "", headerMsg, 90,20, 20)
	footerMsgWidget = gui.newLabel(consoleWindow, "", footerMsg, 250, 450, 20)
	textFieldDest = gui.newTextBox(consoleWindow, "", "Destination", 260, 50, 100)
	startSel = gui.newButton(consoleWindow, "initiateFlight", "Start", 285, 70, 50)
	innerConsole = gui.newSubWindow(consoleWindow, "", "AAP Activity Feed", 100, 640, 300)
	for i=1,outputCount, 1 do
		yPos = 100 + i*15
		outputVals[i] = gui.newLabel(consoleWindow, "", "", 220, yPos, 20)
	end
	gui.showWindow(consoleWindow)
	
end

function clearOutputs()
	for i=1,outputCount, 1 do
		gui.setWidgetValue(outputVals[i], "")
	end
end

--Initate flight beginning
function initiateFlight_OnClick()
	local dest = gui.getWidgetValue(textFieldDest)
	if string.len(dest) ~= 4 then
		outputVal("Invalid airport code. Please Try again. ", "ERROR")
	else
		nav.setSearchGroups( 1,0,0,0,0,0,0,0,0,0,0,0)
		navID = nav.findNavAid(nil,string.upper(dest), nil, nil, nil)  
		navaid_type, destLat, destLon, alt, ICAO_ID, Name, reg, freq, heading = nav.getNavAidInfo(navID)
		console.warn(ICAO_ID..Name)
		if ICAO_ID == string.upper(dest) then
			destination = ICAO_ID
			gui.hideWidget(startSel)
			outputVal("Destination: "..Name, "MESSAGE")
			outputVal("Starting...", "MESSAGE")
			actLoop = timer.newTimer( "executionLoop", activitySpeed)
			timerOn = true
		else
			outputVal("That airport code does not exist. Please try again ", "ERROR")
		end
	end
	
end

function outputVal(newVal, typeStr)
	local toOutput = typeStr .. " >>>" .. newVal
	gui.setWidgetValue(outputVals[currOutput], toOutput)
	currOutput = currOutput + 1
	if(currOutput == outputCount) then
		currOutput = 0
		clearOutputs()
	end

end


function getDataRefFromFeed(dataRefID)
	local dataRow = feedData[dataRefID]
	local dataRowArr = {}
	local regexComma = '([^,]+)'
	local colCount = 1
	for x in string.gmatch(dataRow, regexComma) do
    	dataRowArr[colCount] = x
    	colCount = colCount + 1
	end
	return dataRowArr
end


function changeDataRef(datarefSTR, newVal, type)

    dataref = dref.getDataref(datarefSTR)
    if type == "string" then 
    	dref.setString(dataref, newVal)
    elseif type == "int" then
    	dref.setInt(dataref, newVal) 
    	console.warn("s: "..datarefSTR..".."..newVal)
    elseif type == "float" then
    	dref.setFloat(dataref, newVal)
    end
end


function executionLoop()
	if executeID == feedDataCount then
		timer.stop(actLoop)
		timerOn = false
	end
	dataRowArr = getDataRefFromFeed(executeID)
	if dataRowArr[1] ~= "non" then
		changeDataRef(dataRowArr[1], tonumber(dataRowArr[2]), "int")
		outputVal(dataRowArr[3], "ACTION")
	else
		if timerOn == true then
			timer.stop(actLoop)
			timerOn = false
		end
		nonLinearFunctionality(dataRowArr[2], dataRowArr[3])
		
	end

	executeID = executeID + 1
end

function distanceBetweenCoordSet(lon1,lat1, lon2,lat2)
	a = math.pi / 180
	lat1 = lat1 * a
	lat2 = lat2 * a
	lon1 = lon1 * a
	lon2 = lon2 * a
	t1 = math.sin(lat1) * math.sin(lat2)
	t2 = math.cos(lat1) * math.cos(lat2)
	t3 = math.cos(lon1 - lon2)
	t4 = t2 * t3
	t5 = t1 + t4
	rad_dist = math.atan(-t5/math.sqrt(-t5 * t5 +1)) + 2 * math.atan(1)
	route_distance = rad_dist * 3437.74677 * 1.1508 * 0.868976
	return route_distance
end




CDUQueue = {}
CDUQueuePosID = 1
CDUQueueTotal = 1

function addToCDUQueue(cduString, msgString)
	if msgString ~= "" then
		outputVal(msgString, "ACTION")
	CDUQueueTotal = CDUQueueTotal + 1
	table.insert(CDUQueue, cduString)
end

function addStringToCDUQueue(cduString)
	for i=1,string.len(cduString),1 do
		local fullKeyDrefchar = cduString.sub(destination,i,i)
		addToCDUQueue(fullKeyDrefchar, "")
	end
end

function clearCDU() 
	addToCDUQueue("delete", "")
	addToCDUQueue("clear", "")
end

function nonLinearFunctionality(spec, resumeTimer)
	
	if spec == "AUTO_FUEL" then
		latACF,lonACF,alt_msl = acf.getPosition()
		local currentToDestDistance = distanceBetweenCoordSet(lonACF,latACF,destLon,destLat)
		local fuelForTankInKG = (currentToDestDistance * 100) / 3 ---* 0.453592
		--for i=1,3,1 do
			--local dRefName = "sim/flightmodel/weight/m_fuel"..i
			--changeDataRef(dRefName, fuelForTankInKG, "float")
			
		--end
		outputVal("Fuel aircraft "..fuelForTankInKG.." kg", "**IMPORTANT**")

	elseif spec == "AUTO_FMC" then


		--enter origin
		clearCDU()
		addStringToCDUQueue(destination)
		addToCDUQueue("LLSK2", "")
		addToCDUQueue("RLSK6", "")
		addStringToCDUQueue(destination)
		addToCDUQueue("RLSK1", "SETTING FMC DESTINATIONS / ORIGINS")

		CDUQueueTimer = timer.newTimer( "runCDUQueue",0.1)

	end

	if resumeTimer == "1" then
		 timer.reset(actLoop)
		 timerOn = true
	end

end

function runCDUQueue()
	console.warn("CDU TIMER: "..CDUQueue[CDUQueuePosID])
	changeDataRef(drefCDUpre..CDUQueue[CDUQueuePosID], 1, "int")
	CDUQueuePosID = CDUQueuePosID + 1
	if CDUQueuePosID == CDUQueueTotal then
		timer.stop(CDUQueueTimer)
		timer.reset(actLoop)
		timerOn = true
	end
end
