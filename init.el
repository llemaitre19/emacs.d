;; init.el --- Loic's Emacs configuration file
;;
;;; Commentary:
;;
;;; Code:
;;
;;--------------------------------------------------------------------------------------------------
;; VARIABLES DECLARATION
;;--------------------------------------------------------------------------------------------------
;; Internal
(defvar font-height-medium-screen)
(defvar font-height-large-screen)
(defvar smerge-command-prefix)
(defvar default-max-line-length 100)
(defvar sql-product)
(defvar sql-database)

;; External
(defvar mac-option-key-is-meta)
(defvar mac-right-option-modifier)
(defvar flycheck-check-syntax-automatically)
(defvar tramp-default-method)
(defvar gud-gdb-command-name)
(defvar buffer-move-behavior)
(defvar dashboard-items)
(defvar work-path)
(defvar eslint-bin "eslint_d") ;; npm install -g eslint_d
(defvar jest-bin)
(defvar django-tests-dir-name "tests")
(defvar project-type)
(defvar db-backup-dir nil)
(defvar db-schema-name)
(defvar use-flycheck-eglot nil)

;;--------------------------------------------------------------------------------------------------
;; PACKAGES NOT REFERENCED IN MELPA
;;--------------------------------------------------------------------------------------------------
(add-to-list 'load-path "~/.emacs.d/lisp/")

;;--------------------------------------------------------------------------------------------------
;; MELPA AS PACKAGE SOURCE
;;--------------------------------------------------------------------------------------------------
(prefer-coding-system 'utf-8)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;;--------------------------------------------------------------------------------------------------
;; WIN conf
;;--------------------------------------------------------------------------------------------------
(when (eq system-type 'windows-nt)
  (setq find-program "C:\\msys64\\usr\\bin\\find.exe")
  ;; Projectile doesn't care about find-program configuration, so this
  ;; is usefull on Windows
  (defvar projectile-generic-command (concat find-program ". -type f -print0"))
  (defvar jest-bin "node_modules/.bin/jest.cmd")
  (defvar work-path "F:/Travail")
  (defvar postgresql-user "postgres")
  (defvar font-height-medium-screen 100)
  (defvar font-height-large-screen 110)
  (set-face-font 'default "-outline-Consolas-normal-r-normal-normal-*-*-96-96-c-*-iso8859-1")
  (set-face-font 'bold "-outline-Consolas-bold-r-normal-normal-*-*-96-96-c-*-iso8859-1")
  (set-face-font 'italic "-outline-Consolas-normal-i-normal-normal-*-*-96-96-c-*-iso8859-1")
  (set-face-font 'bold-italic "-outline-Consolas-bold-i-normal-normal-*-*-96-96-c-*-iso8859-1"))

;;--------------------------------------------------------------------------------------------------
;; MAC conf
;;--------------------------------------------------------------------------------------------------
(when (eq system-type 'darwin)
  ;; (load "osx_gud.el")
  (setq exec-path (append '("/usr/local/bin") exec-path))
  (defvar jest-bin "node_modules/jest/bin/jest.js")
  (defvar work-path "~/Travail")
  (defvar postgresql-user "llemaitre")
  (setq mac-option-key-is-meta t)
  (setq mac-right-option-modifier nil)
  (global-set-key (kbd "<s-left>") 'move-beginning-of-line)
  (global-set-key (kbd "<s-right>") 'move-end-of-line)
  (global-set-key (kbd "<s-up>") 'beginning-of-buffer)
  (global-set-key (kbd "<s-down>") 'end-of-buffer)
  (defvar font-height-medium-screen 110)
  (defvar font-height-large-screen 150)
  (set-face-attribute 'default nil :font "Iosevka"))

;;--------------------------------------------------------------------------------------------------
;; LINUX conf
;;--------------------------------------------------------------------------------------------------
(when (eq system-type 'gnu/linux)
  (setq exec-path (append '("/usr/share/virtualenvwrapper") exec-path))
  (defvar work-path "/home/loic/Travail")
  (defvar jest-bin "node_modules/jest/bin/jest.js")
  (defvar postgresql-user "postgres")
  (defvar font-height-medium-screen 100)
  (defvar font-height-large-screen 130))


;;--------------------------------------------------------------------------------------------------
;; EXEC PATH FROM SHELL
;;--------------------------------------------------------------------------------------------------;;
(use-package exec-path-from-shell
  :ensure t
  :if (or (eq system-type 'darwin) (eq system-type 'gnu/linux))
  :init
  (exec-path-from-shell-initialize))

;;--------------------------------------------------------------------------------------------------
;; FONT
;;--------------------------------------------------------------------------------------------------
;; (set-face-attribute 'default nil :height (if (<= (x-display-pixel-width) 1280)
;;                                              font-height-medium-screen
;;                                            font-height-large-screen))
;; FIXME: find which package override font size just after initialization (putting previous line
;; at the end of this file does not work). This issue occurs since a massive package update.
(add-hook 'emacs-startup-hook (lambda () (set-face-attribute 'default nil :height
                                                             (if (<= (x-display-pixel-width) 1280)
                                                                 font-height-medium-screen
                                                               font-height-large-screen))))

;;--------------------------------------------------------------------------------------------------
;; THEMES
;;--------------------------------------------------------------------------------------------------
;; Theme for GUI
(use-package snazzy-theme
  :ensure t
  ;;:if (display-graphic-p) ;; Snazzy theme colors are awfull on terminal
  :init (load-theme 'snazzy t))

;; Theme for terminal
;; (use-package doom-themes
;;   :ensure t
;;   :if (not (display-graphic-p))
;;   :init (load-theme 'doom-snazzy t))

;;--------------------------------------------------------------------------------------------------
;; FRAME
;;--------------------------------------------------------------------------------------------------
(use-package frame
  :config
  (setq window-divider-default-right-width 1)
  (window-divider-mode))

;;--------------------------------------------------------------------------------------------------
;; WHITESPACE
;;--------------------------------------------------------------------------------------------------
(use-package whitespace
  :bind ("C-c w m" . whitespace-mode)
  :init
  (setq whitespace-style '(face tabs lines-tail trailing))
  (add-hook 'prog-mode-hook
            #'(lambda ()
                (set (make-local-variable 'whitespace-line-column)
                     (pcase (projectile-project-name)
                       ;; ("django-api" 79)
                       (_ default-max-line-length)))
                (whitespace-mode 1)))
  :config
  (setq-default fill-column default-max-line-length))

;;--------------------------------------------------------------------------------------------------
;; WS-BUTLER
;;--------------------------------------------------------------------------------------------------
(use-package ws-butler
  :ensure t
  :config
  (setq ws-butler-keep-whitespace-before-point nil)
  (ws-butler-global-mode t))

;;--------------------------------------------------------------------------------------------------
;; HIGHLIGHT INDENTATION
;;--------------------------------------------------------------------------------------------------
(use-package highlight-indentation
  :ensure t
  :config
  (add-hook 'prog-mode-hook 'highlight-indentation-current-column-mode)
  (set-face-background 'highlight-indentation-face "gray10")
  (set-face-background 'highlight-indentation-current-column-face "gray20"))

;;--------------------------------------------------------------------------------------------------
;; IBUFFER
;;--------------------------------------------------------------------------------------------------
(use-package ibuffer
  :bind (("C-x C-b" . ibuffer)))

(use-package ibuffer-projectile
  :ensure t
  :after projectile
  :functions ibuffer-do-sort-by-alphabetic
  :config
  (add-hook 'ibuffer-hook
            (lambda ()
              (ibuffer-projectile-set-filter-groups)
              (unless (eq ibuffer-sorting-mode 'alphabetic)
                (ibuffer-do-sort-by-alphabetic)))))

;;--------------------------------------------------------------------------------------------------
;; WHICH-KEY
;;--------------------------------------------------------------------------------------------------
(use-package which-key
  :ensure t
  :config
  (which-key-mode))

;;--------------------------------------------------------------------------------------------------
;; SMERGE
;;--------------------------------------------------------------------------------------------------
(use-package smerge-mode
  :commands smerge-mode
  :init
  (setq smerge-command-prefix (kbd "C-c =")))


;;--------------------------------------------------------------------------------------------------
;; EGLOT
;;--------------------------------------------------------------------------------------------------
(use-package eglot
  :ensure t
  :bind (("C-c e r" . eglot-rename))
  :hook ((js-base-mode . eglot-ensure)
         (typescript-ts-base-mode . eglot-ensure)
         (python-ts-mode . eglot-ensure)
         (c-ts-base-mode . eglot-ensure)
         (eglot-managed-mode . start-flycheck-eglot))
  :config
  (add-to-list 'eglot-stay-out-of 'flymake)
  ;; Javascript/Typescript -> ts server: npm install -g typescript-language-server
  ;; C/C++ -> clangd : apt install clangd
  ;; Python -> pyright: pip install pyright
  (add-to-list 'eglot-server-programs
               '((js-base-mode typescript-ts-base-mode)
                 . ("typescript-language-server" "--stdio"
                    :initializationOptions
                    (:preferences
                     (:jsxAttributeCompletionStyle "none")))))
  (setq-default eglot-workspace-configuration
                `((:pyright . (:typeCheckingMode "off"))))
  (setq eglot-events-buffer-size 0) ;; No buffer events
  (defun start-flycheck-eglot ()
    (when use-flycheck-eglot (flycheck-eglot-mode 1))))

;;--------------------------------------------------------------------------------------------------
;; PHP
;;--------------------------------------------------------------------------------------------------
;; (autoload 'geben "geben" "DBGp protocol frontend, a script debugger" t)

;;--------------------------------------------------------------------------------------------------
;; PYTHON
;;--------------------------------------------------------------------------------------------------
(use-package py-autopep8
  :ensure t)

(use-package python
  :bind (:map python-ts-mode-map (("C-c ! f" . py-autopep8-buffer)
                                  ("C-c t a" . django-run-all-tests)
                                  ("C-c t f" . django-run-buffer-tests)
                                  ("C-c t p" . django-run-test-at-point)))
  :mode (("\\.py\\'" . python-ts-mode))
  :config
  ;; Copy of elpy-test--current-test-name function from Elpy project
  ;; https://github.com/jorgenschaefer/elpy
  (defun django-get-test-name-at-point ()
    "Return the name of the test at point."
    (let ((name (python-info-current-defun)))
      (if (and name (string-match "\\`\\([^.]+\\.[^.]+\\)\\." name)) (match-string 1 name) name)))

  (defun django-get-module ()
    (file-name-sans-extension (buffer-name)))

  (defun django-run-tests (&optional module test)
    (let* ((dir-part django-tests-dir-name)
           (module-part (if module (concat "." module) ""))
           (test-part (if test (concat "." test) ""))
           (param (concat dir-part module-part test-part))
           (command (format "./manage.py test %s --keepdb" param)))
      (if (string= (projectile-project-name) "django-api")
          (progn
            (message command)
            (projectile-run-async-shell-command-in-root command "*Django tests*"))
        (message "Please switch to the django-api project first."))))

  (defun django-run-all-tests ()
    "Run all Django api tests."
    (interactive)
    (django-run-tests))

  (defun django-run-buffer-tests ()
    "Run Django api tests for current buffer."
    (interactive)
    (let ((module (django-get-module)))
      (django-run-tests module)))

  (defun django-run-test-at-point ()
    "Run Django api test at point."
    (interactive)
    (let ((module (django-get-module))
          (test (django-get-test-name-at-point)))
      (django-run-tests module test))))

(use-package virtualenvwrapper
  :ensure t
  :config
  (require 'virtualenvwrapper)
  (venv-initialize-interactive-shells))

;;--------------------------------------------------------------------------------------------------
;; REALGUD
;;--------------------------------------------------------------------------------------------------
(use-package realgud
  :ensure t
  :bind (("C-c d t" . realgud-track-mode)
         ("C-c d s" . realgud-short-key-mode)
         ("C-c d d" . realgud-cmdbuf-toggle-in-debugger?))
  :config
  (setq realgud-safe-mode nil))

;;--------------------------------------------------------------------------------------------------
;; PO-MODE
;;--------------------------------------------------------------------------------------------------
;; Install gettext
(use-package po-mode
  ;; :ensure t ;; We do not use po-mode from Melpa because of byte compilation issues
  :mode (("\\.po\\'" . po-mode)))

;;--------------------------------------------------------------------------------------------------
;; XML
;;--------------------------------------------------------------------------------------------------
(use-package nxml-mode
  :bind (:map nxml-mode-map (("C-c ! f" . xml-format)))
  :config
  (defun xml-format ()
    "EXTEND-SELECTION-TO-WHOLE-BUFFER is nil for a region, t for the entire buffer."
    (interactive)
    (shell-command-on-region (point-min) (point-max) "xmllint --format -" (buffer-name) t))
  )

;;--------------------------------------------------------------------------------------------------
;; C/C++
;;--------------------------------------------------------------------------------------------------
(use-package c-ts-mode
  :config
  (setq c-ts-mode-indent-offset 2))

;;--------------------------------------------------------------------------------------------------
;; JS/JSX/TS/TSX
;;--------------------------------------------------------------------------------------------------
(use-package jtsx
  :mode (("\\.jsx?\\'" . jtsx-jsx-mode)
         ("\\.tsx?\\'" . jtsx-tsx-mode))
  :commands jtsx-install-treesit-language
  :hook ((js-base-mode . (lambda ()
                           (setq js-indent-level 2)
                           ;; js-mode binds "M-." which conflicts with xref and eglot, so unbind it.
                           (local-unset-key (kbd "M-."))))
         (typescript-ts-base-mode . (lambda () (setq typescript-ts-mode-indent-offset 2))))
  :functions (eslint-fix-file jtsx-bind-keys-to-mode-map)
  :custom
  (jtsx-switch-indent-offset 2)
  (jtsx-indent-statement-block-regarding-standalone-parent t)
  :config
  (defun jtsx-bind-keys-to-mode-map (mode-map)
    "Bind keys to MODE-MAP."
    (define-key mode-map (kbd "C-c ! f") 'eslint-fix-file-and-revert)
    (define-key mode-map (kbd "C-c ! F") 'eslint-fix-all-files)
    (define-key mode-map (kbd "C-c j r") 'jtsx-rename-jsx-element)
    (define-key mode-map (kbd "C-c C-j") 'jtsx-jump-jsx-element-tag-dwim)
    (define-key mode-map (kbd "C-c j o") 'jtsx-jump-jsx-opening-tag)
    (define-key mode-map (kbd "C-c j c") 'jtsx-jump-jsx-closing-tag)
    (define-key mode-map (kbd "C-c j w") 'jtsx-wrap-in-jsx-element)
    (define-key mode-map (kbd "C-c <down>") 'jtsx-move-jsx-element-tag-forward)
    (define-key mode-map (kbd "C-c <up>") 'jtsx-move-jsx-element-tag-backward)
    (define-key mode-map (kbd "C-c C-<down>") 'jtsx-move-jsx-element-forward)
    (define-key mode-map (kbd "C-c C-<up>") 'jtsx-move-jsx-element-backward)
    (define-key mode-map (kbd "C-c C-S-<down>") 'jtsx-move-jsx-element-step-in-forward)
    (define-key mode-map (kbd "C-c C-S-<up>") 'jtsx-move-jsx-element-step-in-backward))

  (defun jtsx-bind-keys-to-jtsx-jsx-mode-map ()
    (jtsx-bind-keys-to-mode-map js-base-mode-map))

  (defun jtsx-bind-keys-to-jtsx-tsx-mode-map ()
    (jtsx-bind-keys-to-mode-map typescript-ts-base-mode-map))

  (add-hook 'jtsx-jsx-mode-hook 'jtsx-bind-keys-to-jtsx-jsx-mode-map)
  (add-hook 'jtsx-tsx-mode-hook 'jtsx-bind-keys-to-jtsx-tsx-mode-map)

  (defun eslint-fix-file ()
    "Eslint fix current buffer file."
    (interactive)
    (let ((options (list "--fix" buffer-file-name)))
      (let ((inhibit-message t))
        (message (concat eslint-bin " " (string-join options " "))))
      (message "eslint --fixing the file `%s'" buffer-file-name)
      (apply #'call-process eslint-bin nil "*ESLint Errors*" nil options)
      (message "done")))

  (defun eslint-fix-file-and-revert ()
    "Eslint fix current buffer file and revert it."
    (interactive)
    (save-buffer)
    (eslint-fix-file)
    (revert-buffer t t))

  (defun eslint-fix-all-files ()
    "Eslint fix all files."
    (interactive)
    (let ((options (list (concat (projectile-project-root) "src/**/*.js")
                         (concat (projectile-project-root) "src/**/*.jsx") "--fix")))
      (let ((inhibit-message t))
        (message (concat eslint-bin " " (string-join options " "))))
      (message "eslint --fixing all project files")
      (apply #'call-process eslint-bin nil "*ESLint Errors*" nil options)
      (message "done"))))

;;--------------------------------------------------------------------------------------------------
;; CSS
;;--------------------------------------------------------------------------------------------------
(use-package css-mode
  :mode (("\\.css\\'" . css-ts-mode)))

;;--------------------------------------------------------------------------------------------------
;; WEB-MODE
;;--------------------------------------------------------------------------------------------------
(use-package web-mode
  :ensure t
  :after projectile
  :defer t
  :preface
  (declare-function web-mode-set-engine "web-mode")
  :functions projectile-project-p
  :mode (("\\.html\\'" . web-mode)
         ("\\.phtml\\'" . web-mode)
         ("\\.[agj]sp\\'" . web-mode)
         ("\\.as[cp]x\\'" . web-mode)
         ("\\.erb\\'" . web-mode)
         ("\\.mustache\\'" . web-mode)
         ("\\.djhtml\\'" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2)

  (defun set-engine ()
    (if (projectile-project-p)
        (if (string= (projectile-project-name) "django-api")
            (web-mode-set-engine "django"))))
  (add-hook 'web-mode-hook 'set-engine))

(use-package company-web
  :ensure t
  :after web-mode)

;;--------------------------------------------------------------------------------------------------
;; LATEX
;;--------------------------------------------------------------------------------------------------
(use-package tex
  :ensure auctex
  :config
  (setq
   TeX-view-program-list '(("PDF Tools" TeX-pdf-tools-sync-view))
   TeX-view-program-selection '((output-pdf "PDF Tools"))
   TeX-source-correlate-mode t))

(use-package company-auctex
  :ensure t
  :after tex
  :config
  (company-auctex-init))

(use-package pdf-tools
  :ensure t
  :functions TeX-revert-document-buffer
  :init
  (pdf-loader-install)
  :config
  (add-hook 'TeX-after-compilation-finished-functions #'TeX-revert-document-buffer)
  (setq pdf-view-use-scaling t)
  (setq pdf-view-resize-factor 1.05)
  :bind (:map pdf-view-mode-map
              ("<left>" . pdf-view-previous-page-command)
              ("<right>" . pdf-view-next-page-command)))

;;--------------------------------------------------------------------------------------------------
;; JSON
;;--------------------------------------------------------------------------------------------------
(use-package json-mode
  :ensure t
  :bind (:map json-mode-map (("C-c j f" . json-pretty-print))))

(use-package json-navigator
  :ensure t
  :bind (("C-c n j r" . json-navigator-navigate-region)
         ("C-c n j a" . json-navigator-navigate-after-point)))

;;--------------------------------------------------------------------------------------------------
;; TREESIT
;;--------------------------------------------------------------------------------------------------
(use-package treesit
  :config
  ;; Debug
  (setq treesit--indent-verbose nil
        treesit--inspect-name nil
        treesit--font-lock-verbose nil)
  ;; Install (or update) grammars with M-x treesit-install-language-grammar
  (setq treesit-language-source-alist
        '((javascript "https://github.com/tree-sitter/tree-sitter-javascript" "master" "src")
          (python "https://github.com/tree-sitter/tree-sitter-python")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript"
                      "master" "typescript/src")
          (c "https://github.com/tree-sitter/tree-sitter-c.git")
          (cpp "https://github.com/tree-sitter/tree-sitter-cpp.git")
          (css "https://github.com/tree-sitter/tree-sitter-css.git"))))

;;--------------------------------------------------------------------------------------------------
;; RESTCLIENT
;;--------------------------------------------------------------------------------------------------
(use-package restclient
  :ensure t
  :mode (("\\.rstclt\\'" . restclient-mode))
  :functions api-restclient-hook
  :config
  (setq restclient-same-buffer-response-name "*restclient HTTP response*")
  (defvar api-restclient-token nil)
  ;;(add-to-list 'restclient-content-type-modes '("application/json" . json-mode))
  (defun api-restclient-hook ()
    "Update token from a request."
    (save-excursion
      (save-match-data
        ;; update regexp to extract required data
        (when (re-search-forward "\"token\":\"\\(.*?\\)\"" nil t)
          (setq api-restclient-token (match-string 1))))))
  (add-hook 'restclient-response-received-hook #'api-restclient-hook)
  (add-hook 'js-base-mode-hook 'flycheck-disable-on-temp-buffers))

;;--------------------------------------------------------------------------------------------------
;; JEST
;;--------------------------------------------------------------------------------------------------
(use-package jest
  :ensure t
  :functions jest-bind-keys-to-mode-map
  :defines typescript-ts-base-mode-map
  :config
  (setq jest-executable (concat jest-bin " --env=jsdom"))

  (defun jest-bind-keys-to-mode-map (mode-map)
    "Bind jest keys to MODE-MAP."
    (define-key mode-map (kbd "C-c t f") 'jest-file)
    (define-key mode-map (kbd "C-c t c") 'jest-function)
    (define-key mode-map (kbd "C-c t p") 'jest)
    (define-key mode-map (kbd "C-c t r") 'jest-repeat))

  (defun jest-bind-keys-to-js-mode-map ()
      (jest-bind-keys-to-mode-map js-base-mode-map))

  (defun jest-bind-keys-to-ts-mode-map ()
      (jest-bind-keys-to-mode-map typescript-ts-base-mode-map))

  (add-hook 'js-base-mode-hook 'jest-bind-keys-to-js-mode-map)
  (add-hook 'typescript-ts-base-mode-hook 'jest-bind-keys-to-ts-mode-map))

;;--------------------------------------------------------------------------------------------------
;; YAML
;;--------------------------------------------------------------------------------------------------
(use-package yaml-mode
  :ensure t
  :mode ("\\.ya?ml\\'" . yaml-mode))

;;--------------------------------------------------------------------------------------------------
;; OBJECTIVE-C
;;--------------------------------------------------------------------------------------------------
(add-to-list 'auto-mode-alist '("\\.mm\\'" . c++-mode))

;;--------------------------------------------------------------------------------------------------
;; MARKDOWN
;;--------------------------------------------------------------------------------------------------
(use-package markdown-mode
  ;; Flycheck : npm install -g markdownlint-cli
  ;; Preview : apt install markdown
  :ensure t
  :mode (("README\\.md\\'" . gfm-mode)
         ("\\.md\\'" . markdown-mode)
         ("\\.markdown\\'" . markdown-mode)))

;;--------------------------------------------------------------------------------------------------
;; FLYSPELL
;;--------------------------------------------------------------------------------------------------
(use-package flyspell-mode
  :defines ispell-local-dictionary
  :bind (("C-c f m" . flyspell-mode)
         ("C-c f r" . flyspell-region)
         ("C-c f b" . flyspell-buffer)
         ("C-c f n" . flyspell-goto-next-error))
  :init
  ;; (set-face-attribute 'flyspell-incorrect nil :underline '(:color "magenta" :style wave))
  (setq ispell-local-dictionary "francais"))

;;--------------------------------------------------------------------------------------------------
;; FLYCHECK
;;--------------------------------------------------------------------------------------------------
(use-package flycheck
  :ensure t
  :preface
  (declare-function flycheck-add-mode "flycheck")
  (declare-function find-nodejs-project-root "flycheck")
  (declare-function add-gatsby-custom-eslint-rules "flycheck")
  :functions use-eslint-from-node-modules
  :config
  (setq-default flycheck-disabled-checkers '(python-pyright
                                             python-pylint
                                             python-pycompile
                                             python-mypy))
  (flycheck-add-mode 'javascript-eslint 'js-base-mode)
  (flycheck-add-mode 'javascript-eslint 'jtsx-jsx-mode)
  (flycheck-add-mode 'javascript-eslint 'typescript-ts-base-mode)
  (flycheck-add-mode 'javascript-eslint 'jtsx-tsx-mode)
  (setq flycheck-python-flake8-executable "python3")
  ;; (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq-default flycheck-emacs-lisp-load-path 'inherit)
  (setq flycheck-javascript-eslint-executable eslint-bin)
  (setq flycheck-eslint-args "--cache")

  (add-hook 'flycheck-mode-hook #'add-gatsby-custom-eslint-rules)
  (global-flycheck-mode)

  (defun flycheck-disable-on-temp-buffers ()
    (unless (and buffer-file-name (file-exists-p buffer-file-name)) (flycheck-mode -1)))

  (defun find-nodejs-project-root()
    (locate-dominating-file (or (buffer-file-name) default-directory) "node_modules"))

  (defun add-gatsby-custom-eslint-rules()
    (let* ((root (find-nodejs-project-root))
           (rules-dir "node_modules/gatsby/dist/utils/eslint-rules")
           (rules-dir-abs (concat root rules-dir)))
      (if (file-directory-p rules-dir-abs)
          (setq-local flycheck-eslint-rules-directories (list rules-dir))))))

(use-package flycheck-eglot
  :ensure t
  :after (flycheck eglot)
  :config
  (setq flycheck-eglot-exclusive nil))

;;--------------------------------------------------------------------------------------------------
;; MAGIT
;;--------------------------------------------------------------------------------------------------
(use-package magit
  :ensure t
  :bind (("C-c m s s" . magit-status)
         ("C-c m c i" . magit-commit-create)
         ("C-c m c o" . magit-checkout)
         ("C-c m b c" . magit-branch-and-checkout)
         ("C-c m b d" . magit-branch-delete)
         ("C-c m p h" . magit-push)
         ("C-c m p t" . magit-push-tag)
         ("C-c m p l" . magit-pull)
         ("C-c m m" . magit-merge)
         ("C-c m s h" . magit-stash)
         ("C-c m s l" . magit-stash-list)
         ("C-c m s a" . magit-stash-apply)
         ("C-c m s c" . magit-stash-clear)
         ("C-c m s m" . magit-stage-modified)
         ("C-c m s r" . magit-show-refs)
         ("C-c m r b" . magit-rebase-branch)
         ("C-c m d" . magit-diff-working-tree)
         ("C-c m l" . magit-log-head)
         ("C-c m a a" . magit-blame-addition)
         ("C-c m a q" . magit-blame-quit)
         ("C-c m f f" . magit-find-file)
         ("C-c m f w" . magit-find-file-other-window)
         ("C-c m r r" . magit-reset)
         ("C-c m t" . magit-tag)
         ("C-c m f a" . magit-fetch-all))
  :config
  (setq auto-revert-check-vc-info t)

  (defun magit-log-head-short ()
    "Log only few commits to make the command faster."
    (interactive)
    (magit-log-head '("-n40"))))

;;--------------------------------------------------------------------------------------------------
;; DOCKERFILE-MODE
;;--------------------------------------------------------------------------------------------------
(use-package dockerfile-mode
  :ensure t)

;;--------------------------------------------------------------------------------------------------
;; TRAMP
;;--------------------------------------------------------------------------------------------------
(use-package tramp
  :bind (("C-c b s u" . tramp-browse-server-user)
         ("C-c b s s" . tramp-browse-server-sudo))
  :functions tramp-browse-server
  :config
  (when (eq system-type 'windows-nt)
    (setq tramp-default-method "plinkx"))

  (defun tramp-browse-server (server path &optional sudo)
    "Browse the SERVER at PATH with Tramp with optional SUDO"
    (find-file (concat
                (concat
                 (concat
                  (concat "/ssh:" server) (if sudo
                                              (concat "|sudo:" server)
                                            "")) ":") (or path ""))))

  (defun tramp-browse-server-sudo (server path)
    "Browse the SERVER at PATH with Tramp in sudo mode"
    (interactive "sServer connection string: \nsRemote path:")
    (tramp-browse-server server path t))

  (defun tramp-browse-server-user (server path &optional sudo)
    "Browse the SERVER at PATH with Tramp"
    (interactive "sServer connection string: \nsRemote path:")
    (tramp-browse-server server path nil)))

;;--------------------------------------------------------------------------------------------------
;; IVY
;;--------------------------------------------------------------------------------------------------
(use-package ivy
  :ensure t
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b" . ivy-switch-buffer)
         ("C-x C-r" . counsel-recentf)
         ("<C-return>" . ivy-minibuffer-immediate-done)
         ("C-?" . counsel-mark-ring)
         ("C-M-s" . swiper-isearch)
         ("C-M-r" . swiper-isearch-backward)
         ("C-S-s" . swiper-isearch-thing-at-point)
         ("<M-S-return>" . show-current-buffer-other-window))
  :preface
  (declare-function ivy-partial "ivy")
  (declare-function ivy-alt-done "ivy")
  (declare-function ivy-immediate-done "ivy")
  (declare-function ivy--switch-buffer-other-window-action "ivy")
  :config
  (ivy-mode 1)

  (define-key ivy-minibuffer-map (kbd "TAB") #'ivy-partial)
  (define-key ivy-minibuffer-map (kbd "RET") #'ivy-alt-done)

  ;; no regexp by default
  (setq ivy-initial-inputs-alist nil)

  (defun ivy-minibuffer-immediate-done ()
    "Same as ivy-immediate-done but do nothing outside the minibuffer"
    (interactive)
    (when (minibufferp (current-buffer)) (ivy-immediate-done)))

  (defun show-current-buffer-other-window ()
    (interactive)
    (ivy--switch-buffer-other-window-action (buffer-name))))

(use-package counsel-projectile
  :ensure t
  :config (counsel-projectile-mode))

;;--------------------------------------------------------------------------------------------------
;; COMPANY
;;--------------------------------------------------------------------------------------------------
(use-package company
  :ensure t
  :defines company-backends-base
  :bind (("S-<iso-lefttab>" . company-complete))
  :config
  (setq company-idle-delay 0.2)
  (setq company-backends-base '(company-capf
                                company-yasnippet
                                company-dabbrev-code
                                company-dabbrev
                                company-files
                                company-keywords
                                company-oddmuse))
  (setq company-backends company-backends-base)

  (add-hook 'web-mode-hook (lambda ()
                             (make-local-variable 'company-backends)
                             (setq company-backends
                                   (append '(company-web-html)
                                           company-backends-base))))

  (add-hook 'emacs-lisp-mode-hook (lambda ()
                                    (make-local-variable 'company-backends)
                                    (setq company-backends company-backends-base)))

  (add-hook 'org-mode-hook (lambda ()
                             (make-local-variable 'company-backends)
                             (setq company-backends company-backends-base)))

  (add-hook 'c-mode-common-hook (lambda ()
                                  (make-local-variable 'company-backends)
                                  (setq company-backends
                                        (append '(company-gtags)
                                                company-backends-base))))

  (add-hook 'after-init-hook 'global-company-mode))

;;--------------------------------------------------------------------------------------------------
;; DABBREV
;;--------------------------------------------------------------------------------------------------
(use-package dabbrev
  :bind (("C-<tab>" . dabbrev-expand)))

;;--------------------------------------------------------------------------------------------------
;; HIPPIE-EXPAND
;;--------------------------------------------------------------------------------------------------
(use-package hippie-exp
  :bind (("C-S-<tab>" . hippie-expand)
         ;; Equivalent to previous line depending on the system...
         ("C-S-<iso-lefttab>" . hippie-expand)))

;;--------------------------------------------------------------------------------------------------
;; YASNIPPET
;;--------------------------------------------------------------------------------------------------
(use-package yasnippet
  :ensure t
  :config
  (setq yas-expand-only-for-last-commands '(self-insert-command))
  (yas-global-mode 1))

(use-package yasnippet-snippets
  :ensure t)

(use-package ivy-yasnippet
  :ensure t
  :bind ("C-c y" . ivy-yasnippet))

;;--------------------------------------------------------------------------------------------------
;; INFLEXION
;;--------------------------------------------------------------------------------------------------
(use-package string-inflection
  :ensure t
  :bind (("C-c s a" . string-inflection-all-cycle)
         ("C-c s C" . string-inflection-camelcase)
         ("C-c s c" . string-inflection-lower-camelcase)
         ("C-c s l" . string-inflection-lisp)
         ("C-c s u" . string-inflection-underscore)
         ("C-c s U" . string-inflection-upcase)))

;;--------------------------------------------------------------------------------------------------
;; INDIUM
;;--------------------------------------------------------------------------------------------------
(use-package indium
  :ensure t
  :bind (("C-c d l" . indium-launch)
         ("C-c d q" . indium-quit)
         ("C-c d k" . indium-quit)
         ("C-c d b" . indium-toggle-breakpoint)
         ("C-c d r" . indium-debugger-resume)
         ("C-c d i" . indium-debugger-step-into)
         ("C-c d o" . indium-debugger-step-out)
         ("C-c d SPC" . indium-debugger-step-over)
         ("C-c d m" . indium-interaction-mode))
  ;; :init
  ;; (setq indium-client-executable "/home/loic/Travail/Temp/Indium/server/bin/debug_indium.bash")
  )

;;--------------------------------------------------------------------------------------------------
;; WINDMOVE & FRAMEMOVE
;;--------------------------------------------------------------------------------------------------
(require 'framemove)
(windmove-default-keybindings 'meta)
(setq framemove-hook-into-windmove t)

;;--------------------------------------------------------------------------------------------------
;; BUFFERMOVE
;;--------------------------------------------------------------------------------------------------
(use-package buffer-move
  :ensure t
  :bind (("M-S-<up>" . buf-move-up)
         ("M-S-<down>" . buf-move-down)
         ("M-S-<left>" . buf-move-left)
         ("M-S-<right>" . buf-move-right))
  :config
  (setq buffer-move-behavior 'move))


;;--------------------------------------------------------------------------------------------------
;; TREEMACS
;;--------------------------------------------------------------------------------------------------
(use-package treemacs
  :ensure t
  :defer t
  :preface
  (declare-function treemacs-follow-mode "treemacs")
  (declare-function treemacs-filewatch-mode "treemacs")
  (declare-function treemacs-git-mode "treemacs")
  :functions (treemacs-follow-mode treemacs-filewatch-mode treemacs-git-mode)
  :config
  (progn
    (setq treemacs-collapse-dirs              0
          treemacs-file-event-delay           5000
          treemacs-follow-after-init          nil
          treemacs-recenter-distance          0.1
          treemacs-goto-tag-strategy          'refetch-index
          treemacs-indentation                2
          treemacs-indentation-string         " "
          treemacs-is-never-other-window      nil
          treemacs-no-png-images              t
          treemacs-project-follow-cleanup     nil
          treemacs-recenter-after-file-follow nil
          treemacs-recenter-after-tag-follow  nil
          treemacs-show-hidden-files          t
          treemacs-silent-filewatch           nil
          treemacs-silent-refresh             nil
          treemacs-sorting                    'alphabetic-desc
          treemacs-tag-follow-cleanup         t
          treemacs-tag-follow-delay           1.5
          treemacs-width                      35)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null (executable-find "python3"))))
      (`(t . t)
       (treemacs-git-mode 'extended))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

;;--------------------------------------------------------------------------------------------------
;; DASHBOARD
;;--------------------------------------------------------------------------------------------------
(use-package dashboard
  :ensure t
  :defines show-week-agenda-p
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-items '((recents  . 20)
                          (projects . 5)
                          (agenda . 15)))
  (setq show-week-agenda-p t)
  (set-face-attribute 'dashboard-items-face nil :underline nil))

;;--------------------------------------------------------------------------------------------------
;; RG
;;--------------------------------------------------------------------------------------------------
(use-package rg
  ;; Install ripgrep: apt install ripgrep
  :ensure t
  :functions (rg-read-pattern dired-current-directory rg-run)
  :bind (("C-c r g" . rg-search)
         ("C-c r G" . rg-search-regexp)
         ("C-c r p" . rg-project-search)
         ("C-c r P" . rg-project-search-regexp)
         ("C-c r l" . rg-libs-search)
         ("C-c r L" . rg-libs-search-regexp))
  :custom
  (rg-command-line-flags '("-z" "--type-not minified"))
  (rg-default-alias-fallback "everything")
  :config
  (rg-define-search rg-search-regexp
    "Search everything."
    :files "everything")

  (rg-define-search rg-search
    "Search everything."
    :format literal
    :files "everything")

  (rg-define-search rg-project-search-regexp
    "Search everything in a project."
    :dir project
    :files "everything")

  (rg-define-search rg-project-search
    "Search everything in a project."
    :dir project
    :format literal
    :files "everything")

  (defun rg-libs-search-regexp (query &optional literal)
    "Find QUERY in project libraries."
    (interactive (list (rg-read-pattern)))
    (let ((dir (pcase project-type
                 ("node" (concat (projectile-project-root) "/node_modules"))
                 ("python" (concat python-shell-virtualenv-root "/lib"))
                 (_ (dired-current-directory)))))
      (funcall (if literal #'rg-search #'rg-search-regexp) query dir)))

  (defun rg-libs-search (query)
    "Find QUERY in project libraries."
    (interactive (list (rg-read-pattern t)))
    (rg-libs-search-regexp query t)))

;;--------------------------------------------------------------------------------------------------
;; PROJECTILE
;;--------------------------------------------------------------------------------------------------
(use-package projectile
  :ensure t
  :bind (("C-c p" . projectile-command-map)
         ("C-c p x p" . run-project)
         ("C-c p x d" . projectile-install-project)
         ("C-c p x i" . start-django-shell)
         ("C-c p x c" . save-pg-database-to-file-dwim)
         ("C-c p x r" . restore-pg-database-from-file)
         ("C-c p L" . find-file-in-libs)
         ("C-c p G" . find-file-at-point))
  :defines postgresql-user
  :functions (projectile-project-name
              projectile-ensure-project
              magit-get-current-branch
              save-pg-database-to-file
              projectile--find-other-file
              find-other-file-goto-same-line
              async-shell-command-no-window
              python-info-current-defun
              django-run-tests
              django-get-module
              django-get-test-name-at-point
              python-shell-calculate-command
              django-project-p)
  :config
  (require 'magit) ;; Needed for save-django-pg-database-to-file function.
  (projectile-mode)
  (setq projectile-indexing-method 'alien)
  (setq projectile-enable-caching t)
  (setq projectile-completion-system 'ivy)
  (setq projectile-run-use-comint-mode t)
  (setq projectile-install-use-comint-mode t)
  (setq projectile-mode-line-function '(lambda () (format " Prj[%s]" (projectile-project-name))))
  (add-to-list 'projectile-other-file-alist '("json" "json"))
  (add-to-list 'projectile-other-file-alist '("tsx" "css.ts"))

  (setq projectile-globally-ignored-directories
        (append '("*.svn"
                  "*.git"
                  "ext")
                projectile-globally-ignored-directories))

  ;; Only works if index method is 'alien
  (setq projectile-globally-ignored-file-suffixes
        (append '(".o"
                  ".gz"
                  ".z"
                  ".jar"
                  ".tar.gz"
                  ".tgz"
                  ".zip"
                  ".png"
                  ".gif"
                  ".odt"
                  ".pdf"
                  ".DS_Store"
                  "~")
                projectile-globally-ignored-file-suffixes))

  (defun run-project()
    "Run a project"
    (interactive)
    (let ((cmd projectile-project-run-cmd)
          (cmd-buffer-name (concat "*" (projectile-project-name) " running*")))
      (if projectile-project-run-cmd
          (progn
            (let* ((cmd-buffer (get-buffer cmd-buffer-name))
                   (cmd-buffer-already-displayed (equal cmd-buffer (current-buffer)))
                   (kill-buffer-query-functions nil))
              (if (and cmd-buffer (not cmd-buffer-already-displayed))
                  (pop-to-buffer cmd-buffer nil t)
                (when cmd-buffer (kill-buffer cmd-buffer))
                (projectile-with-default-dir (projectile-ensure-project (projectile-project-root))
                  (async-shell-command cmd cmd-buffer-name)))))
        (message "No running command set for %s project" (projectile-project-name)))))

  (defun find-other-file-goto-same-line (&optional flex-matching)
  "Switch to other file at same line than the current buffer for *.json file."
  (interactive "P")
  (let ((line (line-number-at-pos)))
    (projectile--find-other-file flex-matching)
    (when (<= line (+ (count-lines (point-min) (point-max)) 1))
      (forward-line (- line (line-number-at-pos))))))

  (advice-add 'projectile-find-other-file :override #'find-other-file-goto-same-line)

  (defun find-file-in-libs (string)
    "Find file in project libraries. Default to filename at point."
    (interactive (list (read-filename-from-minibuffer "Find file in libs" t)))
    (let ((dir (pcase project-type
                 ("node" (concat (projectile-project-root) "/node_modules"))
                 ("python" python-shell-virtualenv-root)
                 (_ (pwd)))))
      (find-name-dired dir string)))

  (defun django-project-p ()
    "Check if inside a Django project."
    (file-exists-p (concat (projectile-project-root) "/manage.py")))

  (defun start-django-shell ()
    "Start a django shell as Inferior Python"
    (interactive)
    (let* ((django-shell-name "Django shell")
          (django-shell-buffer (get-buffer django-shell-name)))
      (if django-shell-buffer
          (pop-to-buffer django-shell-buffer nil t)
        (if (django-project-p)
            (let ((python-shell-interpreter (concat (projectile-project-root) "manage.py"))
                  (python-shell-interpreter-args "shell_plus --ipython -- -i --simple-prompt"))
              (run-python (python-shell-calculate-command) nil t))
          (message "Please switch to a django project first.")))))

    ;; From https://stackoverflow.com/questions/13901955/how-to-avoid-pop-up-of-async-shell-command-buffer-in-emacs
    (defun async-shell-command-no-window (command)
      "Run a async COMMAND without displaying a shell window."
      (let ((display-buffer-alist
             (list
              (cons
               "\\*Async Shell Command\\*.*"
               (cons #'display-buffer-no-window nil)))))
        (async-shell-command command)))

    (defun save-pg-database-to-file (bk-file)
      "Save a postgresql database in BK-FILE."
      (interactive (list (read-file-name "Backup file path: ")))
      (let ((db-name (read-string "Database name: " sql-database)))
        (when (or (not (file-exists-p bk-file))
                (yes-or-no-p (format "Please confirm that you want to overwrite %s file ?" bk-file)))
          (async-shell-command-no-window
           (format "pg_dump -U %s -Fc -b -f %s %s" postgresql-user bk-file db-name)))))

    (defun save-pg-database-to-file-dwim ()
      "Save postgresql database in auto named backup file."
      (interactive)
      (let ((bk-file (when db-backup-dir
                       (format "%s%s%s_%s.backup"
                               (projectile-project-root)
                               db-backup-dir
                               (replace-regexp-in-string "/" "_" (magit-get-current-branch))
                               (format-time-string "%Y-%m-%d")))))
            (save-pg-database-to-file bk-file)))

    (defun restore-pg-database-from-file (bk-file &optional db-name)
      "Restore the DB-NAME postgresql database from BK-FILE."
      (interactive (list (read-file-name "Backup file path: ")
			 (read-string "Database name: " sql-database)))
      (let* ((user postgresql-user)
             (drop-schema-cmd (format
                               "psql -U %s %s -c \"DROP SCHEMA IF EXISTS public CASCADE;\""
                               user db-name))
             (create-schema-cmd (format
                                 "psql -U %s %s -c \"CREATE SCHEMA public AUTHORIZATION %s;\""
                                 user db-name db-schema-name))
             (pg-restore-cmd (format
                              "pg_restore -U %s -d %s -n public --if-exists -c -e -j 5 \"%s\""
                              user db-name bk-file))
             (cmd (concat drop-schema-cmd " && " create-schema-cmd " && " pg-restore-cmd)))
        (async-shell-command-no-window cmd))))

;;--------------------------------------------------------------------------------------------------
;; SQL
;;--------------------------------------------------------------------------------------------------
(use-package sql
  :bind (("C-c q l" . sql-postgres)
         ("C-c q m" . sql-mode)))

(use-package sqlformat
  :ensure t
  :bind (("C-c q f r" . sqlformat-region)
         ("C-c q f b" . sqlformat-buffer))
  :functions comint-send-string
  :config
  (setq sqlformat-command 'sqlformat))

(add-hook 'sql-interactive-mode-hook #'(lambda () (toggle-truncate-lines 1)))

;; From https://www.emacswiki.org/emacs/SqlMode
(add-hook 'sql-login-hook 'my-sql-login-hook)
(defun my-sql-login-hook ()
  "Custom SQL log-in behaviours.  See sql-login-hook."
  ;; n.b. If you are looking for a response and need to parse the
  ;; response, use `sql-redirect-value' instead of `comint-send-string'.
  (when (eq sql-product 'postgres)
    (let ((proc (get-buffer-process (current-buffer))))
      ;; Output each query before executing it. (n.b. this also avoids
      ;; the psql prompt breaking the alignment of query results.)
      (comint-send-string proc "\\set ECHO queries\n"))))

;;--------------------------------------------------------------------------------------------------
;; UNFILL
;;--------------------------------------------------------------------------------------------------
(use-package unfill
  :ensure t
  :bind (("C-c u r" . unfill-region)))

;;--------------------------------------------------------------------------------------------------
;; HIDESHOW
;;--------------------------------------------------------------------------------------------------
(use-package hideshow
  :hook ((prog-mode . hs-minor-mode))
  :bind (("C-c h -" . hs-hide-all)
         ("C-c h +" . hs-show-all)
         ("C-c C-+" . hs-show-block)
         ("C-c C--" . hs-hide-block)
         ("C-c C-/". hs-toggle-hiding)))

;;--------------------------------------------------------------------------------------------------
;; GOOGLE TRANSLATE
;;--------------------------------------------------------------------------------------------------
(use-package google-translate
  :ensure t
  :defer t
  :bind (("C-c g t" . google-translate-query-translate)
         ("C-c g T" . google-translate-query-translate-reverse)
         ("C-c g p" . google-translate-at-point)
         ("C-c g P" .  google-translate-at-point-reverse))
  :init
  (setq google-translate-default-source-language "fr")
  (setq google-translate-default-target-language "en")
  ;; Emacs default backend is broken for now so use the curl one
  (setq google-translate-backend-method 'curl))

;;--------------------------------------------------------------------------------------------------
;; ORG
;;--------------------------------------------------------------------------------------------------
(use-package org
  :bind (("C-c o w" . open-current-work-notes)
         ("C-c o W" . open-previous-work-notes)
         ("C-c o r" . open-current-time-report)
         ("C-c o R" . open-previous-time-report)
         ("C-c o t l" . org-todo-list)
         ("C-c o c l" . org-agenda-show-custom)
         ("C-c <left>" . org-metaleft)
         ("C-c <right>" . org-metaright)
         ("C-c o e s" . org-slack-export-to-clipboard-as-slack)
         ("C-c o n d" . org-notes-new-day))
  :preface
  (declare-function org-insert-time-stamp "org")
  :defines (org-agenda-custom-commands
            org-work-path
            org-work-notes-path
            org-work-agenda-path
            org-work-services-path
            org-work-time-report-dir-name)
  :functions (open-work-notes
              open-annual-work-file
              open-current-work-file
              open-previous-work-file
              get-clients-prompt-with-completion
              get-client-time-report-path)
  :custom
  (org-support-shift-select t)
  :config
  ;; (setq org-startup-indented t)
  (setq org-log-done 'time)
  (setq org-startup-folded nil)
  (setq org-work-path (concat work-path "/Docs/org-work-notes")
        org-work-notes-path (concat org-work-path "/notes")
        org-work-agenda-path (concat org-work-path "/agenda")
        org-work-services-path (concat org-work-path "/services")
        org-work-time-report-dir-name "time_report")
  (setq org-agenda-files (list org-work-agenda-path))
  (setq org-todo-keywords
        '((sequence "TODO" "SUSPENDED" "|" "DONE" "CANCELLED")))
  (setq org-agenda-custom-commands
        '(("c" "Custom agenda view"
           ((agenda "")
            (alltodo "")))))
  (defun org-agenda-show-custom (&optional arg)
    (interactive "P")
    (org-agenda arg "c"))

  ;; Unbind conflicting keys
  (define-key org-mode-map (kbd "<M-left>") nil)
  (define-key org-mode-map (kbd "<M-right>") nil)
  (define-key org-mode-map (kbd "<M-S-left>") nil)
  (define-key org-mode-map (kbd "<M-S-right>") nil)
  (define-key org-mode-map (kbd "<S-left>") nil)
  (define-key org-mode-map (kbd "<S-right>") nil)
  (define-key org-mode-map (kbd "<S-up>") nil)
  (define-key org-mode-map (kbd "<S-down>") nil)

  (defun open-annual-work-file (path year)
    "Open annual work file of YEAR at PATH."
    (find-file (format "%s/%s.org" path year)))

  (defun open-current-work-file (path)
    "Open current work file at PATH."
    (open-annual-work-file path (format-time-string "%Y")))

  (defun open-previous-work-file (path)
    "Open previous work file at PATH."
    (open-annual-work-file path
                           (number-to-string (- (string-to-number(format-time-string "%Y")) 1))))

  (defun open-current-work-notes ()
    "Open current work notes file."
    (interactive)
    (open-current-work-file org-work-notes-path))

  (defun open-previous-work-notes ()
    "Open previous work notes file."
    (interactive)
    (open-previous-work-file org-work-notes-path))

  (defun get-clients-prompt-with-completion ()
    "Get clients prompt with completion."
    (completing-read "Client: " (cl-remove-if (lambda (x) (member x '("." "..")))
                                              (directory-files org-work-services-path nil ""))))

  (defun get-client-time-report-path (client)
    "Returns the CLIENT time report path."
    (concat org-work-services-path "/" client "/" org-work-time-report-dir-name))

  (defun open-current-time-report (client)
    "Open current services time report file for CLIENT."
    (interactive (list (get-clients-prompt-with-completion)))
    (open-current-work-file (get-client-time-report-path client)))

  (defun open-previous-time-report (client)
    "Open previous services time report file for CLIENT."
    (interactive (list (get-clients-prompt-with-completion)))
    (open-previous-work-file (get-client-time-report-path client)))

  (defun org-notes-new-day ()
    "Add new day entry to org notes"
    (interactive)
    (insert "* ")
    (org-insert-time-stamp (current-time))
    (insert " *")
    (newline)))

(use-package ox-gfm
  :ensure t)

;;--------------------------------------------------------------------------------------------------
;; TELEPHONE MODE LINE
;;--------------------------------------------------------------------------------------------------
(use-package telephone-line
  :ensure t
  :config
  (defface telephone-line-extreme-active
    '((t (:foreground "white" :background "#ff5c57" :inherit mode-line)))
    "Accent face for mode-line."
    :group 'telephone-line)

  (defface telephone-line-extreme-inactive
    '((t (:foreground "white" :background "#ff5c57" :inherit mode-line-inactive)))
    "Accent face for inactive mode-line."
    :group 'telephone-line)

  (telephone-line-defsegment venv-segment ()
    (when (and (boundp 'project-type)
               (equal project-type "python")
               (boundp 'venv-current-name)
               venv-current-name)
      (propertize venv-current-name 'help-echo "Python virtual environement")))

  (telephone-line-defsegment line-segment ()
    (concat "%4l/" (format "%d" (+ (count-lines (point-min) (point-max)) 1))))

  (telephone-line-defsegment vc-segment ()
    (when-let ((vc-seg-content (telephone-line-raw vc-mode t)))
      (truncate-string-to-width vc-seg-content 20 0 nil t)))

  (setq telephone-line-faces
         '((extreme . (telephone-line-extreme-active . telephone-line-extreme-inactive))
           (accent . (telephone-line-accent-active . telephone-line-accent-inactive))
           (nil . (mode-line . mode-line-inactive))))

  (setq telephone-line-lhs
        '((extreme . (telephone-line-projectile-segment))
          (accent . (vc-segment))
          (nil . (venv-segment telephone-line-buffer-segment))))

  (setq telephone-line-rhs
        '((nil . (telephone-line-flycheck-segment
                  telephone-line-misc-info-segment
                  telephone-line-process-segment))
          (accent . (line-segment))
          (extreme . (telephone-line-major-mode-segment))))

  (telephone-line-mode 1))

;;--------------------------------------------------------------------------------------------------
;; CRUX
;;--------------------------------------------------------------------------------------------------
(use-package crux
  :ensure t
  :bind (("C-c c r" . crux-rename-file-and-buffer)
         ("C-c c d" . crux-delete-file-and-buffer)
         ("C-c c i" . crux-find-user-init-file)))

;;--------------------------------------------------------------------------------------------------
;; SIMPLE
;;--------------------------------------------------------------------------------------------------
(use-package simple
  :bind (("M-<backspace>" . delete-indentation)
         ("M-<delete>" . delete-horizontal-space)
         ("M-S-<delete>" . just-one-space)))

;;--------------------------------------------------------------------------------------------------
;; IMENU
;;--------------------------------------------------------------------------------------------------
(use-package imenu
  :bind (("C-c C-i" . imenu)))

;;--------------------------------------------------------------------------------------------------
;; SHELL
;;--------------------------------------------------------------------------------------------------
(use-package comint
  :bind (("C-c *" . comint-send-invisible))
  :config
  ;; Prevent large shell output to be slow
  (setq comint-move-point-for-output nil)
  (setq comint-scroll-show-maximum-output nil))

(use-package shell
  :config
  (setq shell-font-lock-keywords nil)
  ;; Force shell-command to load .profile
  (setq shell-command-switch "-lc"))

(use-package term
  :functions (term-bash enable-term-line-mode)
  :preface
  (declare-function term-line-mode "term")
  :config
  (defun term-bash (&rest ignore)
    (interactive)
    (list "/bin/bash"))
  (advice-add 'term :filter-args #'term-bash)
  (defun enable-term-line-mode (&rest ignored)
    (term-line-mode))
  (advice-add 'term :after #'enable-term-line-mode))

;;--------------------------------------------------------------------------------------------------
;; ERT
;;--------------------------------------------------------------------------------------------------
(use-package ert
  :bind (:map emacs-lisp-mode-map (("C-c t e" . ert-eval-and-test-buffer)
                                   ("C-c t t" . ert-run-tests-interactively)))
  :config
  (defun ert-eval-and-test-buffer ()
    (interactive)
    (eval-buffer)
    (call-interactively #'ert-run-tests-interactively)))

;;--------------------------------------------------------------------------------------------------
;; GLOBAL SHORTCUTS
;;--------------------------------------------------------------------------------------------------
(when (eq system-type 'darwin)
  (global-set-key (kbd "<mouse-4>") 'mouse-yank-primary))
(global-set-key (kbd "C-h C-f") 'find-function)
(global-set-key (kbd "C-c b r") 'revert-buffer)
(global-set-key (kbd "C-c b b") 'browse-url-of-buffer)
(global-set-key (kbd "C-c b u") 'browse-url)
(global-set-key (kbd "C-x SPC") 'rectangle-mark-mode)
(global-set-key (kbd "C-c b d") 'diff-buffer-with-file)
(global-set-key (kbd "<f5>") 'kmacro-start-macro)
(global-set-key (kbd "<f6>") 'kmacro-end-and-call-macro)
(global-set-key (kbd "C-n") 'move-line-forward)
(global-set-key (kbd "C-p") 'move-line-backward)

;;--------------------------------------------------------------------------------------------------
;; MISC
;;--------------------------------------------------------------------------------------------------
(setq visible-bell t) ;; Disable sounds
(global-so-long-mode 1) ;; Avoid performance issues in files with very long lines.
(tool-bar-mode -1)
(toggle-frame-maximized) ;; Maximize window
(global-auto-revert-mode t) ;; Auto reload file if changed on disk
(fset 'yes-or-no-p 'y-or-n-p) ;; Enable Y/N answers
(put 'upcase-region 'disabled nil)
(setq-default indent-tabs-mode nil)
(delete-selection-mode 1) ;; Ensure to delete a selected region when hitting a key
(electric-pair-mode 1) ;; Auto add closing parenthese, bracket, ...
(define-key isearch-mode-map (kbd "<backspace>") 'isearch-del-char) ;; More natural behaviour for
;; backspace in isearch
(setq-default cursor-type 'bar) ;; Default cursor as bar
(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
            '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))
(setq set-mark-command-repeat-pop t) ;; C-SPC reverts C-u C-SPC before add marks

(defun get_nb_months_since(month year)
  "Return the number of months since the date MONTH/YEAR."
  (let ((current_year (nth 5 (decode-time (current-time))))
        (current_month (nth 4 (decode-time (current-time)))))
    (+ (* 12 (- current_year year)) (- current_month month))))

;; Inspired by ag/read-from-minibuffer
(defun read-filename-from-minibuffer (prompt &optional remove-directory)
  "Read a value from the minibuffer with PROMPT.
Remove the directory part from the filename if REMOVE-DIRECTORY is non nil.
If there's a string at point, offer that as a default."
  (let* ((suggested (thing-at-point 'filename t))
         (final-suggested (if remove-directory (file-name-nondirectory suggested) suggested))
         (final-prompt
          (if final-suggested
              (format "%s (default %s): " prompt final-suggested)
            (format "%s: " prompt)))
         ;; Ask the user for input, but add `final-suggested' to the history
         ;; so they can use M-n if they want to modify it.
         (user-input (read-from-minibuffer final-prompt nil nil nil nil final-suggested)))
    ;; Return the input provided by the user, or use `final-suggested' if
    ;; the input was empty.
    (if (> (length user-input) 0) user-input final-suggested)))

(defun move-line-forward ()
  "Move the current line forward."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1)
  (indent--funcall-widened indent-line-function))

(defun move-line-backward ()
  "Move the current line backward."
  (interactive)
  (transpose-lines 1)
  (forward-line -2)
  (indent--funcall-widened indent-line-function))

;;--------------------------------------------------------------------------------------------------
;; CUSTOMIZE
;;--------------------------------------------------------------------------------------------------
(setq custom-file (concat user-emacs-directory "/custom.el"))
(load-file custom-file)

;;; init.el ends here
