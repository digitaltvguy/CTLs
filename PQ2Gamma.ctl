

// 
// Convert PQ to Gamma
//




// Assume full range input. Inverse PQ as 0-1

//

import "utilities";
import "transforms-common";
import "odt-transforms-common";
import "utilities-color";
import "PQ";


// Legal Range
//const unsigned int CV_BLACK = 4096; //64.0*64.0;
//const unsigned int CV_WHITE = 60160;

// Work with SDI Range
//const unsigned int CV_BLACK_SDI = 256; //64.0*64.0;
//const unsigned int CV_WHITE_SDI = 65216;

// Work with Full range (S-LOG3 says ok to apply SDI range on that as full range never gets totally used)
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;

const unsigned int BITDEPTH = 16;
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
    input uniform float CLIP=1000.0,
    input uniform float DISPGAMMA=2.4
)
{

    float PQ[3] = { rIn, gIn, bIn};

  // Decode with inverse PQ transfer function
  float linearCV[3];
  linearCV[0] = 10000.0*PQ10000_f(PQ[0]);
  linearCV[1] = 10000.0*PQ10000_f(PQ[1]);
  linearCV[2] = 10000.0*PQ10000_f(PQ[2]);

    
   
  // Clip range to where you want 1.0 in gamma to be
    linearCV = clamp_f3( linearCV, 0., CLIP);
    linearCV = mult_f_f3( 1.0/CLIP, linearCV);
    
  
  // Encode linear code values with transfer function
    float outputCV[3];
    outputCV[0] = bt1886_r( linearCV[0], DISPGAMMA, L_W, L_B);
    outputCV[1] = bt1886_r( linearCV[1], DISPGAMMA, L_W, L_B);
    outputCV[2] = bt1886_r( linearCV[2], DISPGAMMA, L_W, L_B);


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}
