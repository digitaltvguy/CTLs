// 
// Inverse Rec709 Output Device Transform
// v0.7.1
//



import "utilities";
import "transforms-common";
import "odt-transforms-common";



/* ----- ODT Parameters ------ */
const Chromaticities DISPLAY_PRI = REC709_PRI;
const float XYZ_2_OCES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(DISPLAY_PRI,1.0);

const float DISPGAMMA = 2.4; 
const float L_W = 1.0;
const float L_B = 0.0;



void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float MAX = 100.0

)
{

// scale factor to put image through top of tone scale
const float OUT_WP_MAX = MAX;
const float SCALE_MAX = (OCES_WP_VIDEO/OUT_WP_VIDEO)*OUT_WP_MAX/DEFAULT_YMAX_ABS;
 
  /* --- Initialize a 3-element vector with input variables (0-1 CV) --- */
    float outputCV[3] = { rIn, gIn, bIn};

  /* --- SMPTE range to full range--- */
    outputCV = smpteRange_to_fullRange( outputCV);

  /* --- Decode to linear code values with inverse transfer function --- */
    float linearCV[3];
    linearCV[0] = bt1886_f( outputCV[0], DISPGAMMA, L_W, L_B);
    linearCV[1] = bt1886_f( outputCV[1], DISPGAMMA, L_W, L_B);
    linearCV[2] = bt1886_f( outputCV[2], DISPGAMMA, L_W, L_B);

  /* --- Convert from display primary encoding --- */
    // Display primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, DISPLAY_PRI_2_XYZ_MAT);

      // Apply CAT from assumed observer adapted white to ACES white point
      XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));
  
    // CIE XYZ to OCES RGB
    linearCV = mult_f3_f44( XYZ, XYZ_2_OCES_PRI_MAT);
  
  /* --- Apply inverse black point compensation --- */  
    float rgbPre[3] = bpc_inv( linearCV, SCALE_VIDEO, BPC_VIDEO, OUT_BP_VIDEO, OUT_WP_MAX);
    
    
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
   if(rgbPost[0] < OCES_MIN) oces[0] = rgbPre[0];
   if(rgbPost[1] < OCES_MIN) oces[1] = rgbPre[1];
   if(rgbPost[2] < OCES_MIN) oces[2] = rgbPre[2]; 
  
  /* --- Cast OCES to rOut, gOut, bOut --- */  
    rOut = oces[0];
    gOut = oces[1];
    bOut = oces[2];
}
