// Assume full range input. Inverse PQ as 0-1
// Removes PQ but does not do inverse tone map
//

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";

// assume that input file is tiff MSB justified in 2020 PQ
// remove PQ gamma output will be full range 2020 linear 16 bit

const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;
const float F_BLACK = CV_BLACK/65535.0;
const float F_WHITE = CV_WHITE/65535.0;
const float RANGE = F_WHITE - F_BLACK;
// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX = 10000.0; //speculars

const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);




void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float MAX = 1000.0  
)
{
	
// extract out 0-1 range from input that would be MSB justified 0-1
 float PQ2020[3];
 PQ2020[0] = (rIn - F_BLACK)/RANGE;
 PQ2020[1] = (gIn - F_BLACK)/RANGE;
 PQ2020[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 PQ2020 = clamp_f3(PQ2020, 0.0, 1.0);	
	

 float R2020[3];
  R2020[0] = PQ10000_f(PQ2020[0])*OUT_WP_MAX;
  R2020[1] = PQ10000_f(PQ2020[1])*OUT_WP_MAX;
  R2020[2] = PQ10000_f(PQ2020[2])*OUT_WP_MAX;
  
  // unstretch the scale back down
    R2020 = mult_f_f3(MAX/OUT_WP_MAX,R2020);

  
  R2020 = clamp_f3( R2020, 0., OUT_WP_MAX);
  // data is full range now
  
    // convert from  2020 RGB to XYZ
  float XYZ[3] = mult_f3_f44( R2020, R2020_PRI_2_XYZ_MAT);


  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}
