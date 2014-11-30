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
/* dentLength = 10;*/ // now calculated
// Tweak these till it looks right
baseSlots = 24; // number of slots in base
sideSlots = 8; // number of slots on sides
// Laser cutter beam kerf
LaserBeamDiameter = 0.23;
// Material characteristic
materialThickness = 3.20;

// --- COMPILE ----
// make export true if you want to create DXF print sheet, otherwise 3D render is created to visualise
export = 0;

// --- WORKING ----
height = reelOD + (reelID - dowelOD) + buffer*2 + LaserBeamDiameter;
width = reelOD + buffer*2 + materialThickness*2 + LaserBeamDiameter;
length = ((reelW+reelSpacing)*noReels) + materialThickness*4 + LaserBeamDiameter;
trimedHeight = height*trim;

/* baseSlots = floor(length*0.2);*/
/* sideSlots = floor(trimedHeight*0.05);*/
dentLength = (length / baseSlots);
dentSpacing = dentLength; // same as dentLength (too lazy to change code!)
endSpace = width+spacing+materialThickness;

// --- EXPORT SETTIGS --- 
if (export) {
  projection() base();
  projection() translate([materialThickness,endSpace]) end();
  projection() translate([trimedHeight+materialThickness*2+spacing,width+spacing+materialThickness]) end();
  projection() translate([materialThickness,(width+spacing+materialThickness/2)*2]) dowelSlot();
  projection() translate([trimedHeight+materialThickness*2+spacing,(width+spacing+materialThickness/2)*2]) dowelSlot();
  projection() translate([0,(width+spacing+materialThickness/2)*3]) side(0);
  projection() translate([0,(width+spacing)*3+trimedHeight+materialThickness*3+spacing]) side(1);
  echo("Length:",length);
  echo("Width:",width);
  echo("Height:",trimedHeight);
} else {
  base();
  translate([materialThickness,materialThickness,materialThickness]) rotate([0,270,0]) end();
  translate([materialThickness*2,materialThickness,materialThickness]) rotate([0,270,0]) dowelSlot();
  translate([length,materialThickness,materialThickness]) rotate([0,270,0]) end();
  translate([length-materialThickness,materialThickness,materialThickness]) rotate([0,270,0]) dowelSlot();
  translate([0,materialThickness,materialThickness]) rotate([90,0,0]) side(1);
  translate([0,width,materialThickness]) rotate([90,0,0]) side(0);
  // stick dowel and a reel in for size
  translate([materialThickness,width/2,height/2+materialThickness]) rotate([0,90,0]) cylinder(h = (length-materialThickness*2),r = dowelOD/2);
  translate([materialThickness*2+reelSpacing,width/2,height/2+materialThickness]) rotate([0,90,0]) cylinder(h = reelW,r = reelOD/2);
}


// --- END EXPORT ---

module base() {
  difference() {
    cube([length,width,materialThickness]);
      for (x = [dentSpacing:dentSpacing+dentLength:length-dentSpacing+LaserBeamDiameter*baseSlots*2]) {
        translate([x,materialThickness/2-LaserBeamDiameter/2,+materialThickness/2]) dent(1);
        translate([x,width-materialThickness/2+LaserBeamDiameter/2,materialThickness/2]) dent(1);
      }
      for (x = [width/4+materialThickness/2:width/2+materialThickness/2-dentSpacing/2-LaserBeamDiameter:width]) {
        translate([materialThickness-LaserBeamDiameter/2,x,materialThickness/2]) dent(3);
        translate([length-materialThickness+LaserBeamDiameter/2,x,materialThickness/2]) dent(3);
      }
  }
}

module end() {
  widthEnd = width-materialThickness*2;
  sideSpacing = (trimedHeight/sideSlots);
    union() {
      cube([trimedHeight,widthEnd,materialThickness]);
      for (x = [width/4-materialThickness/2:width/2-dentSpacing/2-LaserBeamDiameter+materialThickness/2:widthEnd]) {
        translate([-materialThickness/2,x,materialThickness/2]) tooth(0);
      }
      for (x = [sideSpacing:sideSpacing+sideSpacing:trimedHeight-sideSpacing+LaserBeamDiameter*sideSlots*2]) {
        translate([x,-materialThickness/2+LaserBeamDiameter,materialThickness/2]) tooth(1);
        translate([x,widthEnd+materialThickness/2-LaserBeamDiameter/2,materialThickness/2]) tooth(1);
      }
    }
}

module dowelSlot() {
  widthEnd = width-materialThickness*2;
  difference() {
    end();
    translate([height/2,widthEnd/2]) {
      cylinder(h = materialThickness, r = dowelOD/2+LaserBeamDiameter);
      translate([trimedHeight/4+LaserBeamDiameter,0,materialThickness/2]) cube([trimedHeight/2,dowelOD+LaserBeamDiameter,materialThickness*2],center=true);
    }
  }
}

module side(dispensing) {
  widthEnd = width-materialThickness*2;
  sideSpacing = (trimedHeight/sideSlots);
  difference() {
    union() {
      cube([length,trimedHeight,materialThickness]);
        for (x = [dentSpacing:dentSpacing+dentLength:length-dentSpacing+LaserBeamDiameter*baseSlots*2]) {
          translate([x,-materialThickness/2+LaserBeamDiameter/2,materialThickness/2]) tooth(1);
        }
    }
    for (x = [sideSpacing:sideSpacing+sideSpacing:trimedHeight-sideSpacing+LaserBeamDiameter*sideSlots*2]) {
      translate([materialThickness-LaserBeamDiameter/2,x,materialThickness/2]) dent(2);
      translate([length-materialThickness+LaserBeamDiameter/2,x,materialThickness/2]) dent(2);
    }
    if (dispensing) {
      translate([materialThickness*3/2+reelW/2,height/2]) wireGroove(noReels);
    }
  }
}

module dent(direction) {
  if (direction == 1) {
    cube([dentLength-LaserBeamDiameter,materialThickness-LaserBeamDiameter/2,materialThickness*2], center=true);
  } else if (direction == 2) {
    cube([materialThickness*2-LaserBeamDiameter/2,dentLength-LaserBeamDiameter,materialThickness*2], center=true);
  } else if (direction == 3) {
    cube([materialThickness*2-LaserBeamDiameter/2,width/4-LaserBeamDiameter,materialThickness*2], center=true);
  } else {
    cube([materialThickness-LaserBeamDiameter/2,width/4-LaserBeamDiameter,materialThickness*2], center=true);
  }
}

module tooth(direction) {
  if (direction == 1) {
    cube([dentLength+LaserBeamDiameter,materialThickness+LaserBeamDiameter/2,materialThickness], center=true);
  } else if (direction == 2) {
    cube([materialThickness*2+LaserBeamDiameter/2,dentLength+LaserBeamDiameter,materialThickness], center=true);
  } else {
    cube([materialThickness+LaserBeamDiameter/2,width/4+LaserBeamDiameter,materialThickness], center=true);
  }
}

module wireGroove(number) {
  grooveLength = reelW*0.25;
  for (x = [0:number-1]) {
    translate([x*(reelW+reelSpacing-wireDia/2),0]) {
      cylinder(h=materialThickness,r=wireDia/2);
      translate([0,-wireDia/2]) cube([grooveLength,wireDia,materialThickness],center=false);
      translate([grooveLength,0]) cylinder(h=materialThickness,r=wireDia/2);
    }
  }
}
