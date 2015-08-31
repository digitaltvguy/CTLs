// 
// Inverse Rec709 Output Device Transform
// v0.7.1
// input -param1 MAX <value> sets top nits range and adjusts tone curve application
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
  output varying float bOut

)
{

// scale factor to put image through top of tone scale
const float OUT_WP_MAX = 100;
 
  /* --- Initialize a 3-element vector with input variables (0-1 CV) --- */
    float outputCV[3] = { rIn, gIn, bIn};

  /* --- Decode to linear code values with inverse transfer function --- */
    float linearCV[3];
    linearCV[0] = bt1886_f( outputCV[0], DISPGAMMA, L_W, L_B)*.25;
    linearCV[1] = bt1886_f( outputCV[1], DISPGAMMA, L_W, L_B)*.25;
    linearCV[2] = bt1886_f( outputCV[2], DISPGAMMA, L_W, L_B)*.25;

    // Clip values < 0 or > 1 (i.e. projecting outside the display primaries)
    // Note: there is no hue restore step here.
    linearCV = clamp_f3( linearCV, 0., 1.);

  /* --- Encode linear code values with transfer function --- */
    outputCV[0] = bt1886_r( linearCV[0], DISPGAMMA, L_W, L_B);
    outputCV[1] = bt1886_r( linearCV[1], DISPGAMMA, L_W, L_B);
    outputCV[2] = bt1886_r( linearCV[2], DISPGAMMA, L_W, L_B);
  
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    //aOut = aIn;
}
