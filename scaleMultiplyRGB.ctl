

void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float scaleRED=1.0,
  input uniform float scaleGREEN=1.0,
  input uniform float scaleBLUE=1.0
)
{

  rOut = rIn*scaleRED;
  gOut = gIn*scaleGREEN;
  bOut = bIn*scaleBLUE;
  //aOut = aIn;
}
