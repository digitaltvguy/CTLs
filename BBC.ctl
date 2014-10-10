// ctl script to implement BBC EOTF as described in public whitepaper
// WHP283
//
// BBC L(V=1) = 527.803183,  BBC Lmax8 L(V=1) = 1212.573814
//

const float mu = 0.139401137752;
const float Lmax = 4.0;
const float nu = sqrt(mu)/2.0; // 0.186682308851
const float pho = sqrt(mu)*(1.0-log(sqrt(mu)));
const float eu = 0.3733646177;

float BBC_f(float V, float s=1.2)
{
	float L;
	if (V <= eu)
	{
		L = pow(V, 2*s);
	}
	else
	{
		L = exp(s*(V-pho)/nu);
    }
	return L;
}

float BBC_r(float L, float s=1.0)
{
	float V;
	if (L <= mu)
	{
		V = pow(L, 0.5/s);
	}
	else
	{
		V = nu*log(L)/s + pho;
	}
	return V;
}


// Lmax = 8
const float mu8 = 0.0974018891;
const float Lmax8 = 4.0;
const float nu8 = sqrt(mu8)/2.0; 
const float pho8 = sqrt(mu8)*(1.0-log(sqrt(mu8)));
const float eu8 = 0.3120927572;

float BBC_f8(float V, float s=1.2)
{
	float L;
	if (V <= eu8)
	{
		L = pow(V, 2*s);
	}
	else
	{
		L = exp(s*(V-pho8)/nu8);
    }
	return L;
}

float BBC_r8(float L, float s=1.0)
{
	float V;
	if (L <= mu8)
	{
		V = pow(L, 0.5/s);
	}
	else
	{
		V = nu8*log(L)/s + pho8;
	}
	return V;
}

