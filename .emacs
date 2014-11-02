(add-to-list 'load-path "~/.emacs.d/el-get/el-get")

(unless (require 'el-get nil t)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (goto-char (point-max))
    (eval-print-last-sexp)))

(el-get 'sync)

(evil-mode 1)

(setq inhibit-splash-screen t)
(set-scroll-bar-mode nil) ;;no scrollbar
(tool-bar-mode -1) ;;no toolbar

;;TeX
(setq TeX-save-query nil) ;;autosave before compiling
(setq TeX-PDF-mode t)
(setq TeX-auto-save t)
(setq TeX-parse-self t)
(setq TeX-command-force "")
(setq TeX-command-default "LaTeX")

;; gap mode
(add-to-list 'load-path "~/.emacs.d/other")
(autoload 'gap-mode "gap-mode" "Gap editing mode" t)
(setq auto-mode-alist (append (list '("\\.g$" . gap-mode)
                                    '("\\.gap$" . gap-mode))
                              auto-mode-alist))
(autoload 'gap "gap-process" "Run GAP in emacs buffer" t)

(setq gap-executable "/usr/algebra/bin/gap")
(setq gap-start-options (list "-l" "/usr/algebra/gap3.1/lib"
                              "-m" "2m"))

;; haskell-mode
(evil-define-key 'normal haskell-mode-map (kbd "C-x C-s") 'haskell-mode-save-buffer)
