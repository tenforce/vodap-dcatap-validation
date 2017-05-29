(require 'ob)
(require 'ob-eval)
 
(defvar org-babel-default-header-args:seqdiag
  '((:results . "file") (:exports . "results"))
  "Default arguments to use when evaluating a seqdiag source block.")
 
(defun org-babel-expand-body:seqdiag (body params)
  "Expand BODY according to PARAMS, return the expanded body."
  (let ((vars (mapcar #'cdr (org-babel-get-header params :var))))
    (mapc
     (lambda (pair)
       (let ((name (symbol-name (car pair)))
	     (value (cdr pair)))
	 (setq body
	       (replace-regexp-in-string
		(concat "\$" (regexp-quote name))
		(if (stringp value) value (format "%S" value))
		body))))
     vars)
    body))
 
(defun org-babel-execute:seqdiag (body params)
  "Execute a block of Seqdiag code with org-babel.
This function is called by `org-babel-execute-src-block'."
  (let* ((result-params (cdr (assoc :result-params params)))
	 (out-file (cdr (assoc :file params)))
	 (cmdline (or (cdr (assoc :cmdline params))
		      (format "-T%s" (file-name-extension out-file))))
	 (cmd (or (cdr (assoc :cmd params)) "seqdiag"))
	 (in-file (org-babel-temp-file "seqdiag-")))
    (with-temp-file in-file
      (insert (org-babel-expand-body:seqdiag body params)))
    (org-babel-eval
     (concat cmd
	     " " (org-babel-process-file-name in-file)
	     " " cmdline
	     " -o " (org-babel-process-file-name out-file)) "")
    nil)) ;; signal that output has already been written to file
 
(defun org-babel-prep-session:seqdiag (session params)
  "Return an error because Seqdiag does not support sessions."
  (error "Seqdiag does not support sessions"))
 
(provide 'ob-seqdiag)
