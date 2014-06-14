

import "utilities";
import "utilities-color";


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

  float RGB[3] = {rIn, gIn, bIn};

 
  float outputCV[3] = clamp_f3(RGB,0.,65000.0); 
 

  /*--- Cast outputCV to rOut, gOut, bOut ---*/
  rOut = outputCV[0];
  gOut = outputCV[1];
  bOut = outputCV[2];
  //aOut = aIn;
}
