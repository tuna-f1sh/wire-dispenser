// --- OBJECT DIA AND SETTINGS ---
// reel info
reelOD = 70; // reel outer diameter
reelID = 25; // reel inner diameter
reelW = 31; // reel width
dowelOD = 18; // supporting dowel outer dia
buffer = 10; // buffer around the edges of reels
trim = 3/4; // trim to height by this fraction since the reels don't need to be full enclosed

// reel settings
noReels = 6; // number of wire reels to hold
reelSpacing = 1; // buffer between reels
wireDia = 2; // dia of wire

spacing = 2; // spacing between dxf export for print

// slot
/* dentLength = 10;*/
baseSlots = 24; // number of slots in base
sideSlots = 8;
// Laser cutter beam kerf
LaserBeamDiameter = 0.23;
// Material characteristic
materialThickness = 3.20;

// --- WORKING ----
height = reelOD + (reelID - dowelOD) + buffer*2 + LaserBeamDiameter;
width = reelOD + buffer*2 + materialThickness*2 + LaserBeamDiameter;
length = ((reelW+reelSpacing)*noReels) + materialThickness*4 + LaserBeamDiameter;
trimedHeight = height*trim;

/* baseSlots = floor(length*0.2);*/
/* sideSlots = floor(trimedHeight*0.05);*/
dentLength = (length / baseSlots);
dentSpacing = dentLength; // same as dentLength (too lazy to change code!)

// --- EXPORT SETTIGS --- 
base();
endSpace = width+spacing+materialThickness;
translate([materialThickness,endSpace]) end();
translate([trimedHeight+materialThickness*2+spacing,width+spacing+materialThickness]) end();
translate([materialThickness,(width+spacing+materialThickness/2)*2]) dowelSlot();
translate([trimedHeight+materialThickness*2+spacing,(width+spacing+materialThickness/2)*2]) dowelSlot();
translate([0,(width+spacing+materialThickness/2)*3]) side(0);
translate([0,(width+spacing)*3+trimedHeight+materialThickness*3+spacing]) side(1);
echo("Length:",length);
echo("Width:",width);
echo("Height:",trimedHeight);

// --- END EXPORT ---

module base() {
  difference() {
    square([length,width]);
      for (x = [dentSpacing:dentSpacing+dentLength:length-dentSpacing+LaserBeamDiameter*baseSlots*2]) {
        translate([x,materialThickness/2-LaserBeamDiameter/2]) dent(1);
        translate([x,width-materialThickness/2+LaserBeamDiameter/2]) dent(1);
      }
      for (x = [width/4+materialThickness:width/2+materialThickness/2-dentSpacing/2-LaserBeamDiameter:width]) {
        translate([materialThickness/2-LaserBeamDiameter/2,x]) dent(3);
        translate([length-materialThickness/2+LaserBeamDiameter/2,x]) dent(3);
      }
  }
}

module end() {
  widthEnd = width-materialThickness*2;
  sideSpacing = (trimedHeight/sideSlots);
    union() {
      square([trimedHeight,widthEnd]);
      for (x = [width/4:width/2-dentSpacing/2-LaserBeamDiameter+materialThickness/2:widthEnd]) {
        translate([-materialThickness/2,x]) tooth(0);
      }
      for (x = [sideSpacing:sideSpacing+sideSpacing:trimedHeight-sideSpacing+LaserBeamDiameter*sideSlots*2]) {
        translate([x,-materialThickness/2+LaserBeamDiameter]) dent(1);
        translate([x,widthEnd+materialThickness/2-LaserBeamDiameter/2]) dent(1);
      }
    }
}

module dowelSlot() {
  widthEnd = width-materialThickness*2;
  difference() {
    end();
    translate([height/2,widthEnd/2]) {
      circle(dowelOD/2+LaserBeamDiameter);
      translate([height/4+LaserBeamDiameter,0]) square([height/2,dowelOD+LaserBeamDiameter],center=true);
    }
  }
}

module side(dispensing) {
  widthEnd = width-materialThickness*2;
  sideSpacing = (trimedHeight/sideSlots);
  difference() {
    union() {
      square([length,trimedHeight]);
        for (x = [dentSpacing:dentSpacing+dentLength:length-dentSpacing+LaserBeamDiameter*baseSlots*2]) {
          translate([x,-materialThickness/2+LaserBeamDiameter/2]) tooth(1);
        }
    }
    for (x = [sideSpacing:sideSpacing+sideSpacing:trimedHeight-sideSpacing+LaserBeamDiameter*sideSlots*2]) {
      translate([materialThickness-LaserBeamDiameter/2,x]) dent(2);
      translate([length-materialThickness+LaserBeamDiameter/2,x]) dent(2);
    }
    if (dispensing) {
      translate([materialThickness*2+reelW/2,height/2]) wireGroove(noReels);
    }
  }
}

module dent(direction) {
  if (direction == 1) {
    square([dentLength-LaserBeamDiameter,materialThickness-LaserBeamDiameter/2], center=true);
  } else if (direction == 2) {
    square([materialThickness*2-LaserBeamDiameter/2,dentLength-LaserBeamDiameter], center=true);
  } else if (direction == 3) {
    square([materialThickness*2-LaserBeamDiameter/2,width/4-LaserBeamDiameter], center=true);
  } else {
    square([materialThickness-LaserBeamDiameter/2,width/4-LaserBeamDiameter], center=true);
  }
}

module tooth(direction) {
  if (direction == 1) {
    square([dentLength+LaserBeamDiameter,materialThickness+LaserBeamDiameter/2], center=true);
  } else if (direction == 2) {
    square([materialThickness*2+LaserBeamDiameter/2,dentLength+LaserBeamDiameter], center=true);
  } else {
    square([materialThickness+LaserBeamDiameter/2,width/4+LaserBeamDiameter], center=true);
  }
}

module wireGroove(number) {
  grooveLength = reelW*0.25;
  for (x = [0:number-1]) {
    translate([x*(reelW+reelSpacing-wireDia/2),0]) {
      circle(wireDia/2);
      translate([0,-wireDia/2]) square([grooveLength,wireDia],center=false);
      translate([grooveLength,0]) circle(wireDia/2);
    }
  }
}
