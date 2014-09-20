// ctl script to implement BBC EOTF as described in public whitepaper
// WHP283

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


