/*********************************************
 * OPL 12.6.1.0 Model
 * Author: The Saxon
 * Creation Date: 2015/1/29 at ¤W¤È5:03:15
 *********************************************/

using CP;

dvar int k;
dvar int lu_size;
dvar int chunk;
dvar int tM;
dvar int ix;
dvar int jx;
dvar int iy;
dvar int rx;
dvar int tx;
dvar int ry;
dvar int ty;

dvar int x_0;
dvar int x_1;
dvar int x_2;
dvar int x_3;
dvar int x_4;
dvar int x_5;

dvar int a_13;  
dvar int a_14;  
dvar int a_15; 
dvar int a_16; 
dvar int a_17;

dvar int x_18;
dvar int x_19;
dvar int x_20;
dvar int x_22;
dvar int x_23;

dvar int a_24;
dvar int a_25;
dvar int a_26;
dvar int a_27;

maximize tM;

constraints {

a_13 == (((lu_size - (k+1)) mod chunk == 0) ? (lu_size - (k+1)) / chunk : (lu_size - (k+1)) / chunk + 1);
a_14 == (rx*tM + x_0)*chunk + k;
a_15 == (rx*tM + x_0 + 1)*chunk + k;
a_16 == (tM*x_1 + x_2)*chunk + k;
a_17 == (tM*x_1 + x_2 + 1)*chunk + k;

a_24 == (rx*tM + x_18)*chunk + k;
a_25 == (rx*tM + x_18 + 1)*chunk + k;
a_26 == (tM*x_19 + x_20)*chunk + k;
a_27 == (tM*x_19 + x_20 + 1)*chunk + k;

0 <= rx;
0 < chunk;
1 < tM <= 1 || (1 < tM && tM <= a_13);
x_0 != x_2;
0 <= x_0 && x_0 < tM;
0 <= x_2 && x_2 < tM;
0 <= x_1;
k == 1;
k + 1 <= x_3 && x_3 < lu_size;
k + 1 <= x_4 && x_4 < lu_size;
k + 1 < x_5 && x_5 < lu_size - 1;
a_14 + 1 <= x_3 && x_3 < a_15 + 1;
a_16 + 1 <= x_5 && x_5 < a_17 + 1;

!(
0 <= rx &&
0 < chunk &&
(1 < tM <= 1 || (1 < tM && tM <= a_13)) &&
x_18 != x_20 &&
0 <= x_18 && x_18 < tM &&
0 <= x_20 && x_20 < tM &&
0 <= x_19 &&
k == 1 &&
k + 1 <= x_22 && x_22 < lu_size &&
k + 2 <= x_23 && x_23 < lu_size - 1 &&
a_24 + 2 <= x_23 && x_23 < a_25 + 2 &&
a_26 + 1 <= x_23 && x_23 < a_27 + 1
);

}
