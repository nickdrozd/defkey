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

`defkey` makes the key binding process a lot easier. It might even
make it fun!

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
