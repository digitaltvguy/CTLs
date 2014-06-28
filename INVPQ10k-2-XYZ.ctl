
// Limit input to 16 bit video range. Inverse PQ as 0-1

import "utilities";
import "utilities-color";
import "PQ";

// assume that input file is tiff MSB justified in XYZ PQ
// remove PQ gamma output will be full range XYZ linear 16 bit

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
 float XYZPQ[3];
 XYZPQ[0] = (rIn - F_BLACK)/RANGE;
 XYZPQ[1] = (gIn - F_BLACK)/RANGE;
 XYZPQ[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 XYZPQ = clamp_f3(XYZPQ, 0.0, 1.0);
   
   
 // inverse PQ
 float XYZ[3];
  XYZ[0] = PQ10000_f(XYZPQ[0])*OUT_WP_MAX;
  XYZ[1] = PQ10000_f(XYZPQ[1])*OUT_WP_MAX;
  XYZ[2] = PQ10000_f(XYZPQ[2])*OUT_WP_MAX;
  

  XYZ = clamp_f3( XYZ, 0., OUT_WP_MAX);


  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = XYZ[0];
  gOut = XYZ[1];
  bOut = XYZ[2];
  //aOut = aIn;
}
