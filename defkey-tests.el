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

(defmacro defkey--should-expand-to (input expected)
  "Assert that INPUT expands into EXPECTED."
  (declare (indent 1))
  `(should (equal ',(macroexpand-1 input) ',expected)))

;; defkey

(ert-deftest defkey--test-defkey-simple ()
  (defkey--should-expand-to
      (defkey C-a some-func)
    (define-key global-map (kbd "C-a") (quote some-func))))

(ert-deftest defkey--test-defkey-key-sequence ()
  (defkey--should-expand-to
      (defkey (C-a M-b s-c H-d) some-func)
    (define-key global-map (kbd "C-a M-b s-c H-d") (quote some-func))))

(ert-deftest defkey--test-defkey-nil ()
  (defkey--should-expand-to
      (defkey H-q nil)
    (define-key global-map (kbd "H-q") 'nil)))

(ert-deftest defkey--test-defkey-lambda ()
  (defkey--should-expand-to
      (defkey s-p (func-with-arg -1))
    (define-key global-map (kbd "s-p")
      (lambda nil (interactive) (func-with-arg -1)))))

(ert-deftest defkey--test-defkey-map ()
  (defkey--should-expand-to
      (defkey M-^ some-func some-map)
    (define-key some-map (kbd "M-^") 'some-func)))

(ert-deftest defkey--test-defkey-complex ()
  (defkey--should-expand-to
      (defkey (H-z s-y M-x C-w) (some-func 0 1 -1 t nil) some-map)
    (define-key some-map (kbd "H-z s-y M-x C-w")
      (lambda nil (interactive) (some-func 0 1 -1 t nil)))))


(provide 'defkey-tests)
;;; defkey-tests.el ends here
