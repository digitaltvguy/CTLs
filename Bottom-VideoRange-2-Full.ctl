


import "ACESlib.Utilities.a1.0.1";


//assumes input file is in PQ ranged 0-1

const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 65535;
const float F_BLACK = CV_BLACK/65535.0;
const float F_WHITE = CV_WHITE/65535.0;
const float RANGE = F_WHITE - F_BLACK;



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
 float RGBFULL[3];
 RGBFULL[0] = (rIn - F_BLACK)/RANGE;
 RGBFULL[1] = (gIn - F_BLACK)/RANGE;
 RGBFULL[2] = (bIn - F_BLACK)/RANGE;
 
  RGBFULL = clamp_f3( RGBFULL, 0, 1.0);
 

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = RGBFULL[0];
  gOut = RGBFULL[1];
  bOut = RGBFULL[2];
  //aOut = aIn;
}
