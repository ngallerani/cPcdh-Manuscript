/*
ROI Annotation Macro
by Nick Gallerani
Updated 9/13/2020
This macro allows you to annotate images, and saves those annotations in file formats suitable for analysis in R
How to Use:
Hit run, navigate to folder with single channel images
Images should have been processed with "Split Channel" macro-there should be images that end in "-DAPI"
Follow dialog box instructions-draw a polygonal ROI first and add it to ROI manager, then hit OK in dialog box, which will ask you to draw lines. Draw line ROIs for layers and add, making sure that they are in order, starting from L6B
*/

input = getDirectory("Choose Image Directory");
	list = getFileList(input);
Rinput = input + "/Rinput/";
	check_folders = File.exists(Rinput);
if (check_folders !=1) {
		
		File.makeDirectory(Rinput);			
}

polygonROIfiles = input + "/polygonROIfiles/";
	check_folders = File.exists(polygonROIfiles);
if (check_folders !=1) {
		
		File.makeDirectory(polygonROIfiles);			
}

for (i=0; i<list.length; i++) { 
	run("Close All");
	run("Clear Results");
	if (isOpen("ROI Manager")) {
    selectWindow("ROI Manager");
    run("Close");}	
    print("\\Clear");
if (endsWith(list[i], "DAPI.tif")){ 		    		
open(input+list[i]);
	origName = getTitle(); 
	extIndex = indexOf(origName, "-DAPI.tif"); 
	ID = substring(origName, 0, extIndex);
	print(ID);
	rename(ID);

setTool("polygon");
roiManager("show all");
run("Enhance Contrast", "saturated=0.35");
waitForUser("Add VisCtx polygon to ROI manager");

setTool("polyline");
waitForUser("Add lines at each laminar border to ROI manager starting from L6 bottom to L2/3 top");

waitForUser("Double check that lines are in correct order (should have 6 ROIs in manager total)");

selectWindow(ID);


Null = "Select Region";
  ROI1 = "VisCtx"; ROI2 = "L6B";
  ROI3 = "L5B"; ROI4 = "L4B";
  ROI5 = "L2B"; ROI6 = "L2T";
  ROI7 = "SLM"; ROI8 = "CA3";
  ROI9 = "CA2"; ROI10="DG";
  choices = ROI1 + "," + ROI2 + "," + ROI3 + "," + ROI4 + "," + ROI5 + "," + ROI6 + "," + ROI7 + "," + ROI8 + ","  + ROI9 + "," + ROI10 + ","+ Null;
  choice = split(choices, ",");
  Dialog.create("Create ROIs");
  Dialog.addMessage("Image Name");
  Dialog.addString("", ID, 30);
  Dialog.addMessage("Name ROIs (in order added to manager)");
  
  Dialog.addCheckbox("ROI 1", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[0]);
  Dialog.addCheckbox("ROI 2", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[1]);
  Dialog.addCheckbox("ROI 3", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[2]);
  Dialog.addCheckbox("ROI 4", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[3]);
  Dialog.addCheckbox("ROI 5", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[4]);
  Dialog.addCheckbox("ROI 6", true); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[5]);
  Dialog.addCheckbox("ROI 7", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[6]);
  Dialog.addCheckbox("ROI 8", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[7]);
	Dialog.addCheckbox("ROI 9", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[8]);
Dialog.addCheckbox("ROI 10", false); Dialog.addToSameRow(); Dialog.addChoice("", choice, choice[9]);

  Dialog.addMessage("Check this box if layers cannot be drawn");
  Dialog.addCheckbox("Remove From Dataset?", false);
  
  
  Dialog.show();

  imgD = Dialog.getString();
  ROI1 = Dialog.getChoice(); ROI2 = Dialog.getChoice(); 
  ROI3 = Dialog.getChoice(); ROI4 = Dialog.getChoice();
  ROI5 = Dialog.getChoice(); ROI6 = Dialog.getChoice(); 
  ROI7 = Dialog.getChoice(); ROI8 = Dialog.getChoice();
  ROI9 = Dialog.getChoice(); ROI10 = Dialog.getChoice();
  
  makeROI1 = Dialog.getCheckbox(); makeROI2 = Dialog.getCheckbox();
  makeROI3 = Dialog.getCheckbox(); makeROI4 = Dialog.getCheckbox();
  makeROI5 = Dialog.getCheckbox(); makeROI6 = Dialog.getCheckbox();
  makeROI7 = Dialog.getCheckbox(); makeROI8 = Dialog.getCheckbox();
  makeROI9 = Dialog.getCheckbox(); makeROI10 = Dialog.getCheckbox();
  Discard = Dialog.getCheckbox();
  
remove=0;
if(Discard == 1){
discard = input + "/discard/";
    check_folders = File.exists(discard);
		if(check_folders==0){
		File.makeDirectory(discard);}
		
File.rename(input+list[i], discard+list[i]); 
remove = 1;
};
if (remove ==0){
img =  imgD;
rename(img);


	
output = input;
		
 	ROIs = newArray(ROI1, ROI2, ROI3, ROI4, ROI5, ROI6, ROI7, ROI8, ROI9,ROI10);
 	numROIs = (makeROI1 + makeROI2 + makeROI3 + makeROI4 + makeROI5 + makeROI6 +makeROI7 + makeROI8 + makeROI9 + makeROI10);
	Names = Array.trim(ROIs, numROIs);
    print("Region Names: "); 
    Array.print(Names);
    print("Number of Regions: " + numROIs);

nROIs = roiManager("count");


    
if(nROIs==numROIs){
for (b = 0; b<numROIs; b++) {
	roiManager("Select", b);
			roiManager("Rename", Names[b]);
			poly= "ROI_" + Names[b] + "_" + img + ".csv";
			run("Properties... ", "list");
			saveAs("Results", Rinput + poly);
				selectWindow(poly);
				run("Close");				
}
polyset = "ROI-SET_" + img + ".zip";
roiManager("save", polygonROIfiles + polyset);
counted = input + "/analyzed_images/";
    check_folders = File.exists(counted);
		if(check_folders==0){
		File.makeDirectory(counted);}
		
File.rename(input+list[i], counted+list[i]);
}else{
	error = input + "/errors/";
    check_folders = File.exists(error);
		if(check_folders==0){
		File.makeDirectory(error);}
		File.rename(input+list[i], error+list[i]);
	}
 
}
}

}
run("Close All");
