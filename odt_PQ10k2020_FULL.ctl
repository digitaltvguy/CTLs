// PQ any k for 2020 video
// no tone mapping
// for 2020 video
// range limites to 16 bit FULL range

import "utilities";
import "transforms-common";
import "odt-transforms-common";
import "utilities-color";
import "PQ";

/* ----- ODT Parameters ------ */
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);

// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX_PQ = 10000.0; //speculars


const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;



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

// 700n 1.13, 1000n 1.17
// scale factor to put image through top of tone scale
float OUT_WP_MAX = MAX;
const float RATIO = 1.0;



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
// from odt-transforms:                                     
// bpc_fwd( rgb, SCALE_VIDEO, BPC_VIDEO, OUT_BP_VIDEO, OUT_WP_VIDEO);
// BPC_VIDEO = (OCES_BP_VIDEO * OUT_WP_VIDEO - OCES_WP_VIDEO * OUT_BP_VIDEO) / (OCES_BP_VIDEO - OCES_WP_VIDEO);
// SCALE_VIDEO = (OUT_BP_VIDEO - OUT_WP_VIDEO) / (OCES_BP_VIDEO - OCES_WP_VIDEO);  

                                  	
  /* --- Initialize a 3-element vector with input variables (OCES) --- */
    float oces[3] = { rIn, gIn, bIn};
    

    

  /* --- Apply black point compensation --- */  
   float linearCV[3] = bpc_fwd( oces, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX_PQ); // bpc_cinema_fwd( rgbPost);
   
    
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
  
  /* Desaturate negative values going to DISPLAY Gamut */
  int inds[3] = order3( tmp[0], tmp[1], tmp[2]);
  if(tmp[inds[2]]<0.0){
	  float origY = tmp[1];
	  tmp[inds[2]]= -tmp[inds[2]]*1.3 + tmp[inds[2]];
	  tmp[inds[1]]= -tmp[inds[2]]*1.3 + tmp[inds[1]];
	  tmp[inds[0]]= -tmp[inds[2]]*1.3 + tmp[inds[0]];
	  float newXYZ[3] = mult_f3_f44( tmp, DISPLAY_PRI_2_XYZ_MAT);
	  float scaleY = fabs(origY/newXYZ[1]);
	  tmp = mult_f_f3(scaleY,tmp);    
	}
  // clamp to 10% if 1k (RATIO) or 1k nits and scale output to go from 0-1k nits across whole code value range 
  float tmp2[3] = clamp_f3(tmp,0.,RATIO); // no clamp is 1.0 , clamp if RATIO


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
