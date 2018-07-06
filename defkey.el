;;; defkey.el --- something something keybindings    -*- lexical-binding: t; -*-

;; Copyright (C) 2018  Nick Drozd

;; Author: Nick Drozd <nicholasdrozd@gmail.com>
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

;;

;;; Code:

(defmacro defkey (key def &optional keymap)
  "Assign DEF to KEY in KEYMAP.
KEYMAP defaults to `global-map'."
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
  "Bind def to key in KEYMAP for each key-def pair in KEY-DEFS."
  (let* ((pairs (defkey--partition-pairs key-defs))
         (statements (mapcar (lambda (pair) `(defkey ,@pair ,keymap))
                             pairs)))
    `(progn ,@statements)))

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
