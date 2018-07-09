(use srfi-1 srfi-4 lolevel)

(define *buffer-size* (* 44100 16))
(define *playhead-position* 0.0)

(define *start-step* 0)
(define *loop-length* 16)
(define *recorded-length* 0)

(define *current-step* 0)
(define *step-length* (/ *buffer-size* *loop-length*))

(define *sample-length* 1)
(define *pulse-count* 0)
(define *total-pulses* (* 16 *sample-length*))

(define *record-mode* #t)
(define *record-buffer-position* 0)

(define (make-buffer! buffer-size)
  (make-f32vector buffer-size 0))

(define (store-value! buffer position value)
  (f32vector-set! buffer position value)
  (modulo (+ position 1)
          (f32vector-length buffer)))

(define (get-buffer-value buffer position)
  (f32vector-ref buffer position))

(define (playhead-position position)
  (inexact->exact (round position)))

(define (update-playhead-position delta-t buffer position pitch current-step step-length)
  (let ((new-position (+ position pitch))
        (current-step-in-samples (* current-step step-length)))
    (if (> new-position (+ current-step-in-samples step-length))
      current-step-in-samples
      new-position)))

(define *buffer* (make-buffer! *buffer-size*))

(define *previous-clock* 0)

(define (tick!)
  (display (string-append "Tick " (number->string *pulse-count*) "\n"))
  (when (and (= (+ *pulse-count* 1) *total-pulses*) *record-mode*)
    (set! *record-mode* #f)
    (set! *recorded-length* *record-buffer-position*)
    (set! *step-length* (/ *recorded-length* *total-pulses*))
    (display (string-append "Record mode off " (number->string *record-buffer-position*)
                            ", sl:"
                            (number->string *step-length*) "\n")))

  (set! *pulse-count* (modulo (+ *pulse-count* 1) 16))
  (set! *current-step* (+ (modulo (- (+ *current-step* 1) *start-step*) *loop-length*)
                          *start-step*)))

(define (record!)
  (set! *pulse-count* 0)
  (set! *record-buffer-position* 0)
  (set! *record-mode* #t))

(define (run-dsp delta-t in clock pitch in4 out1 out2 out3 out4)
  (when *record-mode*
    (set!
      *record-buffer-position*
      (store-value! *buffer* *record-buffer-position* in)))

  (when (not (= *previous-clock* clock)) (tick!))

  (set! *previous-clock* clock)

  (pointer-f32-set! out1 (get-buffer-value *buffer* (playhead-position *playhead-position*)))

  (set! *playhead-position*
    (update-playhead-position delta-t
                              *buffer*
                              *playhead-position*
                              (+ (/ pitch 10.0) 1)
                              *current-step*
                              *step-length*)))
