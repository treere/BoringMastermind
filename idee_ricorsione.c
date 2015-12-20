#include <stdio.h>

/*
 * Partire sempre con 1234 come codice proposto
 * Dalla risposta: X + O + codice proposto = Seed
 * Calcolo F(5,X+O+C) come indice da cui iniziare
 */

int f(int n,int x)
{
    int p = 16380;
    if ( n == 0 )
	return x;
    else
    {
	return (  f(n-1,x)  * ( p - f(n-1,x)) ) % p   ;
    }
}

int main()
{
    for ( int i = 0; i < 1000 ; i++){
	printf("%d ",f(5,i));
	printf("\n");
    }
    
    return 0;
}
