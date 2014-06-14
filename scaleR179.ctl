

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

  rOut = rIn/179.0;
  gOut = gIn/179.0;
  bOut = bIn/179.0;
  //aOut = aIn;
}
