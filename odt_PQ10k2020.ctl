// PQ 10k
// for 2020 video
// range limites to 16 bit legal video range
// NO Tone Curve

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "PQ";

/* ----- ODT Parameters ------ */
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);


// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX = 10000.0; //speculars


const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;


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
	
	
// internal variables used by bpc function
const float OCES_BP_HDR = 0.0001;   // luminance of OCES black point. 
                                      // (to be mapped to device black point)
const float OCES_WP_HDR = OCES_WP_VIDEO;     // luminance of OCES white point 
                                      // (to be mapped to device white point)
const float OUT_BP_HDR = OUT_BP;      // luminance of output device black point 
                                      // (to which OCES black point is mapped)
const float OUT_WP_HDR = OUT_WP_VIDEO; // luminance of output device nominal white point
                                      // (to which OCES black point is mapped)
const float BPC_HDR = (OCES_BP_HDR * OUT_WP_HDR - OCES_WP_HDR * OUT_BP_HDR) / (OCES_BP_HDR - OCES_WP_HDR);
const float SCALE_HDR = (OUT_BP_HDR - OUT_WP_HDR) / (OCES_BP_HDR - OCES_WP_HDR); 
	
  // Put input variables (OCES) into a 3-element vector
  float oces[3] = {rIn, gIn, bIn};
  //print(rIn, ", ",gIn, ", ",bIn,", \n");

// No HDR TONE SCALE ... let data clip on both min/max
  /* --- Apply black point compensation --- */  
   float linearCV[3] = bpc_fwd( oces, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX); // 

  // Translate rendered RGB to CIE XYZ
  float XYZ[3] = mult_f3_f44( linearCV, OCES_PRI_2_XYZ_MAT);
  
	// Apply CAT from ACES white point to assumed observer adapted white point
	XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);  
  
  // Convert to 2020
  float rgbOut[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT); 
  

  float tmp2[3] = clamp_f3(rgbOut,0.,1.0); 
  //if(tmp2[0]>9.7)print("tmp2[0]= ",tmp2[0],"\n");
  //if(tmp2[1]>1.0)print("SCALE: ",SCALE, " tmp2[1]= ",tmp2[1],"\n");
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
