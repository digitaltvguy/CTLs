// PQ 10k
// X'Y'Z'

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";




/* ----- ODT Parameters ------ */
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);

const Chromaticities D65_XYZ_PRI =
{
  { 1.0, 0.0},
  { 0.0, 1.0},
  { 0.0, 0.0},
  { 0.31270,  0.32900}
};

const float XYZ_2_D65_XYZ_PRI_MAT[4][4] = XYZtoRGB(D65_XYZ_PRI ,1.0);
const float D65_XYZ_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(D65_XYZ_PRI,1.0);



// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX = 10000.0; //speculars


const float DISPGAMMA = 2.6; // not used
const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;

const float BPC = 0.; // these are not used for HDR tonecurve
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
  float oces[3] = {rIn, gIn, bIn};
  //print(rIn, ", ",gIn, ", ",bIn,", \n");
//print_f44(XYZ_2_D65_XYZ_PRI_MAT);
//print_f44(D65_XYZ_PRI_2_XYZ_MAT);
// No HDR TONE SCALE ... let data clip on both min/max

  // Translate rendered RGB to CIE XYZ
  float XYZ[3] = mult_f3_f44( oces, OCES_PRI_2_XYZ_MAT);
  float rgbOut[3] = XYZ; // ready to add scale and then PQ for X'Y'Z'

  // Black Point Compensation
  float offset_scaled[3];
  offset_scaled[0] = (SCALE * rgbOut[0]) + BPC;
  offset_scaled[1] = (SCALE * rgbOut[1]) + BPC;
  offset_scaled[2] = (SCALE * rgbOut[2]) + BPC;
  
  // convert to D65 XYZ RGB
  offset_scaled = mult_f3_f44( offset_scaled, XYZ_2_D65_XYZ_PRI_MAT);
 

  // CCTF
  float tmp[3];
  tmp[0] = max( (offset_scaled[0] - OUT_BP)/(OUT_WP_MAX - OUT_BP), 0.);
  tmp[1] = max( (offset_scaled[1] - OUT_BP)/(OUT_WP_MAX - OUT_BP), 0.);
  tmp[2] = max( (offset_scaled[2] - OUT_BP)/(OUT_WP_MAX - OUT_BP), 0.);
 
  float tmp2[3] = clamp_f3(tmp,0.,65000.0); 
  //if(tmp2[0]>9.7)print("tmp2[0]= ",tmp2[0],"\n");
  if(tmp2[1]>1.0)print("SCALE: ",SCALE, " tmp2[1]= ",tmp2[1],"\n");
  //if(tmp2[2]>9.7)print("tmp2[2]= ",tmp2[2],"\n");

  float cctf[3];
  cctf[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[0]);
  cctf[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[1]);
  cctf[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[2]); 
  

  float outputCV[3] = clamp_f3( cctf, 0., pow( 2, BITDEPTH)-1);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = outputCV[0];
  gOut = outputCV[1];
  bOut = outputCV[2];
  //aOut = aIn;
}
