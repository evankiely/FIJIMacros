# FIJIMacros
**Macros for FIJI in the FIJI Macro Language**

This is an assortment of macros I have written to help automate processing of 5 dimensional (i.e. XYZ, time, & color) image data sets generated on various microscopes. As these were originally written for my lab, an acknowledgement and citation would be appreciated if used in the course of research culminating in a publication, or if modified to serve such a purpose.

## Macros on Tap

   - **Automator v0.2.3**: A batch processing wizard with a focus on rapid, high-throughput screening of large 5D data sets. Enables reduction in dimensionality of the data set, providing faster turnaround times and facilitating accelerated and targeted review within volumetric visualization software (such as Imaris), while requiring minimal system resources and user involvement to deploy effectively.
 
     - **Function**: Creates maximum intensity projections from a specified range of Zs, despeckles upon request, concatenates max projections temporally, merges disparate channels, and animates the results over time.
 
     - **Input**: A folder full of any assortment of image files, so long as the files of interest contain a single channel and are named in such a way that they can be identified uniquely. For example, an input folder may contain images from 5 different experiments, so long as the channel ID provided is unique to your files of interest. If all experiments call the green channel "CHN00," the macro will use all of them, regardless of experiment of origin, assuming that is the ID provided by the user. Conversely, if the green channel for experiment 1 was "EX1-CHN00," while the green channel for experiment 2 was "EX2-CHN00," the macro would have no problem differentiating, so long as the provided ID included the experimental label as well. This also opens the door to direct experimental comparison; by providing "EX1-CHN00" as the ID for the green channel, while providing "EX2-CHN00" as the ID for the red channel, the user will receive equivalent results in different colors. If there are no other channels present in the folder, this can also be done with "EX1" and "EX2" only. A user may provide up to three, or as few as one, channel IDs. At this time, Automator is not equipped to subsample a specific time range, so the provided input must be representative of your range of interest. Adding this functionality is under consideration.
   
     - **Output**: Each channel as single stack of max projections (i.e. two channels = two stacks), a merge of those (already max projected) channels, and an (optionally timestamped) AVI of those stacks merged. There are additional output options indicated within the macro itself, but they need to be uncommented to be turned on (done this way to streamline UI/UX).
   
     - **Special Features**: Output can be toggled to be color blind friendly (on by default), such that Red -> Magenta, Green -> Cyan, and Blue -> Yellow. If desired, creates a new folder in the input directory to hold processed images/results. Leaving Frame Rate as 0 now defaults to 10 FPS. Z project range is flexible such that leaving the start and end as 0 projects all Zs, start > 0 but end == 0 projects from specified start frame to the last frame in the stack, and the opposite is true of start == 0 but end > 0. The macro interprets a blank channel ID as absence of that channel in your image set, and selecting High-Thoughput creates only concatenated Zs for each channel ID in gray. The idea with High-Throughput is to allow you to process up to three different and unrelated image sets at the same time, so long as all user input values (i.e. Z project range, etc.) are applicable to all images, without the macro spending the time to create a useless merge and AVI. Essentially, selecting it decreases flexibility and nuance in exchange for efficiency, taking each channel ID and producing a concatenated Z stack of max projections for each in gray, and nothing else. If you want to opt out of the AVI, set "Time Between Acquisitions" to 0.
   
     - **Known Issues**: If there is a network error during file transfer, as when operating on data not stored locally (i.e. piped from a NAS, etc.), FIJI will notify you, but the macro will continue to run. This can lead to some weird results. For example, when operating on Z stacks, the macro will max project the Zs it has available to it at that time, leading to frames with omissions in one and/or both channels. At this time, the only solution for this is to ensure a strong connection that will not be interrupted, only use data stored locally, or deploy FIJI and this macro on the networked device containing the data (as in cloud compute).
   
     - **Real World Test/Use Case**: Process 3.21 TB of data, comprised of 4,020 files

       - **Workstation Specifications**:
         - Operating System: Windows 10 x64
         - CPU: x2 Intel Xeon E5-2667 v4 @ 3.2GHz
         - GPU: NVIDIA Quadro M6000 24 GB
         - RAM: 512 GB
         
       - **Results**:
         - Max CPU Load: 20.0% (<1 second while merging)
         - Average CPU Load Range: 6 - 8%
         - Max RAM Occupied: 49.1 GB (~1.5% initial size of data)
         - Total Elapsed Time: 3 Hours and 35 Minutes (~1 TB/hr)
         - Note: GPU Omitted Intentionally, as FIJI is CPU Optimized

## Resources For Learning More About The FIJI Macro Language
 - [Documentation](https://imagej.net/ij/docs/index.html)
 - [Official Introduction](https://imagej.net/Introduction)
 - [FIJI Scripting Tutorial](https://services.ini.uzh.ch/~acardona/fiji-tutorial/)
 - [Built-in Macro Functions](https://imagej.net/ij/developer/macro/functions.html)
 - [Miscellaneous Resources from the University of Latvia](http://priede.bf.lu.lv/ftp/pub/TIS/atteelu_analiize/ImageJ/apraksti/)
 - [Integrated Cellular Imaging Core @ Emory University (YouTube Channel)](https://www.youtube.com/channel/UCRVa5DSphB5gHMaFKPgyKSQ)
