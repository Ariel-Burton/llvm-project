; RUN: opt %s -O1 -o %t
; RUN: llvm-dis %t -o - | FileCheck %s
;
; This test runs the .ll through opt, and the output of opt
; back through llvm-dis
; The objective is to test that HexFloat arithmetic used during
; constant folding works as expected

define internal hex_fp128 @half() #0 {
  ret hex_fp128 5.000000e-01
}

define internal hex_fp128 @two() #0 {
  ret hex_fp128 2.000000e-00
}

define internal hex_fp128 @sixteen() #0 {
  ret hex_fp128 16.000000e-00
}

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @one() #0 {
  ; 2 * 1/2 == 1
  %two = call hex_fp128 @two()
  %half = call hex_fp128 @half()
  %mul = fmul hex_fp128 %two, %half
  ret hex_fp128 %mul
}

; CHECK:      define dso_local noundef hex_fp128 @one()
; CHECK-NEXT:   ret hex_fp128 0xS41100000000000003300000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @quarter() #0 {
  ; 1/2 / 2 == 1/4
  %half = call hex_fp128 @half()
  %two = call hex_fp128 @two()
  %div = fdiv hex_fp128 %half, %two
  ret hex_fp128 %div
}

; CHECK:      define dso_local noundef hex_fp128 @quarter()
; CHECK-NEXT:   ret hex_fp128 0xS40400000000000003200000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @three_quarters() #0 {
  ; 1/2 + 1/4 == 3/4
  %half = call hex_fp128 @half()
  %quarter = call hex_fp128 @quarter()
  %add = fadd hex_fp128 %half, %quarter
  ret hex_fp128 %add
}

; CHECK:      define dso_local noundef hex_fp128 @three_quarters()
; CHECK-NEXT:   ret hex_fp128 0xS40C00000000000003200000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @minus_quarter() #0 {
  ; 1/4 - 1/2 == -1/4
  %quarter = call hex_fp128 @quarter()
  %half = call hex_fp128 @half()
  %sub = fsub hex_fp128 %quarter, %half
  ret hex_fp128 %sub
}

; CHECK:      define dso_local noundef hex_fp128 @minus_quarter()
; CHECK-NEXT:   ret hex_fp128 0xSC040000000000000B200000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @minus_four() #0 {
  ; test +ve * -ve == -ve
  %sixteen = call hex_fp128 @sixteen()
  %minus_quarter = call hex_fp128 @minus_quarter()
  %mul = fmul hex_fp128 %sixteen, %minus_quarter
  ret hex_fp128 %mul
}

; CHECK:      define dso_local noundef hex_fp128 @minus_four()
; CHECK-NEXT:   ret hex_fp128 0xSC140000000000000B300000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp128 @sixteenth() #0 {
  ; test -ve / -ve == +ve
  %minus_quarter = call hex_fp128 @minus_quarter()
  %minus_four = call hex_fp128 @minus_four()
  %div = fdiv hex_fp128 %minus_quarter, %minus_four
  ret hex_fp128 %div
}

; CHECK:      define dso_local noundef hex_fp128 @sixteenth()
; CHECK-NEXT:   ret hex_fp128 0xS40100000000000003200000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp128 @minus_eighth() #0 {
  ; test -ve / +ve == -ve
  %minus_quarter = call hex_fp128 @minus_quarter()
  %two = call hex_fp128 @two()
  %div = fdiv hex_fp128 %minus_quarter, %two
  ret hex_fp128 %div
}

; CHECK:      define dso_local noundef hex_fp128 @minus_eighth()
; CHECK-NEXT:   ret hex_fp128 0xSC020000000000000B200000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @sixty_fourth() #0 {
  ; test -ve * -ve == +ve
  %minus_eighth = call hex_fp128 @minus_eighth()
  %mul = fmul hex_fp128 %minus_eighth, %minus_eighth
  ret hex_fp128 %mul
}

; CHECK:      define dso_local noundef hex_fp128 @sixty_fourth()
; CHECK-NEXT:   ret hex_fp128 0xS3F400000000000003100000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @three_and_three_quarters() #0 {
  ; test -1/4 - -4 == 3 3/4
  %minus_quarter = call hex_fp128 @minus_quarter()
  %minus_four = call hex_fp128 @minus_four()
  %sub = fsub hex_fp128 %minus_quarter, %minus_four
  ret hex_fp128 %sub
}

; CHECK:      define dso_local noundef hex_fp128 @three_and_three_quarters()
; CHECK-NEXT:   ret hex_fp128 0xS413C0000000000003300000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


define dso_local hex_fp128 @minus_one() #0 {
  ; 1 - 2 == -1
  %one = call hex_fp128 @one()
  %two = call hex_fp128 @two()
  %sub = fsub hex_fp128 %one, %two
  ret hex_fp128 %sub
}

; CHECK:      define dso_local noundef hex_fp128 @minus_one()
; CHECK-NEXT:   ret hex_fp128 0xSC110000000000000B300000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @minus_seventeen() #0 {
  ; -1 - 16 == -17
  %minus_one = call hex_fp128 @minus_one()
  %sixteen = call hex_fp128 @sixteen()
  %sub = fsub hex_fp128 %minus_one, %sixteen
  ret hex_fp128 %sub
}

; CHECK:      define dso_local noundef hex_fp128 @minus_seventeen()
; CHECK-NEXT:   ret hex_fp128 0xSC211000000000000B400000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @two_fifty_six() #0 {
  ; 16 / 1/16 == 256
  %sixteen = call hex_fp128 @sixteen()
  %sixteenth = call hex_fp128 @sixteenth()
  %div = fdiv hex_fp128 %sixteen, %sixteenth
  ret hex_fp128 %div
}

; CHECK:      define dso_local noundef hex_fp128 @two_fifty_six()
; CHECK-NEXT:   ret hex_fp128 0xS43100000000000003500000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @minus_sixty_four() #0 {
  ; 256 * -1/4 == -64
  %two_fifty_six = call hex_fp128 @two_fifty_six()
  %minus_quarter = call hex_fp128 @minus_quarter()
  %mul = fmul hex_fp128 %two_fifty_six, %minus_quarter
  ret hex_fp128 %mul
}

; CHECK:      define dso_local noundef hex_fp128 @minus_sixty_four()
; CHECK-NEXT:   ret hex_fp128 0xSC240000000000000B400000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

define dso_local hex_fp128 @minus_sixty_three() #0 {
  ; -64 + 1 == -63
  %minus_sixty_four = call hex_fp128 @minus_sixty_four()
  %one = call hex_fp128 @one()
  %add = fadd hex_fp128 %minus_sixty_four, %one
  ret hex_fp128 %add
}

; CHECK:      define dso_local noundef hex_fp128 @minus_sixty_three()
; CHECK-NEXT:   ret hex_fp128 0xSC23F000000000000B400000000000000

; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
