// PQ any k for 2020 video
// *NOTE* includes tone mapping and gamma
// for 2020 video
// range limites to 16 bit legal video range

import "utilities";
import "transforms-common";
import "odt-transforms-common";
import "utilities-color";
import "PQ";

/* ----- ODT Parameters ------ */
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);


// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX_PQ = 10000.0; //speculars


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
  output varying float bOut,
  input uniform float MAX = 1000.0  
)
{

// scale factor to put image through top of tone scale
const float OUT_WP_MAX = MAX;
const float SCALE_MAX = OUT_WP_MAX/(100.0 - 0.04*(OUT_WP_MAX-100.0));
// internal variables used by bpc function
const float OCES_BP_HDR = 0.0001;   // luminance of OCES black point. 
                                      // (to be mapped to device black point)
const float OCES_WP_HDR = MAX;     // luminance of OCES white point 
                                      // (to be mapped to device white point)
const float OUT_BP_HDR = OUT_BP;      // luminance of output device black point 
                                      // (to which OCES black point is mapped)
const float OUT_WP_HDR = OUT_WP_MAX_PQ; // luminance of output device white point
                                      // (to which OCES black point is mapped)
const float BPC_HDR = (OCES_BP_HDR * OUT_WP_HDR - OCES_WP_HDR * OUT_BP_HDR) / (OCES_BP_HDR - OCES_WP_HDR);
const float SCALE_HDR = (OUT_BP_HDR - OUT_WP_HDR) / (OCES_BP_HDR - OCES_WP_HDR);                                      
                                      	
  /* --- Initialize a 3-element vector with input variables (OCES) --- */
    float oces[3] = { rIn, gIn, bIn};

  /* -- scale to put image through top of tone scale */
	  oces[0] = oces[0]/SCALE_MAX;
	  oces[1] = oces[1]/SCALE_MAX;
	  oces[2] = oces[2]/SCALE_MAX; 
	  
	      

  /* --- Apply hue-preserving tone scale with saturation preservation --- */
    float rgbPost[3] = odt_tonescale_fwd_f3( oces);
    
  /* scale image back to proper range */
   rgbPost[0] = SCALE_MAX * rgbPost[0];
   rgbPost[1] = SCALE_MAX * rgbPost[1];
   rgbPost[2] = SCALE_MAX * rgbPost[2];      
    
    

  /* --- Apply black point compensation --- */  
   float linearCV[3] = bpc_fwd( rgbPost, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_HDR); // bpc_cinema_fwd( rgbPost);
    
  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, OCES_PRI_2_XYZ_MAT);

  /* --- Handle out-of-gamut values --- */
    // Clip to P3 gamut using hue-preserving clip
    XYZ = huePreservingClip_to_p3d60( XYZ);

    // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);
 
  // Convert to 2020
  float tmp[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT); 
  

  // clamp to 10% or 1k nits and scale output to go from 0-1k nits across whole code value range 
  tmp[0] = tmp[0]*0.1;
  tmp[1] = tmp[1]*0.1;
  tmp[2] = tmp[2]*0.1;
  float tmp2[3] = clamp_f3(tmp,0.,0.1); 
  //if(tmp2[0]>9.7)print("tmp2[0]= ",tmp2[0],"\n");
  //if(tmp2[1]>1.0)print("SCALE: ",SCALE, " tmp2[1]= ",tmp2[1],"\n");
  //if(tmp2[2]>9.7)print("tmp2[2]= ",tmp2[2],"\n");

  float cctf[3]; 
  cctf[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[0])/PQ10000_r(0.1);
  cctf[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[1])/PQ10000_r(0.1);
  cctf[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(tmp2[2])/PQ10000_r(0.1); 
  

  float outputCV[3] = clamp_f3( cctf, 0., pow( 2, BITDEPTH)-1);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = outputCV[0];
  gOut = outputCV[1];
  bOut = outputCV[2];
  //aOut = aIn;
}
