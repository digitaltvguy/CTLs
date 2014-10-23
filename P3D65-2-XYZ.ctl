//  P3 to ACES primaries
// slight color balancing to make Oblivion look better


import "utilities";
import "utilities-color";

const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};



const float P3_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D65_PRI,1.0);


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


  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}


