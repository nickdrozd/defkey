;;; defkey-tests.el --- Tests for defkey             -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Nick Drozd

;; Author: Nick Drozd <nicholasdrozd@gmail.com>

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'ert)
(require 'defkey)

;; Integration Tests

(defmacro defkey--with-keymap (name &rest body)
  "Execute BODY with a sparse keymap called NAME."
  (declare (indent 1))
  `(let ((,name (make-sparse-keymap)))
     ,@body))

(defun defkey--should-lookup (keymap key def)
  "Assert that KEY looks-up to DEF in KEYMAP."
  (should (equal def (lookup-key keymap (kbd key)))))

(defun defkey--should-where-is (keymap key def)
  "Assert that DEF where-is's to KEY in KEYMAP."
  (should
   (equal
    (where-is-internal def `(,keymap))
    `(,(vconcat
        (mapcar
         (lambda (c)
           (let ((k (kbd c)))
             (if (arrayp k)
                 (aref k 0)
               (string-to-char k))))
         (split-string key)))))))

(defun defkey--verify-binding (keymap key def)
  "Verify that KEY and DEF are bound in KEYMAP."
  (defkey--should-lookup keymap key def)
  (defkey--should-where-is keymap key def))

(defun defkey--should-unbound (keymap key)
  "Assert that KEY is not bound in KEYMAP."
  (should (null (lookup-key keymap (kbd key)))))

;; defkey

(ert-deftest defkey--test-integration-defkey-simple ()
  (defkey--with-keymap test--map
    (defkey C-a test--func test--map)
    (defkey--verify-binding test--map "C-a" 'test--func)))

(ert-deftest defkey--test-integration-defkey-global ()
  (defkey--with-keymap global-map
    (defkey C-a move-end-of-line)
    (defkey--verify-binding global-map "C-a" 'move-end-of-line)))

(ert-deftest defkey--test-integration-defkey-lambda ()
  (defkey--with-keymap test--map
    (defkey H-y (message "hieeeee") test--map)
    (defkey--should-lookup test--map "H-y"
      (lambda () (interactive) (message "hieeeee")))))

(ert-deftest defkey--test-integration-defkey-key-sequence ()
  (defkey--with-keymap test--map
    (defkey (C-b d) lol test--map)
    (defkey--verify-binding test--map "C-b d" 'lol)))

(ert-deftest defkey--test-integration-defkey-nil ()
  (defkey--with-keymap test--map
    (defkey C-w some-func test--map)
    (defkey--verify-binding test--map "C-w" 'some-func)
    (defkey C-w nil test--map)
    (defkey--should-unbound test--map "C-w")))

;; Unit Tests

(defmacro defkey--should-expand-to (input expected)
  "Assert that INPUT expands into EXPECTED."
  (declare (indent 1))
  `(should (equal ',(macroexpand-1 input) ',expected)))

;; defkey

(ert-deftest defkey--test-unit-defkey-simple ()
  (defkey--should-expand-to
      (defkey C-a some-func)
    (define-key global-map (kbd "C-a") (quote some-func))))

(ert-deftest defkey--test-unit-defkey-key-sequence ()
  (defkey--should-expand-to
      (defkey (C-a M-b s-c H-d) some-func)
    (define-key global-map (kbd "C-a M-b s-c H-d") (quote some-func))))

(ert-deftest defkey--test-unit-defkey-nil ()
  (defkey--should-expand-to
      (defkey H-q nil)
    (define-key global-map (kbd "H-q") 'nil)))

(ert-deftest defkey--test-unit-defkey-lambda ()
  (defkey--should-expand-to
      (defkey s-p (func-with-arg -1))
    (define-key global-map (kbd "s-p")
      (lambda nil (interactive) (func-with-arg -1)))))

(ert-deftest defkey--test-unit-defkey-map ()
  (defkey--should-expand-to
      (defkey M-^ some-func some-map)
    (define-key some-map (kbd "M-^") 'some-func)))

(ert-deftest defkey--test-unit-defkey-complex ()
  (defkey--should-expand-to
      (defkey (H-z s-y M-x C-w) (some-func 0 1 -1 t nil) some-map)
    (define-key some-map (kbd "H-z s-y M-x C-w")
      (lambda nil (interactive) (some-func 0 1 -1 t nil)))))

;; defkeys-in-map

(ert-deftest defkey--test-unit-defkeys-in-map-simple ()
  (defkey--should-expand-to
      (defkeys-in-map whatever-map
        C-a whatever-func-1
        M-b whatever-func-2)
    (progn
      (defkey C-a whatever-func-1 whatever-map)
      (defkey M-b whatever-func-2 whatever-map))))

(ert-deftest defkey--test-unit-defkeys-in-map-dangler ()
  (defkey--should-expand-to
      (defkeys-in-map some-map
        H-g some-func
        H-t some-other-func
        H-v)
    (progn
      (defkey H-g some-func some-map)
      (defkey H-t some-other-func some-map))))

(ert-deftest defkey--test-unit-defkeys-in-map-complex ()
  (defkey--should-expand-to
      (defkeys-in-map global-map
        (C-z M-y) (a-function with args)
        H-x another-function
        s-w nil
        dangler)
    (progn
      (defkey (C-z M-y) (a-function with args) global-map)
      (defkey H-x another-function global-map)
      (defkey s-w nil global-map))))

;; defkeys

(ert-deftest defkey--test-unit-defkeys-simple ()
  (defkey--should-expand-to
      (defkeys
        C-p p-func
        C-g g-func)
    (defkeys-in-map global-map
      C-p p-func
      C-g g-func)))

(ert-deftest defkey--test-unit-defkeys-complex ()
  (defkey--should-expand-to
      (defkeys
        (C-a C-a C-a) function-a
        (M-b M-b) function-b
        (H-c H-c))
    (defkeys-in-map global-map
      (C-a C-a C-a) function-a
      (M-b M-b) function-b
      (H-c H-c))))

;; helpers

(ert-deftest defkey--test-unit-partition-pairs ()
  (should (equal (defkey--partition-pairs '(a 1 b 2 c 3)) '((a 1) (b 2) (c 3))))
  (should (equal (defkey--partition-pairs '(a 1 b 2 c 3 d)) '((a 1) (b 2) (c 3)))))


(provide 'defkey-tests)
;;; defkey-tests.el ends here
