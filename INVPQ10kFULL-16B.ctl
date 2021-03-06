// removes PQ 10k from content and puts into linear
// assumes content is 16-4076 for 0-1 range.
// 12bits


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";

// assume that input file is tiff MSB justified in XYZ linear
// remove PQ gamma




const unsigned int BITDEPTH = 16;
const unsigned int CV_BLACK = 0;
const unsigned int CV_WHITE = pow( 2, BITDEPTH) - 1;
const float OUT_BP = 0.0; // 0.005;
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
	
// scale up and extract 0-1 range
float tmp[3];
tmp[0] = rIn;
tmp[1] = gIn;
tmp[2] = bIn;

// scale up to BitDepth
 float XYZ[3] = mult_f_f3( (pow(2,BITDEPTH)-1), tmp);
 
// extract range
tmp[0] = (XYZ[0] - CV_BLACK)/(CV_WHITE - CV_BLACK);
tmp[1] = (XYZ[1] - CV_BLACK)/(CV_WHITE - CV_BLACK);
tmp[2] = (XYZ[2] - CV_BLACK)/(CV_WHITE - CV_BLACK);
 
 float tmp2[3] = clamp_f3( tmp, 0., 1.0);
 
  XYZ[0] = PQ10000_f(tmp2[0])*OUT_WP_MAX;
  XYZ[1] = PQ10000_f(tmp2[1])*OUT_WP_MAX;
  XYZ[2] = PQ10000_f(tmp2[2])*OUT_WP_MAX;
  
// data now in linear 0-1 range
 

  float outputCV[3] = clamp_f3( XYZ, 0., 65535.0);


  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = outputCV[0];
  gOut = outputCV[1];
  bOut = outputCV[2];
  //aOut = aIn;
}
