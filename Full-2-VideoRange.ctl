

import "ACESlib.Utilities.a1.0.1";

const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;

// Derived BPC and scale parameters
//const float BPC = (ODT_OCES_BP * OUT_WP - ODT_OCES_WP * OUT_BP) / (ODT_OCES_BP - ODT_OCES_WP);
//const float SCALE = (OUT_BP - OUT_WP) / (ODT_OCES_BP - ODT_OCES_WP);

const float BPC = 0.; // above are not used for HDR tonecurve
const float SCALE = 1.;

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
  float RGBFULL[3] = {rIn, gIn, bIn};
  RGBFULL = clamp_f3( RGBFULL, 0., 1.0);

  float RGBVIDEO[3];
  RGBVIDEO[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * RGBFULL[0];
  RGBVIDEO[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * RGBFULL[1];
  RGBVIDEO[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * RGBFULL[2]; 
  



  // This step converts integer CV back into 0-1 which is what CTL expects
  RGBVIDEO = mult_f_f3( 1./(pow(2,BITDEPTH)-1), RGBVIDEO);
  

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = RGBVIDEO[0];
  gOut = RGBVIDEO[1];
  bOut = RGBVIDEO[2];
  //aOut = aIn;
}
