// Assume full range input. Inverse PQ as 0-1
// NOTE: Now includes inverse TONE MAPPING
// REMOVES GAMMA and multiplies from 2020 to XYZ
//
//

import "utilities";
import "transforms-common";
import "odt-transforms-common";
import "utilities-color";
import "PQ";

// assume that input file is tiff MSB justified in 2020 PQ
// remove PQ gamma output will be full range 2020 linear 16 bit
// remove ODT tone curve
// resulting output is back at OCES point in ACES primaries

/* ----- ODT Parameters ------ */
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_OCES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);




const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;
const float F_BLACK = CV_BLACK/65535.0;
const float F_WHITE = CV_WHITE/65535.0;
const float RANGE = F_WHITE - F_BLACK;

// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX_PQ = 10000.0; //speculars
const float R2020_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);


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
const float RATIO = OUT_WP_MAX/OUT_WP_MAX_PQ;
const float SCALE_MAX = (OCES_WP_VIDEO/OUT_WP_VIDEO)*OUT_WP_MAX/DEFAULT_YMAX_ABS;

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
  R2020[0] = PQ10000_f(PQ10000_r(RATIO)*PQ2020[0]);
  R2020[1] = PQ10000_f(PQ10000_r(RATIO)*PQ2020[1]);
  R2020[2] = PQ10000_f(PQ10000_r(RATIO)*PQ2020[2]);
  
  R2020 = clamp_f3( R2020, 0., RATIO);
  // data is full range now
  
    // convert from  2020 RGB to XYZ
  /* --- Convert from display primary encoding --- */
    // Display primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( R2020, DISPLAY_PRI_2_XYZ_MAT);

      // Apply CAT from assumed observer adapted white to ACES white point
      XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));
  
    // CIE XYZ to OCES RGB
   float linearCV[3] = mult_f3_f44( XYZ, XYZ_2_OCES_PRI_MAT);
  
  /* --- Apply inverse black point compensation --- */  
    float rgbPre[3] = bpc_inv( linearCV, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX_PQ); 
  
  /* scale RGB prior to inverse tone map */
  float rgbPost[3];
  rgbPost[0] = rgbPre[0]/SCALE_MAX;
  rgbPost[1] = rgbPre[1]/SCALE_MAX;
  rgbPost[2] = rgbPre[2]/SCALE_MAX;
  
  /* --- Apply inverse hue-preserving tone scale w/ sat preservation --- */
    float oces[3] = odt_tonescale_inv_f3( rgbPost);
    
  /* restore scale back after inverse tone map */
  oces[0] = SCALE_MAX * oces[0];
  oces[1] = SCALE_MAX * oces[1];
  oces[2] = SCALE_MAX * oces[2];
  
// Restore any values that would have been below 0.0001 going into the tone curve
// basically when oces is divided by SCALE_MAX any value below 0.0001 will be clipped
   if(rgbPost[0] < 0.0001) oces[0] = rgbPre[0];
   if(rgbPost[1] < 0.0001) oces[1] = rgbPre[1];
   if(rgbPost[2] < 0.0001) oces[2] = rgbPre[2];  
  
  /* --- Cast OCES to rOut, gOut, bOut --- */  
    rOut = oces[0];
    gOut = oces[1];
    bOut = oces[2];
}
