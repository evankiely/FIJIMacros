# FIJIMacros
Macros for FIJI in the FIJI Macro Language

This is an assortment of macros I have written to help automate processing of 5 dimensional (i.e. XYZ, time, & color) image data sets generated on various microscopes. They are typically limited to a small set of functions, defined more clearly in the code itself. 

The macros on tap today are:
 - AutomatR v0.1: A very early attempt at a wizard of sorts for the particular kind of processing my lab encounters daily.
   - Can: Skim first Z, Remove Specified range of Zs, Merge disparate channels based on user provided channel ID, Create a hyperstack of resulting images, and Create a max projection from the hyperstack.
   - Output: A concatenated stack of each channel as Z stacks over time (saved as a TIF), A hyperstack of all channels overtime as Z stacks (saved as a TIF), A max projection of the aforementioned hyperstack (saved as a TIF), and A timestamped AVI of resulting stack of projections
 - SkimmR for PBNAS: Remove the first Z from a stack via max project, assign channel, repeat for the next color, merge, save as .tif
 
 And our special is a lovely Chilean Sea Bass.
