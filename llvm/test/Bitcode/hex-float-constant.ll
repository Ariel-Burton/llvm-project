; This test runs the .ll through llvm-as, and the output of llvm-as
; back through llvm-dis.
; The constants here in the IR are given in decimal.
; The values that emerge from llvm-dis as in HexFloat 0xS foramt,
; which are checked by FileCheck against the patterns here.
;
; As a further step, we check that HexFloat 0xS format in the IR can be
; read by passig the generated IR (in %t) through llvm-as and llvm-dis again.

; This sequence checks that we are translating from decimal notation
; to HexFloat representation
; RUN: llvm-as %s -o - | llvm-dis - -o %t
; RUN: FileCheck %s < %t
;
; This sequence checks that we can handle the constants given in HexFloat
; RUN: llvm-as %t -o - | llvm-dis - -o - | FileCheck %s
;


@pi_hexfp32 = dso_local global hex_fp32 0xS413243f3, align 4
; CHECK: @pi_hexfp32 = dso_local global hex_fp32 0xS413243F3, align 4

@half = dso_local global hex_fp32 5.000000e-01, align 4
; CHECK: @half = dso_local global hex_fp32 0xS40800000, align 4

@quarter = dso_local global hex_fp32 2.500000e-01, align 4
; CHECK: @quarter = dso_local global hex_fp32 0xS40400000, align 4

;@eighth = dso_local global hex_fp64 1.250000e-01, align 4
; CHECK: @eighth = dso_local global hex_fp64 0xS4020000000000000, align 4

@sixteenth = dso_local global hex_fp128 6.250000e-02, align 4
; CHECK: @sixteenth = dso_local global hex_fp128 0xS40100000000000000000000000000000, align 4

