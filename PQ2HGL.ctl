

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

// NHK HLG constants:
const float a= 0.17883277;
const float b= 0.28466892;
const float c= 0.55991073;
float HLG_r( float L)
{
	
  
  float V;
  // input assumes normalized luma 0-1+
  
  if(L <= 1.0) {
     V = 0.5 * pow(L, 0.5);
  } else {
     V = a * log(L - b) + c;
  }

  return V;
}
// Legal Range
//const unsigned int CV_BLACK = 4096; //64.0*64.0;
//const unsigned int CV_WHITE = 60160;

// Work with SDI Range
//const unsigned int CV_BLACK_SDI = 256; //64.0*64.0;
//const unsigned int CV_WHITE_SDI = 65216;

// Full Range assumed:
const unsigned int CV_BLACK = 0; //64.0*64.0;
const unsigned int CV_WHITE = 65535;

const unsigned int BITDEPTH = 16;



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

    float PQ[3] = { rIn, gIn, bIn};

  // Decode with inverse PQ transfer function
  float linearCV[3];
 // Data from 0-10000.
 // normalize 100 cd/m2 to 1.0 (10000/100 = 100
  linearCV[0] = 100.0*PQ10000_f(PQ[0]);
  linearCV[1] = 100.0*PQ10000_f(PQ[1]);
  linearCV[2] = 100.0*PQ10000_f(PQ[2]);

 // Data from 0-10000.
 // normalize 100 cd/m2 to 1.0
 
    
  
  // Encode linear code values with transfer function
    float outputCV[3];
    outputCV[0] = HLG_r( linearCV[0]);
    outputCV[1] = HLG_r( linearCV[1]);
    outputCV[2] = HLG_r( linearCV[2]);


    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];      
}



