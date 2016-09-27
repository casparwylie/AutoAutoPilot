consoleWindow = gui.newWindow("aap_console")

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

	gui.showWindow(consoleWindow)
	
end

function initiateFlight_OnClick()
	gui.hideWidget(startSel)
	gui.setWidgetValue(innerConsole, "STARTING")
end