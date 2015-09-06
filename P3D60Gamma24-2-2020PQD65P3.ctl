

// 
// Convert Gamma 2.4 P3 D60 and put in PQ 2020 (Gary Demos HDR Nugget output)
//


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";

const Chromaticities P3D65_PRI =
{
  { 0.68000,  0.32000},
  { 0.26500,  0.69000},
  { 0.15000,  0.06000},
  { 0.31270,  0.32900}
};

const float P3D60_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(P3D60_PRI,1.0);
const Chromaticities DISPLAY_PRI = REC2020_PRI;
const float XYZ_2_DISPLAY_PRI_MAT[4][4] = XYZtoRGB(DISPLAY_PRI,1.0);


const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;



const float L_W = 1.0;
const float L_B = 0.0;



void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    input varying float aIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform int legalRange = 0,
    input uniform float peak = 1000.0
)
{
	
    float G24[3] = { rIn, gIn, bIn};
    G24 = clamp_f3( G24, FLT_MIN, 1.0);


  // Decode with inverse PQ transfer function
    float linearCV[3];
    linearCV[0] = bt1886_f( G24[0], 2.4, L_W, L_B);
    linearCV[1] = bt1886_f( G24[1], 2.4, L_W, L_B);
    linearCV[2] = bt1886_f( G24[2], 2.4, L_W, L_B);
    
  // Clip range to where you want 1.0 in gamma to be
    linearCV = clamp_f3( linearCV, FLT_MIN, 1.0);
    
    
  /* --- Convert to display primary encoding --- */
    // OCES RGB to CIE XYZ
    float XYZ[3] = mult_f3_f44( linearCV, P3D60_PRI_2_XYZ_MAT);
    XYZ = clamp_f3( XYZ, FLT_MIN, 1.0);

   // Apply CAT from ACES white point to assumed observer adapted white point
    XYZ = mult_f3_f33( XYZ, D60_2_D65_CAT);  
    
   // Convert to P3 D65
   linearCV = mult_f3_f44( XYZ, XYZ_2_DISPLAY_PRI_MAT);  
   linearCV = clamp_f3( linearCV, FLT_MIN, 1.0);
   linearCV = mult_f_f3(peak/10000.0, linearCV);
    
  
  float cctf[3]; 
  cctf[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(linearCV[0]);
  cctf[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(linearCV[1]);
  cctf[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * PQ10000_r(linearCV[2]); 
  

  float outputCV[3] = clamp_f3( cctf, 0., pow( 2, BITDEPTH)-1);

  // This step converts integer CV back into 0-1 which is what CTL expects
  outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);

  // Default output is full range, check if legalRange param was set to true
    if (legalRange == 1) {
    outputCV = fullRange_to_smpteRange( outputCV);
    }
  
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}
