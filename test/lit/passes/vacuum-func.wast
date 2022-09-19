;; NOTE: Assertions have been generated by update_lit_checks.py and should not be edited.
;; RUN: wasm-opt %s --vacuum -all -S -o - | filecheck %s

;; Tests vacuuming the entire body of a function. In that case we can ignore
;; effects like a return or changes to locals.

(module
  ;; CHECK:      (func $optimizable (param $x i32)
  ;; CHECK-NEXT:  (local $y i32)
  ;; CHECK-NEXT:  (nop)
  ;; CHECK-NEXT: )
  (func $optimizable (param $x i32)
    (local $y i32)
    ;; This entire function body can be optimized out. First, operations on
    ;; locals are not observable once the function exits.
    (local.set $x
      (i32.const 1)
    )
    (local.set $y
      (i32.const 2)
    )
    (drop
      (local.get $x)
    )
    ;; Second, a return has no noticeable effect for the caller to notice.
    (return)
  )

  ;; CHECK:      (func $result (param $x i32) (result i32)
  ;; CHECK-NEXT:  (local $y i32)
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $y
  ;; CHECK-NEXT:   (i32.const 2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (return
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT: )
  (func $result (param $x i32) (result i32)
    (local $y i32)
    ;; As above, but this function returns a value, so we cannot optimize here:
    ;; the value must be computed and returned. (We could in theory remove just
    ;; the parts that are valid to remove, but other passes will do so anyhow
    ;; for the code in this test at least.)
    (local.set $x
      (i32.const 1)
    )
    (local.set $y
      (i32.const 2)
    )
    (return
      (local.get $x)
    )
  )

  ;; CHECK:      (func $partial (param $x i32)
  ;; CHECK-NEXT:  (local $y i32)
  ;; CHECK-NEXT:  (if
  ;; CHECK-NEXT:   (local.get $x)
  ;; CHECK-NEXT:   (unreachable)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $x
  ;; CHECK-NEXT:   (i32.const 1)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (local.set $y
  ;; CHECK-NEXT:   (i32.const 2)
  ;; CHECK-NEXT:  )
  ;; CHECK-NEXT:  (return)
  ;; CHECK-NEXT: )
  (func $partial (param $x i32)
    (local $y i32)

    ;; As above, but with this |if| added with extra possible effects. This
    ;; prevents optimization. (We could in theory remove just the parts that are
    ;; valid to remove, but other passes will do so anyhow for the code in this
    ;; test at least.)
    (if
      (local.get $x)
      (unreachable)
    )

    (local.set $x
      (i32.const 1)
    )
    (local.set $y
      (i32.const 2)
    )
    (drop
      (local.get $x)
    )
    (return)
  )
)
