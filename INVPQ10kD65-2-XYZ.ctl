
// Assume full range input. Inverse PQ as 0-1

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";

// assume that input file is tiff MSB justified in D65 XYZ PQ
// remove PQ gamma output will be full range D65 XYZ linear 16 bit

const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;
const float F_BLACK = CV_BLACK/65535.0;
const float F_WHITE = CV_WHITE/65535.0;
const float RANGE = F_WHITE - F_BLACK;

const Chromaticities D65_XYZ_PRI =
{
  { 1.0, 0.0},
  { 0.0, 1.0},
  { 0.0, 0.0},
  { 0.31270,  0.32900}
};

const float XYZ_2_D65_XYZ_PRI_MAT[4][4] = XYZtoRGB(D65_XYZ_PRI ,1.0);
const float D65_XYZ_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(D65_XYZ_PRI,1.0);






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

// extract out 0-1 range from input that would be MSB justified 0-1
 float PQXYZ[3];
 PQXYZ[0] = (rIn - F_BLACK)/RANGE;
 PQXYZ[1] = (gIn - F_BLACK)/RANGE;
 PQXYZ[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 PQXYZ = clamp_f3(PQXYZ, 0.0, 1.0);	

	
 float XYZ[3];
  XYZ[0] = PQ10000_f(PQXYZ[0]);
  XYZ[1] = PQ10000_f(PQXYZ[1]);
  XYZ[2] = PQ10000_f(PQXYZ[2]);
  
    // convert from D65 XYZ RGB to XYZ
  XYZ = mult_f3_f44( XYZ, D65_XYZ_PRI_2_XYZ_MAT);

  float outputCV[3] = clamp_f3( XYZ, 0., 1.);


  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = outputCV[0];
  gOut = outputCV[1];
  bOut = outputCV[2];
  //aOut = aIn;
}
