use <MCAD/involute_gears.scad>

// differential assembly
diffgear_inner_radius     = 14; // the sphere inside the clamshell where all the gears exist
clamshell_inner_radius    = 15; // inner radius of the differential clamshell
clamshell_outer_radius    = 16; // outer radius of the differential clamshell
diffassy_belt_radius      = 18; // outer radius of the belt holding diff assembly together
diffgear_axle_radius      =  2; // the dimension of the axle of all differential gears

// holding box
box_side                  = 50; // side length of entire box
box_height                = 40; // height of box

// location of diff assembly inside box
diffgear_y_offset         = -5; // y offset from center of differential gear's axle
diffaxle_z_offset         = 21; // z offset (height) of differential gear's axle

// control knobs
knob_axle_radius          =  3; // the dimension of the axle of the control knobs
knob_y_offset             =  7; // how much the knob is off center on the box

// *****************************************************
// standard flat gear
// *****************************************************
module flat_gear(radius=6, teeth=12) {
    gear (number_of_teeth=teeth,
    	  circular_pitch=radius*6.28/teeth,
          diametral_pitch=false,
          pressure_angle=28,
          clearance = 0.2,
          gear_thickness=5,
          rim_thickness=5,
          rim_width=0,
          hub_thickness=2,
          hub_diameter=0,
          bore_diameter=0,
          circles=0,
          backlash=0,
          twist=0,
          involute_facets=0,
          flat=false);
}

// *****************************************************
// a pair of medium flat gears mesh at distance 24
// *****************************************************
module flat_gear_medium() {
    difference() {        
        flat_gear(radius=6, teeth=12);
        cylinder($fn=6, r=2.1, h=10);
    }
}

// *****************************************************
// the large and small gears also mesh at distance 24
// *****************************************************
module flat_gear_small() {
    difference() {
        flat_gear(radius=5,teeth=10);
        cylinder($fn=6, r=2.1, h=10);
    }
}

module flat_gear_large() {
    difference() {
        flat_gear(teeth=14, radius=7);
        cylinder($fn=6, r=2.1, h=10);
    }
}

// *****************************************************
// a variant of the medium gear with a protruding axle and a hexagonal ending
// designed to match up with a control knob
// *****************************************************

module flat_gear_medium_handle() {
    knob_hole_axle_height=5;
    flat_gear(radius=6, teeth=12);
    cylinder($fn=40,r=knob_axle_radius,h=4+3);
    cylinder($fn=6,r=knob_axle_radius,h=4+3+knob_hole_axle_height);
}

// *****************************************************
// as above, but it's a large gear that meshes with a small gear
// designed to match up with a control knob
// *****************************************************

module flat_gear_large_handle() {
    knob_hole_axle_height=5;
    flat_gear(teeth=14, radius=7);
    cylinder($fn=40,r=knob_axle_radius,h=4+3);
    cylinder($fn=6,r=knob_axle_radius,h=4+3+knob_hole_axle_height);
}

// *****************************************************
// differential gear designed to exist inside the differential's clamshell
// there are four such gears meshing and forming a square inside the clamshell
// *****************************************************

module diff_gear () {
    teeth=18;
    circular_pitch = diffgear_inner_radius * 360 / teeth;
    cone_distance = diffgear_inner_radius * 1.414;
    intersection() {
        bevel_gear (
            number_of_teeth=teeth, 
            cone_distance=cone_distance, 
            face_width=10, 
            outside_circular_pitch=circular_pitch, 
            pressure_angle=30,
            clearance = 0.2, 
            bore_diameter=0,
            gear_thickness = 5, 
            backlash = 0, 
            involute_facets=8, 
            finish =0) ;
        translate([0,0, diffgear_inner_radius]) sphere($fn=100, r=diffgear_inner_radius, center=true);
    }
}

// *****************************************************
// one pair of gears are completely inside the differential assembly
// *****************************************************

module diff_gear_inside() {
    handleheight=2;
    rotate([180,0,0]) {
        diff_gear();
        translate([0,0,-handleheight]) cylinder($fn=30,r=diffgear_axle_radius, h=handleheight+1);
    }
}

// *****************************************************
// the other pair of gears reach outside the clamshell and have hexagonal ends
// to match up with the flat gears that eventually connect to the knobs
// *****************************************************

module diff_gear_outside() {
    handleheight=8;
    rotate([180,0,0]) {
        diff_gear();
        translate([0,0,-4]) cylinder($fn=30,r=diffgear_axle_radius, h=handleheight+1-4);
        translate([0,0,-handleheight]) cylinder($fn=6,r=diffgear_axle_radius, h=handleheight+1);
        
    }
}

// *****************************************************
// clamshell containing differential gear
// the differential is running inside a sphere with radius "diffgear_inner_radius"
// the cupola has "clamshell_outer_radius" on outside and "clamshell_inner_radius" on inside
// diffgear_inner_radius < clamshell_inner_radius < clamshell_outer_radius
// *****************************************************
module diff_clamshell() {
    difference() {
        union() {
            // clamshell sphere
            sphere($fn=100,r=clamshell_outer_radius,center=true);
            // flat surfaces of diameter 8mm on x-,x+,y-,y+,z-,z+
            rotate([0, 0, 0]) cylinder($fn=30, r=4, h=2*clamshell_outer_radius, center=true);
            rotate([90, 0, 0]) cylinder($fn=30, r=4, h=2*clamshell_outer_radius, center=true);
            rotate([0, 90, 0]) cylinder($fn=30, r=4, h=2*clamshell_outer_radius, center=true);
            // a sort of almost-brim to improve ground adherence during printing
            // not a functional requirement but improves printing outcomes
            minkowski() {
                cube([18, 18, 0.7], center=true);
                cylinder($fn=40, r=6, h=0.7, center=true);
            }
        }
        union() {
            intersection() {
                sphere($fn=100,r=clamshell_inner_radius, center=true);
                cube([2*diffgear_inner_radius, 2*diffgear_inner_radius, 2*diffgear_inner_radius], center=true);
            }
            // axle holes for the gears
            rotate([90, 0, 0]) cylinder($fn=30, r=2.1, h=2*clamshell_outer_radius+1, center=true);
            rotate([0, 90, 0]) cylinder($fn=30, r=2.1, h=2*clamshell_outer_radius+1, center=true);
            // we only want half a sphere, so kill everything z<0
            translate([0,0,-25]) cube([50,50,50], center=true);
            for (x=[-18,18])
                for (y=[-18,18])
                    translate([x,y,18]) cube([25, 25, 25], center=true);
        }
    }
}

// *****************************************************
// belt around the differential gear
// it slides over the assembled differential assembly and holds it together
// TODO needs numbers on it.
// *****************************************************

module diff_belt() {
    slack = 0.30;
    difference() {
        cylinder($fn=100, r=diffassy_belt_radius, h=10, center=true);
        union() {
            sphere($fn=100,r=clamshell_outer_radius+slack, center=true);
            cube([2*(clamshell_outer_radius+slack), 8, 16], center=true);
            cube([8, 2*(clamshell_outer_radius+slack), 16], center=true);
            cylinder($fn=100,r=clamshell_outer_radius-slack,h=100,center=true);
        }
    }
}

module diff_belt_textentry(text="0") {
    translate([diffassy_belt_radius-0.25, 0, 0])
    rotate([0,90,0])
    translate([-3,-3,0])
    linear_extrude(height=0.5)
    text(text=text, size=6, font="Courier");
}


module diff_belt_text(v0="0", v1="1", v2="1", v3="0") {
    diff_belt();
    diff_belt_textentry(text=v0);
    rotate([0,0,90]) diff_belt_textentry(text=v1);
    rotate([0,0,120]) diff_belt_textentry(text=v2);
    rotate([0,0,210]) diff_belt_textentry(text=v3);
}

module diff_belt_xor() {
    diff_belt_text("0", "1", "1", "0");
}

module diff_belt_and() {
    diff_belt_text("0", "0", "0", "1");
}

module diff_belt_or() {
    diff_belt_text("0", "1", "1", "1");
}


// *****************************************************
// housing: bottom end
// *****************************************************

module housing_bottom() {
    // box with the holes in it
    intersection() {
        translate([0,0,20]) 
            minkowski() {
                cube([box_side-2, box_side-2, 40], center=true);
                cylinder($fn=30, h=0.001, r=2, center=true);
            }
        difference() {
            union() {
                // box
                translate([0,0,1]) cube([box_side,box_side,2], center=true);
                        
                // outer walls
                translate([-box_side/2,0,20]) cube([2, box_side+2, 40], center=true);
                translate([box_side/2,0,20]) cube([2, box_side+2, 40], center=true);

                translate([0, box_side/2,20]) cube([box_side+2, 2, 40], center=true);
                translate([0, -box_side/2,20]) cube([box_side+2, 2, 40], center=true);      
            }
            union() {
                // holes for axles for driving knobs
                translate([0,knob_y_offset,diffaxle_z_offset]) rotate([0,90,0]) cylinder($fn=20, r=knob_axle_radius+0.1, h=box_side+3, center=true);
            }
        }
    }
    
    // support for limiting knob travel
    for (x=[-1,1]) {
        intersection() {
            difference() {
                translate([x*27,knob_y_offset,diffaxle_z_offset/2-1]) cube([4, 25, diffaxle_z_offset-3], center=true);
                translate([0,knob_y_offset,diffaxle_z_offset]) rotate([0,90,0]) cylinder($fn=40, r=10.5, h=100, center=true);
            }
            translate([x*27,knob_y_offset,diffaxle_z_offset]) rotate([0,x*90,0]) cylinder($fn=100, r1= 16, r2=12, h=4, center=true);
        }
    }
    
    for (x=[-1,1])
        for (y=[-1,1])
            translate([x*box_side/2, knob_y_offset+y*11, 
                diffaxle_z_offset+2.5]) sphere($fn=80,r=1.7);
    
    // text
    translate([box_side/2+1,box_side/2,box_height-10]) 
        rotate([0,-90,0])
            rotate([0,0,-90])
                linear_extrude(height=1, center=true)
                    text(text="0", size=10, font="Courier");
    translate([-box_side/2-1,box_side/2,box_height-10]) 
        rotate([0,-90,0])
            rotate([0,0,-90]) 
                linear_extrude(height=1, center=true)
                    text(text="0", size=10, font="Courier");
    translate([box_side/2+1,-10,box_height-10]) 
        rotate([0,90,0])
            rotate([0,0,90]) 
                linear_extrude(height=1, center=true)
                    text(text="1", size=10, font="Courier");
    translate([-box_side/2-1,0,box_height-10]) 
        rotate([0,-90,0])
            rotate([0,0,-90]) 
                linear_extrude(height=1, center=true)
                    text(text="1", size=10, font="Courier");

}


// *****************************************************
// the top of the box. It is designed to be held by friction only
// *****************************************************

module housing_top() {
    intersection() {
        translate([0,0,20]) 
            minkowski() {
                cube([box_side-2, box_side-2, 40], center=true);
                cylinder($fn=30, h=0.001, r=2, center=true);
            }
        difference() {
            union() {
                translate([0,0,1]) cube([box_side+2,box_side+2,2], center=true);
                translate([0,0,3]) cube([box_side-2, box_side-2, 2], center=true);
                translate([0,box_side/2-2,6]) cube([20, 2, 10], center=true);
                translate([0,-box_side/2+2,6]) cube([20, 2, 10], center=true);
                translate([box_side/2-3.5,0,6]) cube([5,box_side-6.5,10], center=true);
                translate([-(box_side/2-3.5),0,6]) cube([5,box_side-6.5,10], center=true);
            }
            union() {
                //translate([0, diffgear_y_offset, 0]) cube([10,10,10], center=true);
                translate([0,diffgear_y_offset,-0.1]) rotate([0,0,45]) cylinder($fn=4,r1=10,r2=5,h=5);
            }
        }
    }
}

// *****************************************************
// brackets inside the housing hold the differential gear and create space for the flat gears
// *****************************************************

module bracket() {
    brack_xdim_slack=0.2; // give the bracket some slack inside the containing box or else it wedges too tight
    // slack of 0.05 was too tight. Trying 0.2
    brack_xdim = box_side/2 - clamshell_outer_radius - 1 - brack_xdim_slack;
    brack_zdim = 40 - 2 - 2;
    axlehole_extra_radius=0.2;
    difference() {
        union() {
            translate([0,0,20-2]) cube([2, box_side-2-2, brack_zdim], center=true);
            translate([brack_xdim/2-1,box_side/2-2,20-2]) cube([brack_xdim, 2, brack_zdim], center=true);
            translate([brack_xdim/2-1,-box_side/2+2,20-2]) cube([brack_xdim, 2, brack_zdim], center=true);
        }
        // holes for gear axles coming from differential
        translate([0,diffgear_y_offset, diffaxle_z_offset-2]) 
            rotate([0,90,0]) cylinder($fn=20, r=diffgear_axle_radius + axlehole_extra_radius, h=40, center=true);
    }
}

// *****************************************************
// control knob.
// has hexagonal center axle hole to match up with flat gear
// *****************************************************

module knob() {
    // how much slack does the axle hole get vs the axle itself
    axle_slack=0.05;
    axle_hole_height=5;
    difference() {
        cylinder($fn=60, r=10, h=10);
        union() {
            for (x=[-10, 10])
                translate([x,0,10])
                    minkowski() {
                        cube([10, 20, 4], center=true);
                        rotate([90,0,0]) cylinder($fn=40, r=3, h=0.01);
                }
            // hole for the axle
            translate([0,0,-0.01]) cylinder($fn=6, r=knob_axle_radius+axle_slack, h=axle_hole_height);
            // a half-circle cutout
            //rotate_extrude($fn=80,angle=200, start=-10, convexity = 20) 
            //    translate([7, 0, 0])
            //        circle($fn=80, r = 0.75);

        }
    }
    // handle extension
    translate([0,14,5]) cube([4, 12, 10], center=true);
    translate([0,20,0]) cylinder($fn=40,r=2, h=10);
}


// *****************************************************
// show the assembly for visualization and debug purposes.
// DO NOT PRINT THIS.
// *****************************************************

module assembly() {
    knob_y_offset=+7;
    
    // case and brackets holding differential
    housing_bottom();
    color("yellow") translate([clamshell_outer_radius+1,0,2]) bracket();

    // differential gear: cupolas, belt, gears
    color("blue") translate([0, diffgear_y_offset,   diffaxle_z_offset]) rotate([0,90,0]) diff_belt();    
    color("red")  translate([0, diffgear_y_offset,   diffaxle_z_offset]) rotate([180, 0,0 ]) diff_clamshell();
    //color("cyan") translate([14,diffgear_y_offset,   diffaxle_z_offset]) rotate([0,90,0]) diff_gear_outside();
    //color("cyan") translate([0, -14+diffgear_y_offset,  diffaxle_z_offset]) rotate([90,0,0]) diff_gear_inside();

    // flat gears
    color("cyan") translate([18.5, diffgear_y_offset,  diffaxle_z_offset]) rotate([0,90,0]) flat_gear_medium();
    color("cyan") translate([18.5, knob_y_offset, diffaxle_z_offset]) rotate([0,90,0]) rotate([0,0,360/20]) flat_gear_medium_handle();

    // control knobs
    color("cyan") translate([30,knob_y_offset,  diffaxle_z_offset]) rotate([0,90,0]) knob();
    
}


// *****************************************************
// print ready: every part needed to assemble a box
// *****************************************************

module print_ready() {
    // differential gears
    
    translate([0,0,7]) diff_gear_inside();
    translate([0,25,7]) diff_gear_inside();
    translate([25,0,7]) diff_gear_outside();
    translate([25,25,7]) diff_gear_outside();
    
    
    // flat gears
    translate([0, 50, 0]) flat_gear_medium();
    translate([25,50 ,0]) flat_gear_medium_handle();
    translate([50, 50, 0]) flat_gear_small();
    translate([125,0 ,0]) flat_gear_large_handle();
    
    // knobs
    
    translate([50, 0, 0]) rotate([0,0,45]) knob();
    translate([50, 25, 0]) rotate([0,0,45]) knob();
    
    // differential housing
    
    translate([0, 80, 0])  diff_clamshell();
    translate([50, 80, 0]) diff_clamshell();    
    translate([85,0,5])    diff_belt_xor();
    translate([125,0,5])   diff_belt_or();
    

    // case and distancers
    translate([20,-40,0]) housing_bottom();
    translate([90,-50,1]) rotate([0,-90,0]) bracket();
    translate([130,-50,1]) rotate([0,-90,0]) bracket();
    translate([100, 70, 0]) housing_top();
}

//assembly();
print_ready();
 
