//  XYZ to ACES primaries


import "utilities";
import "utilities-color";
import "transforms-common";
import "odt-transforms-common";




void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut 
)
{
  // Put input variables (OCES) into a 3-element vector
  float XYZ[3] = {rIn, gIn, bIn};
  
      // Apply CAT from assumed D60 to D65
    XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);
        


  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}
