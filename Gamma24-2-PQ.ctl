

// 
// Convert Gamma 2.4 100 nits to PQ 800 nits
//


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";


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
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform int legalRange = 1,
    input uniform float peak = 800.0
)
{
	
    float G24[3] = { rIn, gIn, bIn};
    
    //manually set these
    //G24 = smpteRange_to_fullRange( G24);


  // Decode with inverse PQ transfer function
    float linearCV[3];
    linearCV[0] = bt1886_f( G24[0], 2.4, L_W, L_B);
    linearCV[1] = bt1886_f( G24[1], 2.4, L_W, L_B);
    linearCV[2] = bt1886_f( G24[2], 2.4, L_W, L_B);
    
  // Clip range to where you want 1.0 in gamma to be
    linearCV = clamp_f3( linearCV, 0., 1);
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
