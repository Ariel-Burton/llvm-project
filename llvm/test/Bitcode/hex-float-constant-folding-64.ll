; RUN: opt %s -O1 -o %t
; RUN: llvm-dis %t -o - | FileCheck %s
;
; This test runs the .ll through opt, and the output of opt
; back through llvm-dis
; The objective is to test that HexFloat arithmetic used during
; constant folding works as expected

define internal hex_fp64 @half() #0 {
  ret hex_fp64 5.000000e-01
}

define internal hex_fp64 @two() #0 {
  ret hex_fp64 2.000000e-00
}

define internal hex_fp64 @sixteen() #0 {
  ret hex_fp64 16.000000e-00
}

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @one() #0 {
  ; 2 * 1/2 == 1
  %two = call hex_fp64 @two()
  %half = call hex_fp64 @half()
  %mul = fmul hex_fp64 %two, %half
  ret hex_fp64 %mul
}

; CHECK:      define dso_local noundef hex_fp64 @one()
; CHECK-NEXT:   ret hex_fp64 0xS4110000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @quarter() #0 {
  ; 1/2 / 2 == 1/4
  %half = call hex_fp64 @half()
  %two = call hex_fp64 @two()
  %div = fdiv hex_fp64 %half, %two
  ret hex_fp64 %div
}

; CHECK:      define dso_local noundef hex_fp64 @quarter()
; CHECK-NEXT:   ret hex_fp64 0xS4040000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @three_quarters() #0 {
  ; 1/2 + 1/4 == 3/4
  %half = call hex_fp64 @half()
  %quarter = call hex_fp64 @quarter()
  %add = fadd hex_fp64 %half, %quarter
  ret hex_fp64 %add
}

; CHECK:      define dso_local noundef hex_fp64 @three_quarters()
; CHECK-NEXT:   ret hex_fp64 0xS40C0000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @minus_quarter() #0 {
  ; 1/4 - 1/2 == -1/4
  %quarter = call hex_fp64 @quarter()
  %half = call hex_fp64 @half()
  %sub = fsub hex_fp64 %quarter, %half
  ret hex_fp64 %sub
}

; CHECK:      define dso_local noundef hex_fp64 @minus_quarter()
; CHECK-NEXT:   ret hex_fp64 0xSC040000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @minus_four() #0 {
  ; test +ve * -ve == -ve
  %sixteen = call hex_fp64 @sixteen()
  %minus_quarter = call hex_fp64 @minus_quarter()
  %mul = fmul hex_fp64 %sixteen, %minus_quarter
  ret hex_fp64 %mul
}

; CHECK:      define dso_local noundef hex_fp64 @minus_four()
; CHECK-NEXT:   ret hex_fp64 0xSC140000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp64 @sixteenth() #0 {
  ; test -ve / -ve == +ve
  %minus_quarter = call hex_fp64 @minus_quarter()
  %minus_four = call hex_fp64 @minus_four()
  %div = fdiv hex_fp64 %minus_quarter, %minus_four
  ret hex_fp64 %div
}

; CHECK:      define dso_local noundef hex_fp64 @sixteenth()
; CHECK-NEXT:   ret hex_fp64 0xS4010000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp64 @minus_eighth() #0 {
  ; test -ve / +ve == -ve
  %minus_quarter = call hex_fp64 @minus_quarter()
  %two = call hex_fp64 @two()
  %div = fdiv hex_fp64 %minus_quarter, %two
  ret hex_fp64 %div
}

; CHECK:      define dso_local noundef hex_fp64 @minus_eighth()
; CHECK-NEXT:   ret hex_fp64 0xSC020000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @sixty_fourth() #0 {
  ; test -ve * -ve == +ve
  %minus_eighth = call hex_fp64 @minus_eighth()
  %mul = fmul hex_fp64 %minus_eighth, %minus_eighth
  ret hex_fp64 %mul
}

; CHECK:      define dso_local noundef hex_fp64 @sixty_fourth()
; CHECK-NEXT:   ret hex_fp64 0xS3F40000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @three_and_three_quarters() #0 {
  ; test -1/4 - -4 == 3 3/4
  %minus_quarter = call hex_fp64 @minus_quarter()
  %minus_four = call hex_fp64 @minus_four()
  %sub = fsub hex_fp64 %minus_quarter, %minus_four
  ret hex_fp64 %sub
}

; CHECK:      define dso_local noundef hex_fp64 @three_and_three_quarters()
; CHECK-NEXT:   ret hex_fp64 0xS413C000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp64 @minus_one() #0 {
  ; 1 - 2 == -1
  %one = call hex_fp64 @one()
  %two = call hex_fp64 @two()
  %sub = fsub hex_fp64 %one, %two
  ret hex_fp64 %sub
}

; CHECK:      define dso_local noundef hex_fp64 @minus_one()
; CHECK-NEXT:   ret hex_fp64 0xSC110000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @minus_seventeen() #0 {
  ; -1 - 16 == -17
  %minus_one = call hex_fp64 @minus_one()
  %sixteen = call hex_fp64 @sixteen()
  %sub = fsub hex_fp64 %minus_one, %sixteen
  ret hex_fp64 %sub
}

; CHECK:      define dso_local noundef hex_fp64 @minus_seventeen()
; CHECK-NEXT:   ret hex_fp64 0xSC211000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @two_fifty_six() #0 {
  ; 16 / 1/16 == 256
  %sixteen = call hex_fp64 @sixteen()
  %sixteenth = call hex_fp64 @sixteenth()
  %div = fdiv hex_fp64 %sixteen, %sixteenth
  ret hex_fp64 %div
}

; CHECK:      define dso_local noundef hex_fp64 @two_fifty_six()
; CHECK-NEXT:   ret hex_fp64 0xS4310000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @minus_sixty_four() #0 {
  ; 256 * -1/4 == -64
  %two_fifty_six = call hex_fp64 @two_fifty_six()
  %minus_quarter = call hex_fp64 @minus_quarter()
  %mul = fmul hex_fp64 %two_fifty_six, %minus_quarter
  ret hex_fp64 %mul
}

; CHECK:      define dso_local noundef hex_fp64 @minus_sixty_four()
; CHECK-NEXT:   ret hex_fp64 0xSC240000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp64 @minus_sixty_three() #0 {
  ; -64 + 1 == -63
  %minus_sixty_four = call hex_fp64 @minus_sixty_four()
  %one = call hex_fp64 @one()
  %add = fadd hex_fp64 %minus_sixty_four, %one
  ret hex_fp64 %add
}

; CHECK:      define dso_local noundef hex_fp64 @minus_sixty_three()
; CHECK-NEXT:   ret hex_fp64 0xSC23F000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
