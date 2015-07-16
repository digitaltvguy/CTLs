

// 
// Hybrid Gamma Log
//


// NHK HLG constants:
const float a= 0.17883277;
const float b= 0.28466892;
const float c= 0.55991073;

float HLG_r( float L)
{
	
  
  float V;
  // input assumes normalized luma 0-1+
  
  if(L <= 1.0) {
     V = 0.5 * pow(L, 0.5);
  } else {
     V = a * log(L - b) + c;
  }

  return V;
}
