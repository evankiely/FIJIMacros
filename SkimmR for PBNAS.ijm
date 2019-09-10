//SkimmR: Skim the Top Slice Off of a Batch of Z-Stacks

openPath = getDirectory("Choose Source Directory");
files = getFileList(openPath);
savePath = getDirectory("Choose Destination Directory");
count = 1;

setBatchMode(true);
for (i = 0; i < (files.length); i=i+2)
{
	tempName = files[i];

	if (indexOf(tempName, "CHN00") >= 0)
	{
		tempNameGreen = files[i] + " - Green";
		open(openPath + files[i]);
		rename(tempNameGreen);

		selectWindow(tempNameGreen);
		run("Slice Remover", "first=1 last=1 increment=1");
		rename(tempNameGreen);

		run("Green");
		rename(tempNameGreen);

		selectWindow(tempNameGreen);
		run("Z Project...", "projection=[Max Intensity] all");
		rename(tempNameGreen + " - Max");
		close(tempNameGreen);
		rename(tempNameGreen);
//----------
		tempNameRed = files[i+1] + " - Red";
		open(openPath + files[i+1]);
		rename(tempNameRed);

		selectWindow(tempNameRed);
		run("Slice Remover", "first=1 last=1 increment=1");
		rename(tempNameRed);

		run("Red");
		rename(tempNameRed);

		selectWindow(tempNameRed);
		run("Z Project...", "projection=[Max Intensity] all");
		rename(tempNameRed + " - Max");
		close(tempNameRed);
		rename(tempNameRed);
//----------
		run("Merge Channels...", "c1=["+tempNameGreen+"] c2=["+tempNameRed+"] create");
		mergedName = "Merged " + count;
		rename(mergedName);
		saveAs("Tiff", savePath + mergedName);
		run("Close All");

		count++;
	}
}
setBatchMode(false);