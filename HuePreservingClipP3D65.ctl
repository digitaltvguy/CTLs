//  P3 to ACES primaries
// slight color balancing to make Oblivion look better


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";

const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};



  
float[3] huePreservingClip_to_p3d65( float XYZ[3])
{
  // Converts CIE XYZ tristimulus values to P3D60, performs a "smart-clip" by 
  // clamping to device primaries and performing a hue restore. The resulting P3
  // code values are then converted back to CIE XYZ tristimulus values and 
  // returned.
  
  const float XYZ_2_P3D65_PRI_MAT[4][4] = XYZtoRGB(P3D65_PRI,1.0);
  const float P3D65_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D65_PRI,1.0);
  
  // CIE XYZ to P3D60 primaries
  float p3[3] = mult_f3_f44( XYZ, XYZ_2_P3D65_PRI_MAT);

  // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
  float p3Clamp[3] = clamp_f3( p3, 0., 1.);

  // Restore hue after clip operation ("smart-clip")
  p3 = restore_hue_dw3( p3, p3Clamp);

  // P3D60 to CIE XYZ
  return mult_f3_f44( p3, P3D65_PRI_2_XYZ_MAT);  
}



