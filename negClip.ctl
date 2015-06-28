

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

  float r=1.;
  float g=1.;
  float b=1.;
  
  if(rIn < 0.) r = 0.;
  if(gIn < 0.) g = 0.;
  if(bIn < 0.) g = 0.;

  rOut = rIn*r;
  gOut = gIn*g;
  bOut = bIn*b;
  

  
  //aOut = aIn;
}
