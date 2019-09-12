# FIJIMacros
Macros for FIJI in the FIJI Macro Language

This is an assortment of macros I have written to help automate processing of 5 dimensional (i.e. XYZ, time, & color) image data sets generated on various microscopes. They are typically limited to a small set of functions, defined more clearly in the code itself. As these were originally written for my lab, an acknowledgement and citation would be appreciated if used in the course of research culminating in a publication, or if modified to serve such a purpose.

The macros on tap today are:
 - AutomatR v0.2: A batch processing wizard for very large 5D data sets, with a focus on rapid screening. Enables reduction in dimensionality of the data set, thus providing much faster turnaround times and facilitating targeted review within volumetric visualization software (such as Imaris), while requiring minimal system resources and user involvement to deploy effectively. 
   - Function: Remove Specified range of Zs, Skim first Z via max projection, Despeckle, Concatenate max projections, and Merge disparate channels.
   - Output: Each channel as single stack of max projections (i.e. two channels = two stacks) and a timestamped AVI of those stacks merged.
   - Special Features: Output can be toggled to be color blind friendly (on by default), such that Red -> Magenta, Green -> Cyan, and Blue -> Yellow. Accepts any folder, including those with other items, so long as the provided channel ID is legitimately unique (thus, can also output to input folder without issue). Z stack clipping range is flexible such that leaving the start and end as 0 skips it entirely, start > 0 but end == 0 clips from specified start frame to the last frame in the stack, and the opposite is true of start == 0 but end > 0. Additionally, the macro interprets a blank channel ID as absence of that channel in your image set.
   
 - SkimmR:
    - Function: Remove the first Z from a stack via max projection, Assign channel, Repeat for the next color, Merge channels
    - Output: A series of merged max projections saved as TIFs. (one per time point; can be concatenated with minimal effort by going File -> Import -> Image Sequence and selecting the output folder).
 
 And our special is a lovely Chilean Sea Bass.
