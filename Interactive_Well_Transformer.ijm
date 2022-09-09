// MIT License
// 
// Copyright (c) 2022 Hani N Alsafadi

// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this Macro and associated documentation files (the "Macro"), to deal
// in the Macro without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Macro, and to permit persons to whom the Macro is
// furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Macro.

// THE MACRO IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// MACRO.
//
// Macro written by: Hani N Alsafadi.

#@File (label="Select directory that contains your images", style="directory") dir1
#@String (label="Image file type (.tif, .jpg, .png)", value=".tif", persist=false) imageType
#@Boolean(label="Do you have more than one image set to rotate:", value=true, persist=false) grouping
#@Boolean(label="Skip Well Rotation:", value=false, persist=false) skipRotation

#@Boolean(label="Crop image to fit well:", value=true, persist=false) inner_crop
#@String (label="Directory name for cropped full wells: \n\n leave blank if you do not need to crop", value="cropped_well", persist=false) outdir1

#@Boolean(label="Crop square for figure preparation:", value=true, persist=false) square_crop
#@String (label="Directory name for  cropped squares: \n\n leave blank if you do not need to crop", value="cropped_box", persist=false) outdir2

/////////////////////////////////////////////////////////////////////////////////////////////////////
// Functions
// Find the Reference Angle in the reference image for each group ***********************************
function findReferenceAngle(ID) { 
// function description
setBatchMode(true);
run("Duplicate...", "title=temp.tif");
run("8-bit");
run("Enhance Contrast", "saturation=0.35");
run("Auto Threshold", "method=Default white");
centerX=(getWidth()/2);
centerY=(getHeight()/2);
doWand(centerX, centerY, 14.0, "Legacy");
run("Fit Circle");
getSelectionBounds(x, y, width, height);
close();
setBatchMode(false);
selectImage(ID);
transformX=centerX-(x+(width/2));
transformY=centerX-(y+(height/2));
run("Translate...", "x="+transformX+" y="+transformY+" interpolation=None");
// CODE BELOW is used to set the reference point first.
makePoint(centerX, centerY, "small yellow");
roiManager("Add");
setTool("point");
title = "Select Reference Point";
msg = "Select a reference point in the image \n\n Make sure it is fairly far from the center. \n\n Click Ok once you are done.";
waitForUser(title, msg);
//selectImage(ID);  //make sure we still have the same image
roiManager("Add");
roiManager("Select", 0);
getSelectionBounds(x1, y1, w1, h1);
roiManager("Select", 1);
getSelectionBounds(x2, y2, w2, h2);
mainAngle = atan2(y2 - y1, x2 - x1) * 180 / PI;
print("Reference angle="+mainAngle);
roiManager("Deselect");
roiManager("Delete");
} 

// crop image ***********************************************************************************
function cropImage(imageId){
selectImage(imageId);
makeOval((getWidth()/2)-(inner_diameter/2), (getHeight()/2)-(inner_diameter/2), inner_diameter, inner_diameter);
run("Clear Outside");
run("Crop");
}
//set well size based on the first image *********************************************************
function setWellSize(imageId){
selectImage(imageId);
makeOval((getWidth()/2)-(inner_diameter/2), (getHeight()/2)-(inner_diameter/2), inner_diameter, inner_diameter);
waitForUser("Confirm Size of Well", "Resize Circle to fit well. \n Click OK when done.");
getSelectionBounds(xn, yn, wn, hn);
inner_diameter=wn;
run("Clear Outside");
run("Crop");
}

// rotateImage ***********************************************************************************
function rotateImage(fileName){
open(dir1+ File.separator +fileName);	
ID = getImageID();
setBatchMode(true);
run("Duplicate...", "title=temp.tif");
//run("Find Edges");
run("8-bit");
run("Enhance Contrast", "saturation=0.35");
run("Auto Threshold", "method=Default white");
//run("Fit Circle to Image", "threshold=50");
centerX=(getWidth()/2);
centerY=(getHeight()/2);
doWand(centerX, centerY, 14.0, "Legacy");
run("Fit Circle");
getSelectionBounds(x, y, width, height);
close();
setBatchMode(false);
selectImage(ID);
transformX=centerX-(x+(width/2));
transformY=centerX-(y+(height/2));
run("Translate...", "x="+transformX+" y="+transformY+" interpolation=None");
makePoint(centerX, centerY, "small yellow");
roiManager("Add");
setTool("point");
title = "Select Reference Point";
msg = "Click on the same reference point in the image \n It must be the same point you selected in the first image";
waitForUser(title, msg);
//selectImage(ID);  //make sure we still have the same image
setBatchMode(true);
roiManager("Add");
roiManager("Select", 0);
getSelectionBounds(x1, y1, w1, h1);
roiManager("Select", 1);
getSelectionBounds(x2, y2, w2, h2);
newAngle = atan2(y2 - y1, x2 - x1) * 180 / PI;

rot=mainAngle-newAngle;
run("Rotate... ", "angle="+rot+" grid=1 interpolation=Bilinear");

roiManager("Deselect");
roiManager("Delete");

}
// Function to return unique items in an array. *****************************************
function unique(array) {
	array 	= Array.sort(array);
	array 	= Array.concat(array, 999999);
	uniqueA = newArray();
	i = 0;	
   	while (i<(array.length)-1) {
		if (array[i] == array[(i)+1]) {
			//print("found: "+array[i]);			
		} else {
			uniqueA = Array.concat(uniqueA, array[i]);
		}
   		i++;
   	}
	return uniqueA;
}

function listParts(len){
	sequence	=	Array.getSequence(len+1);
	result		=	Array.slice(sequence, 1);
	return 	result;
}     
      
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////          
// Code Starts Running Here.
                          
list1 = getFileList(dir1);
list = Array.filter(list1, imageType);

var delimiter="_";
var gPart=1;

if (grouping==true){
	testname=list[1];
	// create a dialog to show the user their file name to show the delimiter.
		Dialog.create("Grouping ...");
		Dialog.addMessage("Example of your image file names:");
		Dialog.addMessage(testname, 18, "red");
		Dialog.addString("Please indicate the name delimiter", "_");
		Dialog.show();
		delimiter=Dialog.getString();
	
	// create the next dialog for user to select which part of the name to use for grouping.
		parts=split(testname, delimiter);
		Dialog.create("Grouping ...");
		Dialog.addMessage("Example of your image file names:");
		Dialog.addMessage(testname, 18, "red");
		Dialog.addMessage("Your name is split into these parts:");
		for (i=0; i<parts.length;i++){
			Dialog.addMessage((i+1)+". "+parts[i], 18, "green");
		}
		Dialog.addMessage("Which part is used for grouping", 18, "blue");
		p = listParts(parts.length);
		Dialog.addChoice("Group by:", p);
		Dialog.show();
			
		
	gPart=Dialog.getChoice();
		
	groups = newArray(0);
	for(i=0; i<list.length; i++){
	nameParts=split(list[i], delimiter);
	groups = Array.concat(groups,nameParts[gPart-1]);
	}
	
	groups = unique(groups);

// Show a message to the user displaying their groups
	groupsMSG = String.join(groups, "\n\n");
	Dialog.create("Available Groups");
	Dialog.addMessage("Here are the identified groups in your data:");
	Dialog.addMessage(groupsMSG, 16, "red");
	Dialog.addMessage("Cancel and Restart if this isn't what you desire.");
	Dialog.show();
} else {
groups= newArray(1);
groups[0]="All_Images";
}

var mainAngle = 0;
var inner_diameter=50;
var sqaure_side=Math.round(inner_diameter / 2.5);;

for(g=0; g<groups.length; g++){
		///*********************************************************
		// Generate a list of file names that belong to the indexed group in order to select a reference image.
			
		if (groups.length>1) {
			f="";
			if (gPart==1){
				f=groups[g]+delimiter;
				}else {
					if (gPart==nameParts.length) {
					f=delimiter+groups[g];
					} else {
					f=delimiter+groups[g]+delimiter;
					}
				}
			
			glist=Array.filter(list,f);
			
		} else {
			glist = list;
		}
		
		setBatchMode(false);
		if (!skipRotation | inner_crop==1) {
		Dialog.create("Reference Image");
		Dialog.addMessage("Select an appropriate reference image \n\n (Earliest timepoint recommended):", 16, "black");
		
		Dialog.addChoice("Image:", glist);
		
		Dialog.show();
		refImage  = Dialog.getChoice();
		open(dir1+ File.separator +refImage);
		mainAngle = 0;
		inner_diameter=Math.round((getWidth() * 0.75));		
		ID=getImageID();
		}
		
		if(!skipRotation){
			findReferenceAngle(ID);
			Dialog.create("Status Information:");
			Dialog.addMessage("Reference point for group: "+ groups[g]+" is defined.", 18, "green");
			Dialog.addMessage("Reference angle: "+mainAngle+" degrees", 16, "black");
			Dialog.show();
		}

		// Set Circle Cropping Parameters
		
		if (inner_crop==1) {
			ID = getImageID();
			if(g==0){
				Dialog.create("Status Information:");
				Dialog.addMessage("Click Ok to set the well size and crop image.", 18, "red");
				Dialog.show();
				setWellSize(ID);
			}
			cropImage(ID);
			
			basename=refImage.substring(0, refImage.length() - 4);
			File.makeDirectory(dir1+ File.separator +outdir1);
			saveAs("Tiff", dir1+ File.separator +outdir1+"/"+basename+"_cropped.tif");
			run("Close All");
			Dialog.create("Status Information:");
			Dialog.addMessage("Reference Image cropped and saved to subfolder: "+outdir1, 18, "green");
			Dialog.addMessage("Selected diameter in pixels: "+inner_diameter, 18, "green");
			Dialog.addMessage("Starting to process all images of group: "+ groups[g], 18, "red");
			Dialog.show();
		}
		
		// Perfrom actions for alll the images of the group
		
		for (i=0; i<glist.length; i++) {
			showProgress(i+1, glist.length);
			// INSERT MACRO HERE
			if (glist[i]!=refImage){
				if(!skipRotation){
					open(dir1+ File.separator +glist[i]);
					rotateImage(glist[i]);
				}		
			setBatchMode(true);
				if (inner_crop==1) {
					ID=getImageID();
					cropImage(ID);
					basename=glist[i].substring(0, glist[i].length() - 4);
					File.makeDirectory(dir1+ File.separator +outdir1);
					saveAs("Tiff", dir1+ File.separator + outdir1+"/"+basename+"_cropped.tif");
				}
			}
		}
		run("Close All");
		
		Dialog.create("Status Information:");
		Dialog.addMessage("All images have been rotated to the selected reference point for group: "+ groups[g], 25, "red");
		Dialog.show();
		
		if (square_crop==1) {
			setBatchMode(false);
				Dialog.create("Reference Image");
				Dialog.addMessage("Select an appropriate reference image to use for setting box cropping", 16, "black");
				Dialog.addChoice("Image:", glist);
				Dialog.show();
				inChoice  = Dialog.getChoice();
				open(dir1+ File.separator +outdir1+"/"+inChoice.substring(0, inChoice.length() - 4)+"_cropped.tif");
				sqaure_side=Math.round(inner_diameter / 2.5);
			makeRectangle(getWidth()/2, getHeight()/2, sqaure_side, sqaure_side);
			waitForUser("Set Cropping bounds and location", "Change size and location of square to crop image then click ok.");
			getSelectionBounds(xx, yy, ww, hh);
			sqaure_side=ww;
			Dialog.create("Square Crop Side");
			Dialog.addMessage("Size of the cropping square: "+sqaure_side+" pixels", 16, "green");
			Dialog.show();
			close();
			File.makeDirectory(dir1+ File.separator +outdir2);
			
			newList = getFileList(dir1+ File.separator +outdir1+"/");
			if (groups.length>1) {
				newGroupList = Array.filter(newList, f);
			} else{
				newGroupList = newList;
			}
							
			setBatchMode(true);
			for (i=0; i<newGroupList.length; i++) {
				if (newGroupList[i].contains(".tif")) {
					open(dir1+ File.separator +outdir1+"/"+newGroupList[i]);
					makeRectangle(xx, yy, sqaure_side, sqaure_side);
					run("Crop");
					basename=newGroupList[i].substring(0, newGroupList[i].length() - 11);
					saveAs("Tiff", dir1+ File.separator +outdir2+"/"+basename+"_square.tif");
					run("Close All");
				}
			}
				
				Dialog.create("Status Information:");
				Dialog.addMessage("Image processing Complete for group : "+ groups[g]+"\n\n Click Ok to process the next group or finish the analysis.", 25, "red");
				Dialog.show();
		}
		///*********************************************************				
}
