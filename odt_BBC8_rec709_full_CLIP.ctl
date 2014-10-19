// 
// Output Device Transform to Rec709
// v0.7.1
// input -param1 MAX <value> sets top nits range and adjusts tone curve application
//

//
// Summary :
//  This transform is intended for mapping OCES onto a Rec.709 broadcast 
//  monitor that is calibrated to a D65 white point at 100 cd/m^2. The assumed 
//  observer adapted white is D65, and the viewing environment is that of a dark
//  theater. 
//
//
// Display EOTF :
//  The reference electro-optical transfer function specified in 
//  Rec. ITU-R BT.1886.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.3217       0.329
//
// Viewing Environment:
//  Environment specified in SMPTE RP 431-2-2007
//   Note: This environment is consistent with the viewing environment typical
//     of a motion picture theater. This ODT makes no attempt to compensate for 
//     viewing environment variables more typical of those associated with the 
//     home.
//



import "utilities";
import "transforms-common";
import "odt-transforms-common";
import "BBC";



/* --- ODT Parameters --- */
const Chromaticities DISPLAY_PRI = REC709_PRI;
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);

// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;

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
  output varying float bOut,
  input uniform float MAX = 1212.0,  
  input uniform float GAMMA = 1.2  // system gamma (double it)
)
{

// Calculate 100% L for V=1.0
const float WP_BBC = BBC_f8(1.0, GAMMA);

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


  /* --- Initialize a 3-element vector with input variables (OCES) --- */
    float oces[3] = { rIn, gIn, bIn};
    
    


  /* --- Apply black point compensation --- */ 
   float linearCV[3] = bpc_fwd( oces, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX); 
   // bpc_cinema_fwd( rgbPost);
   //float linearCV[3] = bpc_fwd( rgbPost, SCALE_VIDEO, BPC_VIDEO, OUT_BP_VIDEO, OUT_WP_MAX);
    

  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, OCES_PRI_2_XYZ_MAT);

      // Apply CAT from ACES white point to assumed observer adapted white point
      XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);

    // CIE XYZ to display primaries
    linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

 
   // clamp to 0-WP_BBC for signal range. WP_BBC will likey be 4 not 1
  /* --- Handle out-of-gamut values --- */
    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    // the scaled ODT above will have L as 0-1 but for BBC that is actually 0-4 if using
    // inverse BBC EOTF
    float linearCVClamp[3] = clamp_f3( linearCV, 0., 1.0);
  
    // Restore hue after clip operation ("smart-clip")
    linearCV = restore_hue_dw3( linearCV, linearCVClamp);
    
    // correct for BBC L going 0-4 and BBC V going 0-1
    linearCV = mult_f_f3(WP_BBC,linearCV);

  /* --- Encode linear code values with transfer function --- */
    float outputCV[3];
    outputCV[0] = (pow(2,BITDEPTH)-1) * BBC_r8( linearCV[0],GAMMA);
    outputCV[1] = (pow(2,BITDEPTH)-1) * BBC_r8( linearCV[1],GAMMA);
    outputCV[2] = (pow(2,BITDEPTH)-1) * BBC_r8( linearCV[2],GAMMA);
    //if (outputCV[1] < 2*CV_BLACK) print(BBC_r( WP_BBC * linearCV[1])/WP_BBC);
    outputCV = clamp_f3( outputCV, 0., pow( 2, BITDEPTH)-1);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);
  
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];

}
