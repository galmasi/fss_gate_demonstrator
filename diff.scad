use <MCAD/involute_gears.scad>


diffgear_inner_radius =14; // the sphere inside the differential where all the gears exist
diffassy_inner_radius =15; // the inner radius of the differential assembly
diffassy_outer_radius =16; // the outer radius of the differential assembly
diffassy_belt_radius  =18; // the outer radius of the belt holding the assembly together
diffgear_axle_radius  = 2; // the dimension of the axle of all differential gears
knob_axle_radius      = 3; // the dimension of the axle of the control knobs

box_side=50;            // side length of entire box
box_height=40;          // height of box

diffgear_y_offset=-5; // y offset from center of differential gear's axle
diffaxle_z_offset=21; // z offset (height) of differential gear's axle

knob_y_offset=7;


module flat_gear(radius=6, teeth=12) {
    gear (number_of_teeth=teeth,
    	  circular_pitch=radius*360/teeth,
          diametral_pitch=false,
          pressure_angle=28,
          clearance = 0.2,
          gear_thickness=4,
          rim_thickness=4,
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

// a pair of medium flat gears mesh at distance 24
module flat_gear_medium() {
    difference() {        
        flat_gear(radius=6, teeth=12);
        cylinder($fn=6, r=2.2, h=10);
    }
}

module flat_gear_medium_handle() {
    knob_hole_axle_height=5;
    flat_gear(radius=6, teeth=12);
//    cylinder($fn=40,r=knob_axle_radius,h=10);
    cylinder($fn=40,r=knob_axle_radius,h=4+3);
    cylinder($fn=6,r=knob_axle_radius,h=4+3+knob_hole_axle_height);
}


// the large and small gears mesh at distance 24
module flat_gear_small() {
    flat_gear(radius=5,teeth=10);
}

module flat_gear_large() {
    difference() {
        flat_gear(teeth=14, radius=7);
        cylinder($fn=6, r=2.2, h=10);
    }
}


module flat_gear_large_handle() {
    knob_hole_axle_height=5;
    flat_gear(teeth=14, radius=7);
    cylinder($fn=40,r=knob_axle_radius,h=4+3);
    cylinder($fn=6,r=knob_axle_radius,h=4+3+knob_hole_axle_height);
}

// differential gears are encased into a sphere of radius diffgear_inner_radius
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

// differential gears that don't extend an axle outside the differential itself
module diff_gear_inside() {
    handleheight=2;
    rotate([180,0,0]) {
        diff_gear();
        translate([0,0,-handleheight]) cylinder($fn=30,r=diffgear_axle_radius, h=handleheight+1);
    }
}

// differential gears that have outside handles
module diff_gear_outside() {
    handleheight=8;
    rotate([180,0,0]) {
        diff_gear();
        translate([0,0,-4]) cylinder($fn=30,r=diffgear_axle_radius, h=handleheight+1-4);
        translate([0,0,-handleheight]) cylinder($fn=6,r=diffgear_axle_radius, h=handleheight+1);
        
    }
}

// ----------------------------------------
// half cupola containing differential gear
// the differential is running inside a sphere with radius "diffgear_inner_radius"
// the cupola has "diffassy_outer_radius" on outside and "diffassy_inner_radius" on inside
// diffgear_inner_radius < diffassy_inner_radius < diffassy_outer_radius
// ----------------------------------------
module diff_halfcupola() {
    difference() {
        union() {
            // cupola sphere
            sphere($fn=100,r=diffassy_outer_radius,center=true);
            // flat surfaces of diameter 8mm on x-,x+,y-,y+,z-,z+
            rotate([0, 0, 0]) cylinder($fn=30, r=4, h=2*diffassy_outer_radius, center=true);
            rotate([90, 0, 0]) cylinder($fn=30, r=4, h=2*diffassy_outer_radius, center=true);
            rotate([0, 90, 0]) cylinder($fn=30, r=4, h=2*diffassy_outer_radius, center=true);
        }
        union() {
            intersection() {
                sphere($fn=100,r=diffassy_inner_radius, center=true);
                cube([2*diffgear_inner_radius, 2*diffgear_inner_radius, 2*diffgear_inner_radius], center=true);
            }
            rotate([0, 0, 0]) cylinder($fn=30, r=2.1, h=2*diffassy_outer_radius+1, center=true);
            rotate([90, 0, 0]) cylinder($fn=30, r=2.1, h=2*diffassy_outer_radius+1, center=true);
            rotate([0, 90, 0]) cylinder($fn=30, r=2.1, h=2*diffassy_outer_radius+1, center=true);
            translate([0,0,-25]) cube([50,50,50], center=true);
        }
    }
    difference() {
        cylinder($fn=30,r=20,h=0.1);
        translate([0,0,-0.1]) cylinder($fn=30,r=diffassy_outer_radius,h=0.5);
    }
}

// ----------------------------------------
// belt around the differential gear
// cupolaradius = outer radius of differential gear's cupola
// beltradius = outer dimensions of belt itself
// TODO needs numbers on it.
// ----------------------------------------

module diff_belt() {
    slack = 0.30;
    difference() {
        cylinder($fn=100, r=diffassy_belt_radius, h=10, center=true);
        union() {
            sphere($fn=100,r=diffassy_outer_radius+slack, center=true);
            cube([2*(diffassy_outer_radius+slack), 8, 16], center=true);
            cube([8, 2*(diffassy_outer_radius+slack), 16], center=true);
            cylinder($fn=100,r=diffassy_outer_radius-slack,h=100,center=true);
        }
    }
}

// housing. has holes in it for the handles

module housing_bottom() {
    slack=0.1;
    knob_y_offset=+7;
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
    }}
    // button to limit knob movement
    // didn't work ot so disabled
    //    translate([box_side/2+1,knob_y_offset,20+7]) sphere($fn=30, r=1.5,center=true);
    //    translate([-(box_side/2+1),knob_y_offset,20+7]) sphere($fn=30, r=1.5,center=true);
}


// the top of the container. It is designed to slide in and be held by friction only

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



// brackets inside the housing hold the differential gear and create space for the flat gears
module bracket() {
    brack_xdim_slack=0.2; // give the bracket some slack inside the containing box or else it wedges too tight
    // slack of 0.05 was too tight. Trying 0.2
    brack_xdim = box_side/2 - diffassy_outer_radius - 1 - brack_xdim_slack;
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


// 
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


// show the assembly for visualization and debug purposes.

module assembly() {
    knob_y_offset=+7;
    
    // case and brackets holding differential
    housing_bottom();
    color("yellow") translate([diffassy_outer_radius+1,0,2]) bracket();

    // differential gear: cupolas, belt, gears
    color("blue") translate([0, diffgear_y_offset,   diffaxle_z_offset]) rotate([0,90,0]) diff_belt();    
    color("red")  translate([0, diffgear_y_offset,   diffaxle_z_offset]) rotate([180, 0,0 ]) diff_halfcupola();
    //color("cyan") translate([14,diffgear_y_offset,   diffaxle_z_offset]) rotate([0,90,0]) diff_gear_outside();
    //color("cyan") translate([0, -14+diffgear_y_offset,  diffaxle_z_offset]) rotate([90,0,0]) diff_gear_inside();

    // flat gears
    color("cyan") translate([18.5, diffgear_y_offset,  diffaxle_z_offset]) rotate([0,90,0]) flat_gear_medium();
    color("cyan") translate([18.5, knob_y_offset, diffaxle_z_offset]) rotate([0,90,0]) rotate([0,0,360/20]) flat_gear_medium_handle();

    // control knobs
    color("cyan") translate([30,knob_y_offset,  diffaxle_z_offset]) rotate([0,90,0]) knob();
    
}


// print every part

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
    translate([120,0 ,0]) flat_gear_large_handle();
    
    // knobs
    
    translate([50, 0, 0]) knob();
    translate([50, 25, 0]) knob();
    
    // differential housing
    
    translate([0, 80, 0])  diff_halfcupola();
    translate([50, 80, 0]) diff_halfcupola();    
    translate([85,0,5])    diff_belt();
    

    // case and distancers
    translate([20,-40,0]) housing_bottom();
    translate([90,-50,1]) rotate([0,-90,0]) bracket();
    translate([130,-50,1]) rotate([0,-90,0]) bracket();
    translate([100, 70, 0]) housing_top();
}

// assembly();
//print_ready();

housing_bottom();

difference() {
    translate([27,knob_y_offset,diffaxle_z_offset/2-1]) cube([4, 25, diffaxle_z_offset-2], center=true);
    translate([0,knob_y_offset,diffaxle_z_offset-2]) rotate([0,90,0]) cylinder($fn=40, r=10, h=100, center=true);
}