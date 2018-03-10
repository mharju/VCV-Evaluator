(declare (uses srfi-18))
(use nrepl lolevel)

(define-external (dsp (float in1) (float in2) (float in3) (float in4)
                       ((c-pointer float) out1)
                       ((c-pointer float) out2)
                       ((c-pointer float) out3)
                       ((c-pointer float) out4))   void
  (run-dsp in1 in2 in3 in4 out1 out2 out3 out4))

;; Re-define this symbol using NREPL connection to modify the behaviour
;; of the plugin.
(define (run-dsp in1 in2 in3 in4 out1 out2 out3 out4)
  (pointer-f32-set! out1 in1))

(define (start-nrepl)
  (thread-start!
    (lambda ()
      (nrepl 4000
        (lambda (in out)
          (nrepl-loop in out))))))

(return-to-host)
