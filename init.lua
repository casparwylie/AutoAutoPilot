
consoleWindow = gui.newWindow("aap_console")
outputCount = 2 
outputs = {"Flight Stage", "Current Activity"}
outputVals = {}
activitySpeed = 1
feedFile = io.open("feed.txt")
feedData = {}
executeID = 0

function populateFeedData()
	count = 0
	for line in io.lines(feedFile) do
		feedData[count] = line
		count = count + 1
	end
end

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
		outputVals[outputs[i]] = gui.newLabel(consoleWindow, "", outputs[i], 10, yPos, 20)
	end
	gui.showWindow(consoleWindow)
	populateFeedData()
	
end

--Initate flight beginning
function initiateFlight_OnClick()
	
	gui.hideWidget(startSel)
	updateOutputVal("Flight Stage", "STARTING...")
	local actLoop = timer.newTimer( "executionLoop", activitySpeed);
	
end

function updateOutputVal(key, newVal)

	local newFinalVal = key .. ": " .. newVal
	console.warn(newFinalVal)
	gui.setWidgetValue(outputVals[key], newFinalVal)

end

function changeDataRef(datarefSTR, newVal)

    dataref = dref.getDataref(datarefSTR)
    if type(newVal)!="string" then 
    	dref.setInt(dataref, newVal)
    else
    	dref.setString(dataref, newVal)
    end

end


function executionLoop()
	dataRow  = feedData[executeID]
	for i in string.gmatch(dataRow, "%S+") do
  		print(i)
	end
	changeDataRef()
end