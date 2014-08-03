//  XYZ to ACES primaries


import "utilities";
import "utilities-color";
import "transforms-common";
import "odt-transforms-common";


const float XYZ_2_ACES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);


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
  
      // Apply CAT from assumed observer adapted white to ACES white point
      XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));
        
    // Convert from XYZ to ACES primaries
    float ACES[3] = mult_f3_f44( XYZ, XYZ_2_ACES_PRI_MAT);

  rOut = ACES[0];
  gOut = ACES[1];
  bOut = ACES[2];
  //aOut = aIn;
}
