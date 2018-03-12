;; A simple semitone quantizer
;; Toggle different scales by evaluating
;; (set! *current-scale* *minor-7th-freqs*)
;; (set! *current-scale* *major-7th-freqs*)
;; etc.
;; Or evaluate your own scale and then set it like so.

(define *t* 0.0)
(define *semitone-volt-step* (/ 1 12))
(define (freqs scale) (fold
                        (lambda (f acc)
                          (cons (+ (* f *semitone-volt-step*) (car acc)) acc))
                        '(0.0)
                        scale))

(define *major-scale* '(0 2 2 1 2 2 2 1))
(define *major-freqs* (freqs *major-scale*))

(define *minor-scale* '(0 2 1 2 2 1 2 2))
(define *minor-freqs* (freqs *minor-scale*))

(define *major-7th* '(0 4 3 4))
(define *major-7th-freqs* (freqs *major-7th*))

(define *minor-7th* '(0 3 4 3))
(define *minor-7th-freqs* (freqs *minor-7th*))

(define (quant-index f q) (floor (/ f q)))
(define (quant-to-semitone v)
  (let ((base (floor v)))
    (+ base (* (quant-index (- v base) *semitone-volt-step*) *semitone-volt-step*))))

(define (quant-to-scale scale-freqs v)
  (let* ((base (floor v))
         (len (length scale-freqs))
         (index (inexact->exact (quant-index (- v base) (/ 1 len)))))
    (+ base (car (drop scale-freqs (- len index 1))))))

(define *current-scale* *minor-7th-freqs*)
(define *voltage-offset* 0.0) ;; 1v/oct
(define (run-dsp delta-t in1 in2 in3 in4 out1 out2 out3 out4)
  (pointer-f32-set! out1 (quant-to-scale *current-scale* (+ in1 *voltage-offset*))))
