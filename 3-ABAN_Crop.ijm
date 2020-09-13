/*
Image Crop Macro
by Nick Gallerani
Updated 9/13/2020
This macro allows the user to define ROIs from an image, typically a large stitched tiled image, and automatically create and save labeled images of those ROIs
How To Use:
Run the macro, select the input folder. This folder should only contain multichannel TIF images
The first image in the folder will be opened.
Don't press OK on the dialog box that opens until the next part has been completed
Create a polygonal selection (the tool is automatically selected) around the desired ROI
Add to ROI manager (default key is "T")
Create up to 8 ROIs, then hit OK
A new dialog box opens.
Assign the image an Allen Brain Atlas Number (https://mouse.brain-map.org/experiment/thumbnails/100042147?image_type=atlas)
Check that the number of ROIs matches the number of checked boxes
Select names of ROIs from dropdown menu (can change default names by changing dialog box section of code)
Hit ok and image crops will be created and saved, and the next image is automatically opened until no more images remain
Original images get moved into a different folder once processed, so that if you want to resume processing a folder you can return to it without loading previously processed images
If there are no ROIs to be made from an image, just check the box, that image gets removed from the dataset
*/


input = getDirectory("Choose Image Directory");
	list = getFileList(input);

output = input + "/ROI Crops/";
check_folders = File.exists(output);
		if(check_folders==0){
		File.makeDirectory(output);
		print("Output Folder Created");}
		
//after an image is processed it gets moved into this folder. this allows you to continue processing from where you left off should the program crash
origfull = output + "/orig_fullimages/";
		check_folders = File.exists(origfull);
		if(check_folders==0){
		File.makeDirectory(origfull);}

	
for (i=0; i<list.length; i++) { 
	run("Close All");
	run("Clear Results");
	if (isOpen("ROI Manager")) {
    selectWindow("ROI Manager");
    run("Close");}	
    print("\\Clear");
if (endsWith(list[i], ".tif")){ 		    		
open(input+list[i]);
	origName = getTitle(); 
	extIndex = indexOf(origName, ".tif"); 
	ID = substring(origName, 0, extIndex);
	print(ID);
	rename(ID);


//if ROI set does not exist mouse=ID
mouse=ID;

FImgROIset = "FROIset_" + mouse + ".zip";
checkFROI = File.exists(input + FImgROIset);
//If ROI set already exists, load ROI set and crop
if (checkFROI == 1){
	if (isOpen("ROI Manager")) {
     		selectWindow("ROI Manager");
     		run("Close");}
	roiManager("open", input + FImgROIset);	
	CropImage = 1;
	roiManager("measure");
	numROIs = nResults;
	run("Clear Results");

Dialog.create("Enter Info");
  Dialog.addMessage("Image Name");
  Dialog.addString("", ID, 30);
  Dialog.addMessage("Allen Brain Atlas Number (1-21)");
  Dialog.addNumber("ABAN: ", 14);
	Dialog.show();
imgD = Dialog.getString();	
ABAN = Dialog.getNumber();
img =  imgD + "_" + "AB" + ABAN;
print("ABAN: " + ABAN);
rename(img);	
Rejected=0;
}else{
setTool("polygon");
roiManager("show all");
Stack.setChannel(3);
run("Enhance Contrast", "saturated=0.35");
waitForUser("Add ROIs to ROI Manager (make polygons clockwise)");

selectWindow(ID);
//DIALOG BOX OPTIONS

Null = "Select Region";
  ROI1 = "VisCtx"; ROI2 = "HPC";
  ROI3 = "SSCtx"; ROI4 = "MotCtx";
  ROI5 = "Str"; ROI6 = "GlP";
  ROI7 = "Thal"; ROI8 = "ACom";
  ROI9 = ""; ROI10="";
  choices = ROI1 + "," + ROI2 + "," + ROI3 + "," + ROI4 + "," + ROI5 + "," + ROI6 + "," + ROI7 + "," + ROI8 + "," + Null;
  choice = split(choices, ",");
  Dialog.create("Create ROIs");
  Dialog.addMessage("Image Name");
  Dialog.addString("", ID, 30);
  Dialog.addMessage("Allen Brain Atlas Number (1-21)");
  Dialog.addNumber("ABAN: ", 14);
  Dialog.addMessage("Name ROIs (in order added to manager)");
  Dialog.addCheckbox("ROI 1", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[0]);
  Dialog.addCheckbox("ROI 2", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[1]);
  Dialog.addCheckbox("ROI 3", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[2]);
  Dialog.addCheckbox("ROI 4", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[3]);
  Dialog.addCheckbox("ROI 5", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[4]);
  Dialog.addCheckbox("ROI 6", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[8]);
  Dialog.addCheckbox("ROI 7", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[8]);
  Dialog.addCheckbox("ROI 8", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[8]);
Dialog.addMessage("Check this box if no ROIs can be created");
Dialog.addCheckbox("No ROIs", false);
  Dialog.show();

  imgD = Dialog.getString();
  ABAN = Dialog.getNumber();
  ROI1 = Dialog.getChoice(); ROI2 = Dialog.getChoice(); 
  ROI3 = Dialog.getChoice(); ROI4 = Dialog.getChoice();
  ROI5 = Dialog.getChoice(); ROI6 = Dialog.getChoice(); 
  ROI7 = Dialog.getChoice(); ROI8 = Dialog.getChoice();
  
  makeROI1 = Dialog.getCheckbox(); makeROI2 = Dialog.getCheckbox();
  makeROI3 = Dialog.getCheckbox(); makeROI4 = Dialog.getCheckbox();
  makeROI5 = Dialog.getCheckbox(); makeROI6 = Dialog.getCheckbox();
  makeROI7 = Dialog.getCheckbox(); makeROI8 = Dialog.getCheckbox();
  Rejected = Dialog.getCheckbox(); 
  CropImage = 1;

  //END OF DIALOG BOX
  
print("ABAN: " + ABAN);
if (Rejected == 1) {
  	output = input + "/rejects/";
    check_folders = File.exists(output);
		if(check_folders==0){
		File.makeDirectory(output);
		print("Rejects Folder Created");}
	CropImage=0;
	File.rename(input+list[i], output+list[i]); 
	output = input + "/ROI Crops/"; //this resets the output folder to the original
}
if (Rejected == 0) {

img =  imgD + "_" + "AB" + ABAN;
rename(img);	
	
 	ROIs = newArray(ROI1, ROI2, ROI3, ROI4, ROI5, ROI6, ROI7, ROI8);
 	numROIs = (makeROI1 + makeROI2 + makeROI3 + makeROI4 + makeROI5 + makeROI6 +makeROI7 + makeROI8);
	Names = Array.trim(ROIs, numROIs);
    print("Region Names: "); 
    Array.print(Names);
    print("Number of Regions: " + numROIs);

for (b = 0; b<numROIs; b++) {
	roiManager("Select", b);
			roiManager("Rename", Names[b]);	
			
}
roiManager("save", input + FImgROIset);

for (a = 0; a<numROIs; a++){
	roiManager("Select", a);
		Name=getInfo("roi.name");
	run("Duplicate...", "duplicate");
		cropname = Name + "_" + img;
	rename(cropname);
		poly= "PolyC_" +  Name + "_" + mouse;
	croppath = output + "/" + Name + "/";
	check_folders = File.exists(croppath);
		if(check_folders==0){
		File.makeDirectory(croppath);}
	saveAs("tif", croppath + cropname);
	if (isOpen("ROI Manager")==1) {
		selectWindow("ROI Manager");
		run("Close");	
			}
	run("Restore Selection");
	roiManager("add");
	roiManager("select", 0);
	roiManager("Rename", Name);
	roiManager("save", croppath + poly + ".zip")
	selectWindow("ROI Manager");
	run("Close");	
	roiManager("open", input + FImgROIset);	


selectWindow(img);					
}
}
}
}
if (Rejected==0){
open(input+list[i]);
File.rename(input+list[i], origfull+list[i]); 
}
run("Close All");
	run("Clear Results");
	if (isOpen("ROI Manager")) {
    selectWindow("ROI Manager");
    run("Close");}	

}