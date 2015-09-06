//  XYZ to ACES primaries


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";

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
  
  
    // Convert from XYZ to ACES primaries
    float ACES[3] = mult_f3_f44( XYZ, XYZ_2_ACES_PRI_MAT);

  rOut = ACES[0];
  gOut = ACES[1];
  bOut = ACES[2];
  //aOut = aIn;
}
