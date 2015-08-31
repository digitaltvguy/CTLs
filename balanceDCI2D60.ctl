
import "utilities";
import "transforms-common";
import "odt-transforms-common";

const float DISPGAMMA = 2.6; 


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

 /* --- Decode to linear code values with inverse transfer function --- */
    float linearCV[3];
    linearCV[0] = pow( rIn, DISPGAMMA)*0.88;
    linearCV[1] = pow( gIn, DISPGAMMA)*1.05;
    linearCV[2] = pow( bIn, DISPGAMMA)*0.94;


  
  /* --- Encode linear code values with transfer function --- */
    float outputCV[3];
    outputCV[0] = pow( linearCV[0], 1./DISPGAMMA);
    outputCV[1] = pow( linearCV[1], 1./DISPGAMMA);
    outputCV[2] = pow( linearCV[2], 1./DISPGAMMA);
  
  /* --- Cast outputCV to rOut, gOut, bOut --- */
    rOut = outputCV[0];
    gOut = outputCV[1];
    bOut = outputCV[2];
    aOut = 1.0;
}
