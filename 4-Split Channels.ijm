//Split Channels
//by Nick Gallerani
//last updated 3.25.2020
//updated for ac2 sert images
//ch1=sst, ch2=sert, ch3=dapi



//This prompts you to pick the folder with your multi-channel images
input = getDirectory("Choose Input Directory ");

Split = input + "/singlechannelimages/"

check_folders = File.exists(Split);
		if(check_folders==0){
		File.makeDirectory(Split);
		print("Split Folder Created");}


list = getFileList(input);
setBatchMode(true);


for (i=0; i<list.length; i++) { 
	//the conditional "if" statement tells it to only open ".tif" images and ignore all others
     if (endsWith(list[i], ".tif")){ 
         print(i + ": " + input+list[i]); 
         open(input+list[i]); 
          //note-stack to hyperstack should be commented out if the image is already a hyperstack
        // run("Stack to Hyperstack...", "order=xyczt(default) channels=3 slices=1 frames=1 display=Grayscale");
         getDimensions(width, height, channels, slices, frames);
         nchan = channels;
         
         imgName=getTitle(); 
         baseNameEnd=indexOf(imgName, ".tif"); 
         baseName=substring(imgName, 0, baseNameEnd); 
       
         run("Split Channels");
         if (nchan == 4){ 
         selectWindow("C4-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-DAPI"); 
         close();
         selectWindow("C3-" + imgName); 
         //this enhances contrast and turns it into a B&W image
         //block out the next two lines of code if you do not want these edits
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         //this next line saves the image with the original filename plus "-DAPI" at the end
         //change "-DAPI" as necessary for your specific image
         saveAs("Tiff", Split +baseName + "-Cas3"); 
         close(); 
         selectWindow("C2-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-tdT"); 
         close(); 
         selectWindow("C1-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-SST"); 

         close(); 
         }
         if (nchan == 3){
         	selectWindow("C3-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
        
         saveAs("Tiff", Split +baseName + "-DAPI"); 
         close(); 
         selectWindow("C2-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-Cas3"); 
         close(); 
         selectWindow("C1-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-tdT"); 

         close(); 
         }

               if (nchan == 2){

         selectWindow("C2-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-DAPI"); 
         close(); 
         selectWindow("C1-" + imgName); 
         	run("Enhance Contrast", "saturated=0.35");
         	run("Grays");
         saveAs("Tiff", Split +baseName + "-tdT"); 

         close(); 
         }
         }
         }

         
        