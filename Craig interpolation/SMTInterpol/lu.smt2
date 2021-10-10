(set-option :print-success false)
(set-option :produce-proofs true)
;(set-logic QF_UFLIA)

(echo "LUreduction, static schedule, mathematical integer domain")
;(set-option :mbqi true)
;(set-option :macro-finder true)
;(set-option :model-compact true)


; chunks_ub = ceil((size-(k+1))/chunk)
(define-fun chunks_ub ((_k Int)(_size Int)(_chunk Int)) Int (ite 
(= (mod (- _size (+ _k 1)) _chunk) 0) 
(div (- _size (+ _k 1)) _chunk) 
(+ (div (- _size (+ _k 1)) _chunk) 1)
))


(define-fun ParallelCondition 
((_k Int)(_size Int)(_chunk Int)(_tM Int)(_ix Int)(_iy Int)(_rx Int)(_tx Int)(_ry Int)(_ty Int)) Bool (and 
; (k+1)+(rx*tM+tx)*chunk ? ix < (k+1)+(rx*tM+tx+1)*chunk
(<= (+ (+ _k 1) (* (+ (* _rx _tM) _tx) _chunk)) _ix)
(< _ix (+ (+ _k 1) (* (+ (+ (* _rx _tM) _tx) 1) _chunk)))

; (k+1)+(ry*tM+ty)*chunk ? iy < (k+1)+(ry*tM+ty+1)*chunk
(<= (+ (+ _k 1) (* (+ (* _ry _tM) _ty) _chunk)) _iy)
(< _iy (+ (+ _k 1) (* (+ (+ (* _ry _tM) _ty) 1) _chunk)))

(not (= _tx _ty))
(<= 0 _tx)
(< _tx _tM)
(<= 0 _ty)
(< _ty _tM)
(<= 0 _rx)
(<= 0 _ry)
(< 0 _chunk)

	; tM > 1 => tM ? ceil((size-(k+1))/chunk), 
	(> _tM 1) 
	(=> (> _tM 1) (<= _tM (chunks_ub _k _size _chunk)))
))



(define-fun PathCondition 
((_k Int)(_size Int)(_ix Int)(_jx Int)(_iy Int)) Bool (and 
(= _k 1)

; k + 1 ? ix < size
(<= (+ _k 1) _ix)
(< _ix _size)

; k + 1 ? jx < size
(<= (+ _k 1) _jx)
(< _jx _size)

; k + 1 < iy < size - 1
(< (+ _k 1) _iy)
(< _iy (- _size 1))
))

(define-fun RaceCondition 
((_ix Int)(_iy Int)) Bool 
; ix = iy ? 1
(= _ix (- _iy 1))
)


(define-fun Inv
((_k Int)(_size Int)(_chunk Int)(_tM Int)(_ix Int)(_jx Int)(_iy Int)(_rx Int)(_tx Int)(_ry Int)(_ty Int)) Bool (and 
(ParallelCondition _k _size _chunk _tM _ix _iy _rx _tx _ry _ty)
(PathCondition _k _size _ix _jx _iy)
))

(define-fun RaceCons
((_k Int)(_size Int)(_chunk Int)(_tM Int)(_ix Int)(_jx Int)(_iy Int)(_rx Int)(_tx Int)(_ry Int)(_ty Int)) Bool (and 
(Inv _k _size _chunk _tM _ix _jx _iy _rx _tx _ry _ty)
(RaceCondition _ix _iy)
))

(define-fun RaceFreeCons 
((_k Int)(_size Int)(_chunk Int)(_tM Int)(_ix Int)) Bool (and
(not (forall ((jx Int)(iy Int)(rx Int)(tx Int)(ry Int)(ty Int)) (not 
(Inv _k _size _chunk _tM _ix jx iy rx tx ry ty))))
(forall ((jx Int)(iy Int)(rx Int)(tx Int)(ry Int)(ty Int)) (=> 
	(Inv _k _size _chunk _tM _ix jx iy rx tx ry ty)
(not (RaceCondition _ix iy))))
))


;;;Algorithm step 1
(define-fun InitRaceFreeVarCond () Bool false)

;;;Algorithm step 4.a.i
(define-fun RaceFreeVarCondTurboHeu
((size Int)(chunk Int)(tM Int)) Bool (or
	;false             ;place-holder for a successful parsing initially
	;negatively learned term?
	;(and (< size 5))      ;(4-,,) non-shared value subsumption, totally conflicting Inv
	;(and (= size 5))      ;(5,,) non-shared value subsumption, not totally conflicting Inv (due to RF cases), no interploants
	;(and (> size 5))      ;(6+,,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< chunk 2))     ;(,1-,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= chunk 2))     ;(,2,) non-shared value subsumption, not totally conflicting Inv (due to RF cases), no interploants
	;(and (> chunk 2))     ;(,3+,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< tM 2))        ;(,,1-) non-shared value subsumption, totally conflicting Inv
	;(and (= tM 2))        ;(,,2) non-shared value subsumption, not totally conflicting Inv (due to RF cases), no interploants
	;(and (> tM 2))        ;(,,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(4-,1-,),(4-,2,),(4-,3+,) non-shared value subsumption, subsumed by (4-,,)
	;(and (= size 5)(< chunk 2))    ;(5,1-,) non-shared value subsumption, not totally conflicting Inv, no interploants
;	(and (= size 5)(= chunk 2))    ;(5,2,) non-shared value subsumption, not totally conflicting Inv (due to RF cases), got an interpolant, TDD backtracking
	;(and (= size 5)(> chunk 2))    ;(5,3+,) non-shared value subsumption, totally conflicting Inv
	;(and (> size 5)(< chunk 2))    ;(6+,1-,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 5)(= chunk 2))    ;(6+,2,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 5)(> chunk 2))    ;(6+,3+,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(4-,,1-),(4-,,2),(4-,,3+) non-shared value subsumption, subsumed by (4-,,)
	;(5,,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (= size 5)(= tM 2))       ;(5,,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= size 5)(> tM 2))       ;(5,,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(6+,,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 5)(= tM 2))       ;(6+,,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 5)(> tM 2))       ;(6+,,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,1-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (< chunk 2)(= tM 2))      ;(,1-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< chunk 2)(> tM 2))      ;(,1-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,2,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (= chunk 2)(= tM 2))      ;(,2,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= chunk 2)(> tM 2))      ;(,2,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,3+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> chunk 2)(= tM 2))      ;(,3+,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> chunk 2)(> tM 2))      ;(,3+,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(4-,X+-,X+-) non-shared value subsumption, subsumed by (4-,,)
	;(5,1-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (= size 5)(< chunk 2)(= tM 2))       ;(5,1-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= size 5)(< chunk 2)(> tM 2))       ;(5,1-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(5,2,1-) non-shared value subsumption, subsumed by (,,1-)
	;(5,2,2) an RF case
	;(and (= size 5)(= chunk 2)(> tM 2))       ;(5,2,3+) non-shared value subsumption, totally conflicting Inv, 
	;(5,3+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(5,3+,2),(5,3+,3+) non-shared value subsumption, subsumed by (5,3+,)
	;(6+,1-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 5)(< chunk 2)(= tM 2))       ;(6+,1-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 5)(< chunk 2)(> tM 2))       ;(6+,1-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(6+,2,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 5)(= chunk 2)(= tM 2))       ;(6+,2,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 5)(= chunk 2)(> tM 2))       ;(6+,2,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(6+,3+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 5)(> chunk 2)(= tM 2))       ;(6+,3+,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 5)(> chunk 2)(> tM 2))       ;(6+,3+,3+) non-shared value subsumption, not totally conflicting Inv, no interploants

	;(,,2) shared var. subsumption, subsumed by (,,2)
	;(4-,1-,2) shared var. subsumption, subsumed by (4-,,)
	;(7+,4+,2) shared var. subsumption, subsumed by (6+,3+,2) and RF case (6,3,2)
	;(5-,,) non-shared value subsumption, subsumed by (5,,) and (4-,,)
	;(and (= size 6))      ;(6,,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 6))      ;(7+,,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,2-,) non-shared value subsumption, subsumed by (,2,) and (,1-,)
	;(and (= chunk 3))      ;(,3,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> chunk 3))      ;(,4+,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< size 6)(< chunk 3))     ;(5-,2-,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(5-,3,),(5-,4+,) non-shared value subsumption, totally conflicting Inv
	;(and (= size 6)(< chunk 3))     ;(6,2-,) non-shared value subsumption, not totally conflicting Inv, no interploants
;	(and (= size 6)(= chunk 3))     ;(6,3,) non-shared value subsumption, not totally conflicting Inv, got an interpolant, TDD backtracking
	;(6,4+,) non-shared value subsumption, totally conflicting Inv
	;(and (> size 6)(< chunk 3))     ;(7+,2-,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 6)(= chunk 3))     ;(7+,3,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 6)(> chunk 3))     ;(7+,4+,) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(5-,,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (< size 6)(= tM 2))     ;(5-,,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< size 6)(> tM 2))     ;(5-,,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(6,,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (= size 6)(= tM 2))     ;(6,,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= size 6)(> tM 2))     ;(6,,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(7+,,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 6)(= tM 2))     ;(7+,,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 6)(> tM 2))     ;(7+,,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,2-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (< chunk 3)(= tM 2))     ;(,2-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< chunk 3)(> tM 2))     ;(,2-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,3,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (= chunk 3)(= tM 2))     ;(,3,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= chunk 3)(> tM 2))     ;(,3,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(,4+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> chunk 3)(= tM 2))     ;(,4+,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> chunk 3)(> tM 2))     ;(,4+,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(5-,2-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (< size 6)(< chunk 3)(= tM 2))       ;(5-,2-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (< size 6)(< chunk 3)(> tM 2))       ;(5-,2-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(5-,3,1-) non-shared value subsumption, subsumed by (,,1-)
	;(5-,3,2),(5-,3,3+) non-shared value subsumption, subsumed by (5-,3,)
	;(5-,4+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(5-,4+,2),(5-,4+,3+) non-shared value subsumption, subsumed by (5-,4+,)
	;(6,2-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (= size 6)(< chunk 3)(= tM 2))       ;(6,2-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (= size 6)(< chunk 3)(> tM 2))       ;(6,2-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(6,3,1-) non-shared value subsumption, subsumed by (,,1-)
	;(6,3,2) non-shared value subsumption, subsumed by (6,3,)
	;(6,3,3+) non-shared value subsumption, totally conflicting Inv
	;(6,4+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(6,4+,2),(6,4+,3+) non-shared value subsumption, subsumed by (6,4+,)
	;(7+,2-,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 6)(< chunk 3)(= tM 2))       ;(7+,2-,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 6)(< chunk 3)(> tM 2))       ;(7+,2-,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(7+,3,1-) non-shared value subsumption, subsumed by (,,1-)
	;(and (> size 6)(= chunk 3)(= tM 2))       ;(7+,3,2) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(and (> size 6)(= chunk 3)(> tM 2))       ;(7+,3,3+) non-shared value subsumption, not totally conflicting Inv, no interploants
	;(7+,4+,1-) non-shared value subsumption, subsumed by (,,1-)
	;(7+,4+,2) non-shared value subsumption, not totally conflicting Inv, no interploants, subsumed by [(6+,3+,2) and not (6,3,2)]
	;(and (> size 6)(> chunk 3)(> tM 2))       ;(7+,4+,3+) non-shared value subsumption, not totally conflicting Inv, no interploants

	(and (= size (+ chunk 3)))     ;simple bounded linear learning from RF cases (5,2,) and (6,3,), not totally conflicting Inv, got an interpolant

))

;;;Algorithm step 3, 4.b
(echo "the known race free area: {false, (5,2,2), (5,2,), (5-,2,), (6,3,2), (6,3,), (7,4,2)}")
(define-fun RaceFreeVarCond
((size Int)(chunk Int)(tM Int)) Bool (or 
;	InitRaceFreeVarCond                          ;hidden by BDD regression
;	(and (= size 5)(= chunk 2)(= tM 2))          ;hidden by BDD regression
;	(and (>= chunk 2) (<= chunk 2) (<= size 5))  ;hidden by BDD regression
;	(and (= size 6)(= chunk 3)(= tM 2))          ;hidden by BDD regression
;	(and (= size 7)(= chunk 4)(= tM 2))          
	(RaceFreeVarCondTurboHeu size chunk tM)      
))

(declare-fun k () Int)
(declare-fun size () Int)
(declare-fun chunk () Int)
(declare-fun tM () Int)
(declare-fun ix () Int)
(declare-fun jx () Int)
(declare-fun iy () Int)
(declare-fun rx () Int)
(declare-fun tx () Int)
(declare-fun ry () Int)
(declare-fun ty () Int)

;(echo "Algorithm step 2: raceFreeConsUnexpl(RaceFreeVarCond)")
;(echo "Existing some k, size, chunk and tM, for all others,")
;(echo "Finding any race free on unexplored area except the known cases...")
;(assert (and (RaceFreeCons k size chunk tM ix)(not (RaceFreeVarCond size chunk tM))))
;(echo "Finding any race free with False regression...")
;(assert (RaceFreeCons k size chunk tM))                  ;(assert (RaceCons 1 5 2 2 ix jx iy rx tx ry ty))

(echo "Algorithm step 4, 4.a:")
(echo "Checking interpolant given the known cases")
;(compute-interpolant
;(echo "Algorithm step 4.c:")
;(echo "Double-checking RF /\\ RaceCons by Z3 (for that iZ3 supports linear integer algorithm only)")
(assert (and 
	(RaceFreeVarCond size chunk tM)
	(RaceCons k size chunk tM ix jx iy rx tx ry ty))
)
(get-interpolants)

;(echo "Algorithm step 4.a:")
;(echo "Checking if ever I != RaceFreeVarCond (i.e. I = RaceFreeVarCond if UNSAT)")
;(echo "Algorithm step 4.a.1:")
;(echo "Checking if ever I_turbo_heu != RaceFreeVarCond_turbo_heu (i.e. I_turbo_heu = RaceFreeVarCond_turbo_heu if UNSAT)")
;(assert (not (= (RaceFreeVarCond size chunk tM)
;  )))
;(simplify (RaceFreeVarCond size chunk tM) :arith-lhs true)	;standard result
;(simplify (RaceFreeVarCond size chunk tM) :arith-lhs true :flat true :gcd-rounding true)
;(simplify (RaceFreeVarCond size chunk tM) :arith-lhs true :elim-and true :flat true :gcd-rounding true :local-ctx true :sort-sums true)

;(echo "Algorithm step 4.a.i:")
;(echo "Checking if (assumed) RaceFreeVarCondTurboHeu not totally conflicts Inv (negative learning by conditional reduction: simplification with case assignment)")
;(assert (and (RaceFreeVarCondTurboHeu size chunk tM)
;(echo "Algorithm step 4.a.1:")
;(echo "Checking if (assumedly derived) I_turbo_heu not totally conflicts Inv")
;(assert (and
;	(Inv k size chunk tM ix jx iy rx tx ry ty)
;))
;(echo "(UNSAT means a total conflict)")

;(echo "changed to bounded integer domain")
;(assert (and (> ?? -2^32) (< ?? 2^32)))
;(check-sat-using (then (using-params simplify :arith-lhs true :som true)
;                       normalize-bounds
;                       lia2pb
;                       pb2bv
;                       bit-blast
;                       sat))
;(check-sat ;-using 
;(using-params smt :arith-lhs true :elim-and true :flat true :gcd-rounding true :local-ctx true :sort-sums true);
;)
;(get-model)
;(get-info :reason-unknown)

(exit)
