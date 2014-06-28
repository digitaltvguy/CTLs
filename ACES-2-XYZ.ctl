//  ACES to XYZ


import "utilities";
import "utilities-color";

const float XYZ_2_ACES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);
const float ACES_2_XYZ_PRI_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);


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
	float ACES[3] = {rIn, gIn, bIn};

    // Convert from XYZ to ACES primaries
	float XYZ[3] = mult_f3_f44(ACES, ACES_2_XYZ_PRI_MAT);

  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}
