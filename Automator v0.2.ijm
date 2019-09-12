//Welcome to Automator: A Batch Processing Wizard for FIJI! v0.2

//If used in the course of reseach culminating in a publication, an acknowledgement and citation would be appreciated.

/* To Do:
 *  Add descriptions of function - comment everything as necessary
 *  Min and Max for Channel Values <--- Added but makes the UI/UX clunky
 *  	Review dialog box creation to try and simplify/beautify input process
 *  Add ability to save at any point if desired <--- Current plan is to implement by providing at any point something meaningful/potentially
 *  	valuable is done to the image, but leave it commented out until a user desires, mainly due to UI/UX headaches associated with that
 *  Add save as gray option for single channel stacks
 *  Add label/timestamp by ROI
 *  Anywhere Things Could be More Efficient
 *  Add Flexibility and Improve Modularity
 *  Eventually: How to go from Macro to PlugIn?
 *  User Input for Save as AVI
 *  	Compression? <- Weird Issue with Prompt to Save When Adding Frame Rate and Compression to saveAs Command
 *  	Verify Frame Rate Changes by Input Value
 */

//User Input Starts Here <----------------------
Dialog.create("Welcome!"); 
Dialog.addMessage("To begin, please select your input directory."); 
Dialog.show();

openPath = getDirectory("Choose Source Directory"); //Allows user to select folder of interest and assigns it to variable "openPath"
files = getFileList(openPath)

Dialog.create("Save Location"); //Creates a dialog box
Dialog.addMessage("Now, please select your output directory."); //Adds message text
Dialog.show(); //Opens the dialog box we created

savePath = getDirectory("Choose Destination Directory"); //Allows user to select save folder

/*Below we define our variables for the dialog box we will be creating with placeholder
text that give the user an idea of what is expected in those fields/what those fields are for*/

title = "Project";
interval = 1;
fontSize = 60;
zSlice = newArray("Yes", "No");
rangeStart = 0; rangeEnd = 0;
takeFirst = ""
orientation = newArray("Horizontally", "I'll Do This Later", "Vertically");
frameRate = 0;
orientationChoice = "";
redID = ""; greenID = ""; blueID = "";
//minValR = 0
//maxValR = 0
//minValG = 0
//maxValG = 0
//minValB = 0
//maxValB = 0
colorBlind = "";

//Here we create our user interface/info gathering dialog box

Dialog.create("AutomatR"); //Creates dialog box
Dialog.addMessage("Please Provide the Following Information.\n\nBe Sure to Leave Blank Fields Blank if Unused."); //Adds message text
Dialog.addString("Title:", title, 15); //Input for title, which later becomes file name
Dialog.addNumber("Time Between Acquisitions:", 1, 0, 3, "Minute(s)");
Dialog.addChoice("Remove the First Frame of Every Z:", zSlice);
Dialog.addNumber("Clip Z Stack Starting at Frame:", 0, 0, 3, "");
Dialog.addNumber("Clip Until Frame:", 0, 0, 3, "");
Dialog.addNumber("Frame Rate:", 7, 0, 3, "FPS");
Dialog.addChoice("For Timestamping: Images are Oriented", orientation);
Dialog.addString("Red Channel ID:", redID, 10);
Dialog.addString("Green Channel ID:", greenID, 10);
Dialog.addString("Blue Channel ID:", blueID, 10);
Dialog.addChoice("Activate Colorblind Accomodation:" zSlice);
//Dialog.addNumber("Min Brightness Red:", 0, 0, 5, "0");
//Dialog.addNumber("Max Brightness Red:", 0, 0, 5, "256");
//Dialog.addNumber("Min Brightness Green:", 0, 0, 5, "0");
//Dialog.addNumber("Max Brightness Green:", 0, 0, 5, "256");
//Dialog.addNumber("Min Brightness Blue:", 0, 0, 5, "0");
//Dialog.addNumber("Max Brightness Blue:", 0, 0, 5, "256");
Dialog.addMessage("(Green -> Cyan, Red -> Magenta, Blue -> Yellow)");
Dialog.show(); //This opens the dialog box we created

//Below gathers user input from above dialog box and reassigns the relevant variables such that they now carry those values

title = Dialog.getString();
interval = Dialog.getNumber();
takeFirst = Dialog.getChoice();
rangeStart = Dialog.getNumber();
rangeEnd = Dialog.getNumber();
frameRate = Dialog.getNumber();
orientationChoice = Dialog.getChoice();
redID = Dialog.getString();
greenID = Dialog.getString();
blueID = Dialog.getString();
//minValR = Dialog.getNumber();
//maxValR = Dialog.getNumber();
//minValG = Dialog.getNumber();
//maxValG = Dialog.getNumber();
//minValB = Dialog.getNumber();
//maxValB = Dialog.getNumber();
colorBlind = Dialog.getChoice();

setBatchMode(true);
automatR(openPath, files, title, rangeStart, rangeEnd, orientationChoice, savePath, interval, takeFirst, colorBlind);
//Function Call Above, Function Creation Below <----------------------
function automatR(openPath, files, title, rangeStart, rangeEnd, orientationChoice, savePath, interval, takeFirst, colorBlind)
{
	channelIDs = newArray(redID, greenID, blueID);
	if(colorBlind == "No")
	{
		channelColors = newArray("Red", "Green", "Blue");
		redChan = title + " - Red";
		greenChan = title + " - Green";
		blueChan = title + " - Blue";
	}
		if(colorBlind == "Yes")
	{
		channelColors = newArray("Magenta", "Cyan", "Yellow");
		redChan = title + " - Magenta";
		greenChan = title + " - Cyan";
		blueChan = title + " - Yellow";
	}
	
	channelNames = newArray(redChan, greenChan, blueChan);
	numChan = 0;
	
	for (i = 0; i < 3; i++)
	{
		if (lengthOf(channelIDs[i]) > 0)
		{
			onlyColor = channelColors[i];
			onlyChan = channelIDs[i];
			numChan++;
		}
	}
	if (numChan > 1)
	{
		for (i = 0; i < numChan; i++) //Allows this macro to expand to a huge number of comingled channels
		{
			numberOpened = 0;
			for (timePoint = 0; timePoint < (files.length); timePoint++) //Runs through input folder
			{
				if (indexOf(files[timePoint], channelIDs[i]) >= 0) //Effectively allows segregation of files by channel ID by indexing through channelIDs list by increment value of the first for loop
				{
					if (numberOpened > 0)
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						tempName = getTitle();

						clippR(tempName, rangeStart, rangeEnd, takeFirst);
						
						run("Concatenate...", "open image1 =  channelNames[i] + image2 = tempName");
						rename(channelNames[i]);
					}
					if (numberOpened == 0) //Opens first instance of a given channel by itself so as to avoid any errors from attempting to concatenate with only a single window open
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						rename(channelNames[i]);
						
						clippR(channelNames[i], rangeStart, rangeEnd, takeFirst);
						
						numberOpened++;
					}
				}
				if (files.length == (timePoint + 1))
				{
					run(channelColors[i]);
					saveAs("Tiff", savePath + channelNames[i]);
					close();
				}
			}
			if (i == (numChan - 1))
			{
				mergR(numChan, channelNames, title, savePath, orientationChoice, interval);
			}
		}
	}
	if (numChan == 1)
	{
		title = title + " - Processed";
		numberOpened = 0;
		for (timePoint = 0; timePoint < files.length; timePoint++)
		{
			if (indexOf(files[timePoint], onlyChan) >= 0)
			{
				if (numberOpened > 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					tempName = getTitle();

					clippR(tempName, rangeStart, rangeEnd, takeFirst);

					run("Concatenate...", "open image1 = title image2 = tempName");
					rename(title);
				}
				if (numberOpened == 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					rename(title);
					
					clippR(title, rangeStart, rangeEnd, takeFirst);

					numberOpened++;
				}
			}
			if (timePoint == (files.length - 1))
			{
				run(onlyColor);
				saveAs("Tif", savePath + title);
				rename(title);
				animatR(title, orientationChoice, savePath, interval, numChan);
			}
		}
	}
}
//-------------------------------
function clippR(imageTitle, rangeStart, rangeEnd, takeFirst)
{	
	selectWindow(imageTitle);
	if (rangeStart > 0 && rangeEnd > 0)
	{
		run("Slice Remover", "first=rangeStart last=rangeEnd increment=1");
	}
	if (rangeStart == 0 && rangeEnd > 0)
	{
		run("Slice Remover", "first=1 last=rangeEnd increment=1");
	}
	if (rangeStart > 0 && rangeEnd == 0)
	{
		run("Slice Remover", "first=rangeStart last=" + nSlices + " increment=1");
	}
	rename(imageTitle);
	
	projectR(imageTitle, savePath, numChan, takeFirst);
}
//-------------------------------
function projectR(imageTitle, savePath, numChan, takeFirst)
{
	selectWindow(imageTitle);
	if (takeFirst != "Yes")
	{
		run("Z Project...", "projection=[Max Intensity] all");
	}
	if (takeFirst == "Yes")
	{
		run("Z Project...", "start=[2] projection=[Max Intensity]");		
	}
	run("Despeckle");
	rename(imageTitle + " - MAX");
	selectWindow(imageTitle);
	close();
}
//-------------------------------
/*
function AdjustR(imageTitle)  <---- Eventually, user input dictates min and max values for a given channel or set of channels, rather than attempting auto brightness/contrast
{
	selectWindow(imageTitle);
	
	
	
	rename(imageTitle);
}
*/
//-------------------------------
function mergR(numChan, channelNames, title, savePath, orientationChoice, interval)
{
	for (i = 0; i < numChan; i++)
	{
		open(savePath + channelNames[i] + ".tif");
		rename("chan" + i);
	}
	if (numChan == 2)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 create");
	}
	if (numChan == 3)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 c3=chan3 create");
	}

	mergedName = title + " - Merged";
	rename(mergedName);
	
	animatR(mergedName, orientationChoice, savePath, interval, numChan);
}
//--------------------------------
function animatR(imageTitle, orientationChoice, savePath, interval, numChan)
{
	numTPs = nSlices/numChan;

	if (numChan > 1)
	{
		run("Make Composite");
	}
	if (orientationChoice == "Vertically")
	{
		run("Label...", "format=00:00 starting=0 interval=interval x=1300 y=20 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=frameRate");
	}
	if (orientationChoice == "Horizontally")
	{		
		run("Label...", "format=00:00 starting=0 interval=interval x=5 y=0 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=frameRate");
	}
	if (orientationChoice == "I'll Do This Later")
	{	
		run("Animation Options...", "speed=frameRate");
	}
	saveAs("avi", savePath + imageTitle); //Saves stack as an Avi, thus creating a movie where each image is a single frame
	close(); //Closes the stack
	Dialog.create("End Message"); 
	Dialog.addMessage("Done!"); 
	Dialog.show();
}
setBatchMode(false);
