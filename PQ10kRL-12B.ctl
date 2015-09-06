//Puts PQ10k onto content. This assumes input is linear and ranged 0-1 but
// output is scaled to 16-4076 so must be careful where used

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";

// assume that input file is tiff MSB justified in XYZ linear
// only apply PQ gamma to it.




const unsigned int BITDEPTH = 12;
const unsigned int CV_BLACK = 16;
const unsigned int CV_WHITE = pow( 2, BITDEPTH) - 20;



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
	
// since 12 bit input data is MSB justified in tiff
// it will look like 16 bit linear to ctlrender
// not doing any color matrix conversion
// for example half-scale input data will be floating point 0.5 in here
// e.g 12 bit 2048 then shifted >>4 and input here will be 50% range or 0.5
  float XYZ[3];
  	XYZ[0] = rIn ;
	XYZ[1] = gIn ;
	XYZ[2] = bIn ;
	//print ( XYZ[1], "   ");
	
	float tmp[3] = XYZ;

  float cctf[3];
  // Implement PQ gamma as 'decode' formula to get "Y":
  cctf[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp[0]);
  cctf[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp[1]);
  cctf[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp[2]); 
  

  //float outputCV[3] = clamp_f3( cctf, 0., pow( 2, BITDEPTH)-1);
  float outputCV[3] = clamp_f3( cctf, CV_BLACK, CV_WHITE);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = outputCV[0];
  gOut = outputCV[1];
  bOut = outputCV[2];
  //aOut = aIn;
}
