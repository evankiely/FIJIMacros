# FIJIMacros
Macros for FIJI in the FIJI Macro Language

This is an assortment of macros I have written to help automate processing of 5 dimensional (i.e. XYZ, time, & color) image data sets generated on various microscopes. They are typically limited to a small set of functions, defined more clearly in the code itself. 

The macros on tap today are:
 - AutomatR v0.1: A very early attempt at a wizard for the particular kind of processing my lab encounters daily.
   - Can: Remove Specified range of Zs, Skim first Z via max projection, Concatenate max projections over time based on user provided channel ID, and Merge disparate channels.
   - Output: Each channel stacked over time as max projections (i.e. two channels = two stacks) and a timestamped AVI of those stacks merged.
   
 - SkimmR:
    - Function: Remove the first Z from a stack via max projection, Assign channel, Repeat for the next color, Merge channels
    - Output: A series of merged max projections saved as TIFs. (one per time point; can be concatenated with minimal effort by going File -> Import -> Image Sequence and selecting the output folder).
 
 And our special is a lovely Chilean Sea Bass.
