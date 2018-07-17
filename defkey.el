;;; defkey.el --- Clean Emacs key bindings    -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Nick Drozd

;; Author: Nick Drozd <nicholasdrozd@gmail.com>
;; URL: https://github.com/nickdrozd/defkey
;; Version: 0.1
;; Package-Requires: ((emacs "24"))
;; Keywords: abbrev, lisp

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

;; defkey is an attempt to smooth over some of the annoyances and
;; irregularities involved in setting Emacs key bindings.

;;; Code:

(defmacro defkey (key def &optional keymap)
  "Bind DEF to KEY in KEYMAP (defaults to `global-map').

KEY can be a symbol or a list of symbols, with a symbol being
interpreted as a key and a list being interpreted as a list of
keys.

EXAMPLE:

  (defkey (C-x C-b) ibuffer)
    =>
      (define-key global-map (kbd \"C-x C-b\") (quote ibuffer))

DEF can be a symbol or a list. A list will be interpreted as an
interactive lambda of no arguments whose body is DEF.

EXAMPLE:

  (defkey H-m (switch-to-buffer \"*Messages*\"))
    =>
      (define-key global-map (kbd \"H-m\")
        (lambda nil (interactive) (switch-to-buffer \"*Messages*\")))

KEYMAP must be a symbol. If none is supplied, `global-map' will
be used."
  (let ((key-string
         (if (symbolp key)
             (symbol-name `,key)
           (mapconcat #'symbol-name key " "))))
  `(define-key
     ,(if keymap keymap 'global-map)
     (kbd ,key-string)
     ,(cond
       ((symbolp def) `',def)
       ((null def) nil)
       (t `(lambda () (interactive) ,def))))))

(defmacro defkeys-in-map (keymap &rest key-defs)
  "Bind def to key in KEYMAP for each key-def pair in KEY-DEFS.

EXAMPLE:

  (defkeys-in-map org-mode-map
    C-v org-yank
    C-y backward-kill-word)"
  (let* ((pairs (defkey--partition-pairs key-defs))
         (statements (mapcar (lambda (pair) `(defkey ,@pair ,keymap))
                             pairs)))
    `(progn ,@statements)))

(defmacro defkeys (&rest key-defs)
  "Bind def to key in `global-map' for each key-def pair in KEY-DEFS.

Equivalent to (defkeys-in-map global map ,@key-defs).

EXAMPLE:

  (defkeys
    (C-x C-x) execute-extended-command
    s-f other-window
    s-b (other-window -1))"
  `(defkeys-in-map global-map ,@key-defs))

;; helpers

(defun defkey--partition-pairs (args)
  "Return a list of pairs of ARGS, ignorning danglers.
Ex: (a 1 b 2 c 3) => ((a 1) (b 2) (c 3))."
  (let (result)
    (while (> (length args) 1)
      (let ((seq `(,(car args) ,(cadr args))))
        (setq result (cons seq result)
              args (cddr args))))
    (nreverse result)))


(provide 'defkey)
;;; defkey.el ends here
