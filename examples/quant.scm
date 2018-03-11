;; A simple semitone quantizer
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

(define (quant-index f q) (floor (/ f q)))
(define (quant-to-semitone v)
  (let ((base (floor v)))
    (+ base (* (quant-index (- v base) *semitone-volt-step*) *semitone-volt-step*))))

(define (quant-to-scale scale-freqs v)
  (let* ((base (floor v))
         (len (length scale-freqs))
         (index (inexact->exact (quant-index (- v base) (/ 1 len)))))
    (+ base (car (drop scale-freqs (- len index 1))))))

(define (run-dsp delta-t in1 in2 in3 in4 out1 out2 out3 out4)
  (pointer-f32-set! out1 (quant-to-scale *minor-freqs* in1)))
