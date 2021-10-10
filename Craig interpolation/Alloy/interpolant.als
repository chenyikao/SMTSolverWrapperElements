module interpolant

sig universe {
	tM, chunk, rx, tx, ix, jx, ry, ty, iy, k, size	:	one Int
} 

pred f {
	tM = chunk
	size <= chunk
	tM > 1
}

pred Inv {
    ((k fun/add 1) fun/add (rx fun/mul tM fun/add tx) fun/mul chunk <= ix)
    (ix < (k fun/add 1) fun/add (rx fun/mul tM fun/add tx fun/add 1) fun/mul chunk)

    ((k fun/add 1) fun/add (ry fun/mul tM fun/add ty) fun/mul chunk <= iy)
    (iy < (k fun/add 1) fun/add (ry fun/mul tM fun/add ty fun/add 1) fun/mul chunk)

    (tx != ty)
    (0 <= tx) && (tx < tM)
    (0 <= ty) && (ty < tM)
    (0 < chunk)
    (0 <= rx)
    (0 <= ry)

    (k fun/add 1 <= ix)
    (ix < size)

    (k fun/add 1 <= jx)
    (jx < size)
    (k = 1)

    (k fun/add 1 < iy)
    (iy < size fun/sub 1)
    ix = iy fun/sub 1
}

/**
	Interpolation specification by interval arithmetic
*/
sig universeI {
	tM_l, tM_u, chunk_l, chunk_u, rx_l, rx_u, tx_l, tx_u, ix_l, ix_u, jx_l, jx_u, ry_l, ry_u, ty_l, ty_u, iy_l, iy_u, k_l, k_u, size_l, size_u	:	one Int
} 
pred I {
	tM_l 			<= tM 		<= tM_u
	chunk_l 	<= chunk	<= chunk_u
	rx_l			<= rx		<= rx_u
	tx_l			<= tx		<= tx_u 
	ix_l			<= ix		<= ix_u 
	jx_l			<= jx		<= jx_u 
	ry_l			<= ry		<= ry_u
	ty_l			<= ty		<= ty_u 
	iy_l			<= iy		<= iy_u 
	k_l			<= k		<= k_u 
	size_l		<= size	<= size_u	
}

fact CraigInterpolation {
	f && Inv => none
	f => I
	Inv && I => none
}


run {} for 5
