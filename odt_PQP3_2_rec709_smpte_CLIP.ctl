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
const float RP3_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D65_PRI,1.0);
const float XYZ_2_OCES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI_D65,1.0);
const Chromaticities DISPLAY_PRI = REC709_PRI;
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI_D65,1.0);
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);

// ODT parameters related to black point compensation (BPC) and encoding
const float OUT_BP = 0.0; //0.005;
const float OUT_WP_MAX_PQ = 10000.0; //speculars

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
  input uniform float MAX=100.0,
  input uniform float DISPGAMMA=2.4  
)
{


// scale factor to put image through top of tone scale
const float OUT_WP_MAX = MAX;


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
// PQ P3 to XYZ

// extract out 0-1 range from input that would be MSB justified 0-1
 float PQP3[3];
 PQP3[0] = (rIn - F_BLACK)/RANGE;
 PQP3[1] = (gIn - F_BLACK)/RANGE;
 PQP3[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 PQP3 = clamp_f3(PQP3, 0.0, 1.0);	
	

 float RP3[3];
 // scale by PQ10000_r(0.1) or "RATIO" so that PQP3[i] is at proper scale 
 // RP3 will come out from 0-0.1 or 1k nits (0 - RATIO)
 // could later then be put into OCES and run through traditional tone curve for 709
  RP3[0] = PQ10000_f(PQP3[0]);
  RP3[1] = PQ10000_f(PQP3[1]);
  RP3[2] = PQ10000_f(PQP3[2]);
  
  RP3 = clamp_f3( RP3, 0., 1.0);
  // data is full range 0-1 now
  
// convert from  P3 RGB to XYZ
  /* --- Convert from display primary encoding --- */
    // Display primaries to CIE XYZ
    float XYZ[3] = mult_f3_f44( RP3, RP3_PRI_2_XYZ_MAT);

   // XYZ to OCES and Inv BPC
    // CIE XYZ to OCES RGB
   float tmp[3] = mult_f3_f44( XYZ, XYZ_2_OCES_PRI_MAT);
  
  /* --- Apply inverse black point compensation --- */  
    float oces[3] = bpc_inv( tmp, SCALE_HDR, BPC_HDR, OUT_BP_HDR, OUT_WP_MAX_PQ);    
   
  /* --- Apply black point compensation --- */ 
   tmp = bpc_fwd( oces, SCALE_VIDEO, BPC_VIDEO, OUT_BP_VIDEO, OUT_WP_MAX); 

  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    XYZ = mult_f3_f44( tmp, OCES_PRI_2_XYZ_MAT);
    
// Get to P3
  /* --- Handle out-of-gamut values --- */
    // Clip to P3 gamut using hue-preserving clip
    XYZ = huePreservingClip_to_p3d65( XYZ);		

// XYZ to BBC 709 CLIP

    // CIE XYZ to display RGB
    float linearCV[3] = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);

    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    // Note: there is no hue restore step here.
    linearCV = clamp_f3( linearCV, 0., 1.);
    

  /* --- Encode linear code values with transfer function --- */
    float outputCV[3];
    outputCV[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * bt1886_r( linearCV[0], DISPGAMMA, L_W, L_B);
    outputCV[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * bt1886_r( linearCV[1], DISPGAMMA, L_W, L_B);
    outputCV[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * bt1886_r( linearCV[2], DISPGAMMA, L_W, L_B);
    //if (outputCV[1] < 2*CV_BLACK) print(BBC_r( WP_BBC * linearCV[1])/WP_BBC);
    outputCV = clamp_f3( outputCV, 0., pow( 2, BITDEPTH)-1);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);
  
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];

}
