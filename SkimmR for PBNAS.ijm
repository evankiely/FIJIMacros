//SkimmR: Skim the Top Slice Off of a Batch of Z-Stacks by Max Projecting Everything Below

openPath = getDirectory("Choose Source Directory");
files = getFileList(openPath);
savePath = getDirectory("Choose Destination Directory");
count = 1;

setBatchMode(true); //Allows the below to be performed behind the scenes.
for (i = 0; i < (files.length); i=i+2) //Increments through files by two since there are two channels present and accounted for below
{
	tempName = files[i];

	if (indexOf(tempName, "CHN00") >= 0) //Verifies we are operating on the appropriate channel first
	{
		tempNameGreen = files[i] + " - Green";
		open(openPath + files[i]); //Opens the file at index i
		rename(tempNameGreen);

		selectWindow(tempNameGreen);
		run("Green"); //Sets channel to green
		rename(tempNameGreen);

		selectWindow(tempNameGreen);
		run("Z Project...", "start=[2] projection=[Max Intensity]"); //Creates a maximum intensity projection from remaining Z frames
		rename(tempNameGreen + " - Max");
		close(tempNameGreen);
		rename(tempNameGreen);
		
//---------- For comments on below, see above

		tempNameRed = files[i+1] + " - Red";
		open(openPath + files[i+1]);
		rename(tempNameRed);

		selectWindow(tempNameRed);
		run("Red");
		rename(tempNameRed);

		selectWindow(tempNameRed);
		run("Z Project...", "start=[2] projection=[Max Intensity]");
		rename(tempNameRed + " - Max");
		close(tempNameRed);
		rename(tempNameRed);
//----------
		run("Merge Channels...", "c1=["+tempNameGreen+"] c2=["+tempNameRed+"] create"); //Merges two resulting max projections
		mergedName = "Merged " + count;
		rename(mergedName);
		saveAs("Tiff", savePath + mergedName); //Saves each resulting merged max projection separately. This is done to allow for use on systems/workstations with few available resources; expectation is that the next step is simply File -> Import -> Open Sequence to open as a stack
		run("Close All");

		count++;
	}
}
setBatchMode(false);
