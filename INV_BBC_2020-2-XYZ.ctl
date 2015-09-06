// 
// Inverse Rec709 Output Device Transform
// v0.7.1
// input -param1 MAX <value> sets top nits range and adjusts tone curve application
//



import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "BBC";


/* ----- ODT Parameters ------ */
const float XYZ_2_OCES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);
const float DISPLAY_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC2020_PRI,1.0);

// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
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
  input uniform float MAX = 400.0

)
{

// Calculate 100% L for V=1.0
const float WP_BBC = BBC_f(1.0, 1.2);

// scale factor to put image through top of tone scale
const float OUT_WP_MAX = MAX;
const float SCALE_MAX = (OCES_WP_VIDEO/(OUT_WP_VIDEO))*OUT_WP_MAX/DEFAULT_YMAX_ABS;

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
 
  /* --- Initialize a 3-element vector with input variables (0-1 CV) --- */
    float outputCV[3];
	 outputCV[0] = (rIn - F_BLACK)/RANGE;
	 outputCV[1] = (gIn - F_BLACK)/RANGE;
	 outputCV[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 outputCV = clamp_f3(outputCV, 0.0, 1.0);

  /* --- Decode to linear code values with inverse transfer function --- */
    float linearCV[3];
    linearCV[0] = BBC_f( outputCV[0], 1.2);
    linearCV[1] = BBC_f( outputCV[1], 1.2);
    linearCV[2] = BBC_f( outputCV[2], 1.2);
    
    // correct for BBC L going 0-4 and BBC V going 0-1
    linearCV = mult_f_f3(OUT_WP_MAX/WP_BBC,linearCV);    

  /* --- Convert from display primary encoding --- */
    // Display primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, DISPLAY_PRI_2_XYZ_MAT);

  
  /* --- Cast OCES to rOut, gOut, bOut --- */  
    rOut = XYZ[0];
    gOut = XYZ[1];
    bOut = XYZ[2];
}
