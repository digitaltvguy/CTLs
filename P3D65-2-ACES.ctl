//  P3 to ACES primaries
// slight color balancing to make Oblivion look better
// NOTE NOT APPLYING CAT SO BE CAREFUL TO OUTPUT D65 even if going through ACES and XYZ


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";

const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};

const float XYZ_2_ACES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);
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
  
//print_f44(P3_PRI_2_XYZ_MAT);

// convert from P3 to XYZ
     float XYZ[3] = mult_f3_f44( P3, P3_PRI_2_XYZ_MAT);
    // Convert from XYZ to ACES primaries
    float ACES[3] = mult_f3_f44( XYZ, XYZ_2_ACES_PRI_MAT);

  rOut = ACES[0];
  gOut = ACES[1];
  bOut = ACES[2];
  //aOut = aIn;
}


