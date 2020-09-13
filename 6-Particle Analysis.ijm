/*
Particle Analysis
by Nick Gallerani
Updated 9/13/2020
This macro processes single channel immunofluorescent images of cells and automatically counts cells and saves cell ROIs and cell coordinate data
How to Use:
Hit run, a dialog box with different options for image processing pops up
Change options as necessary, select or deselect which steps to include
If you want to save images/process folders of images, select batch mode before running
To change default values, the code for the dialog box needs to be edited
*/
function DoG(img, sigma1, sigma2){
	imgName = getTitle();
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=&sigma2");
	rename("sigma2");
	selectWindow(imgName);
	run("Gaussian Blur...", "sigma=&sigma1");
	imageCalculator("Subtract", imgName,"sigma2");
		selectWindow("sigma2");
		run("Close");
	selectWindow(imgName);
	rename("DoG_s1_" + sigma1 + "_s2_" + sigma2 + "_" + imgName);
}

function threshold(img, method){
setAutoThreshold(method);
setOption("BlackBackground", false);
run("Convert to Mask");

}

		default1 = "Default";
		otsu = "Otsu";
  		choices = default1 + "," + otsu;
  		choice = split(choices, ",");

Dialog.create("Preprocessing and Thresholding");
Dialog.addMessage("Enter Parameters for Preprocessing and Thresholding");

Dialog.addCheckbox("Difference of Gaussians", true); Dialog.addToSameRow(); Dialog.addNumber("sigma1: ", 5); Dialog.addToSameRow(); Dialog.addNumber("sigma2: ", 10);
Dialog.addCheckbox("Local Contrast Adjustment", true); Dialog.addToSameRow(); Dialog.addNumber("Block Size: ", 500); Dialog.addToSameRow(); Dialog.addNumber("Slope: ", 2);
Dialog.addCheckbox("Gamma Adjustment", true); Dialog.addToSameRow(); Dialog.addNumber("Gamma: ", 0.7); 
Dialog.addCheckbox("Threshold", true); Dialog.addToSameRow(); Dialog.addChoice("_", choice, choice[0]);
Dialog.addCheckbox("Watershed and Count", true) ;
Dialog.addNumber("Min Size = ", 80); Dialog.addToSameRow(); Dialog.addNumber("Max Size = ",500); Dialog.addToSameRow(); Dialog.addNumber("Min Circularity = ", 0.5);
Dialog.addCheckbox("Batch Mode", false); Dialog.addToSameRow(); Dialog.addString("Extension: ", "tdT.tif");
Dialog.addMessage("For batch mode enter the proper extension, ie 'tdT.tif' if you are trying to process tdTomato tif images");
Dialog.show();

applyDoG = Dialog.getCheckbox(); sig1 = Dialog.getNumber(); sig2 = Dialog.getNumber();
applyCLAHE = Dialog.getCheckbox(); CLAHE1 = Dialog.getNumber(); CLAHE2 = Dialog.getNumber();
applyGamma = Dialog.getCheckbox(); GammaValue = Dialog.getNumber();
applyThreshold = Dialog.getCheckbox(); methodchoice = Dialog.getChoice();
applyShed = Dialog.getCheckbox(); mincell = Dialog.getNumber(); maxcell = Dialog.getNumber(); mincirc = Dialog.getNumber();
batchmode = Dialog.getCheckbox(); filetypes = Dialog.getString();

if(batchmode==0){
	
currImg=getTitle();

if(applyDoG==1){
DoG(currImg, sig1, sig2);}
rename(currImg);
if(applyCLAHE == 1){
run("Enhance Local Contrast (CLAHE)", "blocksize=&CLAHE1 histogram=256 maximum=&CLAHE2 mask=*None* fast_(less_accurate)");}
if(applyGamma ==1){
	run("Gamma...", "value=&GammaValue");
}
if(applyThreshold == 1){
threshold(currImg, methodchoice);
run("Invert");}
if(applyShed==1){
	subtract(currImg, 500, 5000, 0, 1);
	subtract(currImg, 0, 50, 0, 0.25);
	run("Watershed");
	run("Analyze Particles...", "size=&mincell-&maxcell circularity=&mincirc-1.00 show=Nothing display add");

}
}

if(batchmode==1){
input = getDirectory("Choose Image Directory");
list = getFileList(input);

for (i=0; i<list.length; i++) { 
	if (endsWith(list[i], filetypes)) //this only opens images that have the correct channel tag
		{
			//this next block closes any open images, the ROI manager if it is open, and clears results
			if (isOpen("ROI Manager")) {
     		selectWindow("ROI Manager");
     		run("Close");
  				}
  				
			run("Close All");
			run("Clear Results");

open(input+list[i]);


	
currImg=getTitle();
baseNameEnd = indexOf(currImg, ".tif"); 
baseName = substring(currImg, 0, baseNameEnd);

if(applyDoG==1){
DoG(currImg, sig1, sig2);}
rename(currImg);
if(applyCLAHE == 1){
run("Enhance Local Contrast (CLAHE)", "blocksize=&CLAHE1 histogram=256 maximum=&CLAHE2 mask=*None* fast_(less_accurate)");}
if(applyGamma ==1){
	run("Gamma...", "value=&GammaValue");
}

if(applyThreshold == 1){
threshold(currImg, methodchoice);
run("Invert");
binaryimages = input + "/binaryimages/";
check_folders = File.exists(binaryimages);
		if(check_folders==0){
		File.makeDirectory(binaryimages);}
saveAs("tif", binaryimages + "Binary1_" + baseName + ".tif");
rename(currImg);
}
if(applyShed==1){
	subtract(currImg, 500, 5000, 0, 1);
	subtract(currImg, 0, 50, 0, 0.25);
	run("Watershed");
	run("Analyze Particles...", "size=&mincell-&maxcell circularity=&mincirc-1.00 show=Nothing display add");
}

//SAVE PARTICLES AS CSV AND ROI
polygonROIfiles = input + "/polygonROIfiles/";
	check_folders = File.exists(polygonROIfiles);
if (check_folders !=1) {
		
		File.makeDirectory(polygonROIfiles);			
}
roiManager("Save", polygonROIfiles + "AutoCt_" + baseName + ".zip");

Rinput = input + "/Rinput/";
	check_folders = File.exists(Rinput);
if (check_folders !=1) {
		
		File.makeDirectory(Rinput);			
}
run("Close All");
run("Clear Results");
open(input+list[i]);
run("Set Measurements...", "area mean standard modal min centroid center perimeter shape integrated median redirect=None decimal=5");
roiManager("measure");
saveAs("Measurements", Rinput + "AutoCt_" + baseName +".csv");
/*
counted = input + "/analyzed_images/";
    check_folders = File.exists(counted);
		if(check_folders==0){
		File.makeDirectory(counted);}
		
File.rename(input+list[i], counted+list[i]);
this is commented out because the images should only be moved after QC check

*/
if (isOpen("ROI Manager")) {
     		selectWindow("ROI Manager");
     		run("Close");
  				}
  				
			run("Close All");
			run("Clear Results");

}
		}
}



//use this for initial size filtering-all particles of any circularity counted
//these are not added to the counts
//i changed it so it also filters out very low circularity stuff
function sizefilt(img,a,b){
	run("Analyze Particles...", "size=&a-&b circularity=0.3-1 show=Masks include");
	rename("sizefiltered");
}

function countsubtract(img, a, b, c, d){
run("Analyze Particles...", "size=&a-&b circularity=&c-&d show=Masks display include add");
	rename("counts");
	imageCalculator("Subtract", img, "counts");
		selectWindow("counts");
		run("Close");
}

function subtract(img, a, b, c, d){
run("Analyze Particles...", "size=&a-&b circularity=&c-&d show=Masks include");
	rename("trash");
	imageCalculator("Subtract", img, "trash");
		selectWindow("trash");
		run("Close");
}
//this performs watershed on particles large enough to likely be 2 or more cells
//max circ is 0.8, there shouldnt be any touching particles with higher circularity-if there are watershed would probably not be able to separate anyways
//a=min area to perform watershed on-should be ~2x size of largest single cell
//b=max size, not strictly necessary but can help filter out large bright spots
//c=min area of cells after watershed
//d=max area of cells after watershed
//c/d have high circ threshold so this range can be pretty big
//this also subtracts counted particles from the master binary image (sizefiltered image)
function shedmask(img, a, b,c,d){
run("Analyze Particles...", "size=&a-&b circularity=0-0.8 show=Masks include");
	rename("shedded");
	run("Watershed");
	run("Analyze Particles...", "size=&c-&d circularity=0.75-1 show=Masks include display add");
	rename("counted");
	imageCalculator("Subtract", "sizefiltered", "counted");
	selectWindow("counted");
	run("Close");
	selectWindow("shedded");
	run("Close");
	selectWindow(img);
	
}
