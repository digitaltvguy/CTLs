//  P3 to ACES primaries
// slight color balancing to make Oblivion look better


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";


const float XYZ_2_709_PRI_MAT[4][4] = XYZtoRGB(REC709_PRI,1.0);
const float P3_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D60_PRI,1.0);


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
  float P3[3] = {rIn, gIn, bIn};
  


// convert from P3 to XYZ
     float XYZ[3] = mult_f3_f44( P3, P3_PRI_2_XYZ_MAT);
    // Convert from XYZ to ACES primaries
    float ACES[3] = mult_f3_f44( XYZ, XYZ_2_709_PRI_MAT);
    ACES = clamp_f3( ACES, 0., 1.0);

  rOut = ACES[0];
  gOut = ACES[1];
  bOut = ACES[2];
  //aOut = aIn;
}


