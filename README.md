# defkey

#### `defkey` provides a clean, lightweight interface for key bindings that is easy to read and easy to modify.

Go take a look at your Emacs config.

Is it full of key bindings like these?
```
(global-set-key (kbd "M-m") 'do-something)
(global-set-key (kbd "M-M") 'do-something-else)
(global-set-key (kbd "s-m") 'this-function)
(global-set-key (kbd "C-x C-i") 'that-function)
(global-set-key (kbd "C-x M-f") (lambda () (interactive) (what -1)))
(global-set-key (kbd "C-x f") 'a-function-I-wrote)
(global-set-key (kbd "H-x H-p") 'one-I-got-from-emacs-wiki)
```
To me this kind of thing is hard to read. There's a big wall of
repeated text, and to get the information I want, I have to sift
through a bunch of boilerplate.

What's worse is that it's also hard to add new bindings. Most likely
if my config already looks like this, I will simply copy an existing
line and modify it. Maybe I'm just incompetent, but I always end up
accidentally deleting one of the quotation marks, and then when I add
it back, it adds a pair of them, so then I have to delete one, and so
on. It's a whole thing, and it ends up taking longer than it should.

Of course, adding a new key binding from scratch is no picnic either.
Do I use `define-key` or `global-set-key`? How do I set the keys?
`kbd` something? What about `"/C-a"`? Or is it `?\C-a`? Or ""? Or
`[1]`? What about multiple keys? And what about the function, do I
need to quote it? Hash-quote it? What about lambdas?

#### `defkey` makes the key binding process a lot easier. It might even make it fun!

Here are some side-by-side comparisons of `defkey` bindings with their
builtin counterparts.
```
(global-set-key (kbd "C-v") 'yank)

(defkey C-v yank)
```
```
(global-set-key (kbd "C-x C-x") 'execute-extended-command)

(defkey (C-x C-x) execute-extended-command)
```
```
(global-set-key (kbd "s-p") (lambda () (interactive) (other-window -1)))

(defkey s-p (other-window -1))
```
Even better than a bunch of calls to `defkey` is a single call to `defkeys`:
```
(defkeys
  C-v yank
  (C-x C-x) execute-extended-command
  s-p (other-window -1)
  )
```
It's also easy to bind keys in a particular map.
```
(defkeys-in-map comint-mode-map
  H-p comint-previous-prompt
  H-n comint-next-prompt
  )
```
## FAQ

### How do I bind a key like "C-(" or "M-;"?

Just add a backslash before the special syntax character:
```
(defkeys
  C-\( this
  M-\; that
  s-\, the-third)
```
### Does this package actually do anything?

It provides a novel API for defining keys. If you're satisfied with
the builtin key-defining APIs, then you don't need this package. But
ask yourself: are you satisfied with it? I mean, truly satisfied?

### Are you really so lazy that you came up with a whole packages just to save yourself a little typing?

It's not just that I hate typing all the extra little characters. I
also hate reading them, and I don't want them cluttering up my config.
Perhaps that motivation is even pettier than laziness, but that's a
matter of taste.

### How does `defkey` compare to `bind-key`?

[bind-key](http://melpa.org/#/bind-key) is part of
[use-package](https://github.com/jwiegley/use-package), and it allows
for binding keys as part of a package configuration, as in
```
(use-package hi-lock
  :bind (("M-o l" . highlight-lines-matching-regexp)
         ("M-o r" . highlight-regexp)
         ("M-o w" . highlight-phrase)))
```
`use-package` is incredible, but I don't use this feature. Instead, I
just stick `defkeys` in the `:config` section:
```
(use-package hi-lock
  :config
  (defkeys
    (M-o l) highlight-lines-matching-regexp
    (M-o r) highlight-regexp
    (M-o w) highlight phrase))
```
`bind-key` can also be used standalone (though this isn't
well-advertised):
```
(bind-keys*
 ("C-o" . other-window)
 ("C-M-n" . forward-page)
 ("C-M-p" . backward-page))
```
With `defkey`, that would look like:
```
(defkeys
  C-o  other-window
  C-M-n  forward-page
  C-M-p  backward-page)
```
Compared to `bind-key`, `defkey` saves quotation marks, cons dots, and
in most case parentheses.

### How does `defkey` compare to `general.el`?

I haven't used [general.el](https://github.com/noctuid/general.el),
but from what I gather it is a full-featured key-binding package with
an emphasis on `evil` and lots of options for manipulating maps and
submaps. (The name is a pun: *general* as in *covering lots of cases*,
but also *general* as in *leader* as in *leader key*). I don't use
`evil` and my mapping needs are not complex, so `general` seems like
overkill for me. If you need fine control over your maps, `general` is
probably better than `defkey`.

Still, `general` requires quotation marks and quotes:
```
(general-define-key
 "M-x" 'amx
 "C-s" 'counsel-grep-or-swiper)

(general-define-key
 :keymaps 'org-mode-map
 "C-c C-q" 'counsel-org-tag
 ;; ...
 )

(general-def org-mode-map
  "C-c C-q" 'counsel-org-tag
  ;; ...
  )

(general-define-key
 :prefix "C-c"
 "a" 'org-agenda
 "b" 'counsel-bookmark
 "c" 'org-capture)
```
### Never use a macro where a function will do.

Right, well in this case a function won't do. If `defkey` were a
function, then the call `(defkey C-a some-func)` would attempt to look
up the values for variables `C-a` and `some-func` and then fail. Even
worse, `(defkey C-a (other-window -1))` could (depending on the order
of evaluation of arguments) actually execute `(other-window -1)`,
thereby switching the window *at definition time*.
