// Assume full range input. Inverse PQ as 0-1
// NOTE: DOES NOT INVERT TONE MAPPING
// ONLY REMOVES GAMMA and multiplies from 2020 to XYZ
//
//

import "utilities";
import "utilities-color";
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
const float OUT_WP_MAX_PQ = 10000.0; //speculars


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
	
	const float OUT_WP_MAX = MAX;
    const float RATIO = OUT_WP_MAX/OUT_WP_MAX_PQ;
// internal variables used by bpc function
const float OCES_BP_HDR = 0.0001;   // luminance of OCES black point. 
                                      // (to be mapped to device black point)
const float OCES_WP_HDR = MAX;     // luminance of OCES white point 
                                      // (to be mapped to device white point)
const float OUT_BP_HDR = OUT_BP;      // luminance of output device black point 
                                      // (to which OCES black point is mapped)
const float OUT_WP_HDR = OUT_WP_MAX_PQ; // luminance of output device white point
                                      // (to which OCES black point is mapped)    
	
// extract out 0-1 range from input that would be MSB justified 0-1
 float PQ2020[3];
 PQ2020[0] = (rIn - F_BLACK)/RANGE;
 PQ2020[1] = (gIn - F_BLACK)/RANGE;
 PQ2020[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 PQ2020 = clamp_f3(PQ2020, 0.0, 1.0);	
	

 float R2020[3];
 // scale by PQ10000_r(0.1) so that PQ2020[i] is at proper scale 
 // R2020 will come out from 0-0.1 or 1k nits
 // could later then be put into OCES and run through traditional tone curve for 709
  R2020[0] = PQ10000_f(PQ10000_r(RATIO)*PQ2020[0])*OUT_WP_MAX_PQ;
  R2020[1] = PQ10000_f(PQ10000_r(RATIO)*PQ2020[1])*OUT_WP_MAX_PQ;
  R2020[2] = PQ10000_f(PQ10000_r(RATIO)*PQ2020[2])*OUT_WP_MAX_PQ;
  
  R2020 = clamp_f3( R2020, 0., OCES_WP_HDR);
  // data is full range now
  
    // convert from  2020 RGB to XYZ
  float XYZ[3] = mult_f3_f44( R2020, R2020_PRI_2_XYZ_MAT);


  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}
