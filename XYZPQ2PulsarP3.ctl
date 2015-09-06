// multiply XYZ into P3

import "ACESlib.Utilities.a1.0.1";
import "ACESlib.Utilities_Color.a1.0.1";

const float XYZ_2_P3D60_PRI_MAT[4][4] = XYZtoRGB(P3D60_PRI,1.0);


/* ============ CONSTANTS ============ */
/* 
  const float XYZtoPulsarP3[3][3] = {
	{ 2.4935,  -0.9314, -0.4027 },
	{ -0.8295,  1.7627,  0.0236 },
	{ 0.0358, -0.0762,  0.9569 }
};
*/

const float XYZtoPulsarP3[3][3] = {
 {2.4935, -0.8295, 0.0358 },
 {-0.9314, 1.7627, -0.0762},
 {-0.4027, 0.0236, 0.9569}
};






/* ============ Main Algorithm ============ */
void
main
(   input varying float rIn,
    input varying float gIn,
    input varying float bIn,
    output varying float rOut,
    output varying float gOut,
    output varying float bOut
)
{

	float XYZPQ[3];
	XYZPQ[0] = rIn;
	XYZPQ[1] = gIn;
	XYZPQ[2] = bIn;

   // clamp 0-1
   float tmp[3] = clamp_f3( XYZPQ, 0.0, 1.0);


	// XYZ to ACES matrix
	float PulsarP3[3] = mult_f3_f33( tmp, XYZtoPulsarP3);
	//float PulsarP3[3] = mult_f3_f44( tmp, XYZ_2_P3D60_PRI_MAT);

	
	float outputCV[3] = clamp_f3( PulsarP3, 0.0, 1.0);
	//float outputCV[3] = PulsarP3;

	
	rOut = outputCV[0];
	gOut = outputCV[1];
	bOut = outputCV[2];
	//aOut = aIn;
}
