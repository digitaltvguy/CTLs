// write exr file with a floating point number

import "utilities";
import "transforms-common";
import "odt-transforms-common";





void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  output varying float aOut,
  input uniform float value=1.0 )
{


  
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = value;
    gOut = value;
    bOut = value;
    aOut = 1.0;
}
