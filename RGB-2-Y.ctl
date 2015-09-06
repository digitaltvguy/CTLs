//  P3 to ACES primaries
// slight color balancing to make Oblivion look better


import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";





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


  rOut = rIn/3.0 + gIn/3.0 + bIn/3.0;
  gOut = rIn/3.0 + gIn/3.0 + bIn/3.0;
  bOut = rIn/3.0 + gIn/3.0 + bIn/3.0;
  //aOut = aIn;
}


