(in-package :qt)
(named-readtables:in-readtable :qt)

;; generate-image-array used to embed images into lisp code in an unsigned-byte array			 
(defun generate-image-array (filename &optional (stream *standard-output*) name)
  (with-open-file (f filename :direction :input :element-type '(unsigned-byte 8))
    (let ((len (file-length f)))
      (let ((image (make-array len :element-type '(unsigned-byte 8))))
        (read-sequence image f)
        (format stream "(defvar ~A~%" (or name "NAME"))
        (format stream "   #(" )
        (dotimes (i len)
          (when (and (not (zerop i)) (zerop (mod i 16)))
            (format stream "~%     "))
          (format stream "#x~2,'0X " (aref image i)))
        (format stream "))~%~%")
        nil))))

(defun pixmap-svg (svg-image)
  (with-objects ((svg-data (#_new QByteArray svg-image)))
    (with-objects ((svg-buf (#_new QBuffer svg-data)))
      (unwind-protect
           (progn
             (#_open svg-buf (#_QIODevice::ReadOnly))
             (with-objects ((image-reader (#_new QImageReader svg-buf "SVG")))
               (let ((image (#_QPixmap::fromImageReader image-reader)))
                 (#_close svg-buf)
                 image)))))))

;; pixmap return the QPixmap class, is an off-screen image representation that can be used as a paint device
(defun pixmap (image format)
  (if (string-equal format "SVG")
      (pixmap-svg image)
      (let ((len (length image)))
        (let ((dataptr (cffi:foreign-alloc :uint8 :count len)))
          (dotimes (i len)
            (setf (cffi:mem-aref dataptr :uint8 i) (aref image i)))
          (let ((res (#_QPixmap::fromImage (#_QImage::fromData dataptr len format))))
            (cffi:foreign-free dataptr)
            res)))))

#|

(defvar *file-stream* (open "c:/dev/images.lisp" :direction :output
                                    :if-exists :supersede
                                    :if-does-not-exist :create))
									
(format *file-stream* "(in-package :~A)~%(named-readtables:in-readtable :qt)~%~%" "qt")									
								
(qt:generate-image-array  "C:/dev/commonqt-app/examples/mainwindows/mdi/images/copy.png" *file-stream* "*copy-png*") 
(qt:generate-image-array  "C:/dev/commonqt-app/examples/mainwindows/mdi/images/cut.png" *file-stream* "*cut-png*") 
(qt:generate-image-array  "C:/dev/commonqt-app/examples/mainwindows/mdi/images/new.png" *file-stream* "*new-png*") 
(qt:generate-image-array  "C:/dev/commonqt-app/examples/mainwindows/mdi/images/open.png" *file-stream* "*open-png*") 
(qt:generate-image-array  "C:/dev/commonqt-app/examples/mainwindows/mdi/images/paste.png" *file-stream* "*paste-png*") 
(qt:generate-image-array  "C:/dev/commonqt-app/examples/mainwindows/mdi/images/save.png" *file-stream* "*save-png*") 
	
(close *file-stream*)

Usage:
(defvar *save-png*
   #(#x89 #x50 #x4E #x47 #x0D #x0A #x1A #x0A #x00 #x00 #x00 #x0D #x49 #x48 #x44 #x52 
     #x00 #x00 #x00 #x20 #x00 #x00 #x00 #x20 #x08 #x06 #x00 #x00 #x00 #x73 #x7A #x7A
	 .
	 .
	 .
     #x11 #x2F #xC5 #x87 #xF9 #xBF #x3F #xEB #x68 #xF3 #x2F #x7D #x2E #xB5 #x00 #x00 
     #x00 #x00 #x49 #x45 #x4E #x44 #xAE #x42 #x60 #x82 ))

(#_new QIcon (pixmap *save-png* "PNG"))

(defparameter *save-svg*
"<svg version=\"1.1\" id=\"Layer_1\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:xlink=\"http://www.w3.org/1999/xlink\" x=\"0px\" y=\"0px\" viewBox=\"0 0 30 30\" style=\"enable-background:new 0 0 30 30;\" xml:space=\"preserve\">
<g>
	<polygon style=\"fill:#DCD5F2;\" points=\"2.5,27.5 2.5,2.5 21.793,2.5 27.5,8.207 27.5,27.5 	\"></polygon>
	<path style=\"fill:#8B75A1;\" d=\"M21.586,3L27,8.414V27H3V3H21.586 M22,2H2v26h26V8L22,2L22,2z\"></path>
</g>
<g>
	<path style=\"fill:#FFFFFF;\" d=\"M5.5,27.5V17c0-0.827,0.673-1.5,1.5-1.5h16c0.827,0,1.5,0.673,1.5,1.5v10.5H5.5z\"></path>
	<path style=\"fill:#788B9C;\" d=\"M23,16c0.551,0,1,0.449,1,1v10H6V17c0-0.551,0.449-1,1-1H23 M23,15H7c-1.105,0-2,0.895-2,2v11h20V17
		C25,15.895,24.105,15,23,15L23,15z\"></path>
</g>
<g>
	<path style=\"fill:#8B75A1;\" d=\"M19,2H8C7.448,2,7,2.448,7,3v7c0,0.552,0.448,1,1,1h11c0.552,0,1-0.448,1-1V3
		C20,2.448,19.552,2,19,2z\"></path>
</g>
<g>
	<path style=\"fill:#C8D1DB;\" d=\"M10,10.5c-0.276,0-0.5-0.225-0.5-0.5V3c0-0.275,0.224-0.5,0.5-0.5h11c0.276,0,0.5,0.225,0.5,0.5v7
		c0,0.275-0.224,0.5-0.5,0.5H10z\"></path>
	<g>
		<path style=\"fill:#66798F;\" d=\"M21,3v7H10V3H21 M21,2H10C9.448,2,9,2.448,9,3v7c0,0.552,0.448,1,1,1h11c0.552,0,1-0.448,1-1V3
			C22,2.448,21.552,2,21,2L21,2z\"></path>
	</g>
</g>
<rect x=\"8\" y=\"21\" style=\"fill:#C2E8FF;\" width=\"14\" height=\"1\"></rect>
<rect x=\"8\" y=\"18\" style=\"fill:#C2E8FF;\" width=\"14\" height=\"1\"></rect>
<rect x=\"8\" y=\"24\" style=\"fill:#C2E8FF;\" width=\"14\" height=\"1\"></rect>
<rect x=\"17\" y=\"4\" style=\"fill:#66798F;\" width=\"2\" height=\"5\"></rect>
</svg>")

(#_new QIcon (pixmap *save-svg* "SVG"))


|#
