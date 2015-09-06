//  P3D65 to 2020 D65 primaries
//  Full range input/output


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";

const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};


const float XYZ_2_2020_PRI_MAT[4][4] = XYZtoRGB(REC2020_PRI,1.0);
const float P3D65_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D65_PRI,1.0);


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
     float XYZ[3] = mult_f3_f44( P3, P3D65_PRI_2_XYZ_MAT);
    // Convert from XYZ to ACES primaries
    float R2020D65[3] = mult_f3_f44( XYZ, XYZ_2_2020_PRI_MAT);

  rOut = R2020D65[0];
  gOut = R2020D65[1];
  bOut = R2020D65[2];
  //aOut = aIn;
}


