//
// 10000 and 2000 nit PQ curves
// Formula provided by Dolby
//

// 2000 nits
//  1/gamma-ish, calculate V from Luma
// decode L = (max(,0)/(c2-c3*V**(1/m)))**(1/n)
float PQ2000_f( float V)
{
  float L;
  // Lw, Lb not used since absolute Luma used for PQ
  // formula outputs normalized Luma from 0-1
  L = pow(max(pow(V, 1.0/82.53125) - 0.84375 ,0.0)/(16.71875 - 16.5625 * pow(V, 1.0/82.53125)),1.0/0.1715698242);

  return L;
}

// encode (V^gamma ish calculate L from V)
//  encode   V = ((c1+c2*Y**n))/(1+c3*Y**n))**m
float PQ2000_r( float L)
{
  float V;
  // Lw, Lb not used since absolute Luma used for PQ
  // input assumes normalized luma 0-1
  V = pow((0.84375+ 16.71875*pow((L),0.1715698242))/(1+16.5625*pow((L),0.1715698242)),82.53125);
  return V;
}


// 10000 nits
//  1/gamma-ish, calculate V from Luma
// decode L = (max(,0)/(c2-c3*V**(1/m)))**(1/n)
float PQ10000_f( float V)
{
  float L;
  // Lw, Lb not used since absolute Luma used for PQ
  // formula outputs normalized Luma from 0-1
  L = pow(max(pow(V, 1.0/78.84375) - 0.8359375 ,0.0)/(18.8515625 - 18.6875 * pow(V, 1.0/78.84375)),1.0/0.1593017578);

  return L;
}

// encode (V^gamma ish calculate L from V)
//  encode   V = ((c1+c2*Y**n))/(1+c3*Y**n))**m
float PQ10000_r( float L)
{
  float V;
  // Lw, Lb not used since absolute Luma used for PQ
  // input assumes normalized luma 0-1
  V = pow((0.8359375+ 18.8515625*pow((L),0.1593017578))/(1+18.6875*pow((L),0.1593017578)),78.84375);
  return V;
}

// ((0.84375+ 16.71875*(L/2000)**0.1715698242)/(1+16.5625*(L/2000)**0.1715698242))**82.53125 t "Dolby PQ max 2k nits "


// ((0.8359375+ 16.2421875*(L/1000)**0.170288086)/(1+16.078125*(L/1000)**0.170288086))**84.375 t "Dolby PQ max 1k nits "

// (0.8359375+ 18.8515625*(L/10000)**0.15930176)/(1+18.6875*(L/10000)**0.15930176))**78.84375




