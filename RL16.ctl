// Convert full range to video legal range
import "utilities";

const unsigned int BITDEPTH = 16;
const unsigned int CV_BLACK = 64*64;
const unsigned int CV_WHITE = 64*64+876*64;



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
  float tmp[3];
  	tmp[0] = rIn ;
	tmp[1] = gIn ;
	tmp[2] = bIn ;
	//print ( XYZ[1], "   ");
	
  tmp = mult_f_f3( (CV_WHITE - CV_BLACK), tmp);

  float cctf[3];
  // Implement PQ gamma as 'decode' formula to get "Y":
  cctf[0] = CV_BLACK + tmp[0];
  cctf[1] = CV_BLACK + tmp[1];
  cctf[2] = CV_BLACK + tmp[2]; 
  

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
