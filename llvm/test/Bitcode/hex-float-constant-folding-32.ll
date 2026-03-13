; RUN: opt %s -O1 -o %t
; RUN: llvm-dis %t -o - | FileCheck %s
;
; This test runs the .ll through opt, and the output of opt
; back through llvm-dis
; The objective is to test that HexFloat arithmetic used during
; constant folding works as expected

define internal hex_fp32 @half() #0 {
  ret hex_fp32 5.000000e-01
}

define internal hex_fp32 @two() #0 {
  ret hex_fp32 2.000000e-00
}

define internal hex_fp32 @sixteen() #0 {
  ret hex_fp32 16.000000e-00
}

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @one() #0 {
  ; 2 * 1/2 == 1
  %two = call hex_fp32 @two()
  %half = call hex_fp32 @half()
  %mul = fmul hex_fp32 %two, %half
  ret hex_fp32 %mul
}

; CHECK:      define dso_local noundef hex_fp32 @one()
; CHECK-NEXT:   ret hex_fp32 0xS41100000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @quarter() #0 {
  ; 1/2 / 2 == 1/4
  %half = call hex_fp32 @half()
  %two = call hex_fp32 @two()
  %div = fdiv hex_fp32 %half, %two
  ret hex_fp32 %div
}

; CHECK:      define dso_local noundef hex_fp32 @quarter()
; CHECK-NEXT:   ret hex_fp32 0xS40400000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @three_quarters() #0 {
  ; 1/2 + 1/4 == 3/4
  %half = call hex_fp32 @half()
  %quarter = call hex_fp32 @quarter()
  %add = fadd hex_fp32 %half, %quarter
  ret hex_fp32 %add
}

; CHECK:      define dso_local noundef hex_fp32 @three_quarters()
; CHECK-NEXT:   ret hex_fp32 0xS40C00000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @minus_quarter() #0 {
  ; 1/4 - 1/2 == -1/4
  %quarter = call hex_fp32 @quarter()
  %half = call hex_fp32 @half()
  %sub = fsub hex_fp32 %quarter, %half
  ret hex_fp32 %sub
}

; CHECK:      define dso_local noundef hex_fp32 @minus_quarter()
; CHECK-NEXT:   ret hex_fp32 0xSC0400000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @minus_four() #0 {
  ; test +ve * -ve == -ve
  %sixteen = call hex_fp32 @sixteen()
  %minus_quarter = call hex_fp32 @minus_quarter()
  %mul = fmul hex_fp32 %sixteen, %minus_quarter
  ret hex_fp32 %mul
}

; CHECK:      define dso_local noundef hex_fp32 @minus_four()
; CHECK-NEXT:   ret hex_fp32 0xSC1400000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp32 @sixteenth() #0 {
  ; test -ve / -ve == +ve
  %minus_quarter = call hex_fp32 @minus_quarter()
  %minus_four = call hex_fp32 @minus_four()
  %div = fdiv hex_fp32 %minus_quarter, %minus_four
  ret hex_fp32 %div
}

; CHECK:      define dso_local noundef hex_fp32 @sixteenth()
; CHECK-NEXT:   ret hex_fp32 0xS40100000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp32 @minus_eighth() #0 {
  ; test -ve / +ve == -ve
  %minus_quarter = call hex_fp32 @minus_quarter()
  %two = call hex_fp32 @two()
  %div = fdiv hex_fp32 %minus_quarter, %two
  ret hex_fp32 %div
}

; CHECK:      define dso_local noundef hex_fp32 @minus_eighth()
; CHECK-NEXT:   ret hex_fp32 0xSC0200000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @sixty_fourth() #0 {
  ; test -ve * -ve == +ve
  %minus_eighth = call hex_fp32 @minus_eighth()
  %mul = fmul hex_fp32 %minus_eighth, %minus_eighth
  ret hex_fp32 %mul
}

; CHECK:      define dso_local noundef hex_fp32 @sixty_fourth()
; CHECK-NEXT:   ret hex_fp32 0xS3F400000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @three_and_three_quarters() #0 {
  ; test -1/4 - -4 == 3 3/4
  %minus_quarter = call hex_fp32 @minus_quarter()
  %minus_four = call hex_fp32 @minus_four()
  %sub = fsub hex_fp32 %minus_quarter, %minus_four
  ret hex_fp32 %sub
}

; CHECK:      define dso_local noundef hex_fp32 @three_and_three_quarters()
; CHECK-NEXT:   ret hex_fp32 0xS413C0000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp32 @minus_one() #0 {
  ; 1 - 2 == -1
  %one = call hex_fp32 @one()
  %two = call hex_fp32 @two()
  %sub = fsub hex_fp32 %one, %two
  ret hex_fp32 %sub
}

; CHECK:      define dso_local noundef hex_fp32 @minus_one()
; CHECK-NEXT:   ret hex_fp32 0xSC1100000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @minus_seventeen() #0 {
  ; -1 - 16 == -17
  %minus_one = call hex_fp32 @minus_one()
  %sixteen = call hex_fp32 @sixteen()
  %sub = fsub hex_fp32 %minus_one, %sixteen
  ret hex_fp32 %sub
}

; CHECK:      define dso_local noundef hex_fp32 @minus_seventeen()
; CHECK-NEXT:   ret hex_fp32 0xSC2110000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @two_fifty_six() #0 {
  ; 16 / 1/16 == 256
  %sixteen = call hex_fp32 @sixteen()
  %sixteenth = call hex_fp32 @sixteenth()
  %div = fdiv hex_fp32 %sixteen, %sixteenth
  ret hex_fp32 %div
}

; CHECK:      define dso_local noundef hex_fp32 @two_fifty_six()
; CHECK-NEXT:   ret hex_fp32 0xS43100000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @minus_sixty_four() #0 {
  ; 256 * -1/4 == -64
  %two_fifty_six = call hex_fp32 @two_fifty_six()
  %minus_quarter = call hex_fp32 @minus_quarter()
  %mul = fmul hex_fp32 %two_fifty_six, %minus_quarter
  ret hex_fp32 %mul
}

; CHECK:      define dso_local noundef hex_fp32 @minus_sixty_four()
; CHECK-NEXT:   ret hex_fp32 0xSC2400000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp32 @minus_sixty_three() #0 {
  ; -64 + 1 == -63
  %minus_sixty_four = call hex_fp32 @minus_sixty_four()
  %one = call hex_fp32 @one()
  %add = fadd hex_fp32 %minus_sixty_four, %one
  ret hex_fp32 %add
}

; CHECK:      define dso_local noundef hex_fp32 @minus_sixty_three()
; CHECK-NEXT:   ret hex_fp32 0xSC23F0000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
