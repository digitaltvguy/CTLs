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
  input uniform float MAX = 10000.0   
)
{
	
	const float OUT_WP_MAX = MAX;
    const float RATIO = OUT_WP_MAX/OUT_WP_MAX_PQ;
   
	
// extract out 0-1 range from input that would be MSB justified 0-1
 float tmp[3];
 tmp[0] = (rIn - F_BLACK)/RANGE;
 tmp[1] = (gIn - F_BLACK)/RANGE;
 tmp[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 tmp = clamp_f3(tmp, 0.0, 1.0);	
	

 float OUT[3];
 // scale by PQ10000_r(0.1) so that OUT[i] is at proper scale 
 // tmp will come out from 0-0.1 or 1k nits
 // could later then be put into OCES and run through traditional tone curve for 709
  OUT[0] = PQ10000_f(PQ10000_r(RATIO)*tmp[0])*OUT_WP_MAX_PQ;
  OUT[1] = PQ10000_f(PQ10000_r(RATIO)*tmp[1])*OUT_WP_MAX_PQ;
  OUT[2] = PQ10000_f(PQ10000_r(RATIO)*tmp[2])*OUT_WP_MAX_PQ;
  
  OUT = clamp_f3( OUT, 0., OUT_WP_MAX);
  // data is full range now
  

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = OUT[0];
  gOut = OUT[1];
  bOut = OUT[2];
  //aOut = aIn;
}
