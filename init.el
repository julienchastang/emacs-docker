(setq load-path
      (delq nil (mapcar
		 (function (lambda (p)
			     (unless (string-match "lisp\\(/packages\\)?/org$" p)
			       p)))
		 load-path)))

;; remove property list to defeat cus-load and remove autoloads
(mapatoms (function  (lambda (s)
		       (let ((sn (symbol-name s)))
			 (when (string-match "^\\(org\\|ob\\|ox\\)\\(-.*\\)?$" sn)
			   (setplist s nil)
			   (when (eq 'autoload (car-safe s))
			     (unintern s)))))))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/git/org-mode/lisp"))

(add-to-list 'load-path (expand-file-name "~/.emacs.d/git/org-mode/contrib/lisp"))

(package-initialize)
(require 'cl)
(require 'ob-tangle)
(org-babel-load-file "~/.emacs.d/git/dotemacs/settings.org")
