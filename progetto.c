#define TOTAL 25
#define NUMS 4
#define SIZE 4

#include <stdio.h>

// crea tutta la baracca
void calcola(char* arr , char pos )
{
    if  ( pos < 0 )
	return;
    char i, p;
    p = pos  ;
    for ( i = SIZE-1 ; i >= 0 ; i-- ){
	arr[p*SIZE+i] = pos % NUMS;
	pos = pos/NUMS;
    }
    calcola(arr, p-1);
}

// NB: mio e sec vengono distrutti
char get_x(char* mio, char* sec)
{
    int i;
    char r;
    r = 0;
    for( i=SIZE-1; i>=0; i--)
        if ( mio[i] == sec[i] ){
            sec[i]=-1;
            mio[i]=-1;
            r++;
        }

    return r;
}

// NB: mio e sec vengono distrutti
char get_o(char* mio, char* sec)
{
    int i,j;
    char r;
    r=0;
    for ( i =SIZE-1; i>=0; i--)
	for ( j = SIZE-1; j>=0 && mio[i] != -1; j--)
	    if ( mio[i] == sec[j] )
	    {
		sec[j]=-1;
		mio[i]=-1;
		r++;
		break;
	    }
    return r;
}
    

int main()
{
    char a[TOTAL*SIZE];
    calcola(a,TOTAL-1);

    int i , j ;
    for (i = 0; i < TOTAL; i++) {
	for (j = 0; j < SIZE; j++) {
	    printf("%d\t",a[i*SIZE+j]);
	}
	printf("\n");

    }

    char b[4]={'1','2','3','4'};
    char c[4] ={'1','2','3','4'};

    printf("Le x %d\n", get_x(c,b));
    printf("Le o %d\n", get_o(c,b));

    return 0;
}
