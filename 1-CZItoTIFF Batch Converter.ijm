//BioFormats Importer Macro
//by Nick Gallerani 
//Last Updated: 9.13.2020
//Use this macro to convert a folder of CZIs to TIF

//Select the directory that contains the images
in = getDirectory("Select input directory"); 
out  = in + "/TIFF/";
File.makeDirectory(out);
setBatchMode(true);
list  = getFileList(in);


for (j=0; j<list.length; j++) {
	//change ".nd2" to ".czi" for CZI files
    if (endsWith(list[j], ".czi")){
    file = in + list[j];
    print(j + ": " + in+list[j]); 
 	run("Bio-Formats Importer", "open=file color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");

    run("16-bit");
    imgname = getTitle();
    
    //Change the naming format as you see fit
    saveAs("Tiff", out+list[j]);
    run("Close");
    run("Close All");
}
}