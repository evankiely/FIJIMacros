# FIJIMacros
**Macros for FIJI in the FIJI Macro Language**

This is an assortment of macros I have written to help automate processing of 5 dimensional (i.e. XYZ, time, & color) image data sets generated on various microscopes. They are typically limited to a small set of functions, defined more clearly in the code itself. As these were originally written for my lab, an acknowledgement and citation would be appreciated if used in the course of research culminating in a publication, or if modified to serve such a purpose.

**The macros on tap today are**:

 - **Automator v0.2.2**: A batch processing wizard for large 5D data sets, with a focus on rapid screening. Enables reduction in dimensionality of the data set, thus providing much faster turnaround times and facilitating targeted review within volumetric visualization software (such as Imaris), while requiring minimal system resources and user involvement to deploy effectively.
 
    - **Function**: Creates max projections from a specified range of Zs, despeckles upon request, concatenates max projections temporally, merges disparate channels, and animates the results over time.
 
   - **Input**: A folder full of any assortment of image files, so long as the files of interest contain a single channel and are named in such a way that they can be identified uniquely. For example, an input folder may contain images from 5 different experiments, so long as the channel ID provided is unique to your files of interest. If all experiments call the green channel "CHN00," the macro will use all of them, regardless of experiment of origin, assuming that is the ID provided by the user. Conversely, if the green channel for experiment 1 was "EX1-CHN00," while the green channel for experiment 2 was "EX2-CHN00," the macro would have no problem differentiating, so long as the provided ID included the experimental label as well. This also opens the door to direct experimental comparison; by providing "EX1-CHN00" as the ID for the green channel, while providing "EX2-CHN00" as the ID for the red channel, the user will receive equivalent results in different colors. If there are no other channels present in the folder, this can also be done with "EX1" and "EX2" only. A user may provide up to three, or as few as one, channel IDs. At this time, Automator is not equiped to subsample a specific time range, so the provided input must be representative of your range of interest. Adding this functionality is under consideration.
   
   - **Output**: Each channel as single stack of max projections (i.e. two channels = two stacks) and an (optionally timestamped) AVI of those stacks merged. There are additional output options indicated within the macro itself, they just need to be uncommented to be turned on (done this way to streamline UI/UX and because it is unlikely that a user would want to save at those points).
   
   - **Special Features**: Output can be toggled to be color blind friendly (on by default), such that Red -> Magenta, Green -> Cyan, and Blue -> Yellow. If desired, creates a new folder in the input directory to hold processed images/results. Leaving Frame Rate as 0 now defaults to 10 FPS. Z project range is flexible such that leaving the start and end as 0 projects all Zs, start > 0 but end == 0 projects from specified start frame to the last frame in the stack, and the opposite is true of start == 0 but end > 0. Additionally, the macro interprets a blank channel ID as absence of that channel in your image set.
   
   - **Known Issues**: If there is a network error during file transfer when operating on data not stored locally (i.e. piped from a NAS, etc.), FIJI will notify you, but the macro will continue to run. This can lead to some weird results. For example, when operating on Z stacks, the macro will max project the Zs it has available to it at that time, leading to frames with omissions in one or both channels. At this time, the only solution for this is to ensure a strong connection that will not be interupted, only use data stored locally, or deploy FIJI and this macro on the networked device containing the data (as in cloud compute).

And our special is a lovely Chilean Sea Bass.

**Resources For Learning More About The FIJI Macro Language**:
 - [Documentation](https://imagej.net/ij/docs/index.html)
 - [Official Introduction](https://imagej.net/Introduction)
 - [FIJI Scripting Tutorial](https://services.ini.uzh.ch/~acardona/fiji-tutorial/)
 - [Built-in Macro Functions](https://imagej.net/ij/developer/macro/functions.html)
 - [Miscellaneous Resources from the University of Latvia](http://priede.bf.lu.lv/ftp/pub/TIS/atteelu_analiize/ImageJ/apraksti/)
 - [Integrated Cellular Imaging Core @ Emory University (YouTube Channel)](https://www.youtube.com/channel/UCRVa5DSphB5gHMaFKPgyKSQ)
