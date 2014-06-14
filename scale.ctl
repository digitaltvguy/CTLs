

void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float scale = 179.0
)
{

  rOut = rIn/scale;
  gOut = gIn/scale;
  bOut = bIn/scale;
  //aOut = aIn;
}
