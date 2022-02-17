run("Close All");
setOption("ExpandableArrays", true);
//setBatchMode(true);

setForegroundColor(0, 0, 255);
setBackgroundColor(0, 0, 255);

function findColonyPoint(bg) {
	if(bg=="dark") run("Find Maxima...", "noise=50 output=List exclude");
	else run("Find Maxima...", "noise=50 output=List exclude light");
	colonydims = newArray();
	fcX = newArray();
	fcY = newArray();
	for(ii=0;ii<nResults;ii++) {
		fcX[ii] = getResult("X",ii);
		fcY[ii] = getResult("Y",ii);
	}
	fcX = Array.sort(fcX);
	//fcX = Array.reverse(fcX);
	fcX = Array.trim(fcX,12);
	Array.getStatistics(fcX,min,max,mean,stdDev);
	fcXmean = fcX[6];
	fcY = Array.sort(fcY);
	//fcY = Array.reverse(fcY);
	fcY = Array.trim(fcY,12);
	Array.getStatistics(fcY,min,max,mean,stdDev);
	fcYmean = fcY[6];
	colonydims[0] = fcXmean;
	colonydims[1] = fcYmean;
	run("Clear Results");
	return colonydims;
}

r=85;
xmult=53.25;
ymult=51.3;

// List all files in a directory, then loop through them
workingdir = getDirectory("Choose a working directory");
sliceList = getFileList(workingdir);

pnum = 1;

for(i=1;i<=1;i++) {
	run("TIFF Virtual Stack...", "open=["+workingdir+sliceList[0]+"] sort");
	// run("Rotate 90 Degrees Right");
	// open(fulltreatmentpath+sliceList[70]);
	mainTitle = getTitle();
	selectWindow(mainTitle);
	setSlice(nSlices);

	treatmentname = "";

	Dialog.create("Enter experiment name");
		Dialog.addString("Experiment: ",treatmentname);
		Dialog.addNumber("Plate: ",pnum);
	Dialog.show();
	treatmentname = Dialog.getString();
	pnum = Dialog.getNumber();

	if(i==1) {
		makeRectangle(2542, 3162, 1696, 2616);
		// makeRectangle(2528,3144,1696,2616);
		// fc = findColonyPoint("light");
		// makeRectangle(fc[0]-(r*0.9), fc[1]-(r*0.9), 1710, 2630);
	} else {
		makeRectangle(582, 3162, 1696, 2616);
		// makeRectangle(576, 3152, 1696, 2616);
		// fc = findColonyPoint("light");
		// makeRectangle(fc[0]-(r*0.9), fc[1]-(r*0.9), 1710, 2630);
	}
	waitForUser("Check box");

	// run("Duplicate...", "duplicate");
	run("Crop","stack");
	roiManager("reset");
	run("Clear Results");
	run("8-bit","stack");
	run("Invert","stack");
	run("Subtract Background...", "rolling=50 stack");
	run("Set Measurements...", "integrated display redirect=None decimal=4");
	run("Set Scale...", "distance=1200 known=1 pixel=1 unit=inch");
	
	run("Rotate... ");
	
	okay = false;
	dupfc = findColonyPoint("dark");
	xoffset = dupfc[0]-(r/2);
	yoffset = dupfc[1]-(r/2)+5;
	do {	
		roiManager("Show All without labels");
		Dialog.create("Define grid");
			Dialog.addNumber("xmult: ",xmult);
			Dialog.addNumber("ymult: ",ymult);
			Dialog.addNumber("offsetx: ",xoffset);
			Dialog.addNumber("offsety: ",yoffset);
			Dialog.addCheckbox("Okay? ",false)
		Dialog.show();
		roiManager("reset");
		xmult = Dialog.getNumber();
		ymult = Dialog.getNumber();
		xoffset = Dialog.getNumber();
		yoffset = Dialog.getNumber();
		okay = Dialog.getCheckbox();

		for(y=1;y<=32;y++) {
			for(x=1;x<=48;x++) {
				makeOval((x*xmult)-xoffset,(y*ymult)-yoffset,r,r);
				roiManager("Add");
			}
		}
	} while(okay==false);

	roiManager("Multi Measure");
	if(i==1) {
		saveAs("Results", workingdir+treatmentname+"-P"+pnum+"-Results.csv");
	} else {
		saveAs("Results", workingdir+treatmentname+"-P"+pnum+"-Results.csv");
	}

	run("Invert","slice");
	if(i==1) {
		saveAs("PNG", workingdir+treatmentname+"-P"+pnum+"-Working.png");
		roiManager("Show All without labels");
		roiManager("Draw");
		saveAs("PNG", workingdir+treatmentname+"-P"+pnum+"-ROI.png");
	} else {
		saveAs("PNG", workingdir+treatmentname+"-P"+pnum+"-Working.png");
		roiManager("Show All without labels");
		roiManager("Draw");
		saveAs("PNG", workingdir+treatmentname+"-P"+pnum+"-ROI.png");
	}
	roiManager("reset");
	run("Clear Results");
	run("Close");
}
run("Close All");
run("Collect Garbage");