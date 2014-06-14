

void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  output varying float aOut
)
{

  rOut = 100.0*rIn;
  gOut = 100.0*gIn;
  bOut = 100.0*bIn;
  aOut = 1.0;
}
