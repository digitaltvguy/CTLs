

// 
// Convert Full Range PQ to S-LOG3
//

// Following instructions in:
//https://community.sony.com/sony/attachments/sony/large-sensor-camera-F5-F55/12359/2/TechnicalSummary_for_S-Gamut3Cine_S-Gamut3_S-Log3_V1_00.pdf
//
//
// Input Parameter CLIP sets the highest nits that will be kept as come out of PQ
//


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Transform_Common.a1.0.1";
import "ACESlib.ODT_Common.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";
import "PQ";

float SLOG3_r (float in)
{
   float out; 
   if (in >= 0.01125000)
      out = (420.0 + log10((in + 0.01) / (0.18 + 0.01)) * 261.5) / 1023.0;
   else
     out = (in * (171.2102946929 - 95.0)/0.01125000 + 95.0) / 1023.0;    
   
   return out;
}

const unsigned int BITDEPTH = 16;


// Legal Range
//const unsigned int CV_BLACK = 4096; //64.0*64.0;
//const unsigned int CV_WHITE = 60160;

// Work with SDI Range
//const unsigned int CV_BLACK_SDI = 256; //64.0*64.0;
//const unsigned int CV_WHITE_SDI = 65216;

// Work with Full range (S-LOG3 says ok to apply SDI range on that as full range never gets totally used)
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;

void main 
(
    input varying float rIn, 
    input varying float gIn, 
    input varying float bIn, 
    output varying float rOut,
    output varying float gOut,
    output varying float bOut,
    input uniform float CLIP=10000.0
)
{
    float PQ[3] = { rIn, gIn, bIn};

  // Decode with inverse PQ transfer function
  float linearCV[3];
  linearCV[0] = 10000.0*PQ10000_f(PQ[0]);
  linearCV[1] = 10000.0*PQ10000_f(PQ[1]);
  linearCV[2] = 10000.0*PQ10000_f(PQ[2]);

    
  // Clip range to where you want 1.0 (peak nits) to be
  // don't really need to clip for S-LOG3 could just let monitor clip.
    linearCV = clamp_f3( linearCV, 0., CLIP);
    // Set "white" 100 nits (1/100)*fudgedClip
    // multiply white 100% IRE by 0.9 per S-LOG3 document
    linearCV = mult_f_f3( 0.9/100.0, linearCV);
    

  // LIMIT to SDI range
  // Encode linear code values with transfer function
    float outputCV[3];
    outputCV[0] = CV_BLACK + (CV_WHITE - CV_BLACK) * SLOG3_r( linearCV[0]);
    outputCV[1] = CV_BLACK + (CV_WHITE - CV_BLACK) * SLOG3_r( linearCV[1]);
    outputCV[2] = CV_BLACK + (CV_WHITE - CV_BLACK) * SLOG3_r( linearCV[2]);

    // make sure nothing out of range
    outputCV = clamp_f3( outputCV, 0., pow( 2, BITDEPTH)-1);

  // This step converts integer CV back into 0-1 which is what CTL expects
    outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);	

    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
}


