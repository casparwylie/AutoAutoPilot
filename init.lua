
consoleWindow = gui.newWindow("aap_console")
outputCount = 20
outputVals = {}
currOutput = 1
activitySpeed = 0.5
feedDataCount = 54
destination = ""

feedData = {"anim/90/button, 1, CONNECT BATTERY POWER","anim/20/switch, 2, STARTING APU",
	  "anim/91/button, 1, ENGAGING APU GENERATOR","anim/88/button, 1, SETTING ADIRU ALIGNMENT",
	  "anim/25/switch, 1, SETTING CARGO HEAT", "anim/89/button, 1, SETTING Assymetric THRUST COMPENSATION",
	  "anim/92/button, 1, SETTING AC L BUS", "anim/93/button, 1, SETTING AC R BUS",
	  "anim/103/button, 1, WINDOW HEAT ON SIDE L","anim/104/button, 1, WINDOW HEAT ON FWD L",
	  "anim/105/button, 1, WINDOW HEAT ON SIDE R","anim/106/button, 1, WINDOW HEAT ON FWD R",
	  "anim/108/button, 1, ENGAGING LEFT PRIMARY HYDRAULIC PUMP","anim/111/button, 1, ENGAGING RIGHT PRIMARY HYDRAULIC PUMP",
	  "anim/108/button, 1, ENGAGING LEFT PRIMARY HYDRAULICw, IC PUMP","anim/111/button, 1, ENGAGING RIGHT PRIMARY HYDRAULIC PUMP",
	  "anim/50/switch,1, TESTING FIRE ALERT SYSTEM", "anim/116/button, 1, ENGAGING EEC MODE L",
	  "anim/117/button, 1, ENGAGING EEC MODE R", "anim/154/button, 1, SET ENGINE AUTO START",
	  "anim/14/switch, 1, SETTING WING ANTI-ICE TO AUTO", "anim/15/switch, 1, SETTING ENGINE L ANTI-ICE TO AUTO",
	  "anim/16/switch, 1, SETTING ENGINE R ANTI-ICE TO AUTO", "anim/130/button, 1, SETTING NAVIGATION LIGHTS",
	  "anim/134/button, 1, L RECIRCULATION FANS ON","anim/135/button, 1, R RECIRCULATION FANS ON",
	  "anim/136/button, 1, SETTING L AIR PACK ON","anim/147/button, 1, SETTING R AIR PACK ON",
	  "anim/137/button, 1, SETTING L TRIM AIR ON","anim/138/button, 1, SETTING R TRIM AIR ON",
	  "anim/139/button, 1, SETTING BLEED AIR ISLN VALVE L ON","anim/140/button, 1,SETTING BLEED AIR ISLN VALVE C ON",
	  "anim/141/button, 1, SETTING BLEED AIR ISLN VALVE R ON", "anim/143/button, 1, ENGAGING APU BLEED AIR",
	  "anim/145/button, 1, SETTING PRESSURE OUT FLOW VALVES AUTO L", "anim/146/button, 1, SETTING PRESSURE OUT FLOW VALVES AUTO R",
	  "anim/7/switch, -1, SETTING AUTOBRAKES TO RTO", "anim/109/button, 1, SETTING ELECTRICAL HYDRAULIC PUMPS C1",
	  "anim/110/button, 1, SETTING ELECTRICAL HYDRAULIC PUMPS C2", "anim/121/button, 1, SETTING LEFT FUEL PUMPS ON FWD",
	  "anim/121/button, 1, SETTING LEFT FUEL PUMPS ON FWD", "anim/121/button, 1, SETTING LEFT FUEL PUMPS ON FWD",
	  "anim/124/button, 1, SETTING LEFT FUEL PUMPS ON AFT","anim/123/button, 1, SETTING RIGHT FUEL PUMPS ON FWD",
	  "anim/126/button, 1, SETTING RIGHT FUEL PUMPS ON AFT", "anim/129/button, 1, ENGAGING BEACON LIGHTS",
	  "anim/142/button, 1, ENGAGING ENGINE BLEED AIR L", "anim/144/button, 1, ENGAGING ENGINE BLEED AIR R",
	  "anim/96/button, 1, ENGAGING ENGINE GENERATOR L", "anim/97/button, 1, ENGAGING ENGINE GENERATOR R",
	  "anim/2/switch, 2, OPENING FUEL FLOW TO L ENGINE", "anim/18/switch, 0, STARTING L ENGINE",
	  "anim/3/switch, 2, OPENING FUEL FLOW TO R ENGINE", "anim/19/switch, 0, STARTING R ENGINE",
	  "T7Avionics/CDU/LLSK1, 1, SELECTING FMC MENU", "T7Avionics/CDU/clear, 1, CLEARING FMC MESSAGES",
	  "T7Avionics/CDU/RLSK6, 1, GOING TO POS INIT DATA","T7Avionics/CDU/RLSK4, 1, COPYING POSITION DATA",
	  "T7Avionics/CDU/RLSK5, 1, SAVING POSITION DATA", "non, 1, RWY_DATA"
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
		nav.setSearchGroups( 1,1,1,1, 0,0,0,0, 1,1,1,1 )
		navID = nav.findNavAid(string.upper(dest), "*", "*", "*", "*")  
		console.warn(navID)
		navaid_type, lat, lon, alt, ICAO_ID, Name, reg, freq, heading = nav.getNavAidInfo(navID)
		destination = dest
		gui.hideWidget(startSel)
		outputVal("Starting...", "MESSAGE")
		actLoop = timer.newTimer( "executionLoop", activitySpeed)
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


function changeDataRef(datarefSTR, newVal)

    dataref = dref.getDataref(datarefSTR)
    if type(newVal) == "string" then 
    	dref.setString(dataref, newVal)
    else
    	console.warn(datarefSTR, newVal)
    	dref.setInt(dataref, newVal)
    end

end


function executionLoop()
	dataRowArr = getDataRefFromFeed(executeID)
	if dataRowArr[1] ~= "non" then
		changeDataRef(dataRowArr[1], tonumber(dataRowArr[2]))
		outputVal(dataRowArr[3], "ACTION")
	else
		timer.stop(actLoop)
	end
	executeID = executeID + 1

end

function nonLinearFunctionality(spec)

	---if spec == "AUTO_FUEL" then
	---end

end
