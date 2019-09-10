//Welcome to AutomatR: A Batch Processing Wizard for FIJI! v0.1

/* To Do:
 *  Min and Max for Channel Values?
 *  Make User Input More Eficient in General; Figure Out How Much/Which User Provided Values can be Reused/Repurposed or Discarded
 *  	For Example: No Need for Number of Timepoints if the Provided Folder is Free of Misc. Files
 *  	(Channel IDs can Even be Employed to Count Specific Files) -- numTPs = len(files)/numChan
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
redID = ""; greenID = ""; blueID = "";
numTPs = 0; stackSize = 0;
interval = 1;
fontSize = 60;
zSlice = newArray("Yes", "No");
takeFirst = ""
zSliceChoice = "";
orientation = newArray("Horizontally", "I'll Do This Myself Later", "Vertically");
frameRate = 0;
orientationChoice = "";

//Here we create our user interface/info gathering dialog box

Dialog.create("AutomatR"); //Creates dialog box
Dialog.addMessage("Please provide the following information."); //Adds message text
Dialog.addMessage("Leave Channel ID Blank if Unused.");
Dialog.addString("Red Channel ID:", redID, 15);
Dialog.addString("Green Channel ID:", greenID, 15);
Dialog.addString("Blue Channel ID:", blueID, 15);
Dialog.addString("Title:", title, 15); //Input for title, which later becomes file name
Dialog.addNumber("Number of Time Points:", 2, 0, 15, "");
Dialog.addNumber("Z Frames per Timepoint:", 105, 0, 15, "");
Dialog.addNumber("Time Between Acquisitions (Minutes):", 1, 0, 15, "");
//Dialog.addNumber("Font Size for Timestamp:", 60, 0, 15, "");
Dialog.addChoice("I Would Like to Remove the First Frame of Every Z:", zSlice);
Dialog.addChoice("I Would Like to Clip My Z-Stack:", zSlice);
Dialog.addNumber("The Frame Rate for My Animation Should Be:", 7, 0, 15, "");
Dialog.addChoice("For Timestamping: My Images are Oriented", orientation);
Dialog.show(); //This opens the dialog box we created

//Below gathers user input from above dialog box and reassigns the relevant variables such that they now carry those values

redID = Dialog.getString();
greenID = Dialog.getString();
blueID = Dialog.getString();
title = Dialog.getString();
numTPs = Dialog.getNumber();
stackSize = Dialog.getNumber();
interval = Dialog.getNumber();
//fontSize = Dialog.getNumber();
zSliceChoice = Dialog.getChoice();
takeFirst = Dialog.getChoice();
frameRate = Dialog.getNumber();
orientationChoice = Dialog.getChoice();

rangeStart = 0; rangeEnd = 0;

if (zSliceChoice == "Yes")
{
	Dialog.create("Clipping Range");
	Dialog.addNumber("Start Range At Frame:", 61, 0, 15, "");
	Dialog.addNumber("End Range At Frame:", 105, 0, 15, "");
	Dialog.show();

	rangeStart = Dialog.getNumber();
	rangeEnd = Dialog.getNumber();
}

setBatchMode(true);
automatR(openPath, files, title, stackSize, zSliceChoice, rangeStart, rangeEnd, orientationChoice, savePath, numTPs, interval, takeFirst);
//Function Call Above, Function Creation Below <----------------------
function automatR(openPath, files, title, stackSize, zSliceChoice, rangeStart, rangeEnd, orientationChoice, savePath, numTPs, interval, takeFirst)
{
	numChan = 0;
	channelIDs = newArray(redID, greenID, blueID);
	for (j = 0; j < 3; j++)
	{
		if (lengthOf(channelIDs[j]) > 0)
		{
			numChan++;
		}
	}
	
	channelColors = newArray("Red", "Green", "Blue");
	
	redChan = title + " - Red";
	greenChan = title + " - Green";
	blueChan = title + " - Blue";
	
	channelNames = newArray(redChan, greenChan, blueChan);

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

						clippR(tempName, rangeStart, rangeEnd, takeFirst, zSliceChoice);
						
						run("Concatenate...", "open image1 =  channelNames[i] + image2 = tempName");
						rename(channelNames[i]);
					}
					if (numberOpened == 0) //Opens first instance of a given channel by itself so as to avoid any errors from attempting to concatenate with only a single window open
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						rename(channelNames[i]);
						
						clippR(channelNames[i], rangeStart, rangeEnd, takeFirst, zSliceChoice);
						
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
				 mergR(numChan, channelNames, title, stackSize, numTPs, savePath, orientationChoice, interval);
			}
		}
	}
	if (numChan == 1)
	{
		for (timePoint = 0; timePoint < files.length; timePoint++)
		{
			numberOpened = 0;
			if (indexOf(files[timePoint], channelIDs[0]) >= 0)
			{
				if (numberOpened > 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					tempName = getTitle();

					clippR(tempName, rangeStart, rangeEnd, takeFirst, zSliceChoice);

					run("Concatenate...", "open image1 = channelNames[0] image2 = tempName");
					rename(channelNames[0]);
				}
				if (numberOpened == 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					rename(channelNames[0]);
					
					clippR(channelNames[0], rangeStart, rangeEnd, takeFirst, zSliceChoice);

					numberOpened++;
				}
				if (timePoint == (files.length - 1))
				{
					run(colorCHN00[0]);
					imageTitle = "HyperStacked";
					saveAs("Tif", savePath + imageTitle);
					animatR(imageTitle + ".tif", orientationChoice, savePath, numTPs, interval, numChan);
				}
			}
		}
	}
}
//-------------------------------
function clippR(imageTitle, rangeStart, rangeEnd, takeFirst, zSliceChoice)
{	
	if (zSliceChoice == "Yes")
	{
		selectWindow(imageTitle);
		run("Slice Remover", "first=rangeStart last=rangeEnd increment=1");
		rename(imageTitle);
	}
	projectR(imageTitle, savePath, numChan, takeFirst);
}
//-------------------------------
function projectR(imageTitle, savePath, numChan, takeFirst)
{
	if (takeFirst != "Yes")
	{
		selectWindow(imageTitle);
		run("Z Project...", "projection=[Max Intensity] all");
		run("Despeckle");
		rename(imageTitle + " - MAX");
		selectWindow(imageTitle);
		close();
	}
	if (takeFirst == "Yes")
	{
		selectWindow(imageTitle);
		run("Z Project...", "start=[2] projection=[Max Intensity]");
		run("Despeckle");
		rename(imageTitle + " - MAX");
		selectWindow(imageTitle);
		close();
	}
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
function mergR(numChan, channelNames, title, stackSize, numTPs, savePath, orientationChoice, interval)
{
	for (i = 0; i < numChan; i++)
	{
		open(savePath + channelNames[i] + ".tif");
		rename("chan" + i);
	}
	if (numChan == 2)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 create");
		mergedName = title + " - Merged";
		rename(mergedName);
	}
	if (numChan == 3)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 c3=chan3 create");
		mergedName = title + " - Merged";
		rename(mergedName);
	}
	animatR(mergedName, orientationChoice, savePath, numTPs, interval, numChan);
}
//--------------------------------
function animatR(imageTitle, orientationChoice, savePath, numTPs, interval, numChan)
{
	if (numChan > 1)
	{
		run("Make Composite");
	}
	if (orientationChoice == "Vertically")
	{
		run("Label...", "format=00:00 starting=0 interval=interval x=1300 y=20 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=frameRate");
		saveAs("avi", savePath + imageTitle); //Saves stack as an Avi, thus creating a movie where each image is a single frame
		close(); //Closes the stack
		Dialog.create("End Message"); 
		Dialog.addMessage("Done!"); 
		Dialog.show();
	}
	if (orientationChoice == "Horizontally")
	{		
		run("Label...", "format=00:00 starting=0 interval=interval x=5 y=0 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=frameRate");
		saveAs("avi", savePath + imageTitle); //Saves stack as an Avi, thus creating a movie where each image is a single frame
		close(); //Closes the stack
		Dialog.create("End Message"); 
		Dialog.addMessage("Done!"); 
		Dialog.show();
	}
	if (orientationChoice == "I'll Do This Myself Later")
	{	
		run("Animation Options...", "speed=frameRate");
		saveAs("avi", savePath + imageTitle); //Saves stack as an Avi, thus creating a movie where each image is a single frame
		close(); //Closes the stack
		Dialog.create("End Message"); 
		Dialog.addMessage("Done!"); 
		Dialog.show();
	}
}
setBatchMode(false);
