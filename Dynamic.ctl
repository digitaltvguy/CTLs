

import "utilities";
import "utilities-color";
import "transforms-common";
import "odt-transforms-common";
import "PQ";


const float R709_PRI_2_XYZ_MAT[4][4] = RGBtoXYZ(REC709_PRI,1.0);
const float XYZ_2_R709_PRI_MAT[4][4] = XYZtoRGB(REC709_PRI,1.0);

const float XYZ_2_ACES_PRI_MAT[4][4] = XYZtoRGB(ACES_PRI,1.0);
const float ACES_2_XYZ_MAT[4][4] = RGBtoXYZ(ACES_PRI,1.0);

const unsigned int BITDEPTH = 16;
// video range is
// Luma and R,G,B:  CV = Floor(876*D*N+64*D+0.5)
// Chroma:  CV = Floor(896*D*N+64*D+0.5)
const unsigned int CV_BLACK = 4096; //64.0*64.0;
const unsigned int CV_WHITE = 60160;
const float F_BLACK = CV_BLACK/65535.0;
const float F_WHITE = CV_WHITE/65535.0;
const float RANGE = F_WHITE - F_BLACK;



void main 
(
  input varying float rIn, 
  input varying float gIn, 
  input varying float bIn, 
  output varying float rOut,
  output varying float gOut,
  output varying float bOut,
  input uniform float PK = 4000.0,
  input uniform float WHT = 400.0,
  input uniform float MID =  18.0,
  input uniform float TVPK  =  500.0,
  input uniform float TVWHT =  200.0 
)
{
	
float PKi    = PK;
float WHTi   = WHT;
float MIDi   = MID;
float TVPKi  = TVPK;
float TVWHTi = TVWHT;	
	
// 2020: (0.2627*(float)R + 0.6780*(float)G + 0.0593*(float)B) +0.5;
//  709: (0.2126*(float)R + 0.7152*(float)G + 0.0722*(float)B) +0.5;	
	
// Input assumed in PQ 10k gamma Video range	
	

// extract out 0-1 range from input that would be MSB justified 0-1
 float tmp[3];
 tmp[0] = (rIn - F_BLACK)/RANGE;
 tmp[1] = (gIn - F_BLACK)/RANGE;
 tmp[2] = (bIn - F_BLACK)/RANGE;
 
 // remove any negative and >1.0 excursions
 tmp = clamp_f3(tmp, 0.0, 1.0);	
 
float RGB[3];
RGB[0] = PQ10000_f(tmp[0]);
RGB[1] = PQ10000_f(tmp[1]);
RGB[2] = PQ10000_f(tmp[2]);

float L = 10000.0*(0.2126*RGB[0]  + 0.7152*RGB[1]  + 0.0722*RGB[2] );

float RGBPre[3] = RGB;

//// Flip to ACES
//float XYZ[3] = mult_f3_f44( RGB, R709_PRI_2_XYZ_MAT);
//// Apply CAT from assumed observer adapted white to ACES white point
//XYZ = mult_f3_f33( XYZ, invert_f33( D60_2_D65_CAT));
//RGBPre = mult_f3_f44( XYZ, XYZ_2_ACES_PRI_MAT);





float scale=1.0;

// Linear
// calculate slopes
//float m1 = (TVWHT-MID)/(WHT-MID);
//float m2 = (TVPK-TVWHT)/(PK-WHT);
//float b1 = MID - m1*MID;
//float b2 = TVWHT - m2*WHT;
//if(L>MID && L<WHT)
//{
	 //scale = (m1*L+b1)/L;
//}
//if(L>=WHT)
//{
	//scale = (m2*L+b2)/L;
//}

// Linear LOG (correct way)

  int sigmoid=0;
  float PKLOG = log10(PK);
  
	if (!sigmoid) {
	TVWHTi = log10(TVWHT);
	MIDi = log10(MID);
	WHTi = log10(WHT);
	PKi = PKLOG;
	TVPKi = log10(TVPK);
	
	
}


 
// used for linear 
float m1 = (TVWHTi-MIDi)/(WHTi-MIDi);
float m2 = (TVPKi-TVWHTi)/(PKi-WHTi);
float b1 = MIDi - m1*MIDi;
float b2 = TVWHTi - m2*WHTi; 
float L_SAVE = L;

 
// Linear 
// calculate slopes
if (!sigmoid && L > 0.00001) {
    L = log10(L);  

	if(L>MIDi && L<WHTi)
	{
		 scale = (m1*L+b1)/L;
	}
	if(L>=WHTi)
	{
		scale = (m2*L+b2)/L;
	} 
	
	scale = pow(10.0,scale*L)/L_SAVE;
	L = L_SAVE;


}

// used for sigmoid
float yn = 0.0;
float sig = 0.0;
float xs = 0.0;
bool  flipper = false;
 
// Quadratic (or sigmoid)
if(L>MID && sigmoid)
{
	//xn will go 0-1
	float x1n = (WHT-MID)/(PK-MID);
	float x2n = 1.0;
	// yn will go 0-y2n
	float y1n = (TVWHT - MID)/(PK-MID);
	float y2n = (TVPK - MID)/(PK-MID);
	float xn = (L-MID)/(PK-MID);
	float A = (y1n-x1n*y2n)/(x1n*(x1n-1.0));
	float BB = y2n - A;
	yn = A*pow(xn,2)+BB*xn;
	
	// Sigmoid slope = s(x)*(1-s(x))
	float sh = 1.0/(1.0 + pow(M_E, -0.5));
	
	// Sigmoid 
	xs = log10(10000.0*xn);
	sig = (1.0/(1.0-sh))*( -sh + 1.0/(1.0 + pow(M_E, -(0.5+WHT*xs/500.0))));
	sig = 2.0*(sig - 0.5); // goes 0-1 between log10(MID) to log10(TVPK)
	float logyn = (log10(TVPK)-log10(MID))*sig + log10(MID);
	yn = (pow(10.0, logyn)-MID)/(PK-MID);
	
	// generic
	scale = ((PK-MID)*yn+MID)/L;

	if((L > L*scale && ((L-L*scale)/L < 0.02) || sig < 0.1) )
	{
		scale = 1.0;
	}
	
	
}

scale = 10000.0*scale/TVPK;

// apply tone curve and correct hue
float RGBPost[3] = mult_f_f3(scale, RGBPre);
RGB = restore_hue_dw3( RGBPre, RGBPost);

// gamut clip and restore hue
RGB = clamp_f3( RGBPost, 0.0, 1.0);
RGB = restore_hue_dw3( RGBPost, RGB);


/* --- Encode linear code values with transfer function --- */
float outputCV[3];
outputCV[0] = CV_BLACK + (CV_WHITE - CV_BLACK) *bt1886_r( RGB[0], 2.4, 1.0, 0.0);
outputCV[1] = CV_BLACK + (CV_WHITE - CV_BLACK) *bt1886_r( RGB[1], 2.4, 1.0, 0.0);
outputCV[2] = CV_BLACK + (CV_WHITE - CV_BLACK) *bt1886_r( RGB[2], 2.4, 1.0, 0.0);

outputCV = clamp_f3( outputCV, CV_BLACK, CV_WHITE);

// This step converts integer CV back into 0-1 which is what CTL expects
outputCV = mult_f_f3( 1./(pow(2,BITDEPTH)-1), outputCV);

/*--- Cast outputCV to rOut, gOut, bOut ---*/
rOut = outputCV[0];
gOut = outputCV[1];
bOut = outputCV[2];
//aOut = aIn;
}
