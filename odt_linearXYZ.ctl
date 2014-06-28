// 
// Output Device Transform to X'Y'Z'
// v0.7.1
//

// 
// Summary :
//  The output of this transform follows the encoding specified in SMPTE 
//  S428-1-2006. The gamut is a device-independent colorimetric encoding based  
//  on CIE XYZ. Therefore, output values are not limited to any physical 
//  device's actual color gamut that is determined by its color primaries.
// 
//  The assumed observer adapted white is D60, and the viewing environment is 
//  that of a dark theater. 
//
//  This transform shall be used for a device calibrated to match the Digital 
//  Cinema Reference Projector Specification outlined in SMPTE RP 431-2-2007.
//
// Assumed observer adapted white point:
//         CIE 1931 chromaticities:    x            y
//                                     0.32168      0.33767
//
// Viewing Environment:
//  Environment specified in SMPTE RP 431-2-2007
//



import "utilities";
import "transforms-common";
import "odt-transforms-common";



/* --- ODT Parameters --- */
const float OCES_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);

const float DISPGAMMA = 2.6; 



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
  /* --- Initialize a 3-element vector with input variables (OCES) --- */
    float oces[3] = { rIn, gIn, bIn};

  /* --- Apply hue-preserving tone scale with saturation preservation --- */
    float rgbPost[3] = odt_tonescale_fwd_f3( oces);

  /* --- Apply black point compensation --- */  
    float linearCV[3] = bpc_cinema_fwd( rgbPost);

  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, OCES_PRI_2_XYZ_MAT);

  /* --- Handle out-of-gamut values --- */
    // There should not be any negative values but will clip just to ensure no 
    // math errors occur with the gamma function in the encoding function.
    //XYZ = clamp_f3( XYZ, 0., 1.);


    
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = XYZ[0];
    gOut = XYZ[1];
    bOut = XYZ[2];
}
