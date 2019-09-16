//Welcome to Automator: A Batch Processing Wizard for FIJI! v0.2.2

/* To Do:
 *  Update to assume intent if field left blank and/or throw error if missing value(s) are critical
 *  Eventually, add option for first image to be opened to user view such that they can provide macro input via action (essentially like an automated macro recorder)
 *  	Idea is that user would be able to do operations on a given image, the macro would pull those values, then apply them to a folder of interest
 *  Add descriptions of function - comment everything as necessary
 *  Add user definable timestamping location; label/timestamp by ROI? (see roiManagerMacros, ROI Manager Stack Demo and RoiManagerSpeedTestmacros)
 *  User Input for Save as AVI
 *  	Compression? <- Weird Issue with Prompt to Save When Adding Frame Rate and Compression to saveAs Command
 *  	Verify that Frame Rate Changes by Input Value
 *  UI/UX issues with Min/Max color values & save anywhere... Commented out code is cluttering
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
automatR(openPath, files, title, rangeStart, rangeEnd, orientationChoice, savePath, interval, colorBlind, despeckle);
setBatchMode(false);

//Function Call Above, Function Creation Below <----------------------

function automatR(openPath, files, title, rangeStart, rangeEnd, orientationChoice, savePath, interval, colorBlind, despeckle)
{
	channelIDs = newArray(redID, greenID, blueID);
	if(colorBlind == "No")
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
	if (numChan == 0)
	{
		exit("Must provide at least 1 channel ID.");
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
					if (numberOpened == 0) //Opens first instance of a given channel by itself so as to avoid any errors from attempting to concatenate with only a single window open
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						rename(channelNames[i]);
						
						projectR(channelNames[i], rangeStart, rangeEnd, despeckle);

						numberOpened++;	
					}
					else if (numberOpened > 0)
					{
						open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
						tempName = getTitle();

						projectR(tempName, rangeStart, rangeEnd, despeckle);

						run("Concatenate...", "open image1 = channelNames[i] image2 = tempName");
						rename(channelNames[i]);
					}
				}
				if (files.length == (timePoint + 1))
				{
					if (i == 0)
					{
						File.makeDirectory(savePath + "Concatenated Max Projections");
						savePathCompleteMax = savePath + "Concatenated Max Projections" + File.separator;
					}
					run(channelColors[i]);
					saveAs("Tiff", savePathCompleteMax + channelNames[i]);
					close();
				}
			}
			if (i == (numChan - 1))
			{
				mergR(numChan, channelNames, title, savePath, orientationChoice, interval, savePathCompleteMax);
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
				if (numberOpened == 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					rename(title);
					
					projectR(title, rangeStart, rangeEnd, despeckle);

					numberOpened++;
				}
				else if (numberOpened > 0)
				{
					open(openPath + files[timePoint]); //Opens the folder at location timePoint (i.e. number in the list relative to other items in the folder)
					tempName = getTitle();

					projectR(tempName, rangeStart, rangeEnd, despeckle);

					run("Concatenate...", "open image1 = title image2 = tempName");
					rename(title);
				}
			}
			if (timePoint == (files.length - 1))
			{
				//run("Gray");
				//saveAs("Tif", savePath + title + " - Gray");
				run(onlyColor);
				saveAs("Tif", savePath + title);
				rename(title);
				if (interval > 0)
				{
					animatR(title, orientationChoice, savePath, interval, numChan);
				}
			}
		}
	}
}
//-------------------------------
function projectR(imageTitle, rangeStart, rangeEnd, despeckle)
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
		run("Z Project...", "projection=[Max Intensity] start=rangeStart stop=nSlices");
	}
	
	if (despeckle == true)
	{
		run("Despeckle");
	}
	
	rename(imageTitle + " - MAX");
	selectWindow(imageTitle);
	close();
	rename(imageTitle);

	/*File.makeDirectory(savePath + "Clipped");
	savePathClipped = savePath + "Clipped" + File.separator;
	saveAs("Tiff", savePathClipped + imageTitle + timePoint); //<------------------- Uncomment here to save every timepoint after clipping (issue with naming convention)
	rename(imageTitle);*/
}
//-------------------------------
/* <------------------------------------------------------- adjustR on hold for time being
function adjustR(imageTitle, minMax, i)
{
	print(i);
	selectWindow(imageTitle);
	if (i == 0)
	{
		setMinAndMax(minMax[0], minMax[1]);
		print(minMax[0] + " - " + minMax[1]);
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
function mergR(numChan, channelNames, title, savePath, orientationChoice, interval, savePathCompleteMax)
{
	for (i = 0; i < numChan; i++)
	{
		open(savePathCompleteMax + channelNames[i] + ".tif");
		rename("chan" + i);
	}
	if (numChan == 2)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 create");
	}
	else if (numChan == 3)
	{	
		run("Merge Channels...", "c1=chan1 c2=chan0 c3=chan3 create");
	}

	mergedName = title + " - Merged";
	rename(mergedName);

	//saveAs("Tiff", savePath + mergedName); //<------------------- Uncomment here to save merged max project of all timepoints concatenated (WORKS)

	if (interval > 0)
	{
		animatR(mergedName, orientationChoice, savePath, interval, numChan);
	}
	if (interval == 0)
	{
		run("Close All")
		Dialog.create("End Message"); 
		Dialog.addMessage("Done!"); 
		Dialog.show();
	}
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
	else if (orientationChoice == "Horizontally")
	{		
		run("Label...", "format=00:00 starting=0 interval=interval x=5 y=0 font=60 text=Hours:Minutes range=1-numTPs"); //Generates timestamp
		run("Animation Options...", "speed=frameRate");
	}
	else if (orientationChoice == "I'll Do This Later")
	{	
		run("Animation Options...", "speed=frameRate");
	}
	saveAs("avi", savePath + imageTitle); //Saves stack as an Avi, thus creating a movie where each image is a single frame
	close(); //Closes the stack
	Dialog.create("End Message"); 
	Dialog.addMessage("Done!"); 
	Dialog.show();
}
