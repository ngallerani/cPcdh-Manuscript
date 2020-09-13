/*
QC Check
by Nick Gallerani
Updated 9/13/2020
This macro allows you to perform QC on the cell counts previously acquired using the particle analysis macro
This allows you to add or delete ROIs from the set
How to Use:
Hit run, follow dialog prompts, and use the ROI manager, add or delete cells manually as necessary
Auto counts don't actually have to exist-you can entirely manually count using this macro too
The macro will check for specific cell type "tags", ie "-tdT" or "-SST" as created in previous steps of this pipeline
Change the tag as necessary for different cell types
*/

run("Set Measurements...", "area mean standard modal min centroid center shape median redirect=None decimal=3");

//input folder should contain single channel tif images
input = getDirectory("Choose Image Directory");
list = getFileList(input);

//Rinput folder contains CSV files which are read by R
Rinput = input + "/Rinput/";
	check_folders = File.exists(Rinput);
if (check_folders !=1) {
		
		File.makeDirectory(Rinput);			
}

//polygonROIfiles contains any ZIP files of ROI sets, which can be read into imageJ by ROI manager
polygonROIfiles = input + "/polygonROIfiles/";
	check_folders = File.exists(polygonROIfiles);
if (check_folders !=1) {
		
		File.makeDirectory(polygonROIfiles);			
}
//THE FILE EXTENSION MUST BE MANUALLY CHANGED TO THE PROPER CHANNEL TAG
//ie tdT.tif if counting tdTomato cells
for (i=0; i<list.length; i++) { 
	if (endsWith(list[i], "-tdT.tif")) //this only opens images that have the correct channel tag
		{
			//this next block closes any open images, the ROI manager if it is open, and clears results
			if (isOpen("ROI Manager")) {
     		selectWindow("ROI Manager");
     		run("Close");
  				}
  				
			run("Close All");
			run("Clear Results");

open(input+list[i]);

imgName = getTitle();
baseNameEnd = indexOf(imgName, ".tif"); 
baseName = substring(imgName, 0, baseNameEnd);
//this has to manually be changed, need to update so that it is not hard coded
notag = indexOf(imgName, "-tdT.tif");
notagName = substring(imgName, 0, notag);
checkROIs = File.exists(polygonROIfiles + "ROI-SET_" + notagName + ".zip");
if (checkROIs !=1) {
		waitForUser("No analysis regions found, load regions manually");
}
else{
	roiManager("Open", polygonROIfiles + "ROI-SET_" + notagName + ".zip");
	roiManager("measure");
	Z1 = getValue("results.count");
	print(Z1);
	run("Clear Results");
	}

check_autoct = File.exists(polygonROIfiles + "AutoCt_" +baseName + ".zip");
if (check_autoct !=1) {
		waitForUser("No auto count file found-manually load file or proceed with manual counting");
}
else{
	roiManager("Open", polygonROIfiles + "AutoCt_" +baseName + ".zip");

	}

roiManager("Show All without labels");
proceed = getBoolean("Proceed with counting?");

if (proceed==1) {

setTool("point");

	roiManager("measure");
	Z2 = getValue("results.count");
	print(Z2);
	run("Clear Results");
waitForUser("Add cells to ROI manager within analysis ROI, then hit ok");

//delete the analysis regions now that cell addition is complete
//this array is created manually so is inflexible, figure out later how to specify an array of length 0:Z1
	roiManager("Select", newArray(0,1,2,3,4));
	roiManager("delete");

roiManager("measure");
Z3 = getValue("results.count");
	for (m=(Z2-Z1); m < Z3; m++){
			roiManager("Select", m);	
			X0 = getResult("X", m);
			Y0 = getResult("Y", m);
			run("Specify...", "width=15 height=15 x=&X0 y=&Y0 oval constrain centered scaled");
			roiManager("update");
			}
			run("Select None");
			
waitForUser("Confirm that all cells have been added properly");
run("Clear Results");
roiManager("measure");
saveAs("Measurements", Rinput + "HandCt_" + baseName +".csv");
		run("Clear Results");
roiManager("Save", polygonROIfiles + "HandCt_" + baseName + ".zip");




counted = input + "/analyzed_images/";
    check_folders = File.exists(counted);
		if(check_folders==0){
		File.makeDirectory(counted);}
		
File.rename(input+list[i], counted+list[i]);




}else{
	discard = input + "/discard/";
    check_folders = File.exists(discard);
		if(check_folders==0){
		File.makeDirectory(discard);}
		
File.rename(input+list[i], discard+list[i]); 
if(checkROIs==1){
	//the assumption is that if the zip files exist, the ROI csvs are already in Rinput folder-this code moves them to discard
File.rename(Rinput + "ROI_Ctx_" + notagName + ".csv", discard + "ROI_Ctx_" + notagName + ".csv"); 
File.rename(Rinput + "ROI_L2_" + notagName + ".csv", discard + "ROI_L2_" + notagName + ".csv");
File.rename(Rinput + "ROI_L5-L2_" + notagName + ".csv", discard + "ROI_L5-L2_" + notagName + ".csv"); 
File.rename(Rinput + "ROI_L6-L5_" + notagName + ".csv", discard + "ROI_L6-L5_" + notagName + ".csv"); 
File.rename(Rinput + "ROI_L6_" + notagName + ".csv", discard + "ROI_L6_" + notagName + ".csv");     
}



	}




		}
}	
	run("Close All");		
/*


//generate first binary image. this filters out everything below area=35um (measured in the binary transformation, not actual cell size)
//this redirects measurements to the original image
redirectname = "Org_" + imgName;
run("Set Measurements...", "area mean standard modal min centroid center shape median redirect=&redirectname decimal=3");

run("Analyze Particles...", "size=35-Infinity circularity=0-1 show=Masks display include add");
//need to create this folder first, don't save yet
//binaryimages = input + "/binary/";
//this is the original set of particles, ROI set and measurements to be saved in order to analyze this initial set of particles
//roiManager("Save", binaryimages + ");
selectWindow("ROI Manager");
run("Close");
rename("Above35um_"+ imgName);


//save these ROIs
//roiManager("Save", binaryimages + ");
rename("SizeFiltered_" + imgName);
selectWindow("ROI Manager");
	run("Close");
selectWindow("MinusLarge_" + imgName);
	run("Close");
selectWindow("SizeFiltered_" + imgName);

//FROM THIS POINT ON THE ROI MANAGER IS FOR COUNTED CELLS ONLY
//DO NOT INCLUDE "ADD" UNLESS YOU INTEND FOR THOSE CELLS TO BE A PART OF THE ROI SET

//get the first set of cells from the size filtered image
//this is just every particle from 35-75um in area
run("Analyze Particles...", "size=35-75 circularity=0.2-1.00 show=Masks display add include");

rename("cells_35_75");
imageCalculator("Subtract", "SizeFiltered_" + imgName, "cells_35_75");
selectWindow("cells_35_75");
run("Close");
selectWindow("SizeFiltered_" + imgName);
//run watershed after particles 35-75 have been removed to prevent oversegmentation of small particles
run("Watershed");
//note that the minimum size is slightly smaller after the watershed has been carried out
//we start to see potential doublets that could be separated around 110um so we set this as upper limit
run("Analyze Particles...", "size=35-110 circularity=0.2-1.00 show=Masks display add include");
rename("cells_30_110");

imageCalculator("Subtract", "SizeFiltered_" + imgName, "cells_30_110");
selectWindow("cells_30_110");
run("Close");
selectWindow("SizeFiltered_" + imgName);
//at this point many large particles remain-use "and" with outlines image to combine
imageCalculator("AND", "SizeFiltered_" + imgName, "Outlines_" + imgName);
selectWindow("SizeFiltered_" + imgName);
run("Analyze Particles...", "size=10-50 circularity=0.2-1.00 show=Masks display add include");
rename("cells_10_50");
imageCalculator("Subtract", "SizeFiltered_" + imgName, "cells_10_50");
selectWindow("cells_10_50");
run("Close");
selectWindow("Outlines_" + imgName);
run("Close");
selectWindow("SizeFiltered_"+imgName);
//pull out more circular cells
run("Analyze Particles...", "size=50-120 circularity=0.75-1.00 show=Masks display add include");
rename("cells_50_120");
imageCalculator("Subtract", "SizeFiltered_" + imgName, "cells_50_120");
selectWindow("cells_50_120");
run("Close");
selectWindow("SizeFiltered_"+imgName);
//run a dilation before the watershed step to circularize particles a little more
run("Fill Holes");
run("Options...", "iterations=2 count=4 do=Dilate"); //I think the black option is what is messing everything up
//have to invert after this step
//run("Invert");
run("Watershed");

run("Analyze Particles...", "size=25-500 circularity=0.2-1.00 show=Masks display add");
rename("cells_25_500");
imageCalculator("Subtract", "SizeFiltered_" + imgName, "cells_25_500");
selectWindow("cells_25_500");
run("Close");
selectWindow("SizeFiltered_"+imgName);
run("Close");
selectWindow("Org_"+imgName);
roiManager("Show All without labels");


/*
selectWindow("AND");
run("Analyze Particles...", "size=1000-Infinity show=Masks include");
rename("largetosubtract");
run("Invert");
imageCalculator("Subtract", "AND", "largetosubtract");
rename("CleanBin_" + imgName);
selectWindow("largetosubtract");
run("Close");
selectWindow("CleanBin_" + imgName);
run("Invert");
//

run("Analyze Particles...", "size=50-200 circularity=0.90-1.00 show=Masks display include add");
rename("counted");


//generate subtracted image

/*
setAutoThreshold("Default");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Invert"); //not sure why this has to be done. currently objects are given a value of 0 after initial binarization, so the values have to be inverted
run("Set Measurements...", "area mean standard modal min center median redirect=None decimal=3");
run("Analyze Particles...", "size=35-5000 show=Masks display include add");
//run("Convert to Mask");
/*
setAutoThreshold("Default");
run("Convert to Mask");

//generate outline image
DoG(imgName, 4, 2);
run("Find Edges");
global(imgName);
setAutoThreshold("Default");
setOption("BlackBackground", true);
run("Convert to Mask");
run("Invert");


run("Analyze Particles...", "size=15.00-1000.00 circularity=0.80-1.00 show=Masks display include add");

DAPI IMAGE BINARIZATION
//dapi-3,6
//generate cell image
selectWindow("Org_" + imgName);
run("Duplicate...", " ");
DoG(imgName, 3, 9);
global(imgName);

setAutoThreshold("Intermodes");
setOption("BlackBackground", false);
run("Convert to Mask");
run("Invert");
rename("AllParticles_"+imgName);




after subtracting the outlines from the cells:
run("Options...", "iterations=1 count=5 black do=[Fill Holes]");
run("Options...", "iterations=2 count=5 black do=Close");

this will generate the image to count from
only do this after extracting all high confidence single cells from the original cell image, and removing them from the cell image used in subtraction
*/