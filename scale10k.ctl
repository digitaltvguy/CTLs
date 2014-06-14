

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

  rOut = 10000.0*rIn;
  gOut = 10000.0*gIn;
  bOut = 10000.0*bIn;
  //aOut = aIn;
}
