// 



import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "HuePreservingClipP3D65";
import "BBC";
import  "PQ";

const Chromaticities ACES_PRI_D65 =
{
  { 0.73470,  0.26530},
  { 0.00000,  1.00000},
  { 0.00010, -0.07700},
  { 0.31270,  0.32900}
};



/* --- ODT Parameters --- */
const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC2020_PRI,1.0);
const float XYZ_2_OCES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI_D65,1.0);
const Chromaticities DISPLAY_PRI = P3D65_PRI;
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI_D65,1.0);
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);

// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX_PQ = 10000.0; //speculars

const float DISPGAMMA = 2.4; 
const float L_W = 1.0;
const float L_B = 0.0;

const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;
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
  output varying float bOut,
  input uniform float MAX = 1200.0  
)
{


// scale factor to put image through top of tone scale
const float OUT_WP_MAX = MAX;
const float RATIO = OUT_WP_MAX/OUT_WP_MAX_PQ;
const float SCALE_MAX = pow((OCES_WP_VIDEO/(OUT_WP_VIDEO))*OUT_WP_MAX/DEFAULT_YMAX_ABS,1.13);

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
// PQ 2020 to XYZ

// extract out 0-1 range from input that would be MSB justified 0-1
 float PQ2020[3];
 PQ2020[0] = (rIn - F_BLACK)/RANGE;
 PQ2020[1] = (gIn - F_BLACK)/RANGE;
 PQ2020[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 PQ2020 = clamp_f3(PQ2020, 0.0, 1.0);	
	

 float R2020[3];
 // scale by PQ10000_r(0.1) or "RATIO" so that PQ2020[i] is at proper scale 
 // R2020 will come out from 0-0.1 or 1k nits (0 - RATIO)
 // could later then be put into OCES and run through traditional tone curve for 709
  R2020[0] = PQ10000_f(PQ2020[0]);
  R2020[1] = PQ10000_f(PQ2020[1]);
  R2020[2] = PQ10000_f(PQ2020[2]);
  
  R2020 = clamp_f3( R2020, 0., 1.0);
  // data is full range 0-1 now
  
// convert from  2020 RGB to XYZ
  /* --- Convert from display primary encoding --- */
    // Display primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( R2020, R2020_PRI_2_XYZ_MAT);

   // XYZ to OCESD65 and Inv BPC
    // CIE XYZ to OCES RGB
   float tmp[3] = mult_f3_f44( XYZ, XYZ_2_OCES_PRI_MAT);
  
  /* --- Apply inverse black point compensation --- */  
    float oces[3] = bpc_inv( tmp, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX_PQ);    
    
  /* -- scale to put image through top of tone scale */
  float ocesScale[3];
	  ocesScale[0] = oces[0]/SCALE_MAX;
	  ocesScale[1] = oces[1]/SCALE_MAX;
	  ocesScale[2] = oces[2]/SCALE_MAX; 
	       

  /* --- Apply hue-preserving tone scale with saturation preservation --- */
    float rgbPost[3] = odt_tonescale_fwd_f3( ocesScale);
    
  /* scale image back to proper range */
   rgbPost[0] = SCALE_MAX * rgbPost[0];
   rgbPost[1] = SCALE_MAX * rgbPost[1];
   rgbPost[2] = SCALE_MAX * rgbPost[2]; 
          
    
// Restore any values that would have been below 0.0001 going into the tone curve
// basically when oces is divided by SCALE_MAX (ocesScale) any value below 0.0001 will be clipped
   if(ocesScale[0] < OCESMIN) rgbPost[0] = oces[0];
   if(ocesScale[1] < OCESMIN) rgbPost[1] = oces[1];
   if(ocesScale[2] < OCESMIN) rgbPost[2] = oces[2];      
   

  /* --- Apply black point compensation --- */ 
   tmp = bpc_fwd( rgbPost, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX_PQ);

  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    XYZ = mult_f3_f44( tmp, OCES_PRI_2_XYZ_MAT);
    
  
    
// Get to P3
  /* --- Handle out-of-gamut values --- */
    // Clip to P3 gamut using hue-preserving clip
    XYZ = huePreservingClip_to_p3d65( XYZ);	
    
    
  // Convert to 2020
  tmp = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT); 
  

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


}
