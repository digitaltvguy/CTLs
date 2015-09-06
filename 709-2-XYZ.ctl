//  P3 to ACES primaries
// slight color balancing to make Oblivion look better


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";



const float R709_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC709_PRI,1.0);


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
  // Put input variables (709) into a 3-element vector
  float R709[3] = {rIn, gIn, bIn};
  


// convert from 709 to XYZ
     float XYZ[3] = mult_f3_f44( R709, R709_PRI_2_XYZ_MAT);

  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}


