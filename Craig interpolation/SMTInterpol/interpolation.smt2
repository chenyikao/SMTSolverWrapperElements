(set-option :print-success false)
(set-option :produce-proofs true)
(set-logic QF_LIA)

(declare-fun tM () Int)
(declare-fun chunk () Int)

(declare-fun gx () Int)
(declare-fun tx () Int)
(declare-fun ix () Int)
(declare-fun jx () Int)
(declare-fun gy () Int)
(declare-fun ty () Int)
(declare-fun iy () Int)

(declare-fun k () Int)
(declare-fun size () Int)

(assert (! (or 
		(and
			(not (= jx 6))
			(not (= size 7))
			(not (= iy 4))
			(not (= ty 2))
			(not (= gy 0))
			(not (= ix 3))
			(not (= tx 1))
			(not (= tM 3))
			(not (= gx 0))
			(not (= chunk 1))
		)
		(and
			(not (= jx 6))
			(not (= size 7))
			(not (= iy 3))
			(not (= ty 0))
			(not (= gy 0))
			(not (= ix 6))
			(not (= tx 1))
			(not (= tM 2))
			(not (= gx 0))
			(not (= chunk 4))
		)
	) :named IF ))
;	k != 1 is removed since I -> k = 1 appears in P' already

(assert (! (and	
		; (k+1)+(gx*tM+tx)*chunk <= ix < (k+1)+(gx*tM+tx+1)*chunk
		(<= (+ (+ k 1) (* (+ (* gx tM) tx) chunk)) ix)
		(< ix (+ (+ k 1) (* (+ (+ (* gx tM) tx) 1) chunk)))

		; (k+1)+(gy*tM+ty)*chunk <= iy < (k+1)+(gy*tM+ty+1)*chunk
		(<= (+ (+ k 1) (* (+ (* gy tM) ty) chunk)) iy)
		(< iy (+ (+ k 1) (* (+ (+ (* gy tM) ty) 1) chunk)))

		(not (= tx ty))
		(<= 0 tx)
		(< tx tM)
		(<= 0 ty)
		(< ty tM)
		(< 0 chunk)
		(<= 0 gx)
		(<= 0 gy)

		; k + 1 <= ix < size
		(<= (+ k 1) ix)
		(< ix size)

		; k + 1 <= jx < size
		(<= (+ k 1) jx)
		(< jx size)
		(= k 1)

		; k + 1 < iy < size - 1
		(< (+ k 1) iy)
		(< iy (- size 1))
	) :named Inv ))

(assert (!
	; ix != iy - 1
	(not (= ix (- iy 1)) 
	) :named np ))

(check-sat)
(get-interpolants IF (and Inv np))

(exit)
