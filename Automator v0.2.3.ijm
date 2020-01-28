// Written by Evan J. Kiely for the Gilbert-Ross Lab, Emory University, Winter 2019
// Licensed under the GNU General Public License v3.0

//Welcome to Automator: A Batch Processing Wizard for FIJI! v0.2.3

/* To Do:
 *  Eventually, add option for first image to be opened to user view such that they can provide macro input via action (essentially like an automated macro recorder)
 *  	Idea is that user would be able to do operations on a given image, the macro would pull those values, then apply them to a folder of interest
 *  Add user definable timestamping location; label/timestamp by ROI? (see roiManagerMacros, ROI Manager Stack Demo and RoiManagerSpeedTestmacros)
 *  User Input for Save as AVI
 *  	Compression? <- Weird Issue with Prompt to Save When Adding Frame Rate and Compression to saveAs Command
 */

//User Input Starts Here <----------------------

/*Below we define our variables for the dialog box we will be creating with placeholder
text that give the user an idea of what is expected in those fields/what those fields are for*/

title = "Project";
fontSize = 60;
zSlice = newArray("Yes", "No");
rangeStart = 0; rangeEnd = 0;
orientation = newArray("Horizontally", "I'll Do This Later", "Vertically");
orientationChoice = "";
interval = 1;
frameRate = 0;
redID = ""; greenID = ""; blueID = "";
//minValR = 0
//maxValR = 0
//minValG = 0
//maxValG = 0
//minValB = 0
//maxValB = 0
colorBlind = "";

//Here we create our user interface/info gathering dialog box

Dialog.create("Automator"); //Creates dialog box
Dialog.addMessage("Please Provide the Following Information, and Be Sure\n\nto Leave Blank/Zero Fields Blank/Zero if Not Required."); //Adds message text
Dialog.addString("Title:", title, 15); //Input for title, which later becomes file name
Dialog.addNumber("Max Project Starts at Frame:", 0, 0, 3, "");
Dialog.addNumber("Max Project Ends at Frame:", 0, 0, 3, "");
Dialog.addChoice("For Timestamping: Images are Oriented", orientation);
Dialog.addNumber("Time Between Acquisitions:", 1, 0, 3, "Minute(s)");
Dialog.addNumber("Frame Rate:", 0, 0, 3, "FPS");
Dialog.addString("Red Channel ID:", redID, 10);
//Dialog.setInsets(0, -150, 0)
//Dialog.addNumber("Min Brightness Red:", 0, 0, 3, "0");
//Dialog.addToSameRow();
//Dialog.addNumber("Max Brightness Red:", 0, 0, 3, "256");
Dialog.addString("Green Channel ID:", greenID, 10);
//Dialog.addNumber("Min Brightness Green:", 0, 0, 3, "0");
//Dialog.addToSameRow();
//Dialog.addNumber("Max Brightness Green:", 0, 0, 3, "256");
Dialog.addString("Blue Channel ID:", blueID, 10);
//Dialog.addNumber("Min Brightness Blue:", 0, 0, 3, "0");
//Dialog.addToSameRow();
//Dialog.addNumber("Max Brightness Blue:", 0, 0, 3, "256");
Dialog.setInsets(0, 250, 0)
Dialog.addCheckbox("Despeckle", false)
Dialog.setInsets(0, 250, 0)
Dialog.addCheckbox("High-Throughput", false)
Dialog.setInsets(0, 250, 0)
Dialog.addCheckbox("Save in a Different Location", false);
Dialog.addChoice("Activate Colorblind Accomodation:" zSlice);
Dialog.addMessage("(Green -> Cyan, Red -> Magenta, Blue -> Yellow)");
Dialog.show(); //This opens the dialog box we created

//Below gathers user input from above dialog box and reassigns the relevant variables such that they now carry those values

title = Dialog.getString();
rangeStart = Dialog.getNumber();
rangeEnd = Dialog.getNumber();
orientationChoice = Dialog.getChoice();
interval = Dialog.getNumber();
frameRate = Dialog.getNumber();
redID = Dialog.getString();
//minValR = Dialog.getNumber();
//maxValR = Dialog.getNumber();
greenID = Dialog.getString();
//minValG = Dialog.getNumber();
//maxValG = Dialog.getNumber();
blueID = Dialog.getString();
//minValB = Dialog.getNumber();
//maxValB = Dialog.getNumber();
despeckle = Dialog.getCheckbox();
highTP = Dialog.getCheckbox();
saveChoice = Dialog.getCheckbox();
colorBlind = Dialog.getChoice();

//minMax = newArray(minValR, maxValR, minValG, maxValG, minValB, maxValB);

Dialog.create("Welcome!"); 
Dialog.addMessage("To begin, please select your input directory."); 
Dialog.show();

openPath = getDirectory("Choose Source Directory"); //Allows user to select folder of interest and assigns it to variable "openPath"
files = getFileList(openPath)

if(files.length == 0)
{
	exit("Input directory must contain files.");
}

if(saveChoice == false)
{
	File.makeDirectory(openPath + "Processed - Automator");
	savePath = openPath + "Processed - Automator" + File.separator;
}
else if(saveChoice == true)
{
	Dialog.create("Save Path");
	Dialog.addMessage("Please select save location.");
	Dialog.show();
	
	savePath = getDirectory("Choose Save Location");
	File.makeDirectory(savePath + "Processed - Automator");
	savePath = savePath + "Processed - Automator" + File.separator;
}

setBatchMode(true);
automatR(openPath, files, title, rangeStart, rangeEnd, orientationChoice, savePath, interval, colorBlind, despeckle, frameRate);
setBatchMode(false);

//Function Call Above, Function Creation Below <----------------------

function automatR(openPath, files, title, rangeStart, rangeEnd, orientationChoice, savePath, interval, colorBlind, despeckle, frameRate)
{
	channelIDs = newArray(redID, greenID, blueID); //Creates an array with user input channel IDs
	if(highTP == false) //Checks for High-throughput
	{
		if(colorBlind == "No") //Checks for color blind and assigns appropriate colors
		{
			channelColors = newArray("Red", "Green", "Blue");
			redChan = title + " - Red";
			greenChan = title + " - Green";
			blueChan = title + " - Blue";
		}
		else if(colorBlind == "Yes")
		{
			channelColors = newArray("Magenta", "Cyan", "Yellow");
			redChan = title + " - Magenta";
			greenChan = title + " - Cyan";
			blueChan = title + " - Yellow";
		}
	}
	else if(highTP == true) //Sets all colors to gray because High-Throughput is meant for unrelated image sets that will not be merged
	{
		channelColors = newArray("Grays", "Grays", "Grays");
		redChan = title + " - " + redID;
		greenChan = title + " - " + greenID;
		blueChan = title + " - " + blueID;
	}
	
	channelNames = newArray(redChan, greenChan, blueChan); //Makes an array of unique names based on user specified colors
	numChan = 0; //Sets number of channels to 0 so it can be counted later
	
	for (i = 0; i < 3; i++) //Max 3 channels, so max 3 loops
	{
		if (lengthOf(channelIDs[i]) > 0) //Very simple way of figuring out how many channels by checking if there was text entered in the corresponding box
		{
			onlyColor = channelColors[i]; //Set up to set these variables to the last value in the set of up to 3 channels. If only one specified, they will end up carrying the related information
			onlyChan = channelIDs[i];
			numChan++;
		}
	}
	if (numChan == 0)
	{
		exit("Must provide at least 1 channel ID."); //Error if 0 channel IDs input
	}
	if (numChan > 1) //Checks for number of channels being more than one because there is a difference in what is required when processing 1 vs. multiple channels
	{
		for (i = 0; i < numChan; i++) //i is being checked against number of channels here, so everything inside the loop happens the same number of times as there are channels
		{
			numberOpened = 0;
			for (timePoint = 0; timePoint < (files.length); timePoint++) //Runs through input folder, checking timePoint against total number of files
			{
				if (indexOf(files[timePoint], channelIDs[i]) >= 0) //Effectively allows segregation of files by channel ID by indexing through channelIDs list by increment value of the first for loop (i.e. pulling in from the intitial channel tracking loop)
				{
					if (numberOpened == 0) //Opens first instance of a given channel by itself so as to avoid any errors from attempting to concatenate with only a single window open
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						numberOpened++;
						tempTitle = channelNames[i] + " - " + numberOpened; //Names the open window with something specific and known so we can opperate on it with certainty later
						rename(tempTitle);
						
						projectR(tempTitle, rangeStart, rangeEnd, despeckle); //Sends file to be max projected
					}
					else if (numberOpened > 0) //After the first instance has been processed, we can now move on to the remaining
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						numberOpened++;
						tempName = channelNames[i] + " - " + numberOpened; //Notice here how the name set up is similar but not the same variable
						rename(tempName);
						projectR(tempName, rangeStart, rangeEnd, despeckle); //Sends files to be max projected

						run("Concatenate...", "open image1 = tempTitle image2 = tempName"); //Concatenates our two open windows. This is where the naming convention becomes very important
						rename(tempTitle); //Newly concatenated file is renamed to reserved name from if statement above, preserving the unique ID that allows ordered concatenation to take place
					}
				}
				if (files.length == (timePoint + 1)) //If we've made it through all the files in the folder **for a given channel** (still in the initial for loop)
				{
					if (i == 0) //if this is the first channel, make a new folder to hold the results
					{
						File.makeDirectory(savePath + "Concatenated Max Projections");
						savePathCompleteMax = savePath + "Concatenated Max Projections" + File.separator;
					}
					run(channelColors[i]); //Sets the channel to the corresponding color
					saveAs("Tiff", savePathCompleteMax + channelNames[i]);  //<------- This must stay on. Macro requires these for later steps. Can be turned off in favor of using save in projectR & turning off concatenate above if memory resources are limited, but this will break the remaining functionality of the macro
					close();
				}
			}
			if (i == (numChan - 1)) //If we have done the above for every channel
			{
				if(highTP == false) //If High-Throughput is not on, send the various colors to be merged
				{
					mergR(numChan, channelNames, title, savePath, orientationChoice, interval, savePathCompleteMax, frameRate);
				}
				else if(highTP == true) //If High-Throughput is on, close everything and alert the user
				{
					run("Close All");
					Dialog.create("End Message"); 
					Dialog.addMessage("Done!"); 
					Dialog.show();
				}
			}
		}
	}
	if (numChan == 1) //If there is only a single channel (most of this is repeated from above so comments will be sparse here)
	{
		numberOpened = 0;
		for (timePoint = 0; timePoint < files.length; timePoint++)
		{
			if (indexOf(files[timePoint], onlyChan) >= 0)
			{
				if (numberOpened == 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					numberOpened++;
					tempTitle = title + " - " + onlyColor + " - " + numberOpened;
					rename(tempTitle);
					projectR(tempTitle, rangeStart, rangeEnd, despeckle);
				}
				else if (numberOpened > 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					numberOpened++;
					tempName = title + " - " + onlyColor + " - " + numberOpened; //Recall that onlyColor is determined earlier based on presence or abscense of text
					rename(tempName);
					projectR(tempName, rangeStart, rangeEnd, despeckle);
					run("Concatenate...", "open image1 = tempTitle image2 = tempName");
					rename(tempTitle);
				}
			}
			if (timePoint == (files.length - 1))
			{
				//run("Gray");
				//saveAs("Tif", savePath + title + " - Gray");
				run(onlyColor);
				saveAs("Tif", savePath + title);
				rename(title);
				
				if (interval > 0) //If user inputs a time between acquisitions of 0, the macro will not animate it
				{
					animatR(title, orientationChoice, savePath, interval, numChan, frameRate); //Sends the file to be animated
				}
				else if (interval == 0)
				{
					run("Close All");
					Dialog.create("End Message"); 
					Dialog.addMessage("Done!"); 
					Dialog.show();
				}
			}
		}
	}
}
//-------------------------------
function projectR(imageTitle, rangeStart, rangeEnd, despeckle) //Max projection function with input flexibility defined below
{	
	selectWindow(imageTitle);
	if (rangeStart == 0 && rangeEnd == 0)
	{
		run("Z Project...", "projection=[Max Intensity] all");
	}
	else if (rangeStart > 0 && rangeEnd > 0)
	{
		run("Z Project...", "projection=[Max Intensity] start=rangeStart stop=rangeEnd");
	}
	else if (rangeStart == 0 && rangeEnd > 0)
	{
		run("Z Project...", "projection=[Max Intensity] start=1 stop=rangeEnd");
	}
	else if (rangeStart > 0 && rangeEnd == 0)
	{
		run("Z Project...", "projection=[Max Intensity] start=rangeStart stop=" + nSlices);
	}
	
	if (despeckle == true)
	{
		run("Despeckle"); //Optional despeckle
	}
	
	rename(imageTitle + " - MAX");
	selectWindow(imageTitle);
	close();
	rename(imageTitle);

	/*File.makeDirectory(savePath + "Clipped & Projected");
	savePathClipped = savePath + "Clipped & Projected" + File.separator;
	saveAs("Tiff", savePathClipped + imageTitle); //<------------------- Uncomment here to save every timepoint after clipping & projecting (WORKS)
	rename(imageTitle);*/
}
//-------------------------------
/* <------------------------------------------------------- adjustR on hold for time being (Should work as is, but untested)
function adjustR(imageTitle, minMax, i)
{
	print(i);
	selectWindow(imageTitle);
	if (i == 0)
	{
		setMinAndMax(minMax[0], minMax[1]);
	}
	else if (i == 1)
	{
		setMinAndMax(minMax[2], minMax[3]);
	}
	else if (i == 2)
	{
		setMinAndMax(minMax[4], minMax[5]);
	}
	rename(imageTitle);
}
*/
//-------------------------------
function mergR(numChan, channelNames, title, savePath, orientationChoice, interval, savePathCompleteMax, frameRate)
{
	for (i = 0; i < numChan; i++) //Opens the seperate max projection stacks made earlier (1 per channel)
	{
		open(savePathCompleteMax + channelNames[i] + ".tif");
		rename("chan" + i);
	}
	if (numChan == 2) //This and below else if actually do the merging. Note the channels seemingly out of order. This is because FIJI orders the colors as GRB instead of RGB
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 create");
	}
	else if (numChan == 3)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 c3=chan3 create");
	}

	mergedName = title + " - Merged";
	rename(mergedName);

	saveAs("Tiff", savePath + mergedName); //<------------------- Comment here to turn off save merged max project of all timepoints concatenated

	if (interval > 0)
	{
		animatR(mergedName, orientationChoice, savePath, interval, numChan, frameRate); //Sends the file to be animated
	}
	if (interval == 0)
	{
		run("Close All");
		Dialog.create("End Message"); 
		Dialog.addMessage("Done!"); 
		Dialog.show();
	}
}
//--------------------------------
function animatR(imageTitle, orientationChoice, savePath, interval, numChan, frameRate)
{
	numTPs = nSlices/numChan; //Calculates number of timepoints; Even when merged FIJI calculates the number of slices as the product of number of channels and Z frames (i.e. 2 channels, 3 Zs = 6 slices)

	if (frameRate == 0) //Sets the framerate to 10 FPS by default
	{
		frameRate = 10;
	}
	if (numChan > 1)
	{
		run("Make Composite"); //Not sure if number of timepoints == nSlices after merge. Something to think about
	}
	if (orientationChoice == "Vertically") //x and y values are arbitrary holdovers from an earlier macro. Still have not figured out an efficient way of determining this (even as a user it is trial and error for me)
	{
		run("Label...", "format=00:00 starting=0 interval=interval x=1300 y=20 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=" + frameRate);
	}
	else if (orientationChoice == "Horizontally")
	{		
		run("Label...", "format=00:00 starting=0 interval=interval x=5 y=0 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=" + frameRate);
	}
	else if (orientationChoice == "I'll Do This Later")
	{	
		run("Animation Options...", "speed=" + frameRate);
	}
	saveAs("avi", savePath + imageTitle); //Saves stack as an Avi, thus creating a movie where each image is a single frame
	close(); //Closes the stack
	Dialog.create("End Message"); 
	Dialog.addMessage("Done!"); 
	Dialog.show();
}
