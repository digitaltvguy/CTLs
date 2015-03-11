// 
// Output Device Transform to Rec709
// v0.7.1
// with additional parameters
//



import "utilities";
import "transforms-common";
import "odt-transforms-common";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = REC709_PRI;
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);

//const float DISPGAMMA = 2.4; 
const float L_W = 1.0;
const float L_B = 0.0;

const float OUT_WP_MAX_PQ = 10000.0;


void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float MAX=100.0,
  input uniform float FUDGE = 1.0,
  input uniform float DISPGAMMA=2.4,
  input uniform float GAMMA_MAX = 0.0
)
{

// 700n 1.13, 1000n 1.17
// scale factor to put image through top of tone scale
float OUT_WP_MAX = MAX;
const float SCALE_MAX = pow((OCES_WP_VIDEO/(OUT_WP_VIDEO))*OUT_WP_MAX/DEFAULT_YMAX_ABS,FUDGE);
const float SCALE_MAX_TEST = (OCES_WP_VIDEO/OUT_WP_VIDEO)*OUT_WP_MAX/DEFAULT_YMAX_ABS;
//print(SCALE_MAX,"  ",SCALE_MAX_TEST, "  ", SCALE_MAX/SCALE_MAX_TEST,"\n");



  /* --- Initialize a 3-element vector with input variables (OCES) --- */
    float oces[3] = { rIn, gIn, bIn};
    
    
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
  float linearCV[3] = bpc_fwd( rgbPost, SCALE_VIDEO, BPC_VIDEO, OUT_BP_VIDEO, OUT_WP_MAX);
  
  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, OCES_PRI_2_XYZ_MAT);

  /* --- Handle out-of-gamut values --- */
    // Clip to P3 gamut using hue-preserving clip
    XYZ = huePreservingClip_to_p3d60( XYZ);

      // Apply CAT from ACES white point to assumed observer adapted white point
      XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

    // CIE XYZ to display RGB
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    // Note: there is no hue restore step here.
    linearCV = clamp_f3( linearCV, 0., 1.);


  // change peak if GAMMA_MAX used for actual 1.0, MAX will be MAX of the tone curve.
   if(GAMMA_MAX >= MAX) linearCV = mult_f_f3(MAX/GAMMA_MAX, linearCV); 

  /* --- Encode linear code values with transfer function --- */
    float outputCV[3];
    outputCV[0] = bt1886_r( linearCV[0], DISPGAMMA, L_W, L_B);
    outputCV[1] = bt1886_r( linearCV[1], DISPGAMMA, L_W, L_B);
    outputCV[2] = bt1886_r( linearCV[2], DISPGAMMA, L_W, L_B);
  
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    //aOut = aIn;
}
